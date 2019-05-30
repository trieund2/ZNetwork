//
//  ZALocalTaskInfo.h
//  ZNetwork
//
//  Created by CPU12166 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAUserDefaultsManager.h"
#import "ZADefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZALocalTaskInfo : NSObject <NSSecureCoding>

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) ZAHTTPResponseAcceptRangesType acceptRangesType;
@property (assign, nonatomic) int64_t countOfBytesReceived;
@property (assign, nonatomic) NSURLSessionTaskState state;
@property (assign, nonatomic) NSURLRequestCachePolicy requestPolicy;

@end

NS_ASSUME_NONNULL_END
