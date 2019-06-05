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
 * @param error Pointer of error, if there is one while saving, sets the error out parameter.
 */
- (void)saveObject:(nullable id)object withKey:(NSString *)key error:(NSError **)error;

/**
 * @abstract Encode an object to NSData.
 * @discussion Object to be saved must implement `-encodeWithCoder` so that its properties can be encoded when saved.
 * @param object Object to be saved.
 * @param error Pointer of error, if there is one while encoding, sets the error out parameter.
 * @return Returns the encoded data.
 */
- (NSData * _Nullable)encodeObjectToData:(nullable id)object error:(NSError **)error;

/**
 * @abstract Load an object from NSUserDefaults with a specific key.
 * @discussion Object to be loaded must implement `-initWithCoder` so that its properties can be decoded when loaded.
 * @param cls Class of object to be loaded.
 * @param key Key of that object.
 * @param error Pointer of error, if there is one while loading, sets the error out parameter.
 * @return Returns the object.
 */
- (id _Nullable)loadObjectOfClass:(Class)cls withKey:(NSString *)key error:(NSError **)error;

/**
 * @abstract Decode data to an object.
 * @discussion Object class, which data is decoded to, must implement `-initWithCoder` so that its properties can be decoded.
 * @param cls Class of object to be decoded.
 * @param data Data to be decoded.
 * @param error Pointer of error, if there is one while decoding, sets the error out parameter.
 * @return Returns the decoded object.
 */
- (id _Nullable)decodeObjectOfClass:(Class)cls fromData:(NSData *)data error:(NSError **)error;

NS_ASSUME_NONNULL_END

@end
