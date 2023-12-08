//
//  PatternBackgroundView.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "PatternBackgroundView.h"

@implementation PatternBackgroundView

- (void)drawRect:(NSRect)dirtyRect {    
    NSColor* backColor = nil;
    if (self.backColor) {
        backColor = self.backColor;
    }
    else {
        backColor = [NSColor colorWithDeviceRed:0.9137254901960784 green:0.9254901960784314 blue:0.9411764705882353 alpha:1.0];
    }
    
    NSRect bound;
    
    if (self.backImageName || self.leftImage || self.fillImage || self.rightImage) {
        if (self.backImageName) {
            NSImage* img = [NSImage imageNamed:self.backImageName];
            NSColor* color = [NSColor colorWithPatternImage:img];
            [color set];
            
            if (self) {
                bound = [self bounds];
            }
            else {
                bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            }
            NSRectFill(bound);
        }
        
        if (self.leftImage && self.fillImage && self.rightImage) {
            if (self) {
                bound = [self bounds];
            }
            else {
                bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            }
            NSDrawThreePartImage(bound, self.leftImage, self.fillImage, self.rightImage, NO, 2, 1.0, NO);
        }
    }
    else {
        [backColor set];
        if (self) {
            bound = [self bounds];
        }
        else {
            bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        }
        NSRectFill(bound);
    }
}

- (id)initWithFrame:(NSRect)frameRect { 
    if (self = [super initWithFrame:frameRect]) {
        [self setBackImageName:nil];
        [self setLeftImage:nil];
        [self setFillImage:nil];
        [self setRightImage:nil];
        [self setBackColor:nil];
    }
    return self;
}

@end
