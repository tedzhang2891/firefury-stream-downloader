//
//  DownloadsTableCellView.m
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DownloadsTableCellView.h"
#import "RoundedCornerView.h"
#import "RoundedCornerImageView.h"
#import "DSImageButton.h"

@implementation DownloadsTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)viewWillDraw { 
    NSRect bound;
    NSRect frame;
    CGFloat high;
    CGFloat width;
    CGFloat imageViewWidth;
    
    if (self.mainView) {
        bound = self.mainView.frame;
    }
    else {
        bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    if (self) {
        frame = self.frame;
        high = frame.size.height;
    }
    else {
        frame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        high = 0.0;
    }
    
    bound.origin.y = (high - bound.size.height) * 0.5;
    
    [self.mainView setFrame:bound];
    [self.btnStartStopFind sizeToFit];
    
    NSRect btnStartStopFindFrame;
    
    if (self.btnStartStopFind) {
        btnStartStopFindFrame = self.btnStartStopFind.frame;
        width = btnStartStopFindFrame.size.width;
    }
    else {
        btnStartStopFindFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        width = 0.0;
    }
    
    NSRect imageViewFrame;
    
    if (self.imageView) {
        imageViewFrame = self.imageView.frame;
        imageViewWidth = imageViewFrame.size.width * 0.5;
    }
    else {
        imageViewFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        imageViewWidth = 0.0;
    }
    
    btnStartStopFindFrame.origin.x = width + imageViewWidth;
    btnStartStopFindFrame.origin.y = (bound.size.height - btnStartStopFindFrame.size.height) * 0.5;
    
    [self.btnStartStopFind setFrame:btnStartStopFindFrame];
    
    [self.btnCancelDelete sizeToFit];
    
    NSRect btnCancelDeleteFrame;
    
    CGFloat btnHight;
    CGFloat btnWidth;
    
    if (self.btnCancelDelete) {
        btnCancelDeleteFrame = self.btnCancelDelete.frame;
        btnHight = btnCancelDeleteFrame.size.height;
        btnWidth = btnCancelDeleteFrame.size.width + 10.0;
    }
    else {
        btnCancelDeleteFrame = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        btnHight = 0.0;
        btnWidth = 10.0;
    }
    
    btnCancelDeleteFrame.origin.x = bound.size.width - btnWidth;
    btnCancelDeleteFrame.origin.y = (bound.size.height - btnHight) * 0.5;
    [self.btnCancelDelete setFrame:btnCancelDeleteFrame];
}

- (void)awakeFromNib { 
    NSColor* whiteColor = [NSColor whiteColor];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed:0.7686274509803922 green:0.7686274509803922 blue:0.7686274509803922 alpha:1.0];
    NSColor* textColor = [NSColor colorWithCalibratedRed:0.5294117647058824 green:0.5294117647058824 blue:0.5294117647058824 alpha:1.0];
    
    [self.mainView setFillColor:whiteColor];
    [self.mainView setStrokeColor:strokeColor];
    [self.mainView setStrokeWidth:2.0];
    [self.mainView setCornerRadius:4.0];
    
    NSButtonCell* btnStartStopFindCell = [self.btnStartStopFind cell];
    [btnStartStopFindCell setHighlightsBy:NSNoCellMask];
    [btnStartStopFindCell setBezelStyle:NSBezelStyleInline];
    [self.btnStartStopFind setImage:[NSImage imageNamed:@"find"]];
    [self.btnStartStopFind setImagePosition:NSImageOnly];
    
    NSButtonCell* btnCancelDeleteCell = [self.btnCancelDelete cell];
    [btnCancelDeleteCell setHighlightsBy:NSNoCellMask];
    [btnCancelDeleteCell setBezelStyle:NSBezelStyleInline];
    [self.btnCancelDelete setImage:[NSImage imageNamed:@"delete"]];
    [self.btnCancelDelete setImagePosition:NSImageOnly];
    
    [self.txtTitle setBezelStyle:NSTextFieldSquareBezel];
    [self.txtTitle setDrawsBackground:NO];
    [self.txtTitle setEditable:NO];
    [self.txtTitle setSelectable:NO];
    
    [self.txtInformation setBezeled:NO];
    [self.txtInformation setDrawsBackground:NO];
    [self.txtInformation setEditable:NO];
    [self.txtInformation setSelectable:NO];
    [self.txtInformation setTextColor:textColor];
    
    [self.thumbnail setImage:[NSImage imageNamed:@"default"]];
}

- (id)initWithFrame:(NSRect)frameRect { 
    if (self = [super initWithFrame:frameRect]) {
        ;
    }
    return self;
}

@end
