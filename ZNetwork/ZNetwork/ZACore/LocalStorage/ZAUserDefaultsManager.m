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
    }
    return self;
}

- (void)saveObject:(nullable id)object withKey:(NSString *)key completion:(nullable void (^)(NSError *))completion {
#if DEBUG
    NSParameterAssert(key);
#endif
    if (nil == key) { return; }
    
    NSError *error = nil;
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&error];
    if (error) {
        completion(error);
        return;
    }
    [self.defaults setObject:encodedObject forKey:key];
    [self.defaults synchronize];
}

- (nullable id)loadObjectOfClass:(Class)cls withKey:(NSString *)key; {
#if DEBUG
    NSParameterAssert(key);
#endif
    if (nil == key) { return nil; }
    
    NSData *encodedObject = [self.defaults objectForKey:key];
    NSError *error = nil;
    id object = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:encodedObject error:&error];
    if (error) {
        NSLog(@"Error while loading object: %@", error.localizedDescription);
        return nil;
    }
    return object;
}

@end
