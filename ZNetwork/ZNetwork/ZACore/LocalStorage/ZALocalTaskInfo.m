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
NSString * const KeyForLastTimeModified = @"lastTimeModified";
NSString * const KeyForAcceptRangesType = @"acceptRangesType";
NSString * const KeyForCountOfBytesReceived = @"countOfBytesReceived";
NSString * const KeyForCountOfTotalBytes = @"countOfTotalBytes";
NSString * const KeyForState = @"state";
NSString * const KeyForRequestCachePolicy = @"requestCachePolicy";

@implementation ZALocalTaskInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.urlString forKey:KeyForUrlString];
    [aCoder encodeObject:self.filePath forKey:KeyForFilePath];
    [aCoder encodeObject:self.fileName forKey:KeyForFileName];
    [aCoder encodeObject:self.lastTimeModified forKey:KeyForLastTimeModified];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.acceptRangesType] forKey:KeyForAcceptRangesType];
    [aCoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countOfBytesReceived] forKey:KeyForCountOfBytesReceived];
    [aCoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countOfTotalBytes] forKey:KeyForCountOfTotalBytes];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.state] forKey:KeyForState];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.requestCachePolicy] forKey:KeyForRequestCachePolicy];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _urlString = [aDecoder decodeObjectForKey:KeyForUrlString];
        _filePath = [aDecoder decodeObjectForKey:KeyForFilePath];
        _fileName = [aDecoder decodeObjectForKey:KeyForFileName];
        _lastTimeModified = [aDecoder decodeObjectForKey:KeyForLastTimeModified];
        _acceptRangesType = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForAcceptRangesType]).integerValue;
        _countOfBytesReceived = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForCountOfBytesReceived]).unsignedLongLongValue;
        _countOfTotalBytes = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForCountOfTotalBytes]).unsignedLongLongValue;
        _state = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForState]).integerValue;
        _requestCachePolicy = ((NSNumber *)[aDecoder decodeObjectForKey:KeyForRequestCachePolicy]).unsignedIntegerValue;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
