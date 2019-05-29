//
//  ZAQueueModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAQueueModel.h"

@implementation ZAQueueModel

- (instancetype)init
{
    return [self initByPerformOperationType:(ZAPerformOperationTypeFIFO) isMultiCallback:YES performType:(ZAOperationPerformTypeConcurrency)];
}

- (instancetype)initByPerformOperationType:(ZAPerformOperationType)operationType
                           isMultiCallback:(BOOL)isMultiCallback
                               performType:(ZAOperationPerformType)performType {
    self = [super init];
    if (self) {
        _queueType = operationType;
        _isMultiCallback = isMultiCallback;
        _performType = performType;
        _veryHighQueue = [[NSMutableArray alloc] init];
        _highQueue = [[NSMutableArray alloc] init];
        _mediumQueue = [[NSMutableArray alloc] init];
        _lowQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
