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
        _task = nil;
        _status = ZASessionTaskStatusInitialized;
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
    return runningOperationCallbacks.count;
}

- (NSUInteger)numberOfPausedOperation {
    return pausedOperationCallbacks.count;
}

- (void)addOperationCallback:(ZAOperationCallback *)callback {
    if (nil == callback) { return; }
    
    if (callback.priority > self.priority) {
        _priority = callback.priority;
    }
    
    runningOperationCallbacks[callback.identifier] = callback;
}

- (void)pauseOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZAOperationCallback *pauseOperationCallback = [runningOperationCallbacks objectForKey:identifier];
    if (pauseOperationCallback == nil) { return; }
    [runningOperationCallbacks removeObjectForKey:identifier];
    pausedOperationCallbacks[identifier] = pauseOperationCallback;
    
    if (self.numberOfRunningOperation == 0) {
        self.status = ZASessionTaskStatusPaused;
    }
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    if ([runningOperationCallbacks objectForKey:identifier]) {
        [runningOperationCallbacks removeObjectForKey:identifier];
    } else if ([pausedOperationCallbacks objectForKey:identifier]) {
        [pausedOperationCallbacks removeObjectForKey:identifier];
    }
    
    if (self.numberOfRunningOperation == 0) {
        self.status = ZASessionTaskStatusCancelled;
    }
}

- (void)cancelAllOperations {
    [runningOperationCallbacks removeAllObjects];
    [pausedOperationCallbacks removeAllObjects];
    self.status = ZASessionTaskStatusCancelled;
    [self.task cancel];
}

- (void)pauseAllOperations {
    [pausedOperationCallbacks addEntriesFromDictionary:runningOperationCallbacks];
    [runningOperationCallbacks removeAllObjects];
    self.status = ZASessionTaskStatusPaused;
    [self.task cancel];
}

- (void)removePausedOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    [pausedOperationCallbacks removeObjectForKey:identifier];
}

- (NSArray<ZAOperationCallback *> *)allRunningOperationCallback {
    NSArray<ZAOperationCallback *> *returnValue = runningOperationCallbacks.allValues.copy;
    return returnValue;
}

- (void)removeOperationCallback:(ZAOperationCallback *)callback {
    if (nil == callback) { return; }
    
    if ([runningOperationCallbacks objectForKey:callback.identifier]) {
        [runningOperationCallbacks removeObjectForKey:callback.identifier];
    } else if ([pausedOperationCallbacks objectForKey:callback.identifier]) {
        [pausedOperationCallbacks removeObjectForKey:callback.identifier];
    }
}

- (void)removeAllRunningOperations {
    [runningOperationCallbacks removeAllObjects];
}

- (void)pauseAllRunningOperations {
    [pausedOperationCallbacks addEntriesFromDictionary:runningOperationCallbacks];
    [self removeAllRunningOperations];
}

@end
