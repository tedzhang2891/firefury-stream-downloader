//
//  DSImageButtonCell.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DSImageButtonCell.h"

@implementation DSImageButtonCell

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect rect;
    if (self) {
        rect = [self adjustedFrameToVerticallyCenterText:frame];
    }
    else {
        rect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    return rect;
}

- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    CGFloat ascender = [[self font] ascender];
    CGFloat descender = [[self font] descender];
    double height = floor(frame.size.height);
    
    NSRect newRect;
    NSInsetRect(newRect, 0.0, height);
    return newRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawWithFrame:cellFrame inView:controlView];
}

@end
