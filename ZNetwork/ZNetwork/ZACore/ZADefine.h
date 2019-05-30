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

typedef NS_ENUM(NSInteger, ZAPerformOperationType) {
    ZAPerformOperationTypeFIFO,
    ZAPerformOperationTypeLIFO
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

#pragma mark - Define Macro

#ifndef ZA_LOCK
#define ZA_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef ZA_UNLOCK
#define ZA_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

#endif /* ZDefine_h */
