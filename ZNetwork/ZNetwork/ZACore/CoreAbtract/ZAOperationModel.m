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

- (instancetype)initByURL:(NSURL *)url
            requestPolicy:(NSURLRequestCachePolicy)requestPolicy
                 priority:(ZAOperationPriority)priority {
    return [self initByURL:url requestPolicy:requestPolicy priority:priority operationCallback:nil];
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
        _task = nil;
        _status = ZASessionTaskStatusInitialized;
        runningOperationCallbacks = [[NSMutableDictionary alloc] init];
        runningOperationCallbacksLock = dispatch_semaphore_create(1);
        pausedOperationCallbacks = [[NSMutableDictionary alloc] init];
        pausedOperationCallbacksLock = dispatch_semaphore_create(1);
        
        if (callback) {
            runningOperationCallbacks[callback.identifier] = callback;
        }
    }
    return self;
}

#pragma mark - Interface method

- (NSUInteger)numberOfRunningOperation {
    ZA_LOCK(runningOperationCallbacksLock);
    NSUInteger count = runningOperationCallbacks.count;
    ZA_UNLOCK(runningOperationCallbacksLock);
    return count;
}

- (NSUInteger)numberOfPausedOperation {
    ZA_LOCK(pausedOperationCallbacksLock);
    NSUInteger count = pausedOperationCallbacks.count;
    ZA_UNLOCK(pausedOperationCallbacksLock);
    return count;
}

- (void)addOperationCallback:(ZAOperationCallback *)callback {
    if (nil == callback) { return; }
    
    if (callback.priority > self.priority) {
        _priority = callback.priority;
    }
    
    ZA_LOCK(runningOperationCallbacksLock);
    runningOperationCallbacks[callback.identifier] = callback;
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)pauseOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(runningOperationCallbacksLock);
    ZAOperationCallback *pauseOperationCallback = [runningOperationCallbacks objectForKey:identifier];
    if (pauseOperationCallback == nil) {
        ZA_UNLOCK(runningOperationCallbacksLock);
        return;
    }
    
    [runningOperationCallbacks removeObjectForKey:identifier];
    ZA_UNLOCK(runningOperationCallbacksLock);
    
    ZA_LOCK(pausedOperationCallbacksLock);
    pausedOperationCallbacks[identifier] = pauseOperationCallback;
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    if (self.numberOfRunningOperation == 0) {
        self.status = ZASessionTaskStatusPaused;
    }
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(runningOperationCallbacksLock);
    ZA_LOCK(pausedOperationCallbacksLock);
    
    if ([runningOperationCallbacks objectForKey:identifier]) {
        [runningOperationCallbacks removeObjectForKey:identifier];
    } else if ([pausedOperationCallbacks objectForKey:identifier]) {
        [pausedOperationCallbacks removeObjectForKey:identifier];
    }
    
    ZA_UNLOCK(runningOperationCallbacksLock);
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    if (self.numberOfRunningOperation == 0) {
        self.status = ZASessionTaskStatusCancelled;
    }
}

- (void)cancelAllOperations {
    ZA_LOCK(runningOperationCallbacksLock);
    [runningOperationCallbacks removeAllObjects];
    ZA_UNLOCK(runningOperationCallbacksLock);
    
    ZA_LOCK(pausedOperationCallbacksLock);
    [pausedOperationCallbacks removeAllObjects];
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    self.status = ZASessionTaskStatusCancelled;
    [self.task cancel];
}

- (void)pauseAllOperations {
    ZA_LOCK(runningOperationCallbacksLock);
    ZA_LOCK(pausedOperationCallbacksLock);
    
    [pausedOperationCallbacks addEntriesFromDictionary:runningOperationCallbacks];
    [runningOperationCallbacks removeAllObjects];
    
    ZA_UNLOCK(runningOperationCallbacksLock);
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    self.status = ZASessionTaskStatusPaused;
    [self.task cancel];
}

- (void)removePausedOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(pausedOperationCallbacksLock);
    [pausedOperationCallbacks removeObjectForKey:identifier];
    ZA_UNLOCK(pausedOperationCallbacksLock);
}

- (NSArray<ZAOperationCallback *> *)allRunningOperationCallbacks {
    ZA_LOCK(runningOperationCallbacksLock);
    NSArray<ZAOperationCallback *> *returnValue = runningOperationCallbacks.allValues.copy;
    ZA_UNLOCK(runningOperationCallbacksLock);
    
    return returnValue;
}

- (void)removeAllRunningOperations {
    ZA_LOCK(runningOperationCallbacksLock);
    [runningOperationCallbacks removeAllObjects];
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)pauseAllRunningOperations {
    ZA_LOCK(pausedOperationCallbacksLock);
    [pausedOperationCallbacks addEntriesFromDictionary:runningOperationCallbacks];
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    [self removeAllRunningOperations];
}

@end
