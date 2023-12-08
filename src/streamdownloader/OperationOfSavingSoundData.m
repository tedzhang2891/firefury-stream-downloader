//
//  OperationOfSavingSoundData.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationOfSavingSoundData.h"
#import "MainWindowController.h"
#import "DownloadItem.h"

@implementation OperationOfSavingSoundData

- (void)operationOfSavingSoundCompleted { 
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.item setWasSavedSound:YES];
        if (self.item.wasSavedSound) {
            if (self.item.wasSavedVideo) {
                [self.controller conversionOfVideoForItem:self.item];
            }
        }
    });
}

- (void)main { 
    DownloadItem* downloadItem = self.item;
    NSFileHandle* downloadFileHandle = [NSFileHandle fileHandleForWritingAtPath:[downloadItem pathToFileDashSound]];
    
    if (!downloadFileHandle) {
        NSException* exception = [NSException exceptionWithName:@"FileNotFoundException" reason:@"File not found on system" userInfo:nil];
        
        @throw exception;
    }
    
    [downloadFileHandle seekToEndOfFile];
    [downloadFileHandle writeData:self.data];
    [downloadFileHandle offsetInFile];
    
    if (self.isLastOperation) {
        [self operationOfSavingSoundCompleted];
    }
    
    [downloadFileHandle closeFile];
    [self setData:nil];
}

@end
