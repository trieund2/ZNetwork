//
//  ZADownloadOperationCallback.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZADownloadOperationCallback.h"

@implementation ZADownloadOperationCallback

#pragma mark - LifeCycle

- (instancetype)initWithProgressBlock:(ZAProgressBlock)progressBlock
                     destinationBlock:(ZADestinationBlock)destinationBlock
                      completionBlock:(ZACompletionBlock)completionBlock {
    return [self initWithProgressBlock:progressBlock
                      destinationBlock:destinationBlock
                       completionBlock:completionBlock
                              priority:(ZAOperationPriorityMedium)];
}

- (instancetype)initWithProgressBlock:(ZAProgressBlock)progressBlock
                     destinationBlock:(ZADestinationBlock)destinationBlock
                      completionBlock:(ZACompletionBlock)completionBlock
                             priority:(ZAOperationPriority)priority {
    self = [super initWithOperationPriority:priority];
    if (self) {
        _progressBlock = progressBlock;
        _destinationBlock = destinationBlock;
        _completionBlock = completionBlock;
    }
    return self;
}

@end
