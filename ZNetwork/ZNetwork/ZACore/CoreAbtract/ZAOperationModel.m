//
//  ZAOperationModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationModel.h"

@interface ZAOperationModel ()

@property (nonatomic, readonly) dispatch_semaphore_t runningOperationsLock;
@property (nonatomic, readonly) dispatch_semaphore_t pausedOperationsLock;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, ZAOperationCallback *> *runningOperations;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, ZAOperationCallback *> *pausedOperations;

@end

#pragma mark -

@implementation ZAOperationModel

#pragma mark - LifeCycle

- (instancetype)initByURL:(NSURL *)url {
    return [self initByURL:url requestPolicy:NSURLRequestUseProtocolCachePolicy priority:(ZAOperationPriorityMedium)];
}

- (instancetype)initByURL:(NSURL *)url requestPolicy:(NSURLRequestCachePolicy)requestPolicy priority:(ZAOperationPriority)priority {
    self = [super init];
    if (self) {
        _url = url;
        _requestPolicy = requestPolicy;
        _priority = priority;
        _task = NULL;
        _runningOperationsLock = dispatch_semaphore_create(1);
        _pausedOperationsLock = dispatch_semaphore_create(1);
        _runningOperations = [[NSMutableDictionary alloc] init];
        _pausedOperations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Interface method

- (NSUInteger)numberOfRunningOperation {
    ZA_LOCK(self.runningOperationsLock);
    NSUInteger count = self.runningOperations.count;
    ZA_UNLOCK(self.runningOperationsLock);
    return count;
}

- (NSUInteger)numberOfPausedOperation {
    ZA_LOCK(self.pausedOperationsLock);
    NSUInteger count = self.pausedOperations.count;
    ZA_UNLOCK(self.pausedOperationsLock);
    return count;
}

@end
