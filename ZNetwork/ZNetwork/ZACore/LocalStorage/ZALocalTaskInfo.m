//
//  ZALocalTaskInfo.m
//  ZNetwork
//
//  Created by CPU12166 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ZALocalTaskInfo.h"

NSString * const KeyForUrlString = @"urlString";
NSString * const KeyForFilePath = @"filePath";
NSString * const KeyForFileName = @"fileName";
NSString * const KeyForAcceptRangesType = @"acceptRangesType";
NSString * const KeyForCountOfBytesReceived = @"countOfBytesReceived";
NSString * const KeyForState = @"state";
NSString * const KeyForRequestPolicy = @"requestPolicy";

@implementation ZALocalTaskInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.urlString forKey:KeyForUrlString];
    [aCoder encodeObject:self.filePath forKey:KeyForFilePath];
    [aCoder encodeObject:self.fileName forKey:KeyForFileName];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.acceptRangesType] forKey:KeyForAcceptRangesType];
    [aCoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countOfBytesReceived] forKey:KeyForCountOfBytesReceived];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.state] forKey:KeyForState];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.requestPolicy] forKey:KeyForRequestPolicy];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.urlString = [aDecoder decodeObjectForKey:KeyForUrlString];
        self.filePath = [aDecoder decodeObjectForKey:KeyForFilePath];
        self.fileName = [aDecoder decodeObjectForKey:KeyForFileName];
        self.acceptRangesType = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForAcceptRangesType]).integerValue;
        self.countOfBytesReceived = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForCountOfBytesReceived]).unsignedLongLongValue;
        self.state = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForState]).integerValue;
        self.requestPolicy = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForRequestPolicy]).unsignedIntegerValue;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
