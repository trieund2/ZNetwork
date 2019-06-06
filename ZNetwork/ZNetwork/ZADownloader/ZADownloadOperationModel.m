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

- (void)updateCountOfBytesReceived:(NSUInteger)lenght {
    _countOfBytesReceived += lenght;
}

- (void)forwardProgress {
    NSProgress *progress = [[NSProgress alloc] init];
    progress.totalUnitCount = self.countOfTotalBytes;
    progress.completedUnitCount = self.countOfBytesReceived;
    
    ZA_LOCK(runningOperationCallbacksLock);
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.progressBlock(progress, callbackId);
        }
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)forwardCompletion {
    ZA_LOCK(runningOperationCallbacksLock);
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.completionBlock(self.task, self.task.error, callbackId);
        }
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}
- (void)forwardFileFromLocation {
    ZA_LOCK(runningOperationCallbacksLock);
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            NSString *destinationURLString = downloadOperationCallback.destinationBlock(self.filePath, callbackId);
            if (destinationURLString) {
                [NSFileManager.defaultManager copyItemAtPath:self.filePath toPath:destinationURLString error:nil];
            }
        }
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)forwardError:(NSError *)error {
    ZA_LOCK(runningOperationCallbacksLock);
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.completionBlock(self.task, error, callbackId);
        }
    }
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)forwardURLResponse:(NSURLResponse *)response {
    ZA_LOCK(runningOperationCallbacksLock);
    
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            if (downloadOperationCallback.reciveURLSessionResponseBlock && self.task) {
                downloadOperationCallback.reciveURLSessionResponseBlock(self.task, response);
            }
        }
    }
    
    ZA_UNLOCK(runningOperationCallbacksLock);
}

- (void)updateResumeStatusForAllCallbacks {
    ZA_LOCK(runningOperationCallbacksLock);
    for (ZADownloadOperationCallback *downloadOperationCallback in runningOperationCallbacks.allValues) {
        downloadOperationCallback.canResume = self.canResume;
    }
    ZA_UNLOCK(runningOperationCallbacksLock);

    ZA_LOCK(pausedOperationCallbacksLock);
    for (ZADownloadOperationCallback *downloadOperationCallback in pausedOperationCallbacks.allValues) {
        downloadOperationCallback.canResume = self.canResume;
    }
    ZA_UNLOCK(pausedOperationCallbacksLock);
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
    if (self.numberOfRunningOperation == 0) {
        [self.task cancel];
    }
}

@end
