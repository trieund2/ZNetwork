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
    return [self initByURL:url requestPolicy:requestPolicy priority:priority operationCallback:NULL];
}

- (instancetype)initByURL:(NSURL *)url
            requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                 priority:(ZAOperationPriority)priority
        operationCallback:(ZAOperationCallback *)callback {
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
        
        if (callback) {
            _runningOperations[callback.identifier] = callback;
        }
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

- (void)addOperationCallback:(ZAOperationCallback *)callback {
    if (nil == callback) { return; }
    
    if (callback.priority > self.priority) {
        _priority = callback.priority;
    }
    
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        ZA_LOCK(self.runningOperationsLock);
        self.runningOperations[callback.identifier] = callback;
        ZA_UNLOCK(self.runningOperationsLock);
    } else if (nil == self.task || self.task.state == NSURLSessionTaskStateCanceling) {
        ZA_LOCK(self.pausedOperationsLock);
        self.pausedOperations[callback.identifier] = callback;
        ZA_UNLOCK(self.pausedOperationsLock);
    }
}

- (void)pauseOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(self.runningOperationsLock);
    ZAOperationCallback *pauseOperationCallback = [self.runningOperations objectForKey:identifier];
    if (pauseOperationCallback == nil) {
        ZA_UNLOCK(self.runningOperationsLock);
        return;
    }
    [self.runningOperations removeObjectForKey:identifier];
    ZA_UNLOCK(self.runningOperationsLock);
    
    ZA_LOCK(self.pausedOperationsLock);
    self.pausedOperations[identifier] = pauseOperationCallback;
    ZA_UNLOCK(self.pausedOperationsLock);
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(self.runningOperationsLock);
    if ([self.runningOperations objectForKey:identifier]) {
        [self.runningOperations removeObjectForKey:identifier];
    } else {
        ZA_LOCK(self.pausedOperationsLock);
        if ([self.pausedOperations objectForKey:identifier]) {
            [self.pausedOperations removeObjectForKey:identifier];
        }
        ZA_UNLOCK(self.pausedOperationsLock);
    }
    ZA_UNLOCK(self.runningOperationsLock);
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(self.pausedOperationsLock);
    ZAOperationCallback *resumeOperationCallback = [self.pausedOperations objectForKey:identifier];
    if (nil == resumeOperationCallback) {
        ZA_UNLOCK(self.pausedOperationsLock);
        return;
    }
    ZA_UNLOCK(self.pausedOperationsLock);
    
    ZA_LOCK(self.runningOperationsLock);
    self.runningOperations[identifier] = resumeOperationCallback;
    ZA_UNLOCK(self.runningOperationsLock);
}

- (NSArray<ZAOperationCallback *> *)allRunningOperationCallback {
    ZA_LOCK(self.runningOperationsLock);
    NSArray<ZAOperationCallback *> *runningOperations = self.runningOperations.allValues.copy;
    ZA_UNLOCK(self.runningOperationsLock);
    return runningOperations;
}

@end
