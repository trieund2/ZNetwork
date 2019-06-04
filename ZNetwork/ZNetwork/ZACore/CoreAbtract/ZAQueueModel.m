//
//  ZAQueueModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAQueueModel.h"

@interface ZAQueueModel()

@property (nonatomic, readonly) NSUInteger currentRunningOperations;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *veryHighQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *highQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *mediumQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *lowQueue;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZAOperationModel *> *urlToOperationModel;

@end

@implementation ZAQueueModel

- (instancetype)init
{
    return [self initByOperationExecutionOrder:(ZAOperationExecutionOrderFIFO)
                               isMultiCallback:YES
                                   performType:(ZAOperationPerformTypeConcurrency)];
}

- (instancetype)initByOperationExecutionOrder:(ZAOperationExecutionOrder)operationType
                              isMultiCallback:(BOOL)isMultiCallback
                                  performType:(ZAOperationPerformType)performType {
    self = [super init];
    
    if (self) {
        _currentRunningOperations = 0;
        _executionOrder = operationType;
        _isMultiCallback = isMultiCallback;
        _performType = performType;
        _veryHighQueue = [[NSMutableArray alloc] init];
        _highQueue = [[NSMutableArray alloc] init];
        _mediumQueue = [[NSMutableArray alloc] init];
        _lowQueue = [[NSMutableArray alloc] init];
        _urlToOperationModel = [[NSMutableDictionary alloc] init];
        
        switch (_performType) {
            case ZAOperationPerformTypeSerial:
                _maxOperationPerform = 1;
                break;
            case ZAOperationPerformTypeConcurrency:
                _maxOperationPerform = 4;
                break;
        }
    }
    
    return self;
}

- (NSUInteger)numberOfTaskRunning {
    return self.currentRunningOperations;
}

- (NSUInteger)numberOfTaskInQueue {
    return self.urlToOperationModel.count;
}

- (void)resetNumberOfRunningOperations {
    _currentRunningOperations = 0;
}

- (void)enqueueOperation:(ZAOperationModel *)operationModel {
    if (NULL == operationModel && NULL != operationModel.url) { return; }
    
    if (self.isMultiCallback) {
        ZAOperationModel *currentOperationModel = [self.urlToOperationModel objectForKey:operationModel.url];
        
        if (currentOperationModel) {
            ZAOperationCallback *operationCallback = operationModel.allRunningOperationCallback.firstObject;
            if (nil == operationCallback) { return; }
            [currentOperationModel addOperationCallback:operationCallback];
            
            if (currentOperationModel.priority == operationModel.priority) { return; }
            
            switch (currentOperationModel.priority) {
                case ZAOperationPriorityVeryHigh:
                    [self.veryHighQueue removeObject:currentOperationModel];
                    break;
                case ZAOperationPriorityHigh:
                    [self.highQueue removeObject:currentOperationModel];
                    break;
                case ZAOperationPriorityMedium:
                    [self.mediumQueue removeObject:currentOperationModel];
                    break;
                case ZAOperationPriorityLow:
                    [self.lowQueue removeObject:currentOperationModel];
                    break;
            }
            
            currentOperationModel.priority = operationModel.priority;
            [self _addOperationToQueue:currentOperationModel];
            
        } else {
            [self _addOperationToQueue:operationModel];
            self.urlToOperationModel[operationModel.url] = operationModel;
        }
    } else {
        [self _addOperationToQueue:operationModel];
    }
}

- (BOOL)canDequeueOperationModel {
    return (self.currentRunningOperations < self.maxOperationPerform);
}

- (nullable ZAOperationModel *)dequeueOperationModel {
    if ([self canDequeueOperationModel]) {
        ZAOperationModel *operationModel = NULL;
        
        if (self.veryHighQueue.count > 0) {
            switch (self.executionOrder) {
                case ZAOperationExecutionOrderFIFO:
                    operationModel = self.veryHighQueue.firstObject;
                    [self.veryHighQueue removeObjectAtIndex:0];
                    break;
                case ZAOperationExecutionOrderLIFO:
                    operationModel = self.veryHighQueue.lastObject;
                    [self.veryHighQueue removeLastObject];
                    break;
            }
            
        } else if (self.highQueue.count > 0) {
            switch (self.executionOrder) {
                case ZAOperationExecutionOrderFIFO:
                    operationModel = self.highQueue.firstObject;
                    [self.highQueue removeObjectAtIndex:0];
                    break;
                case ZAOperationExecutionOrderLIFO:
                    operationModel = self.highQueue.lastObject;
                    [self.highQueue removeLastObject];
                    break;
            }
            
        } else if (self.mediumQueue.count > 0) {
            switch (self.executionOrder) {
                case ZAOperationExecutionOrderFIFO:
                    operationModel = self.mediumQueue.firstObject;
                    [self.mediumQueue removeObjectAtIndex:0];
                    break;
                case ZAOperationExecutionOrderLIFO:
                    operationModel = self.mediumQueue.lastObject;
                    [self.mediumQueue removeLastObject];
                    break;
            }
            
        } else if (self.lowQueue.count > 0) {
            switch (self.executionOrder) {
                case ZAOperationExecutionOrderFIFO:
                    operationModel = self.lowQueue.firstObject;
                    [self.lowQueue removeObjectAtIndex:0];
                    break;
                case ZAOperationExecutionOrderLIFO:
                    operationModel = self.lowQueue.lastObject;
                    [self.lowQueue removeLastObject];
                    break;
                    break;
            }
        }
        
        if (nil != operationModel && nil != operationModel.url) {
            _currentRunningOperations += 1;
            [self.urlToOperationModel removeObjectForKey:operationModel.url];
            return operationModel;
        }
    }
    
    return nil;
}

- (void)pauseOperationByCallback:(ZAOperationCallback *)callback {
    if (nil == callback || nil == callback.url) { return; }
    ZAOperationModel *operationModel = [self.urlToOperationModel objectForKey:callback.url];
    [operationModel removeOperationCallback:callback];
    
    if ([operationModel numberOfRunningOperation] == 0) {
        [self.urlToOperationModel removeObjectForKey:callback.url];
        
        switch (operationModel.priority) {
            case ZAOperationPriorityVeryHigh:
                [self.veryHighQueue removeObject:operationModel];
                break;
            case ZAOperationPriorityHigh:
                [self.highQueue removeObject:operationModel];
                break;
            case ZAOperationPriorityMedium:
                [self.mediumQueue removeObject:operationModel];
                break;
            case ZAOperationPriorityLow:
                [self.lowQueue removeObject:operationModel];
                break;
        }
    } else if (operationModel.priority == callback.priority) {
        [self.urlToOperationModel removeObjectForKey:callback.url];
        
        ZAOperationPriority newPriority = ZAOperationPriorityLow;;
        for (ZAOperationModel *currentOperationModel in operationModel.allRunningOperationCallback) {
            if (currentOperationModel.priority > newPriority) {
                newPriority = currentOperationModel.priority;
            }
        }
        if (newPriority > operationModel.priority) {
            switch (operationModel.priority) {
                case ZAOperationPriorityLow:
                    [self.lowQueue removeObject:operationModel];
                    break;
                    
                case ZAOperationPriorityMedium:
                    [self.mediumQueue removeObject:operationModel];
                    break;
                    
                case ZAOperationPriorityHigh:
                    [self.highQueue removeObject:operationModel];
                    break;
                    
                case ZAOperationPriorityVeryHigh:
                    [self.veryHighQueue removeObject:operationModel];
                    break;
            }
            
            operationModel.priority = newPriority;
            [self _addOperationToQueue:operationModel];
            
        }
    }
}

- (void)cancelOperationByCallback:(ZAOperationCallback *)callback {
    [self pauseOperationByCallback:callback];
}

- (void)operationDidFinish {
    if (_currentRunningOperations > 0) {
        _currentRunningOperations -= 1;
    }
}

- (void)removeAllOperations {
    [self.urlToOperationModel removeAllObjects];
    [self.highQueue removeAllObjects];
    [self.mediumQueue removeAllObjects];
    [self.lowQueue removeAllObjects];
}

#pragma mark - Private methods

- (void)_addOperationToQueue:(ZAOperationModel *)operationModel {
    if (nil == operationModel) { return; }
    
    switch (operationModel.priority) {
        case ZAOperationPriorityVeryHigh:
            [self.veryHighQueue addObject:operationModel];
            break;
        case ZAOperationPriorityHigh:
            [self.highQueue addObject:operationModel];
            break;
        case ZAOperationPriorityMedium:
            [self.mediumQueue addObject:operationModel];
            break;
        case ZAOperationPriorityLow:
            [self.lowQueue addObject:operationModel];
            break;
    }
}

@end
