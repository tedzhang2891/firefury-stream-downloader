//
//  OperationReceivingLinksOfVideo.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "OperationReceivingLinksOfVideo.h"
#import "EPYoutubeHelper.h"
#import "YDUserDefaults.h"
#import "YoutubeDownloaderAppDelegate.h"
#import "DownloadItem.h"
#import "MainWindowController.h"

@implementation OperationReceivingLinksOfVideo

- (unsigned long long)getResolutionFromString:(id)resolutionString forItag:(int)itag {
    if (itag >= 121 && [resolutionString isEqualToString:@""]) {
        return 0;
    }
    
    NSNumber* retResolution = nil;
    
    NSDictionary* resolutionDict = @{@5:@240,
                                     @6:@270,
                                     @17:@144,
                                     @18:@360,
                                     @22:@720,
                                     @34:@360,
                                     @35:@480,
                                     @36:@240,
                                     @37:@1080,
                                     @38:@3072,
                                     @43:@360,
                                     @44:@480,
                                     @45:@720,
                                     @46:@1080,
                                     @82:@360,
                                     @83:@240,
                                     @84:@720,
                                     @85:@520,
                                     @100:@360,
                                     @101:@480,
                                     @102:@720,
                                     @120:@720,
                                     @133:@240,
                                     @137:@1080,
                                     @138:@2160,
                                     @160:@144,
                                     @242:@240,
                                     @243:@360,
                                     @244:@480,
                                     @247:@720,
                                     @248:@1080,
                                     @264:@1440,
                                     @266:@2160,
                                     @271:@1440,
                                     @272:@2160,
                                     @278:@144,
                                     @298:@720,
                                     @299:@1080,
                                     @302:@720,
                                     @303:@1080
                                     };
    
    NSNumber* resolutionNum = [resolutionDict objectForKey:[NSNumber numberWithInt:itag]];
    if (resolutionNum) {
        if ([resolutionNum intValue] >= [resolutionString intValue]) {
            retResolution = resolutionNum;
        }
        else {
            retResolution = [NSNumber numberWithInt:[resolutionString intValue]];
        }
    }
    else {
        retResolution = [NSNumber numberWithInt:[resolutionString intValue]];
    }
    
    return [retResolution intValue];
}

- (void)getEstimatedSizeForItem:(DownloadItem*)downloadItem {
    if (downloadItem.urlOfSegments) {
        NSURLResponse* response = nil;
        NSError* error = nil;
        
        NSString* urlString = downloadItem.urlOfSegments[0];
        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [mRequest setHTTPMethod:@"HEAD"];
        [NSURLConnection sendSynchronousRequest:mRequest returningResponse:&response error:&error];
        
        if (!error) {
            [downloadItem setTotalExpectedBytes:[response expectedContentLength]];
        }
        
        NSUInteger count = downloadItem.urlOfSegments.count;
        NSString* itemStr = downloadItem.urlOfSegments[(count > 3) + 1];
        
        NSMutableURLRequest* mRequest1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:itemStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [mRequest setHTTPMethod:@"HEAD"];
        [NSURLConnection sendSynchronousRequest:mRequest1 returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"%@", [error description]);
        }
        else {
            long long expectedLen = [response expectedContentLength];
            long long totalExpectedBytes = [downloadItem totalExpectedBytes];
            totalExpectedBytes += (expectedLen * downloadItem.urlOfSegments.count);
            [downloadItem setTotalExpectedBytes:totalExpectedBytes];
        }
    }
    else {
        id arrayArgment = [downloadItem.url componentsSeparatedByString:@"&"];
        for (NSString* argment in arrayArgment) {
            if ([argment hasPrefix:@"clen="]) {
                id subArgment = [argment componentsSeparatedByString:@"="];
                NSString* argExpectedBytes = subArgment[1];
                long long longExpectedBytes = [argExpectedBytes longLongValue];
                [downloadItem setExpectedBytes:longExpectedBytes];
                [downloadItem setTotalExpectedBytes:longExpectedBytes];
            }
        }
    }
}

- (void)main {
    id delegate = [NSApp delegate];
    EPYoutubeHelper* youtubeHelper = [[EPYoutubeHelper alloc] init];
    if ([YDUserDefaults loggingIsEnabled]) {
        [youtubeHelper setEnableLog:YES];
        [youtubeHelper setPathToLogFile:[delegate pathToStreamupLogFile]];
    }
    
    id cookies = [delegate cookies];
    [youtubeHelper setCookies:cookies];
    
    NSInteger nIndex = 0;
    
    
    
    for (id url in self.urls) {
        ++ nIndex;
        id videoLinks = [youtubeHelper getAllLinksForDownloadsOfVideo:url];
        id videoLinksErr = [videoLinks objectForKey:@"error"];
        if (videoLinks && !videoLinksErr && [videoLinks count]) {
            id generalInfo = [videoLinks objectForKey:@"generalInfo"];
            DownloadItem* parentItem = [[DownloadItem alloc] init];
            [parentItem setPageUrl:url];
            [parentItem setTitle:[generalInfo objectForKey:@"title"]];
            [parentItem setThumbnailUrl:[generalInfo objectForKey:@"thumbnail"]];
            [parentItem setLengthSeconds:[[generalInfo objectForKey:@"duration"] unsignedIntegerValue]];
            [parentItem setParent:nil];
            [parentItem setItag:0];
            [parentItem setSig:nil];
            [parentItem setVideoResources:[NSMutableArray array]];
            
            id links = [videoLinks objectForKey:@"links"];
            if (links && [links count]) {
                NSMutableArray* linksArray = [NSMutableArray array];
                for (id link in links) {
                    DownloadItem* subItemCopy = nil;
                    DownloadItem* subItem = [[DownloadItem alloc] init];
                    [subItem setParent:parentItem];
                    [subItem setThumbnailUrl:parentItem.thumbnailUrl];
                    [subItem setItag:[[link objectForKey:@"itag"] intValue]];
                    [subItem setFps:[[link objectForKey:@"fps"] intValue]];
                    [subItem setMimeType:[link objectForKey:@"type"]];
                    
                    NSRange searchRange = [subItem.mimeType rangeOfString:@"audio/mp4"];
                    if (searchRange.location == NSNotFound) {
                        [subItem setFormat:[link objectForKey:@"format"]];
                    }
                    else {
                        [subItem setFormat:@"mp3"];
                    }
                    
                    unsigned long long resolution = [self getResolutionFromString:[link objectForKey:@"resolution"] forItag:subItem.itag];
                    [subItem setResolution:resolution];
                    
                    searchRange = [subItem.mimeType rangeOfString:@"video"];
                    if (searchRange.location == NSNotFound || subItem.resolution) {
                        if (subItem.resolution) {
                            NSString* titleInfo = nil;
                            if (subItem.fps < 31) {
                                titleInfo = [NSString stringWithFormat:@"%@ (%llup)", parentItem.title, subItem.resolution];
                            }
                            else {
                                titleInfo = [NSString stringWithFormat:@"%@ (%llup %llufps)", parentItem.title, subItem.resolution, subItem.fps];
                            }
                            [subItem setTitle:titleInfo];
                        }
                        else {
                            [subItem setTitle:parentItem.title];
                        }
                        
                        [subItem setUrl:[link objectForKey:@"url"]];
                        [subItem setTotalExpectedBytes:-1];
                        id urlArgments = [subItem.url componentsSeparatedByString:@"&"];
                        
                        for (NSString* urlarg in urlArgments) {
                            if ([urlarg hasPrefix:@"clen="]) {
                                id subUrlArg = [urlarg componentsSeparatedByString:@"="];
                                NSString* subUrlArgExpectedBytes = subUrlArg[1];
                                long long longExpectedBytes = [subUrlArgExpectedBytes longLongValue];
                                [subItem setExpectedBytes:longExpectedBytes];
                                [subItem setTotalExpectedBytes:longExpectedBytes];
                                break;
                            }
                        }
                        
                        id segments = [link objectForKey:@"segments"];
                        if (segments) {
                            [subItem setUrlOfSegments:[NSMutableArray arrayWithArray:segments]];
                            [self getEstimatedSizeForItem:subItem];
                        }
                        [subItem setCurrentState:0xFFFFFFFF];
                        [linksArray addObject:subItem];
                        
                        if (!subItemCopy) {
                            if (subItem.itag == 18) {
                                DownloadItem* subItemCopy = [subItem copy];
                                [subItemCopy setMimeType:@"audio/mp4"];
                                [subItemCopy setFormat:@"mp3"];
                                [subItemCopy setResolution:0];
                                [subItemCopy setTitle:parentItem.title];
                                [linksArray addObject:subItemCopy];
                            }
                            else {
                                subItemCopy = nil;
                            }
                        }
                    }
                }
                NSSortDescriptor* sortFormat = [NSSortDescriptor sortDescriptorWithKey:@"format" ascending:NO];
                NSSortDescriptor* sortResolution = [NSSortDescriptor sortDescriptorWithKey:@"resolution" ascending:NO];
                NSSortDescriptor* sortFps = [NSSortDescriptor sortDescriptorWithKey:@"fps" ascending:NO];
                
                NSArray* infoArray = @[sortFormat, sortResolution, sortFps];
                [linksArray sortUsingDescriptors:infoArray];
                [parentItem.videoResources addObjectsFromArray:linksArray];
                
                NSNumber* numIndex = [NSNumber numberWithUnsignedInteger:nIndex];
                
                [self.controller performSelectorOnMainThread:@selector(processOfGettingLinksIsComplete:) withObject:@{@"root":parentItem, @"linksNumber":numIndex} waitUntilDone:NO];
            }
            else {
                NSNumber* numIndex = [NSNumber numberWithUnsignedInteger:nIndex];
                [self.controller performSelectorOnMainThread:@selector(processOfGettingLinksIsComplete:) withObject:@{@"root":parentItem, @"linksNumber":numIndex} waitUntilDone:NO];
            }
        }
        else {
            NSInteger errCode = 0;
            NSDictionary* errUserInfo = nil;
            NSDictionary* linksInfo = nil;
            if (videoLinksErr) {
                long codeValue = [[videoLinksErr objectForKey:@"code"] longValue];
                id reason = [videoLinksErr objectForKey:@"reason"];
                if (codeValue == 13 && reason) {
                    errUserInfo = @{@"errorReason":[videoLinksErr objectForKey:@"reason"]};
                    errCode = [[videoLinksErr objectForKey:@"code"] integerValue];
                    linksInfo = @{@"linksNumber": [NSNumber numberWithUnsignedInteger:nIndex], @"reason":reason};
                }
                else {
                    linksInfo = @{@"linksNumber": [NSNumber numberWithUnsignedInteger:nIndex]};
                    errUserInfo = @{@"errorReason":@"No links for video downloads"};
                    errCode = 0;
                }
            }
            
            NSError* err = [NSError errorWithDomain:@"" code:errCode userInfo:errUserInfo];
            if (err) {
                [delegate saveInLogFile:@{@"error":err ,@"otherInfo":url}];
            }
            
            [self.controller performSelectorOnMainThread:@selector(processOfGettingLinksIsComplete:) withObject:linksInfo waitUntilDone:NO];
        }
    }
}

- (id)initOperationForVideos:(id)videos forController:(id)mainWindowCtrl {
    if (self = [super init]) {
        [self setUrls:videos];
        [self setController:mainWindowCtrl];
        return self;
    } else {
        return nil;
    }
}

@end
