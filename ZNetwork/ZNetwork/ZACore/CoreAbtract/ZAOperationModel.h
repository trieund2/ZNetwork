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

@interface ZAOperationModel : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURLRequestCachePolicy requestPolicy;
@property (nonatomic, readonly) ZAOperationPriority priority;
@property (nonatomic, readonly) NSURLSessionTask *task;

- (id)init NS_UNAVAILABLE;
- (instancetype)initByURL:(NSURL *)url;
- (instancetype)initByURL:(NSURL *)url requestPolicy:(NSURLRequestCachePolicy)requestPolicy priority:(ZAOperationPriority) priority;

- (NSUInteger)numberOfRunningOperation;
- (NSUInteger)numberOfPausedOperation;
- (void)addOperationCallback:(ZAOperationCallback *)callback;
- (void)pauseOperationCallbackById:(NSString *)identifier;
- (void)resumeOperationCallbackById:(NSString *)identifier;
- (void)cancelOperationCallbackById:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
