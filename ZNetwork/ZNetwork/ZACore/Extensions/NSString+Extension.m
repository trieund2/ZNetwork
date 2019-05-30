//
//  NSString+Extension.m
//  ZNetwork
//
//  Created by MACOS on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (nullable NSURL *)toURL {
    NSURL *url = [NSURL URLWithString:self.copy];
    return url;
}

@end
