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
}

- (void)testExistenceOfTaskInfo {
    NSString *testURLString1 = @"testURLString1";
    NSString *testURLString2 = @"testURLString2";
    NSString *testURLString3 = @"testURLString3";
    ZALocalTaskInfo *taskInfo1 = [[ZALocalTaskInfo alloc] initWithURLString:testURLString1
                                                                  filePath:@"testFilePath"
                                                                  fileName:@"testFileName"
                                                         countOfTotalBytes:10000];
    ZALocalTaskInfo *taskInfo2 = [[ZALocalTaskInfo alloc] initWithURLString:testURLString2
                                                                   filePath:@"testFilePath"
                                                                   fileName:@"testFileName"
                                                          countOfTotalBytes:10000];
    ZALocalTaskInfo __unused *taskInfo3 = [[ZALocalTaskInfo alloc] initWithURLString:testURLString3
                                                                   filePath:@"testFilePath"
                                                                   fileName:@"testFileName"
                                                          countOfTotalBytes:10000];
    [[ZASessionStorage sharedStorage] commitTaskInfo:taskInfo1];
    [[ZASessionStorage sharedStorage] commitTaskInfo:taskInfo2];
    XCTAssertTrue([[ZASessionStorage sharedStorage] containsTaskInfo:testURLString1]);
    XCTAssertTrue([[ZASessionStorage sharedStorage] containsTaskInfo:testURLString2]);
    XCTAssertTrue(![[ZASessionStorage sharedStorage] containsTaskInfo:testURLString3]);
}

@end
