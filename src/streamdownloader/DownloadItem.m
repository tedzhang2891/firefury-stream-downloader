//
//  DownloadItem.m
//  streamdownloader
//
//  Created by ted zhang on 5/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DownloadItem.h"
#import "YDUserDefaults.h"

@implementation DownloadItem

+ (DownloadItem*)downloadItemFromDictionaryRepresentation:(id)dict {
    DownloadItem* item = [[DownloadItem alloc] initWithDictionaryRepresentation:dict];
    return item;
}

- (DownloadItem*)copyWithZone:(NSZone *)zone {
    DownloadItem* copy = [[self class] allocWithZone:zone];
    [copy setParent:self.parent];
    [copy setItag:self.itag];
    [copy setMimeType:self.mimeType];
    [copy setFormat:self.format];
    [copy setResolution:self.resolution];
    [copy setTitle:self.title];
    [copy setUrl:self.url];
    [copy setThumbnailUrl:self.thumbnailUrl];
    return copy;
}

- (id)initWithDictionaryRepresentation:(id)dict {
    if (self = [super init]) {
        NSString* parentTitle = [dict objectForKey:@"ParentTitle"];
        if (parentTitle) {
            [self setParentTitle:parentTitle];
        }
        
        NSString* resourceTitle = [dict objectForKey:@"ResourceTitle"];
        if (resourceTitle) {
            [self setTitle:resourceTitle];
        }
        
        NSString* resourceType = [dict objectForKey:@"ResourceType"];
        [self setFormat:resourceType];
        
        NSString* resourceMimeType = [dict objectForKey:@"ResourceMimeType"];
        [self setMimeType:resourceMimeType];
        
        NSUInteger resourceResolution = [[dict objectForKey:@"ResourceResolution"] unsignedIntegerValue];
        [self setResolution:resourceResolution];
        
        NSUInteger resourceTag = [[dict objectForKey:@"ResourceTag"] unsignedIntegerValue];
        [self setItag:resourceTag];
        
        int currentState = [[dict objectForKey:@"CurrentStateForDownloadItem"] intValue];
        [self setCurrentState:currentState];
        
        long long resourceSize = [[dict objectForKey:@"ResourceSize"] longLongValue];
        [self setTotalExpectedBytes:resourceSize];
        
        do {
            if (self.currentState) {
                double multiplier = [[dict objectForKey:@"MultiplierForUpdate"] doubleValue];
                [self setMultiplier:multiplier];
                
                long long totalReceivedBytes = [[dict objectForKey:@"TotalReceivedBytes"] longLongValue];
                [self setTotalReceivedBytes:totalReceivedBytes];
                
                long long receivedBytes = [[dict objectForKey:@"ReceivedBytes"] longLongValue];
                [self setReceivedBytes:receivedBytes];
                
                NSString* pathToDownloadDir = [dict objectForKey:@"PathToDownloadDir"];
                if (pathToDownloadDir) {
                    [self setDownloadDir:pathToDownloadDir];
                }
                
                NSString* pathToPackageOfDownload = [dict objectForKey:@"PathToPackageOfDownload"];
                if (pathToPackageOfDownload) {
                    [self setPathToPackageOfDownload:pathToPackageOfDownload];
                }
                
                if ([self.mimeType hasPrefix:@"video"]) {
                    NSString* pathToFileDashVideo = [dict objectForKey:@"PathToFileDashVideo"];
                    if (pathToFileDashVideo) {
                        [self setPathToFileDashVideo:pathToFileDashVideo];
                    }
                    
                    NSString* pathToFileDashSound = [dict objectForKey:@"PathToFileDashSound"];
                    if (pathToFileDashSound) {
                        [self setPathToFileDashSound:pathToFileDashSound];
                    }
                    
                    BOOL bWasSavedVideo = [[dict objectForKey:@"WasSavedVideo"] boolValue];
                    [self setWasSavedVideo:bWasSavedVideo];
                    
                    BOOL bWasSavedAudio = [[dict objectForKey:@"WasSavedAudio"] boolValue];
                    [self setWasSavedSound:bWasSavedAudio];
                    
                    id urlOfSeg = [dict objectForKey:@"UrlOfSegments"];
                    if (urlOfSeg) {
                        NSMutableArray* urlOfSegments = [NSMutableArray arrayWithArray:urlOfSeg];
                        [self setUrlOfSegments:urlOfSegments];
                        
                        int numOfSegment = [[dict objectForKey:@"NumOfSegment"] intValue];
                        [self setNumOfSegment:numOfSegment];
                        
                        id urlOfSoundSeg = [dict objectForKey:@"UrlOfSoundSegments"];
                        if (urlOfSoundSeg) {
                            NSMutableArray* urlOfSoundSegments = [NSMutableArray arrayWithArray:urlOfSoundSeg];
                            [self setUrlOfSoundSegments:urlOfSoundSegments];
                            
                            int numOfSoundSegment = [[dict objectForKey:@"NumOfSoundSegment"] intValue];
                            [self setNumOfSoundSegment:numOfSoundSegment];
                        }
                        
                        long long totalExpectedBytesOfSound = [[dict objectForKey:@"TotalExpectedBytesOfSound"] longLongValue];
                        [self setTotalExpectedBytesOfSound:totalExpectedBytesOfSound];
                    }
                    
                    if (!self.isVideoDASH) {
                        break;
                    }
                    
                    NSString* soundItemURL = [dict objectForKey:@"SoundItemURL"];
                    if (soundItemURL) {
                        [dict setUrlSoundItem:soundItemURL];
                    }
                    
                    long long totalExpectedBytesOfSound = [[dict objectForKey:@"TotalExpectedBytesOfSound"] longLongValue];
                    [self setTotalExpectedBytesOfSound:totalExpectedBytesOfSound];
                    
                    long long totalReceivedBytesSound = [[dict objectForKey:@"TotalReceivedBytesSound"] longLongValue];
                    [self setTotalReceivedBytesSound:totalReceivedBytesSound];
                    
                    long long receivedBytesSound = [[dict objectForKey:@"ReceivedBytesSound"] longLongValue];
                    [self setReceivedBytesSound:receivedBytesSound];
                    
                }
                else {
                    if (![self.mimeType hasPrefix:@"audio"]) {
                        break;
                    }
                    
                    NSString* pathToFileDashAudio = [dict objectForKey:@"PathToFileDashAudio"];
                    if (pathToFileDashAudio) {
                        [self setPathToFileDashAudio:pathToFileDashAudio];
                    }
                    
                    NSString* pathToFileWithCover = [dict objectForKey:@"PathToFileWithCover"];
                    if (pathToFileWithCover) {
                        [self setPathToFileWithCover:pathToFileWithCover];
                    }
                    
                    NSString* pathToCoverImage = [dict objectForKey:@"PathToCoverImage"];
                    if (pathToCoverImage) {
                        [self setCoverImage:pathToCoverImage];
                    }
                }
            }
        } while (NO);
    }
    
    NSString* pathToFolderWithSubtitles = [dict objectForKey:@"PathToFolderWithSubtitles"];
    if (pathToFolderWithSubtitles) {
        [self setFolderOfVideoWithSub:pathToFolderWithSubtitles];
    }
    
    NSString* pathToTheSavedVideoFile = [dict objectForKey:@"PathToTheSavedVideoFile"];
    if (pathToTheSavedVideoFile) {
        [self setFolderOfVideoWithSub:pathToTheSavedVideoFile];
    }
    
    NSString* pathToTheSavedAudioFile = [dict objectForKey:@"PathToTheSavedAudioFile"];
    if (pathToTheSavedAudioFile) {
        [self setFolderOfVideoWithSub:pathToTheSavedAudioFile];
    }
    
    NSString* thumbnailURL = [dict objectForKey:@"ThumbnailURL"];
    [self setThumbnailUrl:thumbnailURL];
    
    NSString* pageURL = [dict objectForKey:@"PageURL"];
    [self setPageUrl:pageURL];
    
    NSString* resourceURL = [dict objectForKey:@"ResourceURL"];
    [self setUrl:resourceURL];
    
    NSDate* startDownload = [dict objectForKey:@"DateOfSavingResource"];
    if (startDownload) {
        [self setStartDownload:startDownload];
    }
    
    return self;
}

- (id)dictionaryRepresentation { 
    NSMutableDictionary* mDict = [NSMutableDictionary dictionary];
    DownloadItem* parent = self.parent;
    if (parent.title) {
        [mDict setObject:parent.title forKey:@"ParentTitle"];
    }
    
    if (self.title) {
        [mDict setObject:self.title forKey:@"ResourceTitle"];
    }
    
    [mDict setObject:self.format forKey:@"ResourceType"];
    [mDict setObject:self.mimeType forKey:@"ResourceMimeType"];
    [mDict setObject:[NSNumber numberWithUnsignedInteger:self.resolution] forKey:@"ResourceResolution"];
    [mDict setObject:[NSNumber numberWithUnsignedInteger:self.itag] forKey:@"ResourceTag"];
    [mDict setObject:[NSNumber numberWithInt:self.currentState] forKey:@"CurrentStateForDownloadItem"];
    [mDict setObject:[NSNumber numberWithLongLong:self.totalExpectedBytes] forKey:@"ResourceSize"];
    
    NSString* downloadDir = nil;
    if (self.currentState) {
        if (self.downloadDir) {
            downloadDir = self.downloadDir;
        }
        else {
            downloadDir = [[YDUserDefaults currentUserPreferences] objectForKey:@"PathToDownloadsFolder"];
        }
        
        [mDict setObject:downloadDir forKey:@"PathToDownloadDir"];
        [mDict setObject:[NSNumber numberWithDouble:self.multiplier] forKey:@"MultiplierForUpdate"];
        [mDict setObject:[NSNumber numberWithLongLong:self.totalReceivedBytes] forKey:@"TotalReceivedBytes"];
        [mDict setObject:[NSNumber numberWithLongLong:self.receivedBytes] forKey:@"ReceivedBytes"];
        
        if ([self pathToPackageOfDownload]) {
            [mDict setObject:self.pathToPackageOfDownload forKey:@"PathToPackageOfDownload"];
        }
        
        if ([self.mimeType hasPrefix:@"video"]) {
            if (self.pathToFileDashVideo) {
                [mDict setObject:self.pathToFileDashVideo forKey:@"PathToFileDashVideo"];
            }
            
            if (self.pathToFileDashSound) {
                [mDict setObject:self.pathToFileDashSound forKey:@"PathToFileDashSound"];
            }
            
            [mDict setObject:[NSNumber numberWithBool:self.wasSavedVideo] forKey:@"WasSavedVideo"];
            [mDict setObject:[NSNumber numberWithBool:self.wasSavedSound] forKey:@"WasSavedAudio"];
            
            if (!self.urlOfSegments && self.isVideoDASH) {
                if (self.urlSoundItem) {
                    [mDict setObject:self.urlSoundItem forKey:@"SoundItemURL"];
                }
                
                [mDict setObject:[NSNumber numberWithLongLong:self.totalExpectedBytesOfSound] forKey:@"TotalExpectedBytesOfSound"];
                [mDict setObject:[NSNumber numberWithLongLong:self.totalReceivedBytesSound] forKey:@"TotalReceivedBytesSound"];
                [mDict setObject:[NSNumber numberWithLongLong:self.receivedBytesSound] forKey:@"ReceivedBytesSound"];
            }
        }
        else {
            if ([self.mimeType hasPrefix:@"audio"]) {
                if (self.pathToFileDashAudio) {
                    [mDict setObject:self.pathToFileDashAudio forKey:@"PathToFileDashAudio"];
                }
                
                if (self.pathToFileWithCover) {
                    [mDict setObject:self.pathToFileWithCover forKey:@"PathToFileWithCover"];
                }
                
                if ([self coverImage]) {
                    [mDict setObject:[self coverImage] forKey:@"PathToCoverImage"];
                }
            }
        }
    }
    
    if (self.folderOfVideoWithSub) {
        [mDict setObject:self.folderOfVideoWithSub forKey:@"PathToFolderWithSubtitles"];
    }
    
    if (self.pathToTheSavedVideo) {
        [mDict setObject:self.pathToTheSavedVideo forKey:@"PathToTheSavedVideoFile"];
    }
    
    if (self.pathToTheSavedAudio) {
        [mDict setObject:self.pathToTheSavedAudio forKey:@"PathToTheSavedAudioFile"];
    }
    
    [mDict setObject:self.thumbnailUrl forKey:@"ThumbnailURL"];
    
    if (parent.pageUrl) {
        [mDict setObject:parent.pageUrl forKey:@"PageURL"];
    }
    else {
        [mDict setObject:self.pageUrl forKey:@"PageURL"];
    }
    
    [mDict setObject:self.url forKey:@"ResourceURL"];
    
    if (self.startDownload) {
        [mDict setObject:self.startDownload forKey:@"DateOfSavingResource"];
    }
    
    return mDict;
}

- (BOOL)expiryDateOfLinkEnded:(NSString*)url { 
    if (!self.url && !self.urlOfSegments) {
        return YES;
    }
    
    double value = 0.0;
    NSString* link = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id argments = [link componentsSeparatedByString:@"&"];
    for (NSString* argment in argments) {
        NSRange searchRange = [argment rangeOfString:@"expire="];
        if (searchRange.location != NSNotFound) {
            id keyValue = [argment componentsSeparatedByString:@"="];
            value = [[keyValue objectAtIndex:1] doubleValue];
            
            if (value != 0.0) {
                double since1970 = [[NSDate date] timeIntervalSince1970];
                return value - since1970 < 0.0;
            }
        }
    }
    
    NSError* error = nil;
    NSRegularExpression* regularExp = [NSRegularExpression regularExpressionWithPattern:@"/expire/(\\d*)/" options:0 error:&error];
    id matchedString = [regularExp matchesInString:link options:0 range:NSMakeRange(0, link.length)];
    for (NSTextCheckingResult* result in matchedString) {
        NSRange range = [result rangeAtIndex:1];
        NSString* subString = [link substringWithRange:range];
        value = [subString doubleValue];
    }
    
    double since1970 = [[NSDate date] timeIntervalSince1970];
    return value - since1970 < 0.0;
}

- (double)calculateMultiplier {
    long long nMB = 1024 * 1024;
    double multiplier = 0.0;
    if (self.totalExpectedBytes <= 10 * nMB) {
        multiplier = 0.1;
    }
    else if (self.totalExpectedBytes <= 50 * nMB) {
        multiplier = 0.3;
    }
    else if (self.totalExpectedBytes <= 100 * nMB) {
        multiplier = 0.7;
    }
    else if (self.totalExpectedBytes <= 300 * nMB) {
        multiplier = 1.1;
    }
    else if (self.totalExpectedBytes <= 600 * nMB) {
        multiplier = 1.3;
    }
    else if (self.totalExpectedBytes <= 900 * nMB) {
        multiplier = 1.5;
    }
    
    [self setMultiplier:multiplier];
    return multiplier;
}

- (id)getItemWithFormat:(NSString*)format resolution:(long long)nresolution fps:(long long)nfps {
    if (!self.videoResources) {
        return nil;
    }
    
    NSMutableArray* itemArray = [NSMutableArray array];
    for (DownloadItem* each in self.videoResources) {
        if ([each isReasonableFormat]) {
            if ([each.format isEqualToString:format]) {
                if (each.resolution == nresolution) {
                    if (![each.url isEqualToString:@""]) {
                        if (!nfps) {
                            if (each.fps > 30) {
                                continue;
                            }
                            [itemArray addObject:each];
                        }
                        
                        if (each.fps == nfps) {
                            [itemArray addObject:each];
                            continue;
                        }
                    }
                }
            }
        }
    }
    
    if (itemArray.count) {
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itag" ascending:YES];
        NSArray* sortedArray = [NSArray arrayWithObjects:&sortDescriptor count:1];
        [itemArray sortUsingDescriptors:sortedArray];
        return [itemArray objectAtIndex:0];
    }
    return nil;
}

- (id)getItemWithMaxResolution {
    DownloadItem* itemWithMaxResolution = nil;
    
    if (!self.videoResources) {
        return nil;
    }
    
    for (DownloadItem* each in self.videoResources) {
        if ([each isReasonableFormat]) {
            if (itemWithMaxResolution) {
                if (itemWithMaxResolution.resolution < each.resolution) {
                    itemWithMaxResolution = each;
                }
            }
            else {
                itemWithMaxResolution = each;
            }
        }
    }
    
    return itemWithMaxResolution;
}

- (id)getSoundItem { 
    DownloadItem* parent = nil;
    if (self.parent) {
        parent = self.parent;
    }
    
    if (!parent) {
        NSLog(@"Can't get url for downloading sound...");
    }
    
    NSMutableArray* itemArray = [NSMutableArray array];
    NSRange searchRange;
    for (DownloadItem* each in parent.videoResources) {
        if ([each.mimeType hasPrefix:@"audio"]) {
            searchRange = [each.mimeType rangeOfString:@"/mp4"];
            if (searchRange.location != NSNotFound) {
                [itemArray addObject:each];
            }
        }
    }
    
    if (!itemArray.count) {
        return nil;
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itag" ascending:NO];
    NSArray* sortedArray = [NSArray arrayWithObjects:sortDescriptor, nil];
    [itemArray sortUsingDescriptors:sortedArray];
    return [itemArray objectAtIndex:0];
}

- (DownloadItem*)getMp3Item {
    DownloadItem* parent = nil;
    DownloadItem* mp3Item = nil;
    if (self.parent) {
        parent = self.parent;
    }
    
    NSRange searchRange;
    for (DownloadItem* each in parent.videoResources) {
        if (each.itag == 18) {
            searchRange = [each.mimeType rangeOfString:@"audio"];
            if (searchRange.location != NSNotFound) {
                mp3Item = each;
            }
        }
    }
    
    if (!mp3Item) {
        return [self getSoundItem];
    }
    
    return mp3Item;
}

- (NSString*)getPageUrl {
    NSString* pageUrl = nil;
    if (self.parent) {
        pageUrl = self.parent.pageUrl;
    }
    else if (self.pageUrl) {
        pageUrl = self.pageUrl;
    }
    else {
        pageUrl = @"";
    }
    return pageUrl;
}

- (BOOL)isReasonableFormat { 
    BOOL bRet = NO;
    NSRange searchRange = [self.mimeType rangeOfString:@"audio"];
    if (searchRange.location == NSNotFound) {
        searchRange = [self.mimeType rangeOfString:@"webm"];
        if (searchRange.location == NSNotFound && (self.itag < 82 || self.itag >= 103)) {
            bRet = YES;
        }
    }
    return bRet;
}

- (BOOL)isVideoDashMpd { 
    BOOL bRet = YES;
    if (self.itag < 121 || ![self.mimeType hasPrefix:@"video"] || !self.urlOfSegments || !self.urlOfSegments.count) {
        bRet = NO;
    }
    return bRet;
}

- (BOOL)isSoundDASH {
    BOOL bRet = YES;
    if (self.itag < 121 || ![self.mimeType hasPrefix:@"audio"]) {
        bRet = NO;
    }
    return bRet;
}

- (BOOL)isVideoDASH { 
    BOOL bRet = NO;
    if (self.itag >= 121) {
        if ([self.mimeType hasPrefix:@"video"]) {
            if (!self.urlOfSegments) {
                bRet = YES;
            }
        }
    }
    return bRet;
}


- (id)init { 
    if (self = [super init]) {
        [self setLengthSeconds:0];
        [self setNeedAllocMemForSavedUpVideoData:YES];
        [self setNeedAllocMemForSavedUpSoundData:YES];
        [self setNeedAllocMemForSavedUpMp3Data:YES];
        [self setSavedUpVideoData:nil];
        [self setSavedUpSoundData:nil];
        [self setSavedUpMp3Data:nil];
        [self setMultiplier:0.0];
    }
    return self;
}

@end
