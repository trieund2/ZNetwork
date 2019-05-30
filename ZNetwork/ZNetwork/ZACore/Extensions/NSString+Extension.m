//
//  NSString+Extension.m
//  ZNetwork
//
//  Created by MACOS on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extension)

- (nullable NSURL *)toURL {
    NSURL *url = [NSURL URLWithString:self.copy];
    return url;
}

- (NSString *)MD5String {
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
