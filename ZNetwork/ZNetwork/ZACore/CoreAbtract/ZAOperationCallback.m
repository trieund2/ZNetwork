//
//  ZAOperationCallback.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationCallback.h"

@implementation ZAOperationCallback

- (instancetype)init
{
    return [self initWithOperationPriority:ZAOperationPriorityMedium];
}

- (instancetype)initWithOperationPriority:(ZAOperationPriority)priority {
    self = [super init];
    if (self) {
        _identifier = NSUUID.UUID.UUIDString;
        _priority = priority;
    }
    return self;
}

@end
