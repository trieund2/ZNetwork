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
    
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        runningOperationCallbacks[callback.identifier] = callback;
    } else if (nil == self.task || self.task.state == NSURLSessionTaskStateCanceling) {
        pausedOperationCallbacks[callback.identifier] = callback;
    }
}

- (void)pauseOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZAOperationCallback *pauseOperationCallback = [runningOperationCallbacks objectForKey:identifier];
    if (pauseOperationCallback == nil) { return; }
    [runningOperationCallbacks removeObjectForKey:identifier];
    pausedOperationCallbacks[identifier] = pauseOperationCallback;
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    if ([runningOperationCallbacks objectForKey:identifier]) {
        [runningOperationCallbacks removeObjectForKey:identifier];
    } else if ([pausedOperationCallbacks objectForKey:identifier]) {
        [pausedOperationCallbacks removeObjectForKey:identifier];
    }
}

- (void)cancelAllOperations {
    [runningOperationCallbacks removeAllObjects];
    [pausedOperationCallbacks removeAllObjects];
    [self.task cancel];
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    if (nil == identifier) { return; }
    
    ZAOperationCallback *resumeOperationCallback = [pausedOperationCallbacks objectForKey:identifier];
    if (nil == resumeOperationCallback) { return; }
    runningOperationCallbacks[identifier] = resumeOperationCallback;
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

@end
