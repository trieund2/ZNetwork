//
//  ZAUserDefaultsManager.h
//  ZNetwork
//
//  Created by CPU12166 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZAUserDefaultsManager : NSObject

/* Make init private, use +sharedManager to get singleton instead */
- (instancetype)init NS_UNAVAILABLE;

/* Return a singleton */
+ (instancetype)sharedManager;

/**
 * @abstract Save an object to NSUserDefaults with a specific key.
 * @discussion Object to be saved must implement `-encodeWithCoder` so that its properties can be encoded when saved.
 * @param object Object to be saved.
 * @param key Key of that object, must be unique.
 * @param completion Callback that returns error if there's something wrong while saving, nil if successfully saved.
 */
- (void)saveObject:(nullable id)object withKey:(NSString *)key completion:(nullable void (^)(NSError *))completion;

/**
 * @abstract Load an object from NSUserDefaults with a specific key.
 * @discussion Object to be loaded must implement `-initWithCoder` so that its properties can be decoded when loaded.
 * @param cls Class of object to be loaded.
 * @param key Key of that object.
 * @return An id object if found, nil if no object found.
 */
- (nullable id)loadObjectOfClass:(Class)cls withKey:(NSString *)key;

NS_ASSUME_NONNULL_END

@end
