//
//  ZADownloadOperationCallback.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZADownloadOperationCallback.h"

@implementation ZADownloadOperationCallback

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock {
    return [self initWithURL:url
               progressBlock:progressBlock
            destinationBlock:destinationBlock
             completionBlock:completionBlock
                    priority:(ZAOperationPriorityMedium)];
}

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock
                   priority:(ZAOperationPriority)priority {
    self = [super initWithURL:url operationPriority:priority];
    if (self) {
        _progressBlock = progressBlock;
        _destinationBlock = destinationBlock;
        _completionBlock = completionBlock;
    }
    return self;
}

@end
