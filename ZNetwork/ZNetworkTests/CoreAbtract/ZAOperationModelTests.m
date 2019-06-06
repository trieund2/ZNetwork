//
//  ZAOperationModelTests.m
//  ZNetworkTests
//
//  Created by CPU12202 on 6/6/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZNetwork.h"
#import "ZAOperationModel.h"

@interface ZAOperationModelTests : XCTestCase

@property (nonatomic) ZAOperationModel *sut;

@end

@implementation ZAOperationModelTests

- (void)setUp {
    _sut = [[ZAOperationModel alloc] initByURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
}

- (void)tearDown {
    [_sut cancelAllOperations];
}

#pragma mark - Tests Number runnings and paused Operations

- (void)testNumberOperations_WhenInitNumberRunningAndPausedOperations_ThenReturnZero {
    XCTAssertEqual(self.sut.numberOfRunningOperation, 0);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 0);
}

- (void)testNumberOperations_WhenMultithreadingCallNumberRunningAndPausedOperations_ThenNotCrash {
    __block NSUInteger numberRunningOperation = 0;
    __block NSUInteger numberPauseOperation = 0;
    
    dispatch_apply(100, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        numberRunningOperation = self.sut.numberOfRunningOperation;
        numberPauseOperation = self.sut.numberOfPausedOperation;
    });
    
    XCTAssertEqual(numberRunningOperation, 0);
    XCTAssertEqual(numberPauseOperation, 0);
}

#pragma mark - Test Add Operations

- (void)testAddOperation_WhenAddOperationWithNilCallback_ThenNotCrash {
    [self.sut addOperationCallback:nil];
}

- (void)testAddOperation_WhenAddOperation_ThenIncreaseNumberRunningOperations {
    ZAOperationCallback *callback = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback];
    
    XCTAssertEqual(self.sut.numberOfRunningOperation, 1);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 0);
}

- (void)testAddOperation_WhenMultithreadingAddOperations_ThenNotCrash {
    ZAOperationCallback *callback = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        [self.sut addOperationCallback:callback];
    });
}

#pragma mark - Test Pause Operations

- (void)testPauseOperation_WhenPauseRunningOperationWithNilId_ThenNotCrash {
    [self.sut pauseOperationCallbackById:nil];
}

- (void)testPauseOperation_WhenPausedRunningOperation_ThatWillMoveToPausesOperation {
    ZAOperationCallback *callback = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback];
    [self.sut pauseOperationCallbackById:callback.identifier];
    
    XCTAssertEqual(self.sut.numberOfRunningOperation, 0);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 1);
}

- (void)testPauseOperation_WhenPausedOperationNotRunning_ThenDotNotDoAnything {
    ZAOperationCallback *callback = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback];
    [self.sut pauseOperationCallbackById:callback.identifier];
    
    [self.sut pauseOperationCallbackById:callback.identifier];
    
    XCTAssertEqual(self.sut.numberOfRunningOperation, 0);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 1);
}

- (void)testPauseOperation_WhenMultithreadingPauseRunningOperation_ThenNotCrash {
    ZAOperationCallback *callback = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback];
    
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        [self.sut pauseOperationCallbackById:callback.identifier];
    });
}

#pragma mark - Test Remove Paused Operation

- (void)testRemovePauseOperation_WhenSendNilId_ThatDoNotCrash {
    [self.sut removePausedOperationCallbackById:nil];
}

- (void)testRemovePauseOperation_WhenIdNotInOperation_ThenDoNotDoAnyThing {
    ZAOperationCallback *callback1 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    ZAOperationCallback *callback2 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback1];
    [self.sut addOperationCallback:callback2];
    [self.sut pauseOperationCallbackById:callback1.identifier];
    
    [self.sut removePausedOperationCallbackById:NSUUID.UUID.UUIDString];
    
    XCTAssertEqual(self.sut.numberOfPausedOperation, 1);
    XCTAssertEqual(self.sut.numberOfRunningOperation, 1);
}

- (void)testRemovePauseOperation_WhenSendIdRunning_ThenDoNotRemove {
    ZAOperationCallback *callback1 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    ZAOperationCallback *callback2 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback1];
    [self.sut addOperationCallback:callback2];
    
    [self.sut removePausedOperationCallbackById:callback2.identifier];
    
    XCTAssertEqual(self.sut.numberOfRunningOperation, 2);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 0);
}

- (void)testRemovePausOperation_WhenSendPauseId_ThenRemoveCallback {
    ZAOperationCallback *callback1 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    ZAOperationCallback *callback2 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback1];
    [self.sut addOperationCallback:callback2];
    [self.sut pauseOperationCallbackById:callback2.identifier];
    
    [self.sut removePausedOperationCallbackById:callback2.identifier];
    
    XCTAssertEqual(self.sut.numberOfRunningOperation, 1);
    XCTAssertEqual(self.sut.numberOfPausedOperation, 0);
}

- (void)testRemovePauseOperation_WhenMultithreading_ThenNotCrash {
    ZAOperationCallback *callback1 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    ZAOperationCallback *callback2 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback1];
    [self.sut addOperationCallback:callback2];
    [self.sut pauseOperationCallbackById:callback2.identifier];
    
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut removePausedOperationCallbackById:callback2.identifier];
    });
}

#pragma mark - Test Pause All Operation

- (void)testPauseAllOperation_WhenCallMutlthreading_ThenDoNotCrash {
    ZAOperationCallback *callback1 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    ZAOperationCallback *callback2 = [[ZAOperationCallback alloc] initWithURL:[NSURL URLWithString:@"http://ipv4.download.thinkbroadband.com/20MB.zip"]];
    [self.sut addOperationCallback:callback1];
    [self.sut addOperationCallback:callback2];
    
    dispatch_apply(1000, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t size) {
        [self.sut pauseAllOperations];
    });
}

@end
