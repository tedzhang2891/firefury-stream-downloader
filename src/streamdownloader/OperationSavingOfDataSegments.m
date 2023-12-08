//
//  OperationSavingOfDataSegments.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationSavingOfDataSegments.h"
#import "DownloadItem.h"
#import "MainWindowController.h"

@implementation OperationSavingOfDataSegments

- (void)main {
    DownloadItem* downloadItem = self.item;
    NSFileHandle* downloadFileHandle = nil;
    NSString* filePath = nil;
    
    if (self.kindOfItem == 7) {
        filePath = [downloadItem pathToFileDashAudio];
    }
    else if (self.kindOfItem == 5) {
        filePath = [downloadItem pathToFileDashVideo];
    }
    else if (self.kindOfItem == 6) {
        filePath = [downloadItem pathToFileDashSound];
    }
    else {
        filePath = nil;
    }
    
    if (filePath) {
        downloadFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    unsigned long long recvedBytes = [downloadItem receivedBytes];
    [downloadItem setReceivedBytes:(recvedBytes + self.data.length)];
    
    if (!downloadFileHandle) {
        NSException* exception = [NSException exceptionWithName:@"FileNotFoundException" reason:@"File not found on system" userInfo:nil];
        
        @throw exception;
        
        NSDictionary* itemInfo = @{@"item": self.item, @"kindOfItem": [NSNumber numberWithInt:self.kindOfItem]};
        
        NSRange searchRange = [[exception reason] rangeOfString:@"Device not configured"];
        if (searchRange.location == NSNotFound) {
            searchRange = [[exception reason] rangeOfString:@"File not found on system"];
            if (searchRange.location == NSNotFound) {
                searchRange = [[exception reason] rangeOfString:@"No space left on device"];
                if (searchRange.location != NSNotFound) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFreeSpace" object:nil userInfo:itemInfo];
                }
                
            }
            else {
                if (self.item.videoFileWasDeleted) {
                    if (!self.item.audioFileWasDeleted) {
                        [self.controller performSelectorOnMainThread:@selector(fileProbablyWasDeleted:) withObject:itemInfo waitUntilDone:NO];
                        [self.item setAudioFileWasDeleted:YES];
                    }
                }
                else {
                    [self.controller performSelectorOnMainThread:@selector(fileProbablyWasDeleted:) withObject:itemInfo waitUntilDone:NO];
                    [self.item setVideoFileWasDeleted:YES];
                }
            }
        }
        else {
            if (!self.item.deviceWasDeleted) {
                [self.controller performSelectorOnMainThread:@selector(deviceNotConfiguredWhenLoading) withObject:nil waitUntilDone:NO];
                [self.item setDeviceWasDeleted:YES];
                [self.item setVideoFileWasDeleted:YES];
            }
        }
    }
    
    [downloadFileHandle seekToEndOfFile];
    [downloadFileHandle writeData:self.data];
    unsigned long long fileSize = [downloadFileHandle seekToEndOfFile];
    [self setData:nil];
    
    [self.controller performSelectorOnMainThread:@selector(refreshDataInDownloadsListForItem:) withObject:self.item waitUntilDone:NO];
    [self.controller performSelectorOnMainThread:@selector(progressInFinderForItem:) withObject:self.item waitUntilDone:NO];
    
    if (fileSize >= self.expectedBytes) {
        if (self.kindOfItem == 5 || self.kindOfItem == 7) {
            [self.controller performSelectorOnMainThread:@selector(startDownloadOfNextSegmentForItem:) withObject:self.item waitUntilDone:NO];
        }
        if (self.kindOfItem == 6) {
            [self.controller performSelectorOnMainThread:@selector(startDownloadOfNextSoundSegmentForItem:) withObject:self.item waitUntilDone:NO];
        }
    }
}

- (id)initWithData:(id)data forItem:(id)downloadItem type:(int)nType andController:(id)controller {
    if (self = [super init]) {
        [self setController:controller];
        [self setKindOfItem:nType];
        [self setItem:downloadItem];
        [self setData:data];
        
        unsigned long long expectedBytes = 0;
        
        if (self.kindOfItem == 6) {
            expectedBytes = [self.item expectedBytesSound];
        }
        else {
            expectedBytes = [self.init expectedBytes];
        }
        
        [self setExpectedBytes:expectedBytes];
    }
    return self;
}

@end
