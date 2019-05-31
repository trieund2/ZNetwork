//
//  ZADownloadManager.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZADownloadManager.h"
#import "ZADownloadOperationModel.h"
#import "ZAQueueModel.h"
#import "NSString+Extension.h"
#import "ZANetworkManager.h"

@interface ZADownloadManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) dispatch_queue_t root_queue;
@property (nonatomic, readonly) dispatch_queue_t delegate_queue;
@property (nonatomic, readonly) ZAQueueModel *queueModel;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZADownloadOperationModel *> *urlToDownloadOperation;
@property (nonatomic, readonly) dispatch_semaphore_t urlToDownloadOperationLock;
@property (nonatomic, readonly) NSMutableDictionary <NSURL *, NSOutputStream *> *urlToOutputStream;
@property (nonatomic, readonly) dispatch_semaphore_t urlToOutputStreamLock;

@end

@implementation ZADownloadManager

#pragma mark - LifeCycle

+ (instancetype)sharedManager {
    static ZADownloadManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[ZADownloadManager alloc] init];
    });
    return sessionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.za.znetwork.background.download.session"];
        configuration.sessionSendsLaunchEvents = YES;
        configuration.discretionary = YES;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _root_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.rootqueue", DISPATCH_QUEUE_SERIAL);
        _delegate_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.delegatequeue", DISPATCH_QUEUE_CONCURRENT);
        _queueModel = [[ZAQueueModel alloc] init];
        _urlToDownloadOperation = [[NSMutableDictionary alloc] init];
        _urlToDownloadOperationLock = dispatch_semaphore_create(1);
        _urlToOutputStream = [[NSMutableDictionary alloc] init];
        _urlToOutputStreamLock = dispatch_semaphore_create(1);
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_triggerStartRequest)
                                                   name:NetworkStatusDidChangeNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark - Interface methods

- (nullable ZADownloadOperationCallback *)downloadTaskFromURLString:(NSString *)urlString
                                                      requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                                                           priority:(ZAOperationPriority)priority
                                                      progressBlock:(ZAProgressBlock)progressBlock
                                                   destinationBlock:(ZADestinationBlock)destinationBlock
                                                    completionBlock:(ZACompletionBlock)completionBlock {
    NSURL *url = [urlString toURL];
    if (nil == url) { return NULL; }
    
    ZADownloadOperationCallback *downloadCallback = [[ZADownloadOperationCallback alloc] initWithURL:url
                                                                                       progressBlock:progressBlock
                                                                                    destinationBlock:destinationBlock
                                                                                     completionBlock:completionBlock
                                                                                            priority:priority
                                                                                        requestPlicy:requestPolicy];
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        [weakSelf _startRequestByDownloadOperationCallback:downloadCallback];
    });
    
    return downloadCallback;
}

- (void)pauseDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url ) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        ZA_LOCK(weakSelf.urlToDownloadOperationLock);
        ZADownloadOperationModel *operationModel = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        
        if (operationModel) {
            [operationModel pauseOperationCallbackById:downloadCallback.identifier];
            if ([operationModel numberOfRunningOperation] == 0) {
                [weakSelf.urlToDownloadOperation removeObjectForKey:downloadCallback.url];
                [weakSelf.urlToOutputStream removeObjectForKey:downloadCallback.url];
            }
        } else {
            [weakSelf.queueModel pauseOperationByCallback:downloadCallback];
        }
        ZA_UNLOCK(weakSelf.urlToDownloadOperationLock);
    });
}

- (void)resumeDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        [weakSelf _startRequestByDownloadOperationCallback:downloadCallback];
    });
}

- (void)cancelDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url ) { return; }
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        ZA_LOCK(weakSelf.urlToDownloadOperationLock);
        ZADownloadOperationModel *operationModel = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        
        if (operationModel) {
            [operationModel cancelOperationCallbackById:downloadCallback.identifier];
            if ([operationModel numberOfRunningOperation] == 0) {
                [weakSelf.urlToDownloadOperation removeObjectForKey:downloadCallback.url];
                [weakSelf.urlToOutputStream removeObjectForKey:downloadCallback.url];
            }
        } else {
            [weakSelf.queueModel cancelOperationByCallback:downloadCallback];
        }
        ZA_UNLOCK(weakSelf.urlToDownloadOperationLock);
    });
}

- (void)cancelAllRequests {
    
}

#pragma mark - Helper methods

- (void)_startRequestByDownloadOperationCallback:(ZADownloadOperationCallback *)downloadCallback {
    ZA_LOCK(self.urlToDownloadOperationLock);
    ZADownloadOperationModel *downloadOperationModel = [self.urlToDownloadOperation objectForKey:downloadCallback.url];
    if (downloadOperationModel && self.queueModel.isMultiCallback && downloadOperationModel.task.state == NSURLSessionTaskStateRunning) {
        [downloadOperationModel addOperationCallback:downloadCallback];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
    } else {
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        downloadOperationModel = [[ZADownloadOperationModel alloc] initByURL:downloadCallback.url
                                                               requestPolicy:downloadCallback.requestPolicy
                                                                    priority:downloadCallback.priority
                                                           operationCallback:downloadCallback];
        [self.queueModel enqueueOperation:downloadOperationModel];
        if ([self.queueModel canDequeueOperationModel]) {
            [self _triggerStartRequest];
        }
    }
}

- (void)_triggerStartRequest {
    if (ZANetworkManager.sharedInstance.isConnectionAvailable == NO) { return; }
    
    ZADownloadOperationModel *downloadOperationModel = (ZADownloadOperationModel *)[self.queueModel dequeueOperationModel];
    if (nil == downloadOperationModel) { return; }
    
    NSString *filePath = [self _getFilePathFromURL:downloadOperationModel.url];
    if (filePath) {
        NSURLRequest *request = [self _buildRequestFromURL:downloadOperationModel.url headers:NULL];
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
        downloadOperationModel.task = dataTask;
        [dataTask resume];
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        self.urlToDownloadOperation[downloadOperationModel.url] = downloadOperationModel;
        ZA_UNLOCK(self.urlToDownloadOperationLock);

        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:[self _getFilePathFromURL:downloadOperationModel.url] append:YES];
        [stream open];

        ZA_LOCK(self.urlToOutputStreamLock);
        self.urlToOutputStream[downloadOperationModel.url] = stream;
        ZA_UNLOCK(self.urlToOutputStreamLock);
    } else {
        [self.queueModel enqueueOperation:downloadOperationModel];
        [self.queueModel operationDidFinish];
    }
}

- (nullable NSURLRequest *)_buildRequestFromURL:(NSURL *)url headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    if (nil == url) { return NULL; }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = [self _getTimeoutInterval];
    
    // add resume header
    
    return request;
}

- (NSTimeInterval)_getTimeoutInterval {
    NetworkStatus status = ZANetworkManager.sharedInstance.currentNetworkStatus;
    switch (status) {
        case ReachableViaWiFi:
            return 60;
        case ReachableViaWWAN:
            return 90;
        case NotReachable:
            return 0;
    }
}

- (void)_writeDataToFileByURL:(NSURL *)url data:(NSData *)data {
    ZA_LOCK(self.urlToDownloadOperationLock);
    NSOutputStream *stream = [self.urlToOutputStream objectForKey:url];
    [stream write:data.bytes maxLength:data.length];
    ZA_UNLOCK(self.urlToDownloadOperationLock);
}

- (nullable NSString *)_getFilePathFromURL:(NSURL *)url {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths.firstObject;
    if (path) {
        NSString *fileName = [url.absoluteString MD5String];
        return [path stringByAppendingPathComponent:fileName];
    } else {
        return NULL;
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        if (nil == HTTPResponse) { return; }
        
        NSUInteger contentLength = [HTTPResponse.allHeaderFields[@"Content-Length"] integerValue];
        
        NSURL *url = dataTask.currentRequest.URL;
        if (url) {
            ZA_LOCK(weakSelf.urlToDownloadOperationLock);
            ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
            downloadOperationModel.contentLength = contentLength;
            ZA_UNLOCK(weakSelf.urlToDownloadOperationLock);
        }
        
        completionHandler(NSURLSessionResponseAllow);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSURL *url = dataTask.currentRequest.URL;
        if (nil == url) { return; }
        
        [weakSelf _writeDataToFileByURL:url data:data];
        ZA_LOCK(weakSelf.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        [downloadOperationModel addCurrentDownloadLenght:data.length];
        [downloadOperationModel forwardProgress];
        ZA_UNLOCK(weakSelf.urlToDownloadOperationLock);
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSURL *url = task.currentRequest.URL;
        if (nil == url) { return; }
        
        ZA_LOCK(weakSelf.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        [downloadOperationModel forwardCompletion];
        
        if (nil == error) {
            NSString *filePath = [self _getFilePathFromURL:url];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            [downloadOperationModel forwarFileFromLocation:fileURL];
            
            if ([downloadOperationModel numberOfPausedOperation] == 0) {
                [NSFileManager.defaultManager removeItemAtURL:fileURL error:NULL];
                [weakSelf.urlToDownloadOperation removeObjectForKey:url];
                [weakSelf.urlToOutputStream removeObjectForKey:url];
            }
        }
        
        [weakSelf.queueModel operationDidFinish];
        ZA_UNLOCK(weakSelf.urlToDownloadOperationLock);
        
        [weakSelf _triggerStartRequest];
    });
}

@end
