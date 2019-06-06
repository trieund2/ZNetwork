//
//  ZAQueueModelTests.m
//  ZNetworkTests
//
//  Created by CPU12202 on 6/4/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZNetwork.h"
#import "ZAQueueModel.h"

@interface ZAQueueModelTests : XCTestCase
@property ZAQueueModel *sut;
@end

@implementation ZAQueueModelTests

- (void)setUp {
    _sut = [[ZAQueueModel alloc] initByOperationExecutionOrder:(ZAOperationExecutionOrderFIFO)
                                               isMultiCallback:YES
                                                   performType:(ZAOperationPerformTypeConcurrency)];
}

- (void)tearDown {
}

- (void)testEnQueueTaskGetCorrectTaskInQueue {
    ZAOperationModel *operationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get"]];
    [self.sut enqueueOperation:operationModel];
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 1);
    XCTAssertTrue(self.sut.canDequeueOperationModel);
}

- (void)testEnQueueVeryHighOperationAndHighOperationDeQueueVeryHighOperation {
    ZAOperationModel *veryHighoperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                     requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                          priority:(ZAOperationPriorityVeryHigh)];
    ZAOperationModel *highOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                 requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                      priority:(ZAOperationPriorityHigh)];
    [self.sut enqueueOperation:highOperationModel];
    [self.sut enqueueOperation:veryHighoperationModel];
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:veryHighoperationModel]);
}

- (void)testEnQueueVeryHighOperationAndMediumOperationDeQueueVeryHighOperation {
    ZAOperationModel *veryHighoperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                     requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                          priority:(ZAOperationPriorityVeryHigh)];
    ZAOperationModel *mediumOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                   requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                        priority:(ZAOperationPriorityMedium)];
    [self.sut enqueueOperation:mediumOperationModel];
    [self.sut enqueueOperation:veryHighoperationModel];
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:veryHighoperationModel]);
}

- (void)testEnQueueVeryHighOperationAndLowOperationDeQueueVeryHighOperation {
    ZAOperationModel *veryHighoperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                     requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                          priority:(ZAOperationPriorityVeryHigh)];
    ZAOperationModel *lowOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                     priority:(ZAOperationPriorityLow)];
    [self.sut enqueueOperation:lowOperationModel];
    [self.sut enqueueOperation:veryHighoperationModel];
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:veryHighoperationModel]);
}

- (void)testEnQueueHighOperationAndMediumOperationDeQueueVeryHighOperation {
    ZAOperationModel *highOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                 requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                      priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *mediumOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                   requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                        priority:(ZAOperationPriorityMedium)];
    [self.sut enqueueOperation:mediumOperationModel];
    [self.sut enqueueOperation:highOperationModel];
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:highOperationModel]);
}

- (void)testEnQueueHighOperationAndLowOperationDeQueueVeryHighOperation {
    ZAOperationModel *highOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                 requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                      priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *lowOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                     priority:(ZAOperationPriorityLow)];
    [self.sut enqueueOperation:lowOperationModel];
    [self.sut enqueueOperation:highOperationModel];
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:highOperationModel]);
}

- (void)testEnQueueMediumOperationAndLowOperationDeQueueVeryHighOperation {
    ZAOperationModel *mediumOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                   requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                        priority:(ZAOperationPriorityMedium)];
    ZAOperationModel *lowOperationModel = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                     priority:(ZAOperationPriorityLow)];
    [self.sut enqueueOperation:lowOperationModel];
    [self.sut enqueueOperation:mediumOperationModel];
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 2);
    XCTAssertTrue([self.sut.dequeueOperationModel isEqual:mediumOperationModel]);
}

- (void)testEnQueueOperationsSamePriorityThatDeQueueByFIFOExecutionOrder {
    _sut = [[ZAQueueModel alloc] initByOperationExecutionOrder:(ZAOperationExecutionOrderFIFO)
                                               isMultiCallback:YES
                                                   performType:(ZAOperationPerformTypeConcurrency)];
    
    ZAOperationModel *highOperationModel1 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel2 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel3 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/3"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel4 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/4"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel5 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/5"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    [self.sut enqueueOperation:highOperationModel1];
    [self.sut enqueueOperation:highOperationModel2];
    [self.sut enqueueOperation:highOperationModel3];
    [self.sut enqueueOperation:highOperationModel4];
    [self.sut enqueueOperation:highOperationModel5];
    
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 5);
    XCTAssertEqual(self.sut.dequeueOperationModel, highOperationModel1);
}

- (void)testEnQueueOperationsSamePriorityThatDeQueueByLIFOExecutionOrder {
    _sut = [[ZAQueueModel alloc] initByOperationExecutionOrder:(ZAOperationExecutionOrderLIFO)
                                               isMultiCallback:YES
                                                   performType:(ZAOperationPerformTypeConcurrency)];
    
    ZAOperationModel *highOperationModel1 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/1"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel2 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/2"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel3 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/3"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel4 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/4"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    ZAOperationModel *highOperationModel5 = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"https://httpbin.org/get/5"]
                                                                  requestPolicy:(NSURLRequestUseProtocolCachePolicy)
                                                                       priority:(ZAOperationPriorityHigh)];
    [self.sut enqueueOperation:highOperationModel1];
    [self.sut enqueueOperation:highOperationModel2];
    [self.sut enqueueOperation:highOperationModel3];
    [self.sut enqueueOperation:highOperationModel4];
    [self.sut enqueueOperation:highOperationModel5];
    
    XCTAssertTrue(self.sut.canDequeueOperationModel);
    XCTAssertEqual(self.sut.numberOfTaskInQueue, 5);
    XCTAssertEqual(self.sut.dequeueOperationModel, highOperationModel5);
}

@end
