//
//  ZASessionManager.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZADownloadSessionManager.h"
#import "ZADownloadOperationModel.h"
#import "ZAQueueModel.h"
#import "NSString+Extension.h"

@interface ZADownloadSessionManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) dispatch_queue_t root_queue;
@property (nonatomic, readonly) dispatch_queue_t delegate_queue;
@property (nonatomic, readonly) ZAQueueModel *queueModel;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZADownloadOperationModel *> *runningRequestToDownloadOperation;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, ZADownloadOperationModel *> *runningCallbackIdToDownloadOperation;

@end

@implementation ZADownloadSessionManager

#pragma mark - LifeCycle

+ (instancetype)sharedManager {
    static ZADownloadSessionManager *sessionManager = nil;
    dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        sessionManager = [[ZADownloadSessionManager alloc] init];
    });
    return sessionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _root_queue = dispatch_queue_create("com.za.zanetworking.sessionmanager.rootqueue", DISPATCH_QUEUE_SERIAL);
        _delegate_queue = dispatch_queue_create("com.za.zanetworking.sessionmanager.delegatequeue", DISPATCH_QUEUE_CONCURRENT);
        _queueModel = [[ZAQueueModel alloc] init];
    }
    return self;
}

#pragma mark - Interface methods

- (NSString *)downloadTaskFromURLString:(NSString *)urlString
                                headers:(NSDictionary<NSString *,NSString *> *)header
                               priority:(ZAOperationPriority)priority
                          progressBlock:(ZAProgressBlock)progressBlock
                       destinationBlock:(ZADestinationBlock)destinationBlock
                        completionBlock:(ZACompletionBlock)completionBloc {
    ZADownloadOperationCallback *downloadCallback = [[ZADownloadOperationCallback alloc] initWithProgressBlock:progressBlock destinationBlock:destinationBlock completionBlock:completionBloc];
    NSURL *url = [urlString toURL];
    if (nil == url) { return NULL; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.runningRequestToDownloadOperation objectForKey:url];
        if (downloadOperationModel) {
            [downloadOperationModel addOperationCallback:downloadCallback];
        } else {
            downloadOperationModel = [[ZADownloadOperationModel alloc] initByURL:url
                                                                   requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                        priority:priority
                                                               operationCallback:downloadCallback];
            [strongSelf.queueModel enqueueOperation:downloadOperationModel];
            if ([strongSelf.queueModel canDequeueOperationModel]) {
                [strongSelf triggerStartRequest];
            }
        }
    });
    
    return downloadCallback.identifier;
}

- (void)pauseDownloadTaskByIdentifier:(NSString *)identifier {
    
}

- (void)resumeDownloadTaskByIdentifier:(NSString *)identifier {
    
}

- (void)cancelDownloadTaskByIdentifier:(NSString *)identifier {
    
}

#pragma mark - Helper methods

- (void)triggerStartRequest {
    ZADownloadOperationModel *downloadOperationModel = (ZADownloadOperationModel *)[self.queueModel dequeueOperationModel];
    if (nil == downloadOperationModel) { return; }
    
    NSURLRequest *downloadRequest = [self buildRequestFromURL:downloadOperationModel.url headers:NULL];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:downloadRequest];
    [dataTask resume];
}

- (nullable NSURLRequest *)buildRequestFromURL:(NSURL *)url headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    return NULL;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}

@end
