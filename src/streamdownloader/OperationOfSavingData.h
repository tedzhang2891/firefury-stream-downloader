//
//  OperationOfSavingData.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadItem, MainWindowController, NSData;

@interface OperationOfSavingData : NSOperation
{

}

@property(nonatomic) BOOL isLastOperation; // @synthesize isLastOperation=_isLastOperation;
@property(retain, nonatomic) MainWindowController *controller; // @synthesize controller=_controller;
@property(retain, nonatomic) DownloadItem *item; // @synthesize item=_item;
@property(retain, nonatomic) NSData *data; // @synthesize data=_data;
- (void)handlingExceptions:(id)exception;
- (id)initWithData:(id)data forItem:(id)item andController:(id)controller;

@end
