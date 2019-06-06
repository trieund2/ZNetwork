//
//  ZAOperationModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAOperationCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAOperationModel : NSObject {
    
@protected
    NSMutableDictionary<NSString *, ZAOperationCallback *> *runningOperationCallbacks;
    dispatch_semaphore_t runningOperationCallbacksLock;
    NSMutableDictionary<NSString *, ZAOperationCallback *> *pausedOperationCallbacks;
    dispatch_semaphore_t pausedOperationCallbacksLock;
}

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURLRequestCachePolicy requestPolicy;
@property (nonatomic, nullable) NSURLSessionTask *task;
@property (nonatomic) ZASessionTaskStatus status;
@property (nonatomic) ZAOperationPriority priority;

- (id)init NS_UNAVAILABLE;

- (instancetype)initByURL:(NSURL *)url;

- (instancetype)initByURL:(NSURL *)url
            requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                 priority:(ZAOperationPriority) priority;

- (instancetype)initByURL:(NSURL *)url
            requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                 priority:(ZAOperationPriority) priority
        operationCallback:(nullable ZAOperationCallback *)callback;

- (NSUInteger)numberOfRunningOperation;
- (NSUInteger)numberOfPausedOperation;
- (void)addOperationCallback:(ZAOperationCallback *)callback;
- (void)pauseOperationCallbackById:(NSString *)identifier;
- (void)removePausedOperationCallbackById:(NSString *)identifier;
- (void)cancelOperationCallbackById:(NSString *)identifier;
- (void)pauseAllOperations;
- (void)cancelAllOperations;
- (void)removeAllRunningOperations;
- (void)pauseAllRunningOperations;
- (NSArray<ZAOperationCallback *> *)allRunningOperationCallbacks;

@end

NS_ASSUME_NONNULL_END
