//
//  ZAOperationModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZADefine.h"
#import "ZAOperationCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAOperationModel : NSObject {
    
@protected
    NSMutableDictionary<NSString *, ZAOperationCallback *> *runningOperationCallbacks;
    NSMutableDictionary<NSString *, ZAOperationCallback *> *pausedOperationCallbacks;
}

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURLRequestCachePolicy requestPolicy;
@property (nonatomic) ZAOperationPriority priority;
@property (nonatomic) NSURLSessionTask *task;

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
- (void)removeOperationCallback:(ZAOperationCallback *)callback;
- (void)pauseOperationCallbackById:(NSString *)identifier;
- (void)resumeOperationCallbackById:(NSString *)identifier;
- (void)cancelOperationCallbackById:(NSString *)identifier;
- (NSArray<ZAOperationCallback *> *)allRunningOperationCallback;

@end

NS_ASSUME_NONNULL_END
