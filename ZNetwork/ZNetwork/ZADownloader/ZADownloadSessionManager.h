//
//  ZADownloadSessionManager.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZADownloadOperationCallback.h"
#import "ZADefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZADownloadSessionManager : NSObject <NSURLSessionDataDelegate>

+ (instancetype)sharedManager;

- (NSString *)downloadTaskFromURLString:(NSString *)urlString
                                headers:(nullable NSDictionary<NSString *, NSString *> *)header
                               priority:(ZAOperationPriority)priority
                          progressBlock:(ZAProgressBlock)progressBlock
                       destinationBlock:(ZADestinationBlock)destinationBlock
                        completionBlock:(ZACompletionBlock)completionBloc;

- (void)resumeDownloadTaskByIdentifier:(NSString *)identifier;
- (void)pauseDownloadTaskByIdentifier:(NSString *)identifier;
- (void)cancelDownloadTaskByIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
