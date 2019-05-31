//
//  ZAQueueModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAQueueModel.h"

@interface ZAQueueModel()

@property (nonatomic, readonly) NSUInteger currentOperationRunning;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *veryHighQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *highQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *mediumQueue;
@property (nonatomic, readonly) NSMutableArray<ZAOperationModel *> *lowQueue;
@property (nonatomic, readonly) NSMutableDictionary<NSURL *, ZAOperationModel *> *urlToOperationModel;

@end

@implementation ZAQueueModel

- (instancetype)init
{
    return [self initByPerformOperationType:(ZAPerformOperationTypeFIFO)
                            isMultiCallback:YES
                                performType:(ZAOperationPerformTypeConcurrency)];
}

- (instancetype)initByPerformOperationType:(ZAPerformOperationType)operationType
                           isMultiCallback:(BOOL)isMultiCallback
                               performType:(ZAOperationPerformType)performType {
    self = [super init];
    
    if (self) {
        _currentOperationRunning = 0;
        _queueType = operationType;
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
    return (self.currentOperationRunning < self.maxOperationPerform);
}

- (nullable ZAOperationModel *)dequeueOperationModel {
    if ([self canDequeueOperationModel]) {
        ZAOperationModel *operationModel = NULL;
        
        if (self.veryHighQueue.count > 0) {
            switch (self.queueType) {
                case ZAPerformOperationTypeFIFO:
                    operationModel = self.veryHighQueue.firstObject;
                    [self.veryHighQueue removeObjectAtIndex:0];
                    break;
                case ZAPerformOperationTypeLIFO:
                    operationModel = self.veryHighQueue.lastObject;
                    [self.veryHighQueue removeLastObject];
                    break;
            }
        }
        
        if (self.highQueue.count > 0) {
            switch (self.queueType) {
                case ZAPerformOperationTypeFIFO:
                    operationModel = self.highQueue.firstObject;
                    [self.highQueue removeObjectAtIndex:0];
                    break;
                case ZAPerformOperationTypeLIFO:
                    operationModel = self.highQueue.lastObject;
                    [self.highQueue removeLastObject];
                    break;
            }
        }
        
        if (self.mediumQueue.count > 0) {
            switch (self.queueType) {
                case ZAPerformOperationTypeFIFO:
                    operationModel = self.mediumQueue.firstObject;
                    [self.mediumQueue removeObjectAtIndex:0];
                    break;
                case ZAPerformOperationTypeLIFO:
                    operationModel = self.mediumQueue.lastObject;
                    [self.mediumQueue removeLastObject];
                    break;
            }
        }
        
        if (self.lowQueue.count > 0) {
            switch (self.queueType) {
                case ZAPerformOperationTypeFIFO:
                    operationModel = self.lowQueue.firstObject;
                    [self.lowQueue removeObjectAtIndex:0];
                    break;
                case ZAPerformOperationTypeLIFO:
                    operationModel = self.lowQueue.lastObject;
                    [self.lowQueue removeLastObject];
                    break;
                    break;
            }
        }
        
        _currentOperationRunning += 1;
        if (nil != operationModel && nil != operationModel.url) {
             [self.urlToOperationModel removeObjectForKey:operationModel.url];
        }
       
        return operationModel;
    } else {
        return NULL;
    }
}

- (void)pauseOperationByCallback:(ZAOperationCallback *)callback {
    ZAOperationModel *operationModel = [self.urlToOperationModel objectForKey:callback.url];
    [operationModel removeOperationCallback:callback];
}

- (void)cancelOperationByCallback:(ZAOperationCallback *)callback {
    ZAOperationModel *operationModel = [self.urlToOperationModel objectForKey:callback.url];
    [operationModel removeOperationCallback:callback];
}

- (void)operationDidFinish {
    if (_currentOperationRunning > 0) {
        _currentOperationRunning -= 1;
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

- (void)_removeURLToOperationItemByURL:(NSURL *)url {
    if (nil == url) { return; }
    [self.urlToOperationModel removeObjectForKey:url];
}

@end
