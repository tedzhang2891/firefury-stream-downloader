//
//  OperationReceivingLinksOfVideo.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainWindowController, NSArray;

@interface OperationReceivingLinksOfVideo : NSOperation
{
}

@property(retain) NSArray *urls; // @synthesize urls=_urls;
@property(retain) MainWindowController *controller; // @synthesize controller=_controller;
- (unsigned long long)getResolutionFromString:(id)arg1 forItag:(int)arg2;
- (void)getEstimatedSizeForItem:(id)arg1;
- (void)main;
- (id)initOperationForVideos:(id)videos forController:(id)mainWindowCtrl;

@end
