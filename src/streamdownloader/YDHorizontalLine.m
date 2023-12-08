//
//  YDHorizontalLine.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "YDHorizontalLine.h"

@implementation YDHorizontalLine

- (void)drawRect:(NSRect)dirtyRect {    
    NSRect bound;
    CGFloat high;
    
    CGPoint point1;
    CGPoint point2;
    
    if (self.isHorizontal) {
        if (self) {
            bound = self.bounds;
            point1.x = bound.size.height;
            point1.y = bound.size.width;
            point2.x = 0.0;
            point2.y = bound.size.height;
        }
        else {
            bound = NSZeroRect;
            point1.x = 0.0;
            point1.y = 0.0;
            point2.x = 0.0;
            point2.y = 0.0;
        }
    }
    else {
        if (self) {
            bound = self.bounds;
            point1.x = bound.origin.y;
            point1.y = bound.origin.x;
            point2.x = bound.origin.x;
            point2.y = bound.size.height;
        }
        else {
            bound = NSZeroRect;
            point1.x = 0.0;
            point1.y = 0.0;
            point2.x = 0.0;
            point2.y = 0.0;
        }
    }
    
    if (!self.lineColor) {
        [self setLineColor:[NSColor blackColor]];
    }
    
    if (self.lineWidth == 0.0) {
        [self setLineWidth:1.0];
    }
    
    if (self.dashWidth == 0.0) {
        [self setDashWidth:5.0];
    }
    
    if (self.dashDistance == 0.0) {
        [self setDashDistance:2.0];
    }
    
    [self.lineColor set];
    NSBezierPath* bezier = [NSBezierPath bezierPath];
    [bezier setLineWidth:self.lineWidth];
    
    if (self.isDashed) {
        double dashWidth = self.dashWidth;
        [bezier setLineDash:&dashWidth count:2 phase:self.dashDistance * 0.5];
    }
    [bezier moveToPoint:NSMakePoint(point2.x, point1.x)];
    [bezier lineToPoint:NSMakePoint(point1.y, point2.y)];
    [bezier stroke];
    
    if (self.withShadow) {
        NSShadow* shadow = [[NSShadow alloc] init];
        NSColor* shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
        [shadow setShadowColor:shadowColor];
        [shadow setShadowOffset:NSMakeSize(0.0, -0.1)];
        [shadow setShadowBlurRadius:1.0];
        [shadow set];
        [bezier stroke];
    }
}

@end
