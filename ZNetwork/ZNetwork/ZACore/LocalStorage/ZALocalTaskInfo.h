//
//  ZALocalTaskInfo.h
//  ZNetwork
//
//  Created by CPU12166 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAUserDefaultsManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZALocalTaskInfo : NSObject <NSSecureCoding, NSCopying>

/* @warning Careful when edit property because NSUserDefaults only support property list type, urlString is a must because it is the key to identify task info
 */

/* URL String of the task */
@property (strong, nonatomic, readonly) NSString *urlString;
/* Path where the task's file is being saved to */
@property (strong, nonatomic, readonly) NSString *filePath;
/* Name of the task's file */
@property (strong, nonatomic, readonly) NSString *fileName;
/* Last time the task was modified, ex: newly created, progress updated. This field is for management purpose, ex: delete file after a specific time */
@property (strong, nonatomic, readonly) NSDate *lastTimeModified;
/* Accept-Ranges type of the task, see `ZAHTTPResponseAcceptRangesType` */
@property (assign, nonatomic) ZAHTTPResponseAcceptRangesType acceptRangesType;
/* Count of bytes received by the task */
@property (assign, nonatomic) int64_t countOfBytesReceived;
/* Count of total bytes of the task's file to download */
@property (assign, nonatomic) int64_t countOfTotalBytes;
/* State of the task */
@property (assign, nonatomic) NSURLSessionTaskState state;

- (instancetype)initWithURLString:(NSString *)urlString
                         filePath:(NSString *)filePath
                         fileName:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
