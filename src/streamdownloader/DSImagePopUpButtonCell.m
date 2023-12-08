//
//  NSImagePopUpButtonCell.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DSImagePopUpButtonCell.h"

@implementation DSImagePopUpButtonCell

- (NSImage*)rightDisabledImage {
    return self->_imgRightDisabledImage;
}

- (void)setRightDisabledImage:(NSImage*)img {
    self->_imgRightDisabledImage = img;
}

- (NSImage*)fillDisabledImage {
    return self->_imgFillDisabledImage;
}

- (void)setFillDisabledImage:(NSImage*)img {
    self->_imgFillDisabledImage = img;
}

- (NSImage*)leftDisabledImage {
    return self->_imgLeftDisabledImage;
}

- (void)setLeftDisabledImage:(NSImage*)img {
    self->_imgLeftDisabledImage = img;
}

- (NSImage*)rightPressedImage {
    return self->_imgRightPressedImage;
}

- (void)setRightPressedImage:(NSImage*)img {
    self->_imgRightPressedImage = img;
}

- (NSImage*)fillPressedImage {
    return self->_imgFillPressedImage;
}

- (void)setFillPressedImage:(NSImage*)img {
    self->_imgFillPressedImage = img;
}

- (NSImage*)leftPressedImage {
    return self->_imgLeftPressedImage;
}

- (void)setLeftPressedImage:(NSImage*)img {
    self->_imgLeftPressedImage = img;
}

- (NSImage*)rightImage {
    return self->_imgRightImage;
}

- (void)setRightImage:(NSImage*)img {
    self->_imgRightImage = img;
}

- (NSImage*)fillImage {
    return self->_imgFillImage;
}

- (void)setFillImage:(NSImage*)img {
    self->_imgFillImage = img;
}

- (NSImage*)leftImage {
    return self->_imgLeftImage;
}

- (void)setLeftImage:(NSImage*)img {
    self->_imgLeftImage = img;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    id copy = [super copyWithZone:zone];
    [copy _initMembers];
    [copy setLeftImage:self.leftImage];
    [copy setFillImage:self.fillImage];
    [copy setRightImage:self.rightImage];
    [copy setLeftPressedImage:self.leftPressedImage];
    [copy setFillPressedImage:self.fillPressedImage];
    [copy setRightPressedImage:self.rightPressedImage];
    
    return copy;
}

- (NSRect)titleRectForBounds:(NSRect)boundRect {
    NSRect titleRect = [super titleRectForBounds:boundRect];
    NSRect offsetRect = NSOffsetRect(boundRect, titleRect.origin.x, titleRect.origin.y);
    return offsetRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSImage* cellImg = nil;
    NSSize fillImgSize = [self.fillImage size];
    NSRect drawRect = NSZeroRect;
    drawRect.size.width = cellFrame.size.width;
    drawRect.size.height = cellFrame.size.height;
    if (self.isEnabled) {
        cellImg = [[NSImage alloc] initWithSize:cellFrame.size];
        if (!self.isHighlighted) {
            NSDrawThreePartImage(drawRect, self.leftImage, self.fillImage, self.rightImage, NO, 2, 1.0, NO);
        }
        else {
            NSDrawThreePartImage(drawRect, self.leftPressedImage, self.fillPressedImage, self.rightPressedImage, NO, 2, 1.0, NO);
        }
    }
    else {
        cellImg = [[NSImage alloc] initWithSize:cellFrame.size];
        NSDrawThreePartImage(drawRect, self.leftDisabledImage, self.fillDisabledImage, self.rightDisabledImage, NO, 2, 1.0, NO);
    }
    
    NSRect cellRect = cellFrame;
    cellRect.origin.y = -3.3;   // Adjust y-order
    [self setImage:cellImg];
    [self drawInteriorWithFrame:cellRect inView:controlView];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _initMembers];
    }
    return self;
}

- (id)initTextCell:(NSString *)stringValue {
    return [self initTextCell:stringValue pullsDown:NO];
}

- (id)initTextCell:(NSString *)stringValue pullsDown:(BOOL)bPull {
    if (self = [super initTextCell:stringValue pullsDown:bPull]) {
        [self _initMembers];
    }
    return self;
}

- (void)_initMembers { 
    self->_imgLeftImage = nil;
    self->_imgFillImage = nil;
    self->_imgRightImage = nil;
    self->_imgLeftPressedImage = nil;
    self->_imgFillPressedImage = nil;
    self->_imgRightPressedImage = nil;
    self->_imgLeftDisabledImage = nil;
    self->_imgFillDisabledImage = nil;
    self->_imgRightDisabledImage = nil;
}

@end
