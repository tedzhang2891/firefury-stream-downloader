//
//  OperationOfSavingVideoData.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationOfSavingVideoData.h"
#import "MainWindowController.h"
#import "DownloadItem.h"

@implementation OperationOfSavingVideoData

- (void)operationOfSavingVideoCompleted { 
    DownloadItem* downloadItem = self.item;
    if (downloadItem.isVideoDASH || downloadItem.isVideoDashMpd) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.item setWasSavedVideo:YES];
            if (self.item.wasSavedVideo) {
                if (self.item.wasSavedSound) {
                    [self.controller conversionOfVideoForItem:self.item];
                }
            }
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* itemKind = @{@"item": downloadItem, @"kindOfItem": [NSNumber numberWithInt:1]};
            [self.controller removeProgressInFinderForItem:itemKind];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* itemKind = @{@"item": downloadItem, @"kindOfItem": [NSNumber numberWithInt:4]};
            [self.controller removeProgressInFinderForItem:itemKind];
            [self.controller multimediaWasSaved:itemKind];
        });
    }
}

- (void)main { 
    DownloadItem* downloadItem = self.item;
    NSString* filePath = nil;
    
    if (downloadItem.isVideoDASH) {
        filePath = [downloadItem pathToFileDashVideo];
    }
    else {
        filePath = [downloadItem pathToTheSavedVideo];
    }
    
    NSFileHandle* downloadFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!downloadFileHandle) {
        if (!downloadItem.videoFileWasDeleted) {
            NSException* exception = [NSException exceptionWithName:@"FileNotFoundException" reason:@"File not found on system" userInfo:nil];
            
            @throw exception;
        }
    }
    
    [downloadFileHandle seekToEndOfFile];
    [downloadFileHandle writeData:self.data];
    unsigned long long fileOffset = [downloadFileHandle offsetInFile];
    unsigned long long totalRecvBytes = [downloadItem totalReceivedBytes];
    unsigned long long recvBytes = [downloadItem receivedBytes];
    
    if (recvBytes + totalRecvBytes == downloadItem.totalExpectedBytes) {
        if (fileOffset < downloadItem.totalExpectedBytes) {
            [downloadItem setCurrentState:11];
        }
    }
    
    if (self.isLastOperation) {
        [downloadItem setCurrentState:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.controller refreshDataInDownloadsListForItem:self.item];
            [self.controller.tableDownloadList reloadData];
            [self.controller progressInFinderForItem:self.item];
        });
        [self operationOfSavingVideoCompleted];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.controller refreshDataInDownloadsListForItem:self.item];
        [self.controller progressInFinderForItem:self.item];
    });
    
    [downloadFileHandle closeFile];
    [self setData:nil];
}

@end
