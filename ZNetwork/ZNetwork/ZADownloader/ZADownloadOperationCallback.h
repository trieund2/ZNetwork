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
typedef NSURL * (^ZADestinationBlock)(NSURL *location, NSString *callBackIdentifier);
typedef void (^ZACompletionBlock)(NSURLResponse *response, NSError *error, NSString *callBackIdentifier);

@interface ZADownloadOperationCallback : ZAOperationCallback

@property (copy, readonly) ZAProgressBlock progressBlock;
@property (copy, readonly) ZADestinationBlock destinationBlock;
@property (copy, readonly) ZACompletionBlock completionBlock;

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock;

- (instancetype)initWithURL:(NSURL *)url
              progressBlock:(ZAProgressBlock)progressBlock
           destinationBlock:(ZADestinationBlock)destinationBlock
            completionBlock:(ZACompletionBlock)completionBlock
                   priority:(ZAOperationPriority)priority;

@end

NS_ASSUME_NONNULL_END
