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

@implementation ZADownloadConfiguration

+ (instancetype)defaultConfiguration {
    static ZADownloadConfiguration *defaultConfiguration;
    static dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        defaultConfiguration = [ZADownloadConfiguration new];
    });
    return defaultConfiguration;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isMultiCallback = YES;
        _continueDownloadInBackground = YES;
        _queueType = ZAOperationExecutionOrderFIFO;
        _performType = ZAOperationPerformTypeConcurrency;
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return self;
}

@end

#pragma mark -

@interface ZADownloadManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) dispatch_queue_t root_queue;
@property (nonatomic, readonly) dispatch_queue_t delegate_queue;
@property (nonatomic, readonly) ZAQueueModel *queueModel;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZADownloadOperationModel *> *urlToDownloadOperation;
@property (nonatomic, readonly) dispatch_semaphore_t urlToDownloadOperationLock;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic) BOOL continueDownloadInBackground;
@property (nonatomic) BOOL isPaused;

@end

@implementation ZADownloadManager

#pragma mark - LifeCycle

+ (instancetype)sharedManager {
    static ZADownloadManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[ZADownloadManager alloc] initWithConfiguration:ZADownloadConfiguration.defaultConfiguration];
    });
    return sessionManager;
}

+ (instancetype)shareManagerWithConfiguration:(ZADownloadConfiguration *)configuration {
    static ZADownloadManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[ZADownloadManager alloc] initWithConfiguration:configuration];
    });
    return sessionManager;
}

- (instancetype)initWithConfiguration:(ZADownloadConfiguration *)configuration {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:configuration.sessionConfiguration delegate:self delegateQueue:nil];
        _root_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.rootqueue", DISPATCH_QUEUE_SERIAL);
        _delegate_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.delegate", DISPATCH_QUEUE_CONCURRENT);
        _urlToDownloadOperation = [[NSMutableDictionary alloc] init];
        _urlToDownloadOperationLock = dispatch_semaphore_create(1);
        [ZASessionStorage.sharedStorage loadAllTaskInfo:^(NSError * _Nullable error) {}];
        _continueDownloadInBackground = configuration.continueDownloadInBackground;
        _backgroundTaskId = UIBackgroundTaskInvalid;
        _isPaused = false;
        _queueModel = [[ZAQueueModel alloc] initByOperationExecutionOrder:configuration.queueType
                                                          isMultiCallback:configuration.isMultiCallback
                                                              performType:configuration.performType];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_triggerStartRequest)
                                                   name:NetworkStatusDidChangeNotification
                                                 object:nil];
        
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:app];
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

- (NSUInteger)maxTaskPerform {
    return self.queueModel.maxOperationPerform;
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
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        if (downloadOperation) {
            [downloadOperation pauseOperationCallbackById:downloadCallback.identifier];
            if ([downloadOperation numberOfRunningOperation] == 0) {
                NSError *error = [NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorPauseTask userInfo:nil];
                downloadCallback.completionBlock(downloadOperation.task, error, downloadCallback.identifier);
            }
        } else {
            [weakSelf.queueModel pauseOperationByCallback:downloadCallback];
        }
    });
}

- (void)resumeDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        if (nil == downloadOperation) { return; }
        [downloadOperation removePausedOperationCallbackById:downloadCallback.identifier];
        if ([downloadOperation numberOfRunningOperation] == 0 && [downloadOperation numberOfPausedOperation] == 0) {
            
            ZA_LOCK(self.urlToDownloadOperationLock);
            [weakSelf.urlToDownloadOperation removeObjectForKey:downloadOperation.url];
            ZA_UNLOCK(self.urlToDownloadOperationLock);
        }
        [weakSelf _startRequestByDownloadOperationCallback:downloadCallback];
    });
}

- (void)cancelDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url ) { return; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:downloadCallback.url];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        if (downloadOperation) {
            [downloadOperation cancelOperationCallbackById:downloadCallback.identifier];
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
            downloadCallback.completionBlock(downloadOperation.task, error, downloadCallback.identifier);
        } else {
            [weakSelf.queueModel cancelOperationByCallback:downloadCallback];
        }
    });
}

- (void)cancelAllRequests {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        ZA_LOCK(self.urlToDownloadOperationLock);
        for (ZADownloadOperationModel *downloadOperationModel in weakSelf.urlToDownloadOperation.allValues) {
            [downloadOperationModel cancelAllOperations];
            [ZASessionStorage.sharedStorage removeTaskInfoByURLString:downloadOperationModel.url.absoluteString completion:nil];
        }
        [weakSelf.urlToDownloadOperation removeAllObjects];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        [weakSelf.queueModel removeAllOperations];
        [weakSelf.queueModel resetNumberOfRunningOperations];
    });
}

- (void)pauseAllRequests {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.root_queue, ^{
        ZA_LOCK(self.urlToDownloadOperationLock);
        for (ZADownloadOperationModel *downloadOperationModel in weakSelf.urlToDownloadOperation.allValues) {
            NSError *error = [NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorAppEnterBackground userInfo:nil];
            [downloadOperationModel forwardError:error];
            [downloadOperationModel pauseAllOperations];
        }
        ZA_UNLOCK(self.urlToDownloadOperationLock);
    });
}

#pragma mark - Helper methods

- (void)_startRequestByDownloadOperationCallback:(ZADownloadOperationCallback *)downloadCallback {
    if (nil == downloadCallback || nil == downloadCallback.url) { return; }
    
    ZA_LOCK(self.urlToDownloadOperationLock);
    ZADownloadOperationModel *downloadOperationModel = [self.urlToDownloadOperation objectForKey:downloadCallback.url];
    ZA_UNLOCK(self.urlToDownloadOperationLock);
    
    if (downloadOperationModel
        && self.queueModel.isMultiCallback
        && downloadOperationModel.status == ZASessionTaskStatusRunning) {
        
        [downloadOperationModel addOperationCallback:downloadCallback];
        downloadCallback.canResume = downloadOperationModel.canResume;
        
    } else if (downloadOperationModel
               && downloadOperationModel.status == ZASessionTaskStatusSuccessed) {
        [downloadOperationModel cancelOperationCallbackById:downloadCallback.identifier];
        downloadCallback.completionBlock(downloadOperationModel.task, downloadOperationModel.task.error, downloadCallback.identifier);
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
    
    ZA_LOCK(self.urlToDownloadOperationLock);
    ZADownloadOperationModel *downloadOperationModel = (ZADownloadOperationModel *)[self.queueModel dequeueOperationModel];
    ZA_UNLOCK(self.urlToDownloadOperationLock);
    if (nil == downloadOperationModel) { return; }
    
    if (self.continueDownloadInBackground) {
        __weak __typeof__ (self) weakSelf = self;
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [weakSelf _endBackgroundTask];
        }];
    }
    
    ZA_LOCK(self.urlToDownloadOperationLock);
    self.urlToDownloadOperation[downloadOperationModel.url] = downloadOperationModel;
    ZA_UNLOCK(self.urlToDownloadOperationLock);
    
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
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
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

- (void)_applicationWillTerminate:(NSNotification *)notification {
    self.isPaused = YES;
    [self pauseAllRequests];
    [ZASessionStorage.sharedStorage pushAllTaskInfoWithCompletion:^(NSError * _Nullable error) {}];
}

- (void)_endBackgroundTask {
    [self pauseAllRequests];
    [ZASessionStorage.sharedStorage pushAllTaskInfoWithCompletion:^(NSError * _Nullable error) {}];
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    _backgroundTaskId = UIBackgroundTaskInvalid;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.delegate_queue, ^{
        NSURL *url = dataTask.originalRequest.URL;
        
        if (url) {
            
            ZA_LOCK(self.urlToDownloadOperationLock);
            ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
            ZA_UNLOCK(self.urlToDownloadOperationLock);
            
            if (nil == downloadOperationModel) { return; }
            
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
            NSUInteger contentLength = [HTTPResponse.allHeaderFields[@"Content-Length"] integerValue];
            
            long long freeDiskSize = [[[NSFileManager.defaultManager attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
            if (contentLength > freeDiskSize) {
                NSError *error = [NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorFullDisk userInfo:nil];
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
            [downloadOperationModel forwardURLResponse:response];
        }
        
        completionHandler(NSURLSessionResponseAllow);
    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.isPaused) { return; }
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.delegate_queue, ^{
        NSURL *url = dataTask.originalRequest.URL;
        if (nil == url) { return; }
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        [downloadOperationModel updateCountOfBytesReceived:data.length];
        
        if (downloadOperationModel.countOfBytesReceived > downloadOperationModel.countOfTotalBytes) {
            downloadOperationModel.status = ZASessionTaskStatusFailed;
            [downloadOperationModel.task cancel];
            NSError *error = [NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorFileError userInfo:nil];
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
    
    dispatch_async(self.delegate_queue, ^{
        NSURL *url = task.originalRequest.URL;
        if (nil == url) { return; }
        
        ZA_LOCK(self.urlToDownloadOperationLock);
        ZADownloadOperationModel *downloadOperation = [weakSelf.urlToDownloadOperation objectForKey:url];
        ZA_UNLOCK(self.urlToDownloadOperationLock);
        
        if (nil == downloadOperation) { return; }
        __block NSError *errorToForward = nil;
        
        if (nil == error) {
            unsigned long long fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:downloadOperation.filePath error:nil] fileSize];
            if (fileSize == downloadOperation.countOfTotalBytes) {
                downloadOperation.status = ZASessionTaskStatusSuccessed;
                [downloadOperation forwardFileFromLocation];
            } else {
                downloadOperation.status = ZASessionTaskStatusFailed;
                NSError *storageError = [NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorFileError userInfo:nil];
                errorToForward = storageError;
            }
            
        } else {
            if (downloadOperation.status != ZASessionTaskStatusFailed) {
                if (error.code == NSURLErrorTimedOut
                    || error.code == NSURLErrorNetworkConnectionLost
                    || error.code == NSURLErrorCannotConnectToHost
                    || error.code == NSURLErrorNotConnectedToInternet) {
                    
                    [downloadOperation pauseAllOperations];
                }
                
                errorToForward = error;
            }
        }
        
        if ([downloadOperation numberOfPausedOperation] == 0) {
            [ZASessionStorage.sharedStorage removeTaskInfoByURLString:url.absoluteString completion:^(NSError * _Nullable removeTaskInfoError) {
                if (removeTaskInfoError) {
                    [downloadOperation forwardError:removeTaskInfoError];
                    return;
                }
                
                [downloadOperation.outputStream close];
                [weakSelf.urlToDownloadOperation removeObjectForKey:url];
                
                if (errorToForward) {
                    [downloadOperation forwardError:errorToForward];
                } else {
                    [downloadOperation forwardCompletion];
                }
            }];
        }
        
        [downloadOperation removeAllRunningOperations];
        dispatch_async(weakSelf.root_queue, ^{
            [weakSelf.queueModel operationDidFinish];
            [weakSelf _triggerStartRequest];
        });
    });
}

@end
