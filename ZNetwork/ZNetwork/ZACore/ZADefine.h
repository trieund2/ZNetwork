//
//  ZADefine.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#ifndef ZDefine_h
#define ZDefine_h

#import <Foundation/Foundation.h>

#define ZASessionStorageErrorDomain @"com.trieund.ZNetwork.sessionStorageError"
#define ZARequestAcceptRangeBytes @"bytes"
#define ZARequestAcceptRangeNone @"none"

typedef NS_ENUM(NSInteger, ZASessionStorageErrorCode) {
    kErrorWhileEncodingTaskInfo = 101,
    kErrorWhileDecodingTaskInfo = 102
};

typedef NS_ENUM(NSUInteger, ZANetworkError) {
    ZANetworkErrorFullDisk              = 9981,
    ZANetworkErrorFileError             = 9982,
    ZANetworkErrorAppEnterBackground    = 9983
};

typedef NS_ENUM(NSInteger, ZAOperationExecutionOrder) {
    ZAOperationExecutionOrderFIFO,
    ZAOperationExecutionOrderLIFO
};

typedef NS_ENUM(NSInteger, ZAOperationPriority) {
    ZAOperationPriorityVeryHigh     = 4,
    ZAOperationPriorityHigh         = 3,
    ZAOperationPriorityMedium       = 2,
    ZAOperationPriorityLow          = 1
};

typedef NS_ENUM(NSUInteger, ZAOperationPerformType) {
    ZAOperationPerformTypeSerial,
    ZAOperationPerformTypeConcurrency
};

typedef NS_ENUM(NSInteger, ZASessionTaskStatus) {
    // Status when task has just been initialized.
    ZASessionTaskStatusInitialized  = 0,
    // Status when task runs.
    ZASessionTaskStatusRunning      = 1,
    // Status when task is paused, might be resumed later.
    ZASessionTaskStatusPaused       = 2,
    // Status when task is cancelled, can not be resumed later.
    ZASessionTaskStatusCancelled    = 3,
    // Status when task successful
    ZASessionTaskStatusSuccessed    = 4,
    // Status when task Failed
    ZASessionTaskStatusFailed       = 5
};

typedef NS_ENUM(NSInteger, ZAHTTPResponseAcceptRangesType) {
    // HTTP Response does not support request by range
    ZAHTTPResponseAcceptRangesTypeNone = 0,
    // HTTP Response supports request by range `bytes` (ex: Range: bytes=0-10000 for 10000 first bytes)
    ZAHTTPResponseAcceptRangesTypeBytes = 1
};


#pragma mark - Define Macro

#ifndef ZA_LOCK
#define ZA_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef ZA_UNLOCK
#define ZA_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

#endif /* ZDefine_h */
