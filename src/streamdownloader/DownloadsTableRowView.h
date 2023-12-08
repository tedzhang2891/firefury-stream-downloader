//
//  DownloadsTableRowView.h
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DownloadsTableRowView : NSTableRowView
{
    NSTrackingArea *trackingArea;
}

@property BOOL hideBtnCancelDelete; // @synthesize hideBtnCancelDelete;
@property BOOL hideBtnStartStopFind; // @synthesize hideBtnStartStopFind;
@property long long rowIndex; // @synthesize rowIndex;
@property BOOL mouseInside; // @synthesize mouseInside;

- (void)mouseExited:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)updateTrackingAreas;
- (void)ensureTrackingArea;

@end

