//
//  ZAUserDefaultsManager.m
//  ZNetwork
//
//  Created by CPU12166 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZAUserDefaultsManager.h"
#import "ZALocalTaskInfo.h"

@interface ZAUserDefaultsManager ()

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) dispatch_semaphore_t userDefaultsLock;

@end

@implementation ZAUserDefaultsManager

+ (instancetype)sharedManager {
    static ZAUserDefaultsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] initSingleton];
    });
    return sharedManager;
}

- (instancetype)initSingleton {
    if (self = [super init]) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        self.userDefaultsLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)saveObject:(nullable id)object withKey:(NSString *)key completion:(void (^)(NSError *))completion {
#if DEBUG
    NSParameterAssert(key);
    NSParameterAssert(completion);
#endif
    if (nil == key || nil == completion) { return; }
    
    __block NSData *encodedObject = nil;
    [self encodeObjectToData:object completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        encodedObject = data;
        ZA_LOCK(self.userDefaultsLock);
        [self.defaults setObject:encodedObject forKey:key];
        [self.defaults synchronize];
        ZA_UNLOCK(self.userDefaultsLock);
        completion(nil);
    }];
}

- (void)encodeObjectToData:(nullable id)object completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
#if DEBUG
    NSParameterAssert(completion);
#endif
    if (nil == completion) { return; }
    
    if (nil == object) {
        completion(nil, nil);
    }
    NSError *error = nil;
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&error];
    if (error) {
        completion(nil, error);
    } else {
        completion(encodedObject, nil);
    }
}

- (void)loadObjectOfClass:(Class)cls withKey:(NSString *)key completion:(void (^)(id _Nullable, NSError * _Nullable))completion {
#if DEBUG
    NSParameterAssert(cls);
    NSParameterAssert(key);
    NSParameterAssert(completion);
#endif
    if (nil == cls || nil == key || nil == completion) { return; }
    
    ZA_LOCK(self.userDefaultsLock);
    NSData *encodedObject = [self.defaults objectForKey:key];
    ZA_UNLOCK(self.userDefaultsLock);
    [self decodeObjectOfClass:cls fromData:encodedObject completion:completion];
}

- (void)decodeObjectOfClass:(Class)cls fromData:(NSData *)data completion:(void (^)(id _Nullable, NSError * _Nullable))completion {
#if DEBUG
    NSParameterAssert(cls);
    NSParameterAssert(completion);
#endif
    if (nil == cls || nil == completion) { return; }
    
    if (nil == data) {
        completion(nil, nil);
    }
    NSError *error = nil;
    id object = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:data error:&error];
    if (error) {
        completion(nil, error);
    } else {
        completion(object, nil);
    }
}

@end
