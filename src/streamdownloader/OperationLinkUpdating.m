//
//  OperationLinkUpdating.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationLinkUpdating.h"
#import "YoutubeDownloaderAppDelegate.h"
#import "MainWindowController.h"
#import "EPYoutubeHelper.h"
#import "YDUserDefaults.h"
#import "DownloadItem.h"

@implementation OperationLinkUpdating

- (void)main { 
    id delegate = [NSApp delegate];
    EPYoutubeHelper* youtubeHelper = [[EPYoutubeHelper alloc] init];
    if ([YDUserDefaults loggingIsEnabled]) {
        [youtubeHelper setEnableLog:YES];
        [youtubeHelper setPathToLogFile:[delegate pathToStreamupLogFile]];
    }
    
    id cookies = [delegate cookies];
    [youtubeHelper setCookies:cookies];
    
    if (self.isCancelled) {
        // youtubeHelper need to release, but we use the Arc so don't warry about this
        ;
    }
    else {
        NSString* pageUrl = nil;
        DownloadItem* parentItem = nil;
        if (self.item.parent) {
            pageUrl = [self.item.parent pageUrl];
            parentItem = self.item.parent;
        }
        else {
            pageUrl = [self.item pageUrl];
            parentItem = nil;
        }
        
        id allLinks = [youtubeHelper getAllLinksForDownloadsOfVideo:pageUrl];
        id links = [allLinks objectForKey:@"links"];
        if ([links count]) {
            if (parentItem) {
                for (id link in links) {
                    id videos = [parentItem videoResources];
                    for (id video in videos) {
                        if ([video itag] == [[link objectForKey:@"itag"] intValue]) {
                            if ([video urlOfSegments] && self.item.urlOfSegments.count) {
                                [video setUrl:[link objectForKey:@"url"]];
                                [[video urlOfSegments] removeAllObjects];
                                [[video urlOfSegments] addObjectsFromArray:[link objectForKey:@"segments"]];
                                [[video urlOfSoundSegments] removeAllObjects];
                                [video setUrlOfSoundSegments:nil];
                            }
                            else {
                                [video setUrl:[link objectForKey:@"url"]];
                            }
                        }
                    }
                }
            }
            else {
                for (id link in links) {
                    if (self.item.itag == [[link objectForKey:@"itag"] intValue]) {
                        if (self.item.urlOfSegments && self.item.urlOfSoundSegments.count) {
                            [self.item setUrl:[link objectForKey:@"url"]];
                            [self.item.urlOfSegments removeAllObjects];
                            [self.item.urlOfSegments addObjectsFromArray:[link objectForKey:@"segments"]];
                            [self.item.urlOfSoundSegments removeAllObjects];
                            [self.item setUrlOfSoundSegments:nil];
                        }
                        else {
                            [self.item setUrl:[link objectForKey:@"url"]];
                        }
                    }
                }
            }
        }
        else {
            [self.item setUpdateError:YES];
            NSDictionary* errInfoDict = @{@"errorReason":@"Can not update the links to download the video"};
            NSError* err = [NSError errorWithDomain:@"" code:0 userInfo:errInfoDict];
            NSDictionary* moreErrDict = @{@"error": err, @"otherInfo":pageUrl};
            [delegate saveInLogFile:moreErrDict];
        }
        
        [self.controller performSelectorOnMainThread:@selector(processOfUpdatingUrlIsCompleteForItem:) withObject:self.item waitUntilDone:NO];
    }
}

- (id)initOperationForDownloadItem:(id)downloadItem forController:(id)controller {
    if (self = [super init]) {
        [self setController:controller];
        [self setItem:downloadItem];
    }
    return self;
}

@end
