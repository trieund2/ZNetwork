//
//  ZADownloadOperationModel.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZADownloadOperationModel : ZAOperationModel

@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

NS_ASSUME_NONNULL_END
