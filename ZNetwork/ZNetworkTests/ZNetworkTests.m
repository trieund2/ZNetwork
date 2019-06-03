//
//  ZNetworkTests.m
//  ZNetworkTests
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZASessionStorage.h"

@interface ZNetworkTests : XCTestCase

@end

@implementation ZNetworkTests

- (void)testMultiCommitTaskInfo {
    NSString *testURLString = @"testURLString";
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        ZALocalTaskInfo *taskInfo = [[ZALocalTaskInfo alloc] initWithURLString:testURLString filePath:@"testFilePaht" fileName:@"testFileName" countOfTotalBytes:10000];
        [[ZASessionStorage sharedStorage] commitTaskInfo:taskInfo];
    });
    XCTAssertTrue([[ZASessionStorage sharedStorage] containsTaskInfo:testURLString]);
}

@end
