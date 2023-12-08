//
//  EPYoutubeHelper.h
//  streamdownloader
//
//  Created by ted zhang on 5/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#ifndef EPYoutubeHelper_h
#define EPYoutubeHelper_h

#import <Cocoa/Cocoa.h>

@interface EPYoutubeHelper : NSObject

@property(retain, nonatomic) NSString *cookies; // @synthesize cookies;
@property(nonatomic) BOOL enableLog; // @synthesize enableLog;
@property(retain, nonatomic) NSString *pathToLogFile; // @synthesize pathToLogFile;

+ (void)globalCleaning;
+ (void)globalInitialization;
- (id)errorDescription:(long long)arg1;
- (id)getAllLinksForDownloadsOfVideo:(id)arg1;
- (id)getAllURLsInPlaylistOrChannel:(id)arg1;
- (id)init;

@end



#endif /* EPYoutubeHelper_h */
