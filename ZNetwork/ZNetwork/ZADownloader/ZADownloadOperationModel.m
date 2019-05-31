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
    progress.totalUnitCount = self.countOfTotalBytes;
    progress.completedUnitCount = self.completedUnitCount;
    
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
            downloadOperationCallback.completionBlock(self.task.response, self.task.error, callbackId);
        }
    }
}
- (void)forwarFileFromLocation:(NSURL *)url {
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            NSURL *destinationURL = downloadOperationCallback.destinationBlock(url, callbackId);
            if (destinationURL) {
                [NSFileManager.defaultManager copyItemAtURL:url toURL:destinationURL error:NULL];
            }
        }
    }
}

- (void)forwardError:(NSError *)error {
    for (NSString *callbackId in runningOperationCallbacks.allKeys) {
        ZAOperationCallback *callback = [runningOperationCallbacks objectForKey:callbackId];
        if ([callback isKindOfClass:ZADownloadOperationCallback.class]) {
            ZADownloadOperationCallback *downloadOperationCallback = (ZADownloadOperationCallback *)callback;
            downloadOperationCallback.completionBlock(self.task.response, error, callbackId);
        }
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
