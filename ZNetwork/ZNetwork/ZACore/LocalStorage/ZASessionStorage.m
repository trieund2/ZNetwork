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
    }
    return self;
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
    
    /* Dispatch group to concurrently encode all ZALocalTaskInfo in dictionary to data */
    NSMutableDictionary *encodedDict = [NSMutableDictionary dictionary];
    dispatch_semaphore_t encodedDictLock = dispatch_semaphore_create(1);
    __block NSError *err = nil;
    dispatch_group_t group = dispatch_group_create();
    for (ZALocalTaskInfo *taskInfo in allTaskInfo) {
        [ZAUserDefaultsManager.sharedManager encodeObjectToData:taskInfo completion:^(NSData * _Nullable data, NSError * _Nullable error) {
            dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                if (error) {
                    err = error;
                } else {
                    ZA_LOCK(encodedDictLock);
                    [encodedDict setObject:data forKey:taskInfo.urlString];
                    ZA_UNLOCK(encodedDictLock);
                }
            });
        }];
    }
    /* If there is an error while encoding, return it.
     * If all are successfully encoded to data, push encoded dictionary to local storage and mark pushing task info NO
     */
    dispatch_group_notify(group, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if (err) {
            NSError *error = [NSError errorWithDomain:ZASessionStorageErrorDomain code:kErrorWhileEncodingTaskInfo userInfo:nil];
            completion(error);
        } else {
            [[ZAUserDefaultsManager sharedManager] saveObject:encodedDict withKey:KeyForTaskInfoDictionary completion:^(NSError * _Nonnull error) {
                completion(error);
            }];
        }
    });
}

- (void)commitTaskInfo:(ZALocalTaskInfo *)taskInfo andPushAllTaskInfoWithCompletion:(void (^)(NSError * _Nullable))completion {
    [self commitTaskInfo:taskInfo];
    [self pushAllTaskInfoWithCompletion:completion];
}

- (void)loadAllTaskInfo:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion {
    [ZAUserDefaultsManager.sharedManager loadObjectOfClass:[NSDictionary class]
                                                   withKey:KeyForTaskInfoDictionary
                                                completion:^(id  _Nullable object, NSError * _Nullable error) {
                                                    if (error) {
                                                        completion(nil, error);
                                                        return;
                                                    }
                                                    NSDictionary *taskInfoDictionary = (NSDictionary *)object;
                                                    if (taskInfoDictionary) {
                                                        ZA_LOCK(self.taskInfoLock);
                                                        [self.taskInfoKeyedByURLString addEntriesFromDictionary:taskInfoDictionary];
                                                        ZA_UNLOCK(self.taskInfoLock);
                                                    }
                                                    completion((NSDictionary *)self.taskInfoKeyedByURLString, nil);
                                                }];
}

@end
