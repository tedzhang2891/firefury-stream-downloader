//
//  RoundedCornerImageView.m
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "RoundedCornerImageView.h"

@implementation RoundedCornerImageView

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bound;
    if (self) {
        bound = [self bounds];
    }
    else {
        bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    NSRect inBox = NSInsetRect(bound, 1.0, 1.0);
    
    NSBezierPath* bezier = [NSBezierPath bezierPathWithRoundedRect:inBox xRadius:3.0 yRadius:3.0];
    [bezier addClip];
    [self.strokeColor setStroke];
    
    [bezier setLineWidth:2.0];
    [bezier stroke];
    
    NSRect drawRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    
    if (!self.image.name) {
        drawRect.origin.x = 0;
        drawRect.origin.y = 0;
        drawRect.size.width = self.image.size.width;
        drawRect.size.height = self.image.size.height;
        drawRect = NSInsetRect(drawRect, 10, 10);
    }
    
    [self.image drawInRect:bound fromRect:drawRect operation:2 fraction:1.0];
}

- (id)initWithFrame:(NSRect)frameRect { 
    if (self = [super initWithFrame:frameRect]) {
        NSColor* color = [NSColor colorWithCalibratedRed:0.7686274509803922 green:0.7686274509803922 blue:0.7686274509803922 alpha:1.0];
        
        [self setFillColor:color];
        
        NSColor* color1 = [NSColor colorWithCalibratedRed:0.807843137254902 green:0.807843137254902 blue:0.807843137254902 alpha:1.0];
        
        [self setStrokeColor:color1];
    }
    return self;
}

@end
