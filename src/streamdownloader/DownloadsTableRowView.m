//
//  DownloadsTableRowView.m
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DownloadsTableRowView.h"
#import "DownloadsTableCellView.h"

@implementation DownloadsTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)mouseExited:(NSEvent *)event { 
    id view = [self viewAtColumn:0];
    [[view btnStartStopFind] setHidden:YES];
    [[view btnCancelDelete] setHidden:YES];
    [self setMouseInside:NO];
}

- (void)mouseEntered:(NSEvent *)event { 
    id view = [self viewAtColumn:0];
    [[view btnStartStopFind] setHidden:self.hideBtnStartStopFind];
    [[view btnCancelDelete] setHidden:self.hideBtnCancelDelete];
    [self setMouseInside:YES];
}

- (void)updateTrackingAreas { 
    if (self->trackingArea) {
        [self removeTrackingArea:self->trackingArea];
    }
    
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect|NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    
    [self addTrackingArea:trackingArea];
    [self.window mouseLocationOutsideOfEventStream];
    NSPoint point = [self convertPoint:NSZeroPoint fromView:nil];
    
    NSRect bound = [self bounds];
    
    if (NSPointInRect(point, bound)) {
        [self mouseEntered:nil];
    }
    else {
        [self mouseExited:nil];
    }
}

- (void)ensureTrackingArea { 
    if (!self->trackingArea) {
        self->trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect|NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}

@end
