//
//  OperationSavingOfDataSegments.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadItem, MainWindowController, NSData;

@interface OperationSavingOfDataSegments : NSOperation
{
}

@property(nonatomic) long long expectedBytes; // @synthesize expectedBytes=_expectedBytes;
@property(retain, nonatomic) MainWindowController *controller; // @synthesize controller=_controller;
@property(nonatomic) int kindOfItem; // @synthesize kindOfItem=_kindOfItem;
@property(retain, nonatomic) DownloadItem *item; // @synthesize item=_item;
@property(retain, nonatomic) NSData *data; // @synthesize data=_data;
- (void)main;
- (id)initWithData:(id)data forItem:(id)downloadItem type:(int)nType andController:(id)controller;

@end
