//
//  DownloadsTableCellView.h
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RoundedCornerImageView, RoundedCornerView, YDProgressView;

@interface DownloadsTableCellView : NSTableCellView
{
}

@property NSButton *btnCancelDelete; // @synthesize btnCancelDelete;
@property NSButton *btnStartStopFind; // @synthesize btnStartStopFind;
@property NSProgressIndicator *progressIndicator; // @synthesize progressIndicator;
@property NSTextField *txtInformation; // @synthesize txtInformation;
@property NSTextField *txtTitle; // @synthesize txtTitle;
@property YDProgressView *progressView; // @synthesize progressView;
@property RoundedCornerImageView *thumbnail; // @synthesize thumbnail;
@property RoundedCornerView *mainView; // @synthesize mainView;
- (void)viewWillDraw;
- (void)drawRect:(NSRect)dirtyRect;
- (void)awakeFromNib;
- (id)initWithFrame:(NSRect)frameRect;

@end
