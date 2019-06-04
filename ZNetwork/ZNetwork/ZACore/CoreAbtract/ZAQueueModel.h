//
//  ZAQueueModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAOperationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAQueueModel : NSObject

@property (nonatomic, readonly) BOOL isMultiCallback;
@property (nonatomic, readonly) NSUInteger maxOperationPerform;
@property (nonatomic, readonly) ZAOperationQueueType queueType;
@property (nonatomic, readonly) ZAOperationPerformType performType;

- (instancetype)initByOperationQueueType:(ZAOperationQueueType) operationType
                           isMultiCallback:(BOOL)isMultiCallback
                               performType:(ZAOperationPerformType)performType;

- (NSUInteger)numberOfTaskRunning;
- (NSUInteger)numberOfTaskInQueue;
- (void)enqueueOperation:(ZAOperationModel *)operationModel;
- (nullable ZAOperationModel *)dequeueOperationModel;
- (BOOL)canDequeueOperationModel;
- (void)pauseOperationByCallback:(ZAOperationCallback *)callback;
- (void)cancelOperationByCallback:(ZAOperationCallback *)callback;
- (void)operationDidFinish;
- (void)removeAllOperations;
- (void)resetNumberOfRunningOperations;

@end

NS_ASSUME_NONNULL_END
