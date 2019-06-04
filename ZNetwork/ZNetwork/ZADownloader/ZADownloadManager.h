//
//  ZADownloadManager.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZADownloadOperationCallback.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZADownloadConfiguration : NSObject

@property (nonatomic) BOOL isMultiCallback;
@property (nonatomic) BOOL continueDownloadInBackground;
@property (nonatomic) ZAOperationQueueType queueType;
@property (nonatomic) ZAOperationPerformType performType;

@end

#pragma mark -

@interface ZADownloadManager : NSObject <NSURLSessionDataDelegate>

+ (instancetype)sharedManager;
+ (instancetype)shareManagerWithConfiguration:(ZADownloadConfiguration *)configuration;

- (nullable ZADownloadOperationCallback *)downloadTaskFromURLString:(NSString *)urlString
                                                      requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                                                           priority:(ZAOperationPriority)priority
                                                      progressBlock:(ZAProgressBlock)progressBlock
                                                   destinationBlock:(ZADestinationBlock)destinationBlock
                                                    completionBlock:(ZACompletionBlock)completionBlock;

- (void)resumeDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback;
- (void)pauseDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback;
- (void)cancelDownloadTaskByDownloadCallback:(ZADownloadOperationCallback *)downloadCallback;
- (void)cancelAllRequests;
- (void)pauseAllRequests;
- (NSUInteger)numberOfTaskRunning;
- (NSUInteger)numberOfTaskInQueue;

@end

NS_ASSUME_NONNULL_END
