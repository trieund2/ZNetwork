//
//  ZAQueueModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZADefine.h"
#import "ZAOperationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAQueueModel : NSObject

@property (nonatomic, readonly) BOOL isMultiCallback;
@property (nonatomic, readonly) NSUInteger maxOperationPerform;
@property (nonatomic, readonly) ZAPerformOperationType queueType;
@property (nonatomic, readonly) ZAOperationPerformType performType;

- (instancetype)initByPerformOperationType:(ZAPerformOperationType) operationType
                           isMultiCallback:(BOOL)isMultiCallback
                               performType:(ZAOperationPerformType)performType;

- (void)enqueueOperation:(ZAOperationModel *)operationModel;
- (BOOL)canDequeueOperationModel;
- (nullable ZAOperationModel *)dequeueOperationModel;

@end

NS_ASSUME_NONNULL_END
