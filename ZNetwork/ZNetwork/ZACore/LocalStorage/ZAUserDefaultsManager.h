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
 * @param completion Callback that receives error if there's something wrong while saving, nil if successfully saved.
 */
- (void)saveObject:(nullable id)object withKey:(NSString *)key completion:(void (^)(NSError * _Nullable error))completion;

/**
 * @abstract Encode an object to NSData.
 * @discussion Object to be saved must implement `-encodeWithCoder` so that its properties can be encoded when saved.
 * @param object Object to be saved.
 * @param completion Completion callback, check for error first, if error is nil then object is encoded successfully to data.
 */
- (void)encodeObjectToData:(nullable id)object completion:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completion;

/**
 * @abstract Load an object from NSUserDefaults with a specific key.
 * @discussion Object to be loaded must implement `-initWithCoder` so that its properties can be decoded when loaded.
 * @param cls Class of object to be loaded.
 * @param key Key of that object.
 * @param completion Completion callback, check for error first, if error is nil then object is loaded successfully.
 */
- (void)loadObjectOfClass:(Class)cls withKey:(NSString *)key completion:(void (^)(id _Nullable object, NSError * _Nullable error))completion;

/**
 * @abstract Decode data to an object.
 * @discussion Object class, which data is decoded to, must implement `-initWithCoder` so that its properties can be decoded.
 * @param cls Class of object to be decoded.
 * @param data Data to be decoded.
 * @param completion Completion callback, check for error first, if error is nil then data is decoded successfully to object.
 */
- (void)decodeObjectOfClass:(Class)cls fromData:(NSData *)data completion:(void (^)(id _Nullable object, NSError * _Nullable error))completion;

NS_ASSUME_NONNULL_END

@end
