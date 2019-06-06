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

@interface ZDownloaderTests : XCTestCase
@property NSArray *trackDownloads;
@end

@implementation ZDownloaderTests

- (void)setUp {
    TrackDownload *track1 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityMedium)];
    TrackDownload *track2 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track3 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityMedium)];
    TrackDownload *track4 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track5 = [[TrackDownload alloc] initFromURLString:@"https://speed.hetzner.de/1GB.bin" trackName:@"Test file 1GB"];
    
    TrackDownload *track6 = [[TrackDownload alloc] initFromURLString:@"https://download.microsoft.com/download/8/7/D/87D36A01-1266-4FD3-924C-1F1F958E2233/Office2010DevRefs.exe"
                                                           trackName:@"Test file 50MB microsoft"];
    TrackDownload *track7 = [[TrackDownload alloc] initFromURLString:@"https://download.microsoft.com/download/B/1/7/B1783FE9-717B-4F78-A39A-A2E27E3D679D/ENU/x64/spPowerPivot16.msi"
                                                           trackName:@"Test file 100MB microsoft"];
    TrackDownload *track8 = [[TrackDownload alloc] initFromURLString:@"https://download.microsoft.com/download/8/b/2/8b2347d9-9f9f-410b-8436-616f89c81902/WindowsServer2003.WindowsXP-KB914961-SP2-x64-ENU.exe"
                                                           trackName:@"Test file 350MB microsoft"];
    
    TrackDownload *track9 = [[TrackDownload alloc] initFromURLString:@"https://speed.hetzner.de/100MB.bin" trackName:@"speed.hetzner.de 100MB" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track10 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/10MB.zip" trackName:@"Thinkbroadband 10Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track11 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/20MB.zip" trackName:@"Thinkbroadband 20Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track12 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/50MB.zip" trackName:@"Thinkbroadband 50Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track13 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/100MB.zip" trackName:@"Thinkbroadband 100Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track14 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/200MB.zip" trackName:@"Thinkbroadband 200Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track15 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/512MB.zip" trackName:@"Thinkbroadband 512Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track16 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/1GB.zip" trackName:@"Thinkbroadband 1Gb" priority:(ZAOperationPriorityHigh)];
    
    
    TrackDownload *track17 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_16MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 16Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track18 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_32MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 32Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track19 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_64MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 64Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track20 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_128MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 128Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track21 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_256MB.dat?_ga=2.58545706.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 256Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track22 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_512MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 512Mb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track23 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_1024MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 1Gb" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track24 = [[TrackDownload alloc] initFromURLString:@"http://mirror.filearena.net/pub/speed/SpeedTest_2048MB.dat?_ga=2.71070992.1674869205.1559302009-2103913929.1559302009" trackName:@"Adam Blank Test Files 2Gb" priority:(ZAOperationPriorityHigh)];
    
    _trackDownloads = [NSArray arrayWithObjects:track1, track2, track3, track4, track5, track6, track7, track8, track9, track10, track11, track12, track13, track14, track15, track16,
                       track17, track18, track19, track20, track21, track22, track23, track24, nil];
    
    [ZASessionStorage.sharedStorage removeAllTaskInfos];
}

- (void)tearDown {
    [ZADownloadManager.sharedManager cancelAllRequests];
    [ZASessionStorage.sharedStorage removeAllTaskInfos];
}

- (NSString *)localFilePathForURLString:(NSString *)urlString {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [NSString stringWithFormat:@"%@%f", urlString.MD5String, [[NSDate date] timeIntervalSince1970]];
    return [path stringByAppendingPathComponent:fileName];
}


- (void)testMultiStartDownload {
    dispatch_apply(self.trackDownloads.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        TrackDownload *trackDownload = self.trackDownloads[index];
        [ZADownloadManager.sharedManager downloadTaskFromURLString:trackDownload.urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:trackDownload.priority progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:trackDownload.urlString];
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
    });
}

- (void)testMultiStartDownloadJustStartMaxOperationPerform {
    dispatch_apply(self.trackDownloads.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t index) {
        TrackDownload *trackDownload = self.trackDownloads[index];
        [ZADownloadManager.sharedManager downloadTaskFromURLString:trackDownload.urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:trackDownload.priority progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:trackDownload.urlString];
        } completionBlock:^(NSURLSessionTask * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
            
        }];
    });
    
    XCTAssertEqual([ZADownloadManager.sharedManager numberOfTaskRunning], [ZADownloadManager.sharedManager maxTaskPerform]);
}

- (void)testStartSameRequestJustStartOne {
    TrackDownload *track1 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityMedium)];
    TrackDownload *track2 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityHigh)];
    TrackDownload *track3 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityMedium)];
    TrackDownload *track4 = [[TrackDownload alloc] initFromURLString:@"http://ipv4.download.thinkbroadband.com/5MB.zip" trackName:@"Thinkbroadband 5MB" priority:(ZAOperationPriorityHigh)];
    NSArray *tracks = @[track1, track2, track3, track4];
    
    for (TrackDownload *track in tracks) {
        [ZADownloadManager.sharedManager downloadTaskFromURLString:track.urlString requestPolicy:NSURLRequestUseProtocolCachePolicy priority:track.priority progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
            
        } destinationBlock:^NSString *(NSString * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
            return [self localFilePathForURLString:track.urlString];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [ZADownloadManager.sharedManager pauseDownloadTaskByDownloadCallback:downloadCallback];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
