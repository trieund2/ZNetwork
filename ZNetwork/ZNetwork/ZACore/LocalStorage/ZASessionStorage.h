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
 * @abstract Get a copy of task info by url string.
 * @param urlString The url string to search for.
 * @return A ZALocalTaskInfo object or nil if no object is found.
 */
- (ZALocalTaskInfo * _Nullable)getTaskInfoByURLString:(NSString *)urlString;

/**
 * @abstract Check whether a task info is already existed by its url string.
 * @param urlString The url string to search for.
 * @return A boolean indicates existence of the task info.
 */
- (BOOL)containsTaskInfo:(NSString *)urlString;

/**
 * @abstract Return number of task info are being saved on mem.
 * @discussion The number is only total of task info on mem, there might be some other in local storage.
 */
- (NSUInteger)countOfTaskInfo;

/**
 * @abstract Commit a local task info to temporary storage (still on mem).
 * @discussion If there isn't a need to save task info to local storage right away, use this to save on mem first.
 * @param taskInfo The task info to save.
 * @warning This is not saved to local storage yet.
 */
- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo;

/**
 * @abstract Update count of bytes received by a task.
 * @discussion If no task info is found, then nothing happens.
 * @param amount The number of bytes to add up to current count of bytes received.
 */
- (void)updateCountOfBytesReceived:(int64_t)amount byURLString:(NSString *)urlString;

/**
 * @abstract Update count of total bytes of a task.
 * @discussion If no task info is found, then nothing happens.
 * @param count The new number of total bytes.
 */
- (void)updateCountOfTotalBytes:(int64_t)count byURLString:(NSString *)urlString;

/**
 * @abstract Push all task info currently on mem to local storage.
 * @discussion This might take a while list of task info is large.
 * @param completion Completion callback that receives error if there is one while saving data to local storage, nil if successful.
 */
- (void)pushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 * @abstract Commit a task info and push all task info commite  d previously to local storage.
 * @discussion This might take a while list of task info is large.
 * @param taskInfo The task info to save.
 * @param completion Completion callback that receives error if there is one while saving data to local storage, nil if successful.
 */
- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo andPushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion;

/**
 * @abstract Remove a task info from dictionary and its file on disk.
 * @discussion Task info dictionary will be updated to disk on the next time pushing.
 * @param urlString The url string of task info to remove.
 * @param completion Completion callback that receives error if there is one while removing file from disk.
 */
- (void)removeTaskInfoByURLString:(NSString *)urlString completion:(nullable void (^)(NSError * _Nullable))completion;

/**
 * @abstract Load all task info from local storage to mem.
 * @discussion This might take a while if task info list in local storage is large.
 * @param completion Completion callback that receives error if there is one while loading.
 */
- (void)loadAllTaskInfo:(void (^)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
