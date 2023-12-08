//
//  OperationReceivingLinksOfPlaylist.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainWindowController, NSString;

@interface OperationReceivingLinksOfPlaylist : NSOperation
{
}

@property unsigned long long currentLinksNumber; // @synthesize currentLinksNumber=_currentLinksNumber;
@property(retain) NSString *pageUrl; // @synthesize pageUrl=_pageUrl;
@property(retain) MainWindowController *controller; // @synthesize controller=_controller;
- (void)main;
- (id)initOperationForPlaylist:(id)pageUrl forController:(id)controller currentLinksNumber:(unsigned long long)linksNumber;

@end
