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

/**
 * @abstract Commit a local task info to temporary storage (still on mem).
 * @discussion If there isn't a need to save task info to local storage right away, use this to save on mem first.
 * @param taskInfo The task info to save.
 * @warning This is not saved to local storage yet.
 */
- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo;

/**
 * @abstract Push all task info currently on mem to local storage.
 * @discussion This might take a while list of task info is large.
 * @param completion Completion callback that receives error if there is one while saving data to local storage, nil if successful.
 */
- (void)pushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 * @abstract Commit a task info and push all task info commited previously to local storage.
 * @discussion This might take a while list of task info is large.
 * @param taskInfo The task info to save.
 * @param completion Completion callback that receives error if there is one while saving data to local storage, nil if successful.
 */
- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo andPushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 * @abstract Load all task info saved previously from local storage plus currently saved task info on mem.
 * @discussion This will get all task info from local st
 * @param completion Completion callback, check for error first if there is any while loading, if error is nil then data is loaded successfully.
 */
- (void)loadAllTaskInfo:(void (^)(NSDictionary * _Nullable dictionary, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
