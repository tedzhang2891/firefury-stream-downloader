//
//  OperationOfSavingAudioData.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationOfSavingAudioData.h"
#import "MainWindowController.h"
#import "DownloadItem.h"

@implementation OperationOfSavingAudioData

- (void)operationOfSavingAudioCompleted { 
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.controller conversionOfAudioForItem:self.item];
    });
}

- (void)main { 
    DownloadItem* downloadItem = self.item;
    if (self.data || downloadItem.currentState != 4) {
        NSFileHandle* downloadFileHandle = [NSFileHandle fileHandleForWritingAtPath:downloadItem.pathToFileDashAudio];
        
        if (!downloadFileHandle) {
            if (!downloadItem.audioFileWasDeleted) {
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
                [downloadItem setCurrentState:1];
            }
        }
        
        if (self.isLastOperation) {
            [downloadItem setCurrentState:4];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controller refreshDataInDownloadsListForItem:self.item];
                [self.controller.tableDownloadList reloadData];
                [self.controller progressInFinderForItem:self.item];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.controller refreshDataInDownloadsListForItem:self.item];
            [self.controller progressInFinderForItem:self.item];
        });
    }
    else {
        [self operationOfSavingAudioCompleted];
    }
}

@end
