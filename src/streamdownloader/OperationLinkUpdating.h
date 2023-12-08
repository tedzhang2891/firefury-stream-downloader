//
//  OperationLinkUpdating.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadItem, MainWindowController, NSString;

@interface OperationLinkUpdating : NSOperation
{
}

@property(retain) NSString *pageUrl; // @synthesize pageUrl=_pageUrl;
@property(retain) DownloadItem *item; // @synthesize item=_item;
@property(retain) MainWindowController *controller; // @synthesize controller=_controller;
- (void)main;
- (id)initOperationForDownloadItem:(id)arg1 forController:(id)arg2;

@end
