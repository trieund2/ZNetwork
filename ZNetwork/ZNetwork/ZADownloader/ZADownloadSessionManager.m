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

@interface ZADownloadSessionManager ()

@property (nonatomic, readonly) NSURLSession *session;
@property (readonly, nonatomic) dispatch_queue_t root_queue;
@property (readonly, nonatomic) dispatch_queue_t delegate_queue;
@property (readonly, nonatomic) ZAQueueModel *queueModel;

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
    ZADownloadOperationModel *downloadOperationModel = [[ZADownloadOperationModel alloc] initByURL:NULL
                                                                                     requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                                          priority:priority
                                                                                 operationCallback:downloadCallback];
    return NULL;
}

- (void)pauseDownloadTaskByIdentifier:(NSString *)identifier {
    
}

- (void)resumeDownloadTaskByIdentifier:(NSString *)identifier {
    
}

- (void)cancelDownloadTaskByIdentifier:(NSString *)identifier {
    
}

#pragma mark - Helper methods

- (nullable NSURLRequest *)buildRequestFromURL:(NSString *)urlString headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    return NULL;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}

@end
