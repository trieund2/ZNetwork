//
//  ZADownloadOperationModel.m
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZADownloadOperationModel.h"

@implementation ZADownloadOperationModel

#pragma mark - Interface methods

- (void)addCurrentDownloadLenght:(NSUInteger)lenght {
    _completedUnitCount += lenght;
}

- (void)forwardProgress {
    NSProgress *progress = [[NSProgress alloc] init];
    progress.totalUnitCount = self.contentLength;
    progress.completedUnitCount = self.completedUnitCount;
    
    ZA_LOCK(runningOperationCallbacksLock);
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if (callbackId && [callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.progressBlock(progress, callbackId);
        }
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)forwardCompletion {
    
}

- (void)forwardDestination {
    
}

#pragma mark - Override methods

- (void)pauseOperationCallbackById:(NSString *)identifier {
    [super pauseOperationCallbackById: identifier];
    
    if (self.numberOfRunningOperation == 0) {
        [self.task cancel];
    }
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    [super cancelOperationCallbackById:identifier];
    
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    [super resumeOperationCallbackById:identifier];
    
}


@end
