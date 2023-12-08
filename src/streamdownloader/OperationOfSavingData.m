//
//  OperationOfSavingData.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationOfSavingData.h"
#import "MainWindowController.h"
#import "DownloadItem.h"

@implementation OperationOfSavingData

- (void)handlingExceptions:(id)exception { 
    DownloadItem* downloadItem = self.item;
    MainWindowController* controller = self.controller;
    NSDictionary* itemInfo = @{@"item": downloadItem};
    
    NSRange searchRange = [[exception reason] rangeOfString:@"Device not configured"];
    if (searchRange.location != NSNotFound) {
        if ([downloadItem deviceWasDeleted]) {
            return;
        }
        
        [controller performSelectorOnMainThread:@selector(deviceNotConfiguredWhenLoading) withObject:nil waitUntilDone:NO];
        
        [downloadItem setDeviceWasDeleted:YES];
        [downloadItem setVideoFileWasDeleted:YES];
    }
    
    searchRange = [[exception reason] rangeOfString:@"File not found on system"];
    if (searchRange.location != NSNotFound) {
        searchRange = [[exception reason] rangeOfString:@"No space left on device"];
        if (searchRange.location != NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoFreeSpace" object:nil userInfo:itemInfo];
        }
        return;
    }
    
    if (![downloadItem videoFileWasDeleted] || ![downloadItem audioFileWasDeleted]) {
        [controller performSelectorOnMainThread:@selector(fileProbablyWasDeleted:) withObject:itemInfo waitUntilDone:NO];
        
        [downloadItem setVideoFileWasDeleted:YES];
    }
}

- (id)initWithData:(id)data forItem:(id)downloadItem andController:(id)controller {
    if (self = [super init]) {
        [self setController:controller];
        [self setItem:downloadItem];
        [self setData:data];
    }
    return self;
}

@end
