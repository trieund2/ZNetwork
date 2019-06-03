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
#import "ZASessionStorage.h"

@interface ZADownloadManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) dispatch_queue_t root_queue;
@property (nonatomic, readonly) ZAQueueModel *queueModel;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZADownloadOperationModel *> *urlToDownloadOperation;

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
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _root_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.rootqueue", DISPATCH_QUEUE_SERIAL);
        _queueModel = [[ZAQueueModel alloc] init];
        _urlToDownloadOperation = [[NSMutableDictionary alloc] init];
        [ZASessionStorage.sharedStorage loadAllTaskInfo:^(NSError * _Nullable error) {}];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_triggerStartRequest)
                                                   name:NetworkStatusDidChangeNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark - Interface methods

- (NSUInteger)numberOfTaskRunning {
    return self.queueModel.numberOfTaskRunning;
}

- (NSUInteger)numberOfTaskInQueue {
    return self.queueModel.numberOfTaskInQueue;
}

- (nullable ZADownloadOperationCallback *)downloadTaskFromURLString:(NSString *)urlString
                                                      requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                                                           priority:(ZAOperationPriority)priority
                                                      progressBlock:(ZAProgressBlock)progressBlock
                                                   destinationBlock:(ZADestinationBlock)destinationBlock
                                                    completionBlock:(ZACompletionBlock)completionBlock {
    NSURL *url = [urlString toURL];
    if (nil == url) { return nil; }
    
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
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        if (downloadOperation) {
            [downloadOperation pauseOperationCallbackById:downloadCallback.identifier];
            if ([downloadOperation numberOfRunningOperation] == 0) {
                [weakSelf.queueModel operationDidFinish];
            }
            [self _triggerStartRequest];
        } else {
            [weakSelf.queueModel pauseOperationByCallback:downloadCallback];
        }
    });
}

- (void)resumeDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        if (nil == downloadOperation) {
            return;
        }
        [downloadOperation removePausedOperationCallbackById:downloadCallback.identifier];
        [weakSelf _startRequestByDownloadOperationCallback:downloadCallback];
    });
}

- (void)cancelDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url ) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        
        if (downloadOperation) {
            [downloadOperation cancelOperationCallbackById:downloadCallback.identifier];
            
            if ([downloadOperation numberOfPausedOperation] == 0) {
                [weakSelf.queueModel operationDidFinish];
                if ([downloadOperation numberOfRunningOperation] == 0) {
                    [weakSelf.urlToDownloadOperation removeObjectForKey:downloadCallback.url];
                    [ZASessionStorage.sharedStorage removeTaskInfoByURLString:downloadCallback.url.absoluteString completion:NULL];
                }
            }
        } else {
            [weakSelf.queueModel cancelOperationByCallback:downloadCallback];
        }
    });
}

- (void)cancelAllRequests {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        for (ZADownloadOperationModel *downloadOperationModel in weakSelf.urlToDownloadOperation.allValues) {
            [downloadOperationModel cancelAllOperations];
        }
        [weakSelf.urlToDownloadOperation removeAllObjects];
        [weakSelf.queueModel removeAllOperations];
    });
}

- (void)pauseAllRequests {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        for (ZADownloadOperationModel *downloadOperationModel in weakSelf.urlToDownloadOperation.allValues) {
            [downloadOperationModel pauseAllOperations];
        }
        [weakSelf.queueModel resetNumberOfRunningOperations];
    });
}

#pragma mark - Helper methods

- (void)_startRequestByDownloadOperationCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url) { return; }
    
    ZADownloadOperationModel *downloadOperationModel = [self.urlToDownloadOperation objectForKey:downloadCallback.url];
    
    if (downloadOperationModel
        && self.queueModel.isMultiCallback
        && downloadOperationModel.status == ZASessionTaskStatusRunning) {
        
        [downloadOperationModel addOperationCallback:downloadCallback];
        downloadCallback.canResume = downloadOperationModel.canResume;
        
    } else if (downloadOperationModel
               && downloadOperationModel.status == ZASessionTaskStatusSuccessed) {
        [downloadOperationModel cancelOperationCallbackById:downloadCallback.identifier];
        downloadCallback.completionBlock(downloadOperationModel.task.response, downloadOperationModel.task.error, downloadCallback.identifier);
        return;
        
    } else {
        if (nil == downloadOperationModel) {
            downloadOperationModel = [[ZADownloadOperationModel alloc] initByURL:downloadCallback.url
                                                                   requestPolicy:downloadCallback.requestPolicy
                                                                        priority:downloadCallback.priority
                                                               operationCallback:downloadCallback];
        } else {
            [downloadOperationModel addOperationCallback:downloadCallback];
        }
        
        [self.queueModel enqueueOperation:downloadOperationModel];
        [self _triggerStartRequest];
    }
}

- (void)_triggerStartRequest {
    if (ZANetworkManager.sharedInstance.isConnectionAvailable == NO) { return; }
    
    ZADownloadOperationModel *downloadOperationModel = (ZADownloadOperationModel *)[self.queueModel dequeueOperationModel];
    if (nil == downloadOperationModel) { return; }
    
    self.urlToDownloadOperation[downloadOperationModel.url] = downloadOperationModel;
    downloadOperationModel.status = ZASessionTaskStatusRunning;
    
    ZALocalTaskInfo *taskInfo = [ZASessionStorage.sharedStorage getTaskInfoByURLString:downloadOperationModel.url.absoluteString];
    if (taskInfo) {
        downloadOperationModel.countOfBytesReceived = taskInfo.countOfBytesReceived;
        downloadOperationModel.countOfTotalBytes = taskInfo.countOfTotalBytes;
        downloadOperationModel.filePath = taskInfo.filePath;
        downloadOperationModel.outputStream = [NSOutputStream outputStreamToFileAtPath:taskInfo.filePath append:YES];
        [downloadOperationModel.outputStream open];
    } else {
        NSString *filePath = [self _getFilePathFromURL:downloadOperationModel.url];
        [self _removeFileIfExitByFilePath:filePath];
        downloadOperationModel.filePath = filePath;
        downloadOperationModel.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
        [downloadOperationModel.outputStream open];
    }
    
    NSURLRequest *request = [self _buildRequestFromURL:downloadOperationModel.url headers:NULL];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    downloadOperationModel.task = dataTask;
    [dataTask resume];
}

- (nullable NSURLRequest *)_buildRequestFromURL:(NSURL *)url headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    if (nil == url) { return NULL; }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = [self _getTimeoutInterval];
    
    ZALocalTaskInfo *taskInfo = [ZASessionStorage.sharedStorage getTaskInfoByURLString:url.absoluteString];
    if (taskInfo && taskInfo.countOfBytesReceived != 0 && taskInfo.countOfTotalBytes != 0) {
        NSString *range = [NSString stringWithFormat:@"bytes=%lli-%lli", taskInfo.countOfBytesReceived, taskInfo.countOfTotalBytes];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    
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
    NSOutputStream *stream = [self.urlToDownloadOperation objectForKey:url].outputStream;
    [stream write:data.bytes maxLength:data.length];
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

- (void)_removeFileIfExitByFilePath:(NSString *)filePath {
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:NULL];
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSURL *url = dataTask.originalRequest.URL;
        
        if (url) {
            ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
            NSUInteger contentLength = [HTTPResponse.allHeaderFields[@"Content-Length"] integerValue];
            
            long long freeDiskSize = [[[NSFileManager.defaultManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
            if (contentLength > freeDiskSize) {
                NSError *error = [NSError errorWithDomain:ZASessionStorageErrorDomain code:ZANetworkErrorFullDisk userInfo:nil];
                [downloadOperationModel forwardError:error];
                downloadOperationModel.status = ZASessionTaskStatusFailed;
                [downloadOperationModel.task cancel];
                completionHandler(NSURLSessionResponseCancel);
                return;
            }
            
            if (downloadOperationModel.countOfTotalBytes == 0) {
                downloadOperationModel.countOfTotalBytes = contentLength;
            }
            
            NSString *acceptRange = (NSString *)[HTTPResponse.allHeaderFields objectForKey:@"Accept-Ranges"];
            if ([acceptRange isEqualToString:ZARequestAcceptRangeBytes]) {
                if ([ZASessionStorage.sharedStorage containsTaskInfo:url.absoluteString] == NO) {
                    ZALocalTaskInfo *taskInfo = [[ZALocalTaskInfo alloc] initWithURLString:downloadOperationModel.url.absoluteString
                                                                                  filePath:downloadOperationModel.filePath
                                                                                  fileName:url.absoluteString.MD5String
                                                                         countOfTotalBytes:downloadOperationModel.countOfTotalBytes];
                    [ZASessionStorage.sharedStorage commitTaskInfo:taskInfo];
                }
                
                downloadOperationModel.canResume = YES;
            } else {
                downloadOperationModel.canResume = NO;
            }
            
            [downloadOperationModel updateResumeStatusForAllCallbacks];
        }
        
        completionHandler(NSURLSessionResponseAllow);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSURL *url = dataTask.originalRequest.URL;
        if (nil == url) { return; }
        
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        [downloadOperationModel updateCountOfBytesReceived:data.length];
        
        if (downloadOperationModel.countOfBytesReceived > downloadOperationModel.countOfTotalBytes) {
            downloadOperationModel.status = ZASessionTaskStatusFailed;
            [downloadOperationModel.task cancel];
            NSError *error = [NSError errorWithDomain:ZASessionStorageErrorDomain code:ZANetworkErrorFileError userInfo:nil];
            [downloadOperationModel forwardError:error];
        } else {
            [weakSelf _writeDataToFileByURL:url data:data];
            [downloadOperationModel forwardProgress];
            [ZASessionStorage.sharedStorage updateCountOfBytesReceived:data.length byURLString:url.absoluteString];
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.root_queue, ^{
        NSURL *url = task.originalRequest.URL;
        if (nil == url) { return; }
        
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        if (nil == downloadOperationModel) {
            [ZASessionStorage.sharedStorage removeTaskInfoByURLString:url.absoluteString completion:nil];
            return;
        }
        
        if (nil == error) {
            unsigned long long fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:downloadOperationModel.filePath error:nil] fileSize];
            if (fileSize == downloadOperationModel.countOfTotalBytes) {
                downloadOperationModel.status = ZASessionTaskStatusSuccessed;
                [downloadOperationModel forwarFileFromLocation];
                [downloadOperationModel forwardCompletion];
            } else {
                downloadOperationModel.status = ZASessionTaskStatusFailed;
                NSError *error = [NSError errorWithDomain:ZASessionStorageErrorDomain code:ZANetworkErrorFileError userInfo:nil];
                [downloadOperationModel forwardError:error];
            }
            
            [downloadOperationModel removeAllRunningOperations];
        } else if (error && downloadOperationModel.status != ZASessionTaskStatusFailed) {
            [downloadOperationModel forwardError:error];
        }
        
        if ([downloadOperationModel numberOfPausedOperation] == 0) {
            [ZASessionStorage.sharedStorage removeTaskInfoByURLString:url.absoluteString completion:nil];
            [weakSelf.urlToDownloadOperation removeObjectForKey:url];
            [downloadOperationModel.outputStream close];
            NSLog(@"--- REMOVE FILE");
        }
        
        [weakSelf.queueModel operationDidFinish];
        [weakSelf _triggerStartRequest];
    });
}

@end
