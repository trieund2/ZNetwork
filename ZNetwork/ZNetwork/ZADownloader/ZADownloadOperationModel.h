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

@property (nonatomic) NSUInteger contentLength;
@property (nonatomic, readonly) NSUInteger completedUnitCount;

- (void)addCurrentDownloadLenght:(NSUInteger)lenght;
- (void)forwardProgress;
- (void)forwardCompletion;

@end

NS_ASSUME_NONNULL_END
