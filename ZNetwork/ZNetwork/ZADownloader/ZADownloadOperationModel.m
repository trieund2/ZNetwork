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
    _alreadyDownloadLenght += lenght;
}

- (void)forwardProgress {
    
}

- (void)forwardCompletion {
    
}

- (void)forwardDestination {
    
}

#pragma mark - Override methods

- (void)pauseOperationCallbackById:(NSString *)identifier {
    [super pauseOperationCallbackById: identifier];
    
    if (self.numberOfRunningOperation == 0) {
        if (self.numberOfPausedOperation == 0) {
            
        } else {
            // TODO: - Perform cancel task and save file
            
        }
    }
}

- (void)cancelOperationCallbackById:(NSString *)identifier {
    [super cancelOperationCallbackById:identifier];
    
}

- (void)resumeOperationCallbackById:(NSString *)identifier {
    [super resumeOperationCallbackById:identifier];
    
}


@end
