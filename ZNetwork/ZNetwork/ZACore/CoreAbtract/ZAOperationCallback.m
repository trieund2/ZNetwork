//
//  ZAOperationCallback.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationCallback.h"

@implementation ZAOperationCallback

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url operationPriority:(ZAOperationPriorityMedium)];
}

- (instancetype)initWithURL:(NSURL *)url operationPriority:(ZAOperationPriority)priority {
    self = [super init];
    if (self) {
        _identifier = NSUUID.UUID.UUIDString;
        _priority = priority;
        _url = url;
    }
    return self;
}

@end
