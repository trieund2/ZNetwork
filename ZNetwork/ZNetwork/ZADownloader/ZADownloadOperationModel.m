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
    
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.progressBlock(progress, callbackId);
        }
    }
}

- (void)forwardCompletion {
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.completionBlock(self.task, self.task.error, callbackId);
        }
    }
}
- (void)forwardFileFromLocation {
    NSError *error;
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            NSString *destinationURLString = downloadOperationCallback.destinationBlock(self.filePath, callbackId);
            if (destinationURLString) {
                [NSFileManager.defaultManager copyItemAtPath:self.filePath toPath:destinationURLString error:&error];
                NSLog(@"error");
            }
        }
    }
}

- (void)forwardError:(NSError *)error {
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.completionBlock(self.task, error, callbackId);
        }
    }
}

- (void)updateResumeStatusForAllCallbacks {
    for (ZADownloadOperationCallback *downloadOperationCallback in runningOperationCallbacks.allValues) {
        downloadOperationCallback.canResume = self.canResume;
    }

    for (ZADownloadOperationCallback *downloadOperationCallback in pausedOperationCallbacks.allValues) {
        downloadOperationCallback.canResume = self.canResume;
    }
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
