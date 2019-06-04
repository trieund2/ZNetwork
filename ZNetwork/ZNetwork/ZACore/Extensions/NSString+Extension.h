//
//  NSString+Extension.h
//  ZNetwork
//
//  Created by MACOS on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

- (nullable NSURL *)toURL;
- (NSString *)MD5String;

@end

NS_ASSUME_NONNULL_END
