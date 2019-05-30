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
    return [self initWithURL:url operationPriority:(ZAOperationPriorityMedium) requestPlicy:NSURLRequestUseProtocolCachePolicy];
}

- (instancetype)initWithURL:(NSURL *)url operationPriority:(ZAOperationPriority)priority {
    return [self initWithURL:url operationPriority:(priority) requestPlicy:NSURLRequestUseProtocolCachePolicy];
}

- (instancetype)initWithURL:(NSURL *)url
          operationPriority:(ZAOperationPriority)priority
                requestPlicy:(NSURLRequestCachePolicy)requestPolicy {
    self = [super init];
    if (self) {
        _identifier = NSUUID.UUID.UUIDString;
        _priority = priority;
        _url = url;
        _requestPolicy = requestPolicy;
    }
    return self;
}

@end
