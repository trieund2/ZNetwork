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
        runningOperationCallbacksLock = dispatch_semaphore_create(1);
        pausedOperationCallbacksLock = dispatch_semaphore_create(1);
        runningOperationCallbacks = [[NSMutableDictionary alloc] init];
        pausedOperationCallbacks = [[NSMutableDictionary alloc] init];
        
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
    
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        ZA_LOCK(runningOperationCallbacksLock);
        runningOperationCallbacks[callback.identifier] = callback;
        ZA_UNLOCK(runningOperationCallbacksLock);
    } else if (nil == self.task || self.task.state == NSURLSessionTaskStateCanceling) {
        ZA_LOCK(pausedOperationCallbacksLock);
        pausedOperationCallbacks[callback.identifier] = callback;
        ZA_UNLOCK(pausedOperationCallbacksLock);
    }
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
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(runningOperationCallbacksLock);
    if ([runningOperationCallbacks objectForKey:identifier]) {
        [runningOperationCallbacks removeObjectForKey:identifier];
    } else {
        ZA_LOCK(pausedOperationCallbacksLock);
        if ([pausedOperationCallbacks objectForKey:identifier]) {
            [pausedOperationCallbacks removeObjectForKey:identifier];
        }
        ZA_UNLOCK(pausedOperationCallbacksLock);
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZA_LOCK(pausedOperationCallbacksLock);
    ZAOperationCallback *resumeOperationCallback = [pausedOperationCallbacks objectForKey:identifier];
    if (nil == resumeOperationCallback) {
        ZA_UNLOCK(pausedOperationCallbacksLock);
        return;
    }
    ZA_UNLOCK(pausedOperationCallbacksLock);
    
    ZA_LOCK(runningOperationCallbacksLock);
    runningOperationCallbacks[identifier] = resumeOperationCallback;
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (NSArray<ZAOperationCallback *> *)allRunningOperationCallback {
    ZA_LOCK(runningOperationCallbacksLock);
    NSArray<ZAOperationCallback *> *returnValue = runningOperationCallbacks.allValues.copy;
    ZA_UNLOCK(runningOperationCallbacksLock);
    return returnValue;
}

- (void)removeOperationCallback:(ZAOperationCallback *)callback {
    ZA_LOCK(runningOperationCallbacksLock);
    
    if ([runningOperationCallbacks objectForKey:callback.identifier]) {
        [runningOperationCallbacks removeObjectForKey:callback.identifier];
        ZA_UNLOCK(runningOperationCallbacksLock);
        ZA_LOCK(pausedOperationCallbacksLock);
    } else if ([pausedOperationCallbacks objectForKey:callback.identifier]) {
        [pausedOperationCallbacks removeObjectForKey:callback.identifier];
    }
    ZA_UNLOCK(pausedOperationCallbacksLock);
}

@end
