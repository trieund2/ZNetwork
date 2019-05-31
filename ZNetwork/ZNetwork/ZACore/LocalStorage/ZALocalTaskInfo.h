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

/* @warning Careful when edit property because NSUserDefaults only support property list type, urlString is a must because it is the key to identify task info
 */
@property (strong, nonatomic, readonly) NSString *urlString;
@property (strong, nonatomic, readonly) NSString *filePath;
@property (strong, nonatomic, readonly) NSString *fileName;
@property (strong, nonatomic) NSDate *lastTimeModified;
@property (assign, nonatomic) ZAHTTPResponseAcceptRangesType acceptRangesType;
@property (assign, nonatomic) int64_t countOfBytesReceived;
@property (assign, nonatomic) int64_t countOfTotalBytes;
@property (assign, nonatomic) NSURLSessionTaskState state;
@property (assign, nonatomic, readonly) NSURLRequestCachePolicy requestCachePolicy;

- (instancetype)initWithURLString:(NSString *)urlString
                         filePath:(NSString *)filePath
                         fileName:(NSString *)fileName;

- (instancetype)initWithURLString:(NSString *)urlString
                         filePath:(NSString *)filePath
                         fileName:(NSString *)fileName
               requestCachePolicy:(NSURLRequestCachePolicy)requestCachePolicy;

@end

NS_ASSUME_NONNULL_END
