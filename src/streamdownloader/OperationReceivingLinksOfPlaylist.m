//
//  OperationReceivingLinksOfPlaylist.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationReceivingLinksOfPlaylist.h"
#import "YoutubeDownloaderAppDelegate.h"
#import "MainWindowController.h"
#import "EPYoutubeHelper.h"
#import "YDUserDefaults.h"

@implementation OperationReceivingLinksOfPlaylist

- (void)main { 
    EPYoutubeHelper* youtubeHelper = [[EPYoutubeHelper alloc] init];
    id delegate = [NSApp delegate];
    
    [youtubeHelper setCookies:[delegate cookies]];
    if ([YDUserDefaults loggingIsEnabled]) {
        [youtubeHelper setEnableLog:YES];
        [youtubeHelper setPathToLogFile:[delegate pathToStreamupLogFile]];
    }
    
    id allUrls = [youtubeHelper getAllURLsInPlaylistOrChannel:self.pageUrl];
    [allUrls setObject:self.pageUrl forKey:@"playlistUrl"];
    [allUrls setObject:[NSNumber numberWithUnsignedInteger:self.currentLinksNumber] forKey:@"playlistNumber"];
    [self.controller performSelectorOnMainThread:@selector(processOfGettingPlaylistLinksIsComplete:) withObject:allUrls waitUntilDone:NO];
}

- (id)initOperationForPlaylist:(id)pageUrl forController:(id)controller currentLinksNumber:(unsigned long long)linksNumber {
    if (self = [super init]) {
        [self setController:controller];
        [self setPageUrl:pageUrl];
        [self setCurrentLinksNumber:linksNumber];
    }
    return self;
}

@end
