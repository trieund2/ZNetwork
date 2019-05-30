//
//  ZASessionStorage.h
//  ZNetwork
//
//  Created by CPU12166 on 5/30/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZALocalTaskInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZASessionStorage : NSObject

/* Make init private, use +sharedManager to get singleton instead */
- (instancetype)init NS_UNAVAILABLE;

/* Return a singleton */
+ (instancetype)sharedStorage;

- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo;

- (void)pushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo andPushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

- (void)loadAllTaskInfo:(void (^)(NSDictionary * _Nullable dictionary))handler;

@end

NS_ASSUME_NONNULL_END
