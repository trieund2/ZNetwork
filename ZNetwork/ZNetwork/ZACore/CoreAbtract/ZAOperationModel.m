//
//  ZAOperationModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationModel.h"

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
        runningOperationsLock = dispatch_semaphore_create(1);
        pausedOperationsLock = dispatch_semaphore_create(1);
        runningOperations = [[NSMutableDictionary alloc] init];
        pausedOperations = [[NSMutableDictionary alloc] init];
        
        if (callback) {
            runningOperations[callback.identifier] = callback;
        }
    }
    return self;
}

#pragma mark - Interface method

- (NSUInteger)numberOfRunningOperation {
    ZA_LOCK(runningOperationsLock);
    NSUInteger count = runningOperations.count;
    ZA_UNLOCK(runningOperationsLock);
    return count;
}

- (NSUInteger)numberOfPausedOperation {
    ZA_LOCK(pausedOperationsLock);
    NSUInteger count = pausedOperations.count;
    ZA_UNLOCK(pausedOperationsLock);
    return count;
}

- (void)addOperationCallback:(ZAOperationCallback *)callback {
    if (nil == callback) { return; }
    
    if (callback.priority > self.priority) {
        _priority = callback.priority;
    }
    
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        ZA_LOCK(runningOperationsLock);
        runningOperations[callback.identifier] = callback;
        ZA_UNLOCK(runningOperationsLock);
    } else if (nil == self.task || self.task.state == NSURLSessionTaskStateCanceling) {
        ZA_LOCK(pausedOperationsLock);
        pausedOperations[callback.identifier] = callback;
        ZA_UNLOCK(pausedOperationsLock);
    }
}

- (void)pauseOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(runningOperationsLock);
    ZAOperationCallback *pauseOperationCallback = [runningOperations objectForKey:identifier];
    if (pauseOperationCallback == nil) {
        ZA_UNLOCK(runningOperationsLock);
        return;
    }
    [runningOperations removeObjectForKey:identifier];
    ZA_UNLOCK(runningOperationsLock);
    
    ZA_LOCK(pausedOperationsLock);
    pausedOperations[identifier] = pauseOperationCallback;
    ZA_UNLOCK(pausedOperationsLock);
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(runningOperationsLock);
    if ([runningOperations objectForKey:identifier]) {
        [runningOperations removeObjectForKey:identifier];
    } else {
        ZA_LOCK(pausedOperationsLock);
        if ([pausedOperations objectForKey:identifier]) {
            [pausedOperations removeObjectForKey:identifier];
        }
        ZA_UNLOCK(pausedOperationsLock);
    }
    ZA_UNLOCK(runningOperationsLock);
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(pausedOperationsLock);
    ZAOperationCallback *resumeOperationCallback = [pausedOperations objectForKey:identifier];
    if (nil == resumeOperationCallback) {
        ZA_UNLOCK(pausedOperationsLock);
        return;
    }
    ZA_UNLOCK(pausedOperationsLock);
    
    ZA_LOCK(runningOperationsLock);
    runningOperations[identifier] = resumeOperationCallback;
    ZA_UNLOCK(runningOperationsLock);
}

- (NSArray<ZAOperationCallback *> *)allRunningOperationCallback {
    ZA_LOCK(runningOperationsLock);
    NSArray<ZAOperationCallback *> *returnValue = runningOperations.allValues.copy;
    ZA_UNLOCK(runningOperationsLock);
    return returnValue;
}

@end
