//
//  ZADownloadOperationModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationModel.h"
#import "ZADownloadOperationCallback.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZADownloadOperationModel : ZAOperationModel

@property (nonatomic) BOOL canResume;
@property (nonatomic) NSUInteger countOfTotalBytes;
@property (nonatomic) NSUInteger countOfBytesReceived;
@property (nonatomic) NSOutputStream *outputStream;
@property (nonatomic) NSString *filePath;

- (void)updateCountOfBytesReceived:(NSUInteger)lenght;
- (void)forwardProgress;
- (void)forwardCompletion;
- (void)forwardError:(NSError *)error;
- (void)forwarFileFromLocation;
- (void)updateResumeStatusForAllCallbacks;

@end

NS_ASSUME_NONNULL_END
