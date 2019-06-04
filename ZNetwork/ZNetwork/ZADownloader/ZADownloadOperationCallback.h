//
//  ZADownloadOperationCallback.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAOperationCallback.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZAProgressBlock)(NSProgress *progress, NSString *callBackIdentifier);
typedef NSString * (^ZADestinationBlock)(NSString *location, NSString *callBackIdentifier);
typedef void (^ZACompletionBlock)(NSURLSessionTask *response, NSError *error, NSString *callBackIdentifier);

@interface ZADownloadOperationCallback : ZAOperationCallback

@property (nonatomic) BOOL canResume;
@property (nonatomic, copy, readonly) ZAProgressBlock progressBlock;
@property (nonatomic, copy, readonly) ZADestinationBlock destinationBlock;
@property (nonatomic, copy, readonly) ZACompletionBlock completionBlock;

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock;

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock
                   priority:(ZAOperationPriority)priority;

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock
                   priority:(ZAOperationPriority)priority
                requestPlicy:(NSURLRequestCachePolicy)requestPlicy;

@end

NS_ASSUME_NONNULL_END
