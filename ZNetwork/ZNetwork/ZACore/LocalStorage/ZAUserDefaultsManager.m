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

- (void)saveObject:(nullable id)object withKey:(NSString *)key error:(NSError **)error {
#if DEBUG
    NSParameterAssert(key);
#endif
    if (nil == key) { return; }
    
    NSError *err = nil;
    NSData *encodedObject = [self encodeObjectToData:object error:&err];
    if (err) {
        *error = err;
        return;
    }
    ZA_LOCK(self.userDefaultsLock);
    [self.defaults setObject:encodedObject forKey:key];
    [self.defaults synchronize];
    ZA_UNLOCK(self.userDefaultsLock);
    error = nil;
}

- (NSData * _Nullable)encodeObjectToData:(nullable id)object error:(NSError **)error {
    if (nil == object) {
        *error = nil;
        return nil;
    }
    NSData *encodedObject = nil;
    if (@available(iOS 11.0, *)) {
        NSError *err = nil;
        encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&err];
        if (err) {
            *error = err;
            return nil;
        } else {
            *error = nil;
            return encodedObject;
        }
    } else {
        encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
        *error = nil;
        return encodedObject;
    }
}

- (id _Nullable)loadObjectOfClass:(Class)cls withKey:(NSString *)key error:(NSError **)error {
#if DEBUG
    NSParameterAssert(cls);
    NSParameterAssert(key);
#endif
    if (nil == cls || nil == key) { *error = nil; return nil; }
    
    ZA_LOCK(self.userDefaultsLock);
    NSData *encodedObject = [self.defaults objectForKey:key];
    ZA_UNLOCK(self.userDefaultsLock);
    NSError *err = nil;
    id decodedObject = [self decodeObjectOfClass:cls fromData:encodedObject error:&err];
    if (err) {
        *error = err;
        return nil;
    } else {
        *error = nil;
        return decodedObject;
    }
}

- (id _Nullable)decodeObjectOfClass:(Class)cls fromData:(NSData *)data error:(NSError **)error {
#if DEBUG
    NSParameterAssert(cls);
#endif
    if (nil == cls) { *error = nil; return nil; }
    
    if (nil == data) {
        *error = nil;
        return nil;
    }
    id object = nil;
    if (@available(iOS 11.0, *)) {
        NSError *err = nil;
        object = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:data error:&err];
        if (err) {
            *error = err;
            return nil;
        } else {
            *error = nil;
            return object;
        }
    } else {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        *error = nil;
        return object;
    }
}

@end
