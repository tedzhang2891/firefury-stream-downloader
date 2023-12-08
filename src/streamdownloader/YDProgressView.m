//
//  YDProgressView.m
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "YDProgressView.h"

@implementation YDProgressView

- (void)drawRect:(NSRect)dirtyRect {    
    NSRect bound;
    if (self) {
        bound = self.bounds;
    }
    else {
        bound = NSZeroRect;
    }
    
    NSRect copyBound = NSInsetRect(bound, 0.0, 0.0);
    NSBezierPath* bezier = [NSBezierPath bezierPathWithRoundedRect:copyBound xRadius:4.0 yRadius:4.0];
    [bezier addClip];
    copyBound.size.width = self.colorRectWidth;
    [self.colorRect set];
    NSRectFillUsingOperation(copyBound, 2);
}

- (id)initWithFrame:(NSRect)frameRect { 
    if (self = [super initWithFrame:frameRect]) {
        NSColor* rectColor = [NSColor colorWithDeviceRed:0.7333333333333333 green:0.2549019607843137 blue:0.1333333333333333 alpha:1.0];
        [self setColorRect:rectColor];
    }
    return self;
}

@end
