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

@interface ZADownloadManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) dispatch_queue_t root_queue;
@property (nonatomic, readonly) dispatch_queue_t delegate_queue;
@property (nonatomic, readonly) ZAQueueModel *queueModel;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZADownloadOperationModel *> *urlToDownloadOperation;
@property (nonatomic, readonly) dispatch_semaphore_t urlToDownloadOperationLock;

@end

@implementation ZADownloadManager

#pragma mark - LifeCycle

+ (instancetype)sharedManager {
    static ZADownloadManager *sessionManager = nil;
    dispatch_once_t onceToken;
    _dispatch_once(&onceToken, ^{
        sessionManager = [[ZADownloadManager alloc] init];
    });
    return sessionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.za.znetwork.background.download.session"];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _root_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.rootqueue", DISPATCH_QUEUE_SERIAL);
        _delegate_queue = dispatch_queue_create("com.za.znetwork.sessionmanager.delegatequeue", DISPATCH_QUEUE_CONCURRENT);
        _queueModel = [[ZAQueueModel alloc] init];
        _urlToDownloadOperation = [[NSMutableDictionary alloc] init];
        _urlToDownloadOperationLock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Interface methods

- (nullable ZADownloadOperationCallback *)downloadTaskFromURLString:(NSString *)urlString
                                                            headers:(NSDictionary<NSString *,NSString *> *)header
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
                                                                                            priority:priority];
    
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.root_queue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        ZADownloadOperationModel *downloadOperationModel = [weakSelf.urlToDownloadOperation objectForKey:url];
        if (downloadOperationModel && self.queueModel.isMultiCallback) {
            [downloadOperationModel addOperationCallback:downloadCallback];
        } else {
            downloadOperationModel = [[ZADownloadOperationModel alloc] initByURL:url
                                                                   requestPolicy:requestPolicy
                                                                        priority:priority
                                                               operationCallback:downloadCallback];
            [strongSelf.queueModel enqueueOperation:downloadOperationModel];
            if ([strongSelf.queueModel canDequeueOperationModel]) {
                [strongSelf triggerStartRequest];
            }
        }
    });
    
    return downloadCallback;
}

- (void)pauseDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    
}

- (void)resumeDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    
}

- (void)cancelDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback {
    
}

#pragma mark - Helper methods

- (void)triggerStartRequest {
    ZADownloadOperationModel *downloadOperationModel = (ZADownloadOperationModel *)[self.queueModel dequeueOperationModel];
    if (nil == downloadOperationModel) { return; }
    
    NSURLRequest *downloadRequest = [self buildRequestFromURL:downloadOperationModel.url headers:NULL];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:downloadRequest];
    [dataTask resume];
    downloadOperationModel.task = dataTask;
    
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
