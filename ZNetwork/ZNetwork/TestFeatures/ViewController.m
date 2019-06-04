//
//  ViewController.m
//  ZANetworking
//
//  Created by CPU12202 on 5/23/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import "ViewController.h"
#import "ZNetwork.h"
#import "TrackDownload.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *downloadTableView;
@property (nonatomic) NSMutableArray<TrackDownload *> *trackDownloads;
@property (nonatomic) NSMutableDictionary<NSString *, TrackDownload *> *currentDownload;
@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentDownload = [[NSMutableDictionary alloc] init];
    [self initDownloadTableView];
    [self initDataSource];
}

#pragma mark - Init

- (void)initDownloadTableView {
    UINib *downloadNib = [UINib nibWithNibName:@"DownloadTableViewCell" bundle:NULL];
    [self.downloadTableView registerNib:downloadNib forCellReuseIdentifier:@"DownloadTableViewCell"];
    self.downloadTableView.delegate = self;
    self.downloadTableView.dataSource = self;
}

- (IBAction)tapAllCancellAllRequest:(id)sender {
    [ZADownloadManager.sharedManager cancelAllRequests];
    for (TrackDownload *trackDownload in self.currentDownload.allValues) {
        trackDownload.status = ZASessionTaskStatusCancelled;
    }
    [self.currentDownload removeAllObjects];
    [self.downloadTableView reloadData];
}

- (void)initDataSource {
    _trackDownloads = [[NSMutableArray alloc] init];
    
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
    
    [self.trackDownloads addObjectsFromArray:@[track1, track2, track3, track4, track5, track6, track7, track8, track9, track10, track11, track12, track13, track14, track15, track16, 
                                               track17, track18, track19, track20, track21, track22, track23, track24]];
    
    [self.downloadTableView reloadData];
}

#pragma mark - Helper

- (NSURL *)localFilePathForURL:(NSURL *)url {
    NSURL *documentsPath = [NSFileManager.defaultManager URLsForDirectory:(NSDocumentationDirectory) inDomains:(NSUserDomainMask)].firstObject;
    return [documentsPath URLByAppendingPathComponent:url.lastPathComponent];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trackDownloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell"];
    cell.delegate = self;
    TrackDownload *trackDownload = [self.trackDownloads objectAtIndex:indexPath.row];
    [cell configCellByTrackDownload:trackDownload indexPath:indexPath];
    return cell;
}

#pragma mark - DownloadTableViewCellDelegate

- (void)didSelectDownloadAtIndexPath:(NSIndexPath *)indexPath {
    TrackDownload *trackDownload = [self.trackDownloads objectAtIndex:indexPath.row];
    if (nil == trackDownload) { return; }
    __weak typeof(self) weakSelf = self;
    
    ZADownloadOperationCallback *downloadCallback = [ZADownloadManager.sharedManager downloadTaskFromURLString:trackDownload.urlString requestPolicy:(NSURLRequestUseProtocolCachePolicy) priority:trackDownload.priority progressBlock:^(NSProgress * _Nonnull progress, NSString * _Nonnull callBackIdentifier) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TrackDownload *currentTrackDownload = [weakSelf.currentDownload objectForKey:callBackIdentifier];
            if (currentTrackDownload) {
                NSUInteger index = [weakSelf.trackDownloads indexOfObject:currentTrackDownload];
                currentTrackDownload.progress = progress;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                DownloadTableViewCell *cell = [weakSelf.downloadTableView cellForRowAtIndexPath:indexPath];
                [cell configCellByTrackDownload:currentTrackDownload indexPath:indexPath];
            }
        });
        
    } destinationBlock:^NSURL *(NSURL * _Nonnull location, NSString * _Nonnull callBackIdentifier) {
        return [self localFilePathForURL:[NSURL URLWithString:trackDownload.urlString]];
        
    } completionBlock:^(NSURLResponse * _Nonnull response, NSError * _Nonnull error, NSString * _Nonnull callBackIdentifier) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            TrackDownload *currentTrackDownload = [weakSelf.currentDownload objectForKey:callBackIdentifier];
            
            if (error) {
                if (error.code == NSURLErrorCancelled) {
                    currentTrackDownload.status = ZASessionTaskStatusCancelled;
                } else if (error.code == ZANetworkErrorAppEnterBackground) {
                    currentTrackDownload.status = ZASessionTaskStatusPaused;
                } else {
                    currentTrackDownload.status = ZASessionTaskStatusFailed;
                }
            } else {
                [weakSelf.currentDownload removeObjectForKey:callBackIdentifier];
                currentTrackDownload.status = ZASessionTaskStatusSuccessed;
            }
            
            if (currentTrackDownload) {
                NSUInteger index = [weakSelf.trackDownloads indexOfObject:currentTrackDownload];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
                DownloadTableViewCell *cell = [weakSelf.downloadTableView cellForRowAtIndexPath:indexPath];
                [cell configCellByTrackDownload:currentTrackDownload indexPath:indexPath];
            }
        });
    }];
    
    trackDownload.progress = [[NSProgress alloc] init];
    trackDownload.identifier = downloadCallback;
    trackDownload.status = ZASessionTaskStatusRunning;
    self.currentDownload[downloadCallback.identifier] = trackDownload;
    [self.downloadTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
}

- (void)didSelectPauseAtIndexPath:(NSIndexPath *)indexPath {
    TrackDownload *trackDownload = [self.trackDownloads objectAtIndex:indexPath.row];
    if (nil == trackDownload) { return; }
    
    [ZADownloadManager.sharedManager pauseDownloadTaskByDownloadCallback:trackDownload.identifier];
    trackDownload.status = ZASessionTaskStatusPaused;
    
    [self.downloadTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
}

- (void)didSelectResumeAtIndexPath:(NSIndexPath *)indexPath {
    TrackDownload *trackDownload = [self.trackDownloads objectAtIndex:indexPath.row];
    if (nil == trackDownload) { return; }
    
    [ZADownloadManager.sharedManager resumeDownloadTaskByDownloadCallback:trackDownload.identifier];
    trackDownload.status = ZASessionTaskStatusRunning;
    [self.downloadTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
}

- (void)didSelectCancelAtIndexPath:(NSIndexPath *)indexPath {
    TrackDownload *trackDownload = [self.trackDownloads objectAtIndex:indexPath.row];
    if (nil == trackDownload) { return; }
    
    [ZADownloadManager.sharedManager cancelDownloadTaskByDownloadCallback:trackDownload.identifier];
    trackDownload.status = ZASessionTaskStatusCancelled;
    [self.downloadTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
}

@end
