//
//  RoundedCornerView.m
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "RoundedCornerView.h"

@implementation RoundedCornerView

- (void)drawRect:(NSRect)dirtyRect {    
    NSRect bound;
    if (self) {
        bound = [self bounds];
    }
    else {
        bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    NSBezierPath* bezier = nil;
    
    NSRect inBox = NSInsetRect(bound, 0.0, 0.0);
    if (self.cornerRadius == 0.0) {
        NSColor* color = [NSColor colorWithDeviceRed:0.7450980392156863 green:0.7450980392156863 blue:0.7450980392156863 alpha:1.0];
        [color set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(5.0, 0.0) toPoint:NSMakePoint(inBox.size.width, 0.0)];
    }
    else {
        bezier = [NSBezierPath bezierPathWithRoundedRect:inBox xRadius:self.cornerRadius yRadius:0.0];
    }
    
    if (self.fillColor) {
        [self.fillColor setFill];
        [bezier fill];
    }
    
    [bezier addClip];
    
    if (self.strokeColor) {
        [self.strokeColor setStroke];
        [bezier setLineWidth:self.strokeWidth];
        [bezier stroke];
    }
}

- (id)initWithFrame:(NSRect)rect {
    if (self = [super initWithFrame:rect]) {
        [self setStrokeColor:nil];
        [self setStrokeWidth:0.0];
        [self setCornerRadius:0.0];
        [self setFillColor:nil];
    }
    return self;
}

@end
