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

@implementation ZALocalTaskInfo

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSString stringWithString:self.urlString] forKey:KeyForUrlString];
    [aCoder encodeObject:[NSString stringWithString:self.filePath] forKey:KeyForFilePath];
    [aCoder encodeObject:[NSString stringWithString:self.fileName] forKey:KeyForFileName];
    [aCoder encodeObject:self.lastTimeModified forKey:KeyForLastTimeModified];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.acceptRangesType] forKey:KeyForAcceptRangesType];
    [aCoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countOfBytesReceived] forKey:KeyForCountOfBytesReceived];
    [aCoder encodeObject:[NSNumber numberWithUnsignedLongLong:self.countOfTotalBytes] forKey:KeyForCountOfTotalBytes];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.state] forKey:KeyForState];
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
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString filePath:(NSString *)filePath fileName:(NSString *)fileName countOfTotalBytes:(int64_t)countOfTotalBytes {
    if (self = [super init]) {
        _urlString = urlString;
        _filePath = filePath;
        _fileName = fileName;
        _countOfTotalBytes = countOfTotalBytes;
        _lastTimeModified = [NSDate date];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    ZALocalTaskInfo *copyTaskInfo = [[ZALocalTaskInfo alloc] initWithURLString:[self.urlString copyWithZone:zone]
                                                                      filePath:[self.filePath copyWithZone:zone]
                                                                      fileName:[self.fileName copyWithZone:zone]
                                                             countOfTotalBytes:self.countOfTotalBytes];
    copyTaskInfo.countOfBytesReceived = self.countOfBytesReceived;
    copyTaskInfo.state = self.state;
    return copyTaskInfo;
}

- (void)setCountOfBytesReceived:(int64_t)countOfBytesReceived {
    _countOfBytesReceived = countOfBytesReceived;
    _lastTimeModified = [NSDate date];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
