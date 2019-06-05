//
//  ZASessionStorage.m
//  ZNetwork
//
//  Created by CPU12166 on 5/30/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZASessionStorage.h"
#import "ZAUserDefaultsManager.h"

NSString * const KeyForTaskInfoDictionary = @"TaskInfoDictionary";

@interface ZASessionStorage ()

@property (strong, nonatomic) NSMutableDictionary *taskInfoKeyedByURLString;
@property (strong, nonatomic) dispatch_semaphore_t taskInfoLock;

@end

@implementation ZASessionStorage

+ (instancetype)sharedStorage {
    static ZASessionStorage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] initSingleton];
    });
    return sharedStorage;
}

- (instancetype)initSingleton {
    if (self = [super init]) {
        self.taskInfoKeyedByURLString = [NSMutableDictionary dictionary];
        self.taskInfoLock = dispatch_semaphore_create(1);
        [self loadAllTaskInfo:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"error: %@", error);
            }
        }];
    }
    return self;
}

- (NSUInteger)numberOfTaskInfo {
    ZA_LOCK(self.taskInfoLock);
    NSUInteger count = self.taskInfoKeyedByURLString.count;
    ZA_UNLOCK(self.taskInfoLock);
    return count;
}

- (ZALocalTaskInfo * _Nullable)getTaskInfoByURLString:(NSString *)urlString {
    ZALocalTaskInfo *taskInfo = [self _getTaskInfoByURLString:urlString];
    if (taskInfo) {
        return [taskInfo copy];
    } else {
        return nil;
    }
}

- (BOOL)containsTaskInfo:(NSString *)urlString {
    return (nil != [self _getTaskInfoByURLString:urlString]);
}

- (ZALocalTaskInfo * _Nullable)_getTaskInfoByURLString:(NSString *)urlString {
    ZA_LOCK(self.taskInfoLock);
    ZALocalTaskInfo *taskInfo = [self.taskInfoKeyedByURLString objectForKey:urlString];
    ZA_UNLOCK(self.taskInfoLock);
    return taskInfo;
}

- (NSUInteger)countOfTaskInfo {
    return self.taskInfoKeyedByURLString.count;
}

- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo {
#if DEBUG
    NSAssert(taskInfo && taskInfo.urlString, @"ZASessionStorage commitTaskInfo: TaskInfo urlString must not be nil");
#endif
    if (nil == taskInfo || nil == taskInfo.urlString) { return; }
    
    ZA_LOCK(self.taskInfoLock);
    [self.taskInfoKeyedByURLString setObject:taskInfo forKey:taskInfo.urlString];
    ZA_UNLOCK(self.taskInfoLock);
}

- (void)pushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable error))completion {
    ZA_LOCK(self.taskInfoLock);
    NSArray *allTaskInfo = self.taskInfoKeyedByURLString.allValues;
    ZA_UNLOCK(self.taskInfoLock);
    
    /* Create semaphore to wait for all ZALocalTaskInfo in dictionary to be encoded to data */
    NSMutableDictionary<NSString *, NSData *> *encodedDict = [NSMutableDictionary dictionary];
    dispatch_semaphore_t encodedDictLock = dispatch_semaphore_create(1);
    NSError *error = nil;
    for (ZALocalTaskInfo *taskInfo in allTaskInfo) {
        NSError *err = nil;
        NSData *data = [[ZAUserDefaultsManager sharedManager] encodeObjectToData:taskInfo error:&err];
        if (err) {
            error = err;
            break;
        } else {
            ZA_LOCK(encodedDictLock);
            [encodedDict setObject:[NSData dataWithData:data] forKey:taskInfo.urlString];
            ZA_UNLOCK(encodedDictLock);
        }
    }
    /* If there is an error while encoding, return it.
     * If all are successfully encoded to data, push encoded dictionary to local storage
     */
    if (error) {
        NSError *uxError = [NSError errorWithDomain:ZASessionStorageErrorDomain code:kErrorWhileEncodingTaskInfo userInfo:nil];
        completion(uxError);
    } else {
        NSError *err = nil;
        [[ZAUserDefaultsManager sharedManager] saveObject:encodedDict withKey:KeyForTaskInfoDictionary error:&err];
        completion(err);
    }
}

- (void)updateCountOfBytesReceived:(int64_t)amount byURLString:(NSString *)urlString {
    ZALocalTaskInfo *taskInfo = [self _getTaskInfoByURLString:urlString];
    if (taskInfo) {
        taskInfo.countOfBytesReceived += amount;
    }
}

- (void)updateCountOfTotalBytes:(int64_t)count byURLString:(NSString *)urlString {
    ZALocalTaskInfo *taskInfo = [self _getTaskInfoByURLString:urlString];
    if (taskInfo) {
        taskInfo.countOfTotalBytes = count;
    }
}

- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo andPushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable))completion {
    [self commitTaskInfo:taskInfo];
    [self pushAllTaskInfoWithCompletion:completion];
}

- (void)loadAllTaskInfo:(void (^)(NSError * _Nullable))completion {
    NSError *error = nil;
    NSDictionary *taskInfoDictionary = [[ZAUserDefaultsManager sharedManager] loadObjectOfClass:[NSDictionary class] withKey:KeyForTaskInfoDictionary error:&error];
    /* If there is an error loading task info dictionary, return it */
    if (error) {
        completion(error);
        return;
    }
    /* Dispatch group to concurrently decode all data in dictionary to ZALocalTaskInfo */
    NSMutableDictionary *decodedDict = [NSMutableDictionary dictionary];
    dispatch_semaphore_t decodedDictLock = dispatch_semaphore_create(1);
    
    for (NSData *data in taskInfoDictionary.allValues) {
        NSError *err = nil;
        ZALocalTaskInfo *taskInfo = [[ZAUserDefaultsManager sharedManager] decodeObjectOfClass:[ZALocalTaskInfo class] fromData:data error:&err];
        if (err) {
            error = err;
        } else {
            ZA_LOCK(decodedDictLock);
            [decodedDict setObject:taskInfo forKey:taskInfo.urlString];
            ZA_UNLOCK(decodedDictLock);
        }
    }
    /* If there is an error while decoding, return it.
     * If all are successfully decoded to ZALocalTaskInfo, add them to current task info on mem
     */
    if (error) {
        NSError *uxError = [NSError errorWithDomain:ZASessionStorageErrorDomain code:kErrorWhileDecodingTaskInfo userInfo:nil];
        completion(uxError);
    } else {
        ZA_LOCK(self.taskInfoLock);
        [self.taskInfoKeyedByURLString addEntriesFromDictionary:decodedDict];
        ZA_UNLOCK(self.taskInfoLock);
        completion(nil);
    }
}

- (void)removeTaskInfoByURLString:(NSString *)urlString completion:(void (^)(NSError * _Nullable))completion {
    ZALocalTaskInfo *taskInfo = [self _getTaskInfoByURLString:urlString];
    if (nil == taskInfo) {
        if (completion) { completion(nil); }
        return;
    }
    if (taskInfo.filePath) {
        [self _removeFileAtPath:taskInfo.filePath completion:^(NSError * _Nullable error) {
            if (error) {
                if (completion) { completion(error); }
            } else {
                [self.taskInfoKeyedByURLString removeObjectForKey:urlString];
                if (completion) { completion(nil); }
            }
        }];
    } else {
        [self.taskInfoKeyedByURLString removeObjectForKey:urlString];
        if (completion) { completion(nil); }
    }
}

- (void)_removeFileAtPath:(NSString *)filePath completion:(void (^)(NSError * _Nullable))completion {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    completion(error);
}

@end
