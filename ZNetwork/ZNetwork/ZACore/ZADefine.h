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

typedef NS_ENUM(NSInteger, ZASessionStorageErrorCode) {
    kErrorWhileEncodingTaskInfo = 101,
};

typedef NS_ENUM(NSInteger, ZAPerformOperationType) {
    ZAPerformOperationTypeFIFO,
    ZAPerformOperationTypeLIFO
};

typedef NS_ENUM(NSInteger, ZAOperationPriority) {
    ZAOperationPriorityVeryHigh,
    ZAOperationPriorityHigh,
    ZAOperationPriorityMedium,
    ZAOperationPriorityLow
};

typedef NS_ENUM(NSUInteger, ZAOperationPerformType) {
    ZAOperationPerformTypeSerial,
    ZAOperationPerformTypeConcurrency
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
