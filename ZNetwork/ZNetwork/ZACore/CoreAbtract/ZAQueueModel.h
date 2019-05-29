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
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *veryHighQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *highQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *mediumQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *lowQueue;

- (instancetype)initByPerformOperationType:(ZAPerformOperationType) operationType
                           isMultiCallback:(BOOL)isMultiCallback
                               performType:(ZAOperationPerformType)performType;

+ (void)addOperation;

@end

NS_ASSUME_NONNULL_END
