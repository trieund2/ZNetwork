//
//  ZADownloadOperationModelTests.m
//  ZNetworkTests
//
//  Created by CPU12202 on 6/6/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZNetwork.h"
#import "ZADownloadOperationModel.h"

@interface ZADownloadOperationModelTests : XCTestCase

@property (nonatomic) ZADownloadOperationModel *sut;

@end

@implementation ZADownloadOperationModelTests

- (void)setUp {
    _sut = [[ZADownloadOperationModel alloc] initByURL:[NSURL URLWithString:@"https://speed.hetzner.de/1GB.bin"]];
}

- (void)tearDown {
    
}

- (void)testUpdateCountOfBytesReciver {
    [self.sut updateCountOfBytesReceived:100];
    XCTAssertEqual(self.sut.countOfBytesReceived, 100);
}

- (void)testMutltiThreadingCallForwardProgress {
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut forwardProgress];
    });
}

- (void)testMultiThreadingCallForwardCompletion {
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut forwardCompletion];
    });
}

- (void)testMultithreadingCallForwardError {
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut forwardError:[NSError errorWithDomain:ZANetworkErrorDomain code:ZANetworkErrorFullDisk userInfo:nil]];
    });
}

- (void)testMultithreadingCallFile {
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut forwardFileFromLocation];
    });
}

@end
