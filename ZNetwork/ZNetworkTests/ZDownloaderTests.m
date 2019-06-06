//
//  ZDownloaderTests.m
//  ZNetworkTests
//
//  Created by CPU12202 on 6/4/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZNetwork.h"
#import "TrackDownload.h"
#import "ZASessionStorage.h"
#import "ZNetworkConstant.h"

@interface ZDownloaderTests : XCTestCase
@property NSArray *urlStrings;
@end

@implementation ZDownloaderTests

- (void)setUp {
    _urlStrings = @[ @"http://ipv4.download.thinkbroadband.com/5MB.zip",
                     @"https://speed.hetzner.de/1GB.bin",
                     @"https://download.microsoft.com/download/8/7/D/87D36A01-1266-4FD3-924C-1F1F958E2233/Office2010DevRefs.exe",
                     @"https://download.microsoft.com/download/B/1/7/B1783FE9-717B-4F78-A39A-A2E27E3D679D/ENU/x64/spPowerPivot16.msi",
                     @"https://download.microsoft.com/download/B/1/7/B1783FE9-717B-4F78-A39A-A2E27E3D679D/ENU/x64/spPowerPivot16.msi",
                     @"https://download.microsoft.com/download/8/b/2/8b2347d9-9f9f-410b-8436-616f89c81902/WindowsServer2003.WindowsXP-KB914961-SP2-x64-ENU.exe",
                     @"https://speed.hetzner.de/100MB.bin",
                     @"http://ipv4.download.thinkbroadband.com/10MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/20MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/50MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/100MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/200MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/512MB.zip",
                     @"http://ipv4.download.thinkbroadband.com/1GB.zip",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_16MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_32MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_64MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_128MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_256MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_512MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009",
                     @"http://mirror.filearena.net/pub/speed/SpeedTest_2048MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009"];
    
    [ZASessionStorage.sharedStorage removeAllTaskInfos];
    [ZADownloadManager.sharedManager cancelAllRequests];
}

- (void)tearDown {
}

- (NSString *)localFilePathForURLString:(NSString *)urlString {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [NSString stringWithFormat:@"%@%f", urlString.MD5String, [[NSDate date] timeIntervalSince1970]];
    return [path stringByAppendingPathComponent:fileName];
}


- (void)testMultiStartDownload {
    dispatch_apply(self.urlStrings.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        NSString *urlString = self.urlStrings[index];
        [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:ZAOperationPriorityMedium progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:urlString];
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
    });
}

- (void)testMultiStartDownloadJustStartMaxOperationPerform {
    dispatch_apply(self.urlStrings.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        NSString *urlString = self.urlStrings[index];
        [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:ZAOperationPriorityMedium progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:urlString];
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
    });
    
    XCTAssertEqual([ZADownloadManager.sharedManager numberOfTaskRunning], [ZADownloadManager.sharedManager maxTaskPerform]);
}

- (void)testStartSameRequestJustStartOne {
    NSMutableArray<NSString *> *fileURLStrings = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 100; i++) {
        [fileURLStrings addObject:@"http://ipv4.download.thinkbroadband.com/5MB.zip"];
    }
    
    for (NSString *urlString in fileURLStrings) {
        [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:NSURLRequestUseProtocolCachePolicy priority:ZAOperationPriorityMedium progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:urlString];
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
    }
    
    XCTAssertEqual(ZADownloadManager.sharedManager.numberOfTaskRunning, 1);
    XCTAssertEqual(ZADownloadManager.sharedManager.numberOfTaskInQueue, 0);
}

- (void)testDownloadRequest {
    NSString *urlString = @"http://speedtest.ftp.otenet.gr/files/test100k.db";
    NSString *filePath = [self localFilePathForURLString:urlString];
    __block NSURLSessionTask *urlResponse;
    __block NSString *sourceFileLocation = nil;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download correct bytes"];
    
    ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:(ZAOperationPriorityVeryHigh) progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
        
    } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
        sourceFileLocation = location;
        return filePath;
    } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
        urlResponse = response;
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
    
    unsigned long long fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:filePath error:nil] fileSize];
    
    XCTAssertNotNil(downloadCallback);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:filePath]);
    XCTAssertEqual(fileSize, urlResponse.countOfBytesExpectedToReceive);
    XCTAssertNotNil(urlResponse);
    XCTAssertNotNil(urlResponse.originalRequest);
    XCTAssertNotNil(urlResponse.currentRequest);
    XCTAssertTrue([urlResponse.originalRequest.URL.absoluteString isEqualToString:urlString]);
    XCTAssertNil(urlResponse.error);
    XCTAssertNotNil(sourceFileLocation);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:sourceFileLocation]);
}

- (void)testCancelDownloadRequest {
    NSString *urlString = @"https://speed.hetzner.de/1GB.bin";
    NSString *filePath = [self localFilePathForURLString:urlString];
    __block NSURLSessionTask *urlResponse = nil;
    __block NSError *downloadError = nil;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Canceled download request shold cancel correct task"];
    
    ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:(ZAOperationPriorityVeryHigh) progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
        
    } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
        return filePath;
    } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
        downloadError = error;
        urlResponse = response;
        [expectation fulfill];
    }];
    
    [ZADownloadManager.sharedManager cancelDownloadTaskByDownloadCallback:downloadCallback];
    
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
    
    XCTAssertNotNil(downloadCallback);
    XCTAssertNotNil(urlResponse);
    XCTAssertNotNil(urlResponse.originalRequest);
    XCTAssertNotNil(urlResponse.currentRequest);
    XCTAssertTrue([urlResponse.originalRequest.URL.absoluteString isEqualToString:urlString]);
    XCTAssertNotNil(downloadError);
    XCTAssertEqual(downloadError.code, NSURLErrorCancelled);
    XCTAssertEqual(ZADownloadManager.sharedManager.numberOfTaskInQueue, 0);
}

- (void)testPauseDownloadRequest {
    NSString *urlString = @"http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009";
    NSString *filePath = [self localFilePathForURLString:urlString];
    __block NSURLSessionTask *urlResponse = nil;
    __block NSError *downloadError = nil;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Paused download request shold pause correct task"];
    
    ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:(ZAOperationPriorityVeryHigh) progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
        
    } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
        return filePath;
    } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
        downloadError = error;
        urlResponse = response;
        [expectation fulfill];
    }];
    
    [ZADownloadManager.sharedManager pauseDownloadTaskByDownloadCallback:downloadCallback];
    
    [self waitForExpectationsWithTimeout:90.0 handler:nil];
    
    XCTAssertNotNil(downloadError);
    XCTAssertEqual(downloadError.code, ZANetworkErrorPauseTask);
    XCTAssertNotNil(urlResponse.originalRequest);
    XCTAssertNotNil(urlResponse.currentRequest);
    XCTAssertNotNil(downloadCallback);
    XCTAssertNotNil(urlResponse);
    XCTAssertTrue([urlResponse.originalRequest.URL.absoluteString isEqualToString:urlString]);
}

- (void)testPauseAndResumeDownloadRequest {
    NSString *urlString2GB = @"http://mirror.filearena.net/pub/speed/SpeedTest_256MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009";
    NSString *filePath = [self localFilePathForURLString:urlString2GB];
    __block NSURLResponse *urlResponse = nil;
    __block NSURLSessionTask *task = nil;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Paused and resume download task"];
    expectation.expectedFulfillmentCount = 2;
    
    ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString2GB requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:(ZAOperationPriorityVeryHigh) progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
        
    } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
        return filePath;
    } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
        
    }];
    
    downloadCallback.reciveURLSessionResponseBlock = ^(NSURLSessionTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        urlResponse = response;
        task = dataTask;
        [expectation fulfill];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZADownloadManager.sharedManager pauseDownloadTaskByDownloadCallback:downloadCallback];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZADownloadManager.sharedManager resumeDownloadTaskByDownloadCallback:downloadCallback];
    });
    
    [self waitForExpectationsWithTimeout:90.0 handler:nil];
    
    ZALocalTaskInfo *taskInfo = [ZASessionStorage.sharedStorage getTaskInfoByURLString:urlString2GB];
    NSString *range = [NSString stringWithFormat:@"bytes %lli-%lli/%lli", taskInfo.countOfBytesReceived, (taskInfo.countOfTotalBytes - 1), taskInfo.countOfTotalBytes];
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)urlResponse;
    NSString *expectRangeHeader = (NSString *)HTTPResponse.allHeaderFields[@"Content-Range"];
    
    XCTAssertNotNil(taskInfo);
    XCTAssertNotNil(expectRangeHeader);
    XCTAssertTrue([expectRangeHeader isEqualToString:range]);
    
    XCTAssertNotNil(task);
    XCTAssertNotNil(urlResponse);
    XCTAssertNotNil(task.originalRequest);
    XCTAssertNotNil(task.currentRequest);
    XCTAssertTrue([task.originalRequest.URL.absoluteString isEqual:urlString2GB]);
    XCTAssertTrue([task.currentRequest.URL.absoluteString isEqual:urlString2GB]);
    
}

- (void)testResumeDownloadInLocal {
    NSString *urlString2GB = @"http://mirror.filearena.net/pub/speed/SpeedTest_2048MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009";
    NSString *filePath = [self localFilePathForURLString:urlString2GB];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Resume download task in local"];
    __block NSURLResponse *urlResponse = nil;
    __block NSURLSessionTask *task = nil;
    
    ZALocalTaskInfo *taskInfo = [[ZALocalTaskInfo alloc] initWithURLString:urlString2GB filePath:filePath
                                                                  fileName:[self localFilePathForURLString:urlString2GB]
                                                         countOfTotalBytes:2147483648];
    
    [ZASessionStorage.sharedStorage commitTaskInfo:taskInfo];
    [ZASessionStorage.sharedStorage updateCountOfBytesReceived:10000 byURLString:urlString2GB];
    
    [ZASessionStorage.sharedStorage pushAllTaskInfoWithCompletion:^(NSError * _Nullable error) {
        
        ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:urlString2GB requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:(ZAOperationPriorityVeryHigh) progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return filePath;
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
        
        downloadCallback.reciveURLSessionResponseBlock = ^(NSURLSessionTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            urlResponse = response;
            task = dataTask;
            [expectation fulfill];
        };
        
    }];
    
    [self waitForExpectationsWithTimeout:90.0 handler:nil];
    
    ZALocalTaskInfo *expectTaskInfo = [ZASessionStorage.sharedStorage getTaskInfoByURLString:urlString2GB];
    NSString *range = [NSString stringWithFormat:@"bytes %lli-%lli/%lli", expectTaskInfo.countOfBytesReceived, (expectTaskInfo.countOfTotalBytes - 1), expectTaskInfo.countOfTotalBytes];
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)urlResponse;
    NSString *expectRangeHeader = (NSString *)HTTPResponse.allHeaderFields[@"Content-Range"];
    
    XCTAssertNotNil(taskInfo);
    XCTAssertNotNil(expectRangeHeader);
    XCTAssertTrue([expectRangeHeader isEqualToString:range]);
    
    XCTAssertNotNil(task);
    XCTAssertNotNil(urlResponse);
    XCTAssertNotNil(task.originalRequest);
    XCTAssertNotNil(task.currentRequest);
    XCTAssertTrue([task.originalRequest.URL.absoluteString isEqual:urlString2GB]);
    XCTAssertTrue([task.currentRequest.URL.absoluteString isEqual:urlString2GB]);
    
}

@end
