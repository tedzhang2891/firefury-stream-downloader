//
//  DSImageButton.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DSImageButton.h"
#import "DSImageButtonCell.h"

@implementation DSImageButton

- (void)drawRect:(NSRect)dirtyRect {    
    NSRect drawRect;
    NSSize size;
    DSImageButtonCell* btnCell = [self cell];
    if (self.leftPressedImage && self.fillPressedImage && self.rightPressedImage && self.leftImage && self.fillImage && self.rightImage && self.leftDisabledImage && self.fillDisabledImage && self.rightDisabledImage) {
        NSRect rect;
        
        if (self) {
            rect = [self bounds];
            size.width = rect.size.width;
        }
        else {
            rect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            size.width = 0.0;
        }
        
        id fillImg = [self fillImage];
        NSSize imgSize = [fillImg size];
        
        size.height = imgSize.height;
        
        
        NSImage* startCap = nil;
        NSImage* centerFill = nil;
        NSImage* endCap = nil;
        NSImage* img  = nil;
        if ([self isEnabled]) {
            img = [[NSImage alloc] initWithSize:size];
            if (btnCell.isHighlighted) {
                startCap = [self leftPressedImage];
                centerFill = [self fillPressedImage];
                endCap = [self rightPressedImage];
                drawRect.size = size;
                drawRect.origin.x = 0;
                drawRect.origin.y = 0;
            }
            else {
                startCap = [self leftImage];
                centerFill = [self fillImage];
                endCap = [self rightImage];
                drawRect.size = size;
                drawRect.origin.x = 0;
                drawRect.origin.y = 0;
            }
        }
        else {
            img = [[NSImage alloc] initWithSize:size];
            startCap = [self leftDisabledImage];
            centerFill = [self fillDisabledImage];
            endCap = [self rightDisabledImage];
            drawRect.size = size;
            drawRect.origin.x = 0;
            drawRect.origin.y = 0;
        }
        NSDrawThreePartImage(drawRect, startCap, centerFill, endCap, NO, 2, 1.0, NO);
        [self setImage:img];
    }
    else {
        float index = 1.0;
        id image = [self currentImage:&index];
        [image drawInRect:dirtyRect fromRect:NSMakeRect(0.0, 0.0, 0.0, 0.0) operation:2 fraction:index];
    }
    
    NSRect bound;
    NSAttributedString* currTitle = [self currentTitle];
    if (currTitle) {
        CGSize titleSize = [currTitle size];
        if (self) {
            bound = [self bounds];
        }
        else {
            bound = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        }
            
        bound.origin.y = (bound.size.height - titleSize.height) * 0.5 + 2;
        bound.origin.x = (bound.size.width - titleSize.width) * 0.5;
        
        if (btnCell.isHighlighted) {
            bound.origin.y = self.pressDeltaY + bound.origin.y;
            bound.origin.x = self.pressDeltaX + bound.origin.x;
        }
        
        [currTitle drawAtPoint:bound.origin];
    }
}

- (float)pressDeltaY { 
    return self->_fPressDeltaY;
}

- (void)setPressDeltaY:(float)delta {
    self->_fPressDeltaY = delta;
}

- (float)pressDeltaX { 
    return self->_fPressDeltaX;
}

- (void)setPressDeltaX:(float)delta {
    self->_fPressDeltaX = delta;
}

- (id)attributedDisabledTitle { 
    return self->_txtDisabled;
}

- (void)setAttributedDisabledTitle:(id)title {
    self->_txtDisabled = title;
}

- (id)attributedMixedTitle { 
    return self->_txtMixed;
}

- (void)setAttributedMixedTitle:(id)title {
    self->_txtMixed = title;
}

- (id)attributedAlternateTitle { 
    return self->_txtOn;
}

- (void)setAttributedAlternateTitle:(id)title {
    self->_txtOn = title;
}

- (id)attributedTitle { 
    return self->_txtOff;
}

- (void)setAttributedTitle:(id)title {
    self->_txtOff = title;
}

- (NSImage*)mixedImageOver {
    return self->_imgMixedOver;
}

- (void)setMixedImageOver:(id)img {
    self->_imgMixedOver = img;
}

- (NSImage*)alternateImageOver {
    return self->_imgOnOver;
}

- (void)setAlternateImageOver:(id)img {
    self->_imgOnOver = img;
}

- (NSImage*)imageOver {
    return self->_imgOffOver;
}

- (void)setImageOver:(id)img {
    self->_imgOffOver = img;
}

- (NSImage*)disabledImageInactive {
    return self->_imgDisabledInactive;
}

- (void)setDisabledImageInactive:(id)img {
    self->_imgDisabledInactive = img;
}

- (NSImage*)mixedImageInactive {
    return self->_imgMixedInactive;
}

- (void)setMixedImageInactive:(id)img {
    self->_imgMixedInactive = img;
}

- (NSImage*)alternateImageInactive {
    return self->_imgOnInactive;
}

- (void)setAlternateImageInactive:(id)img {
    self->_imgOnInactive = img;
}

- (NSImage*)imageInactive {
    return self->_imgOffInactive;
}

- (void)setImageInactive:(id)img {
    self->_imgOffInactive = img;
}

- (NSImage*)mixedImagePressed {
    return self->_imgMixedPressed;
}

- (void)setMixedImagePressed:(id)img {
    self->_imgMixedPressed = img;
}

- (NSImage*)alternateImagePressed {
    return self->_imgOnPressed;
}

- (void)setAlternateImagePressed:(id)img {
    self->_imgOnPressed = img;
}

- (NSImage*)imagePressed {
    return self->_imgOffPressed;
}

- (void)setImagePressed:(id)img {
    self->_imgOffPressed = img;
}

- (NSImage*)disabledImage {
    return self->_imgDisabled;
}

- (void)setDisabledImage:(id)img {
    self->_imgDisabled = img;
}

- (NSImage*)mixedImage {
    return self->_imgMixed;
}

- (void)setMixedImage:(id)img {
    self->_imgMixed = img;
}

- (NSImage*)alternateImage {
    return self->_imgOn;
}

- (void)setAlternateImage:(id)img {
    self->_imgOn = img;
}

- (NSImage*)image {
    return self->_imgOff;
}

- (void)setImage:(id)img {
    self->_imgOff = img;
}

- (NSImage*)rightDisabledImage {
    return self->_imgRightD;
}

- (void)setRightDisabledImage:(id)img {
    self->_imgRightD = img;
}

- (NSImage*)fillDisabledImage {
    return self->_imgFillD;
}

- (void)setFillDisabledImage:(id)img {
    self->_imgFillD = img;
}

- (NSImage*)leftDisabledImage {
    return self->_imgLeftD;
}

- (void)setLeftDisabledImage:(id)img {
    self->_imgLeftD = img;
}

- (NSImage*)rightPressedImage {
    return self->_imgRightP;
}

- (void)setRightPressedImage:(id)img {
    self->_imgRightP = img;
}

- (NSImage*)fillPressedImage {
    return self->_imgFillP;
}

- (void)setFillPressedImage:(id)img {
    self->_imgFillP = img;
}

- (NSImage*)leftPressedImage {
    return self->_imgLeftP;
}

- (void)setLeftPressedImage:(id)img {
    self->_imgLeftP = img;
}

- (NSImage*)rightImage {
    return self->_imgRightN;
}

- (void)setRightImage:(id)img {
    self->_imgRightN = img;
}

- (NSImage*)fillImage {
    return self->_imgFillN;
}

- (void)setFillImage:(id)img {
    self->_imgFillN = img;
}

- (NSImage*)leftImage {
    return self->_imgLeftN;
}

- (void)setLeftImage:(id)img {
    self->_imgLeftN = img;
}

- (NSAttributedString*)currentTitle {
    NSAttributedString* attrString = nil;
    if ([self isEnabled]) {
        if (self.state == 1) {
            attrString = [self attributedAlternateTitle];
        }
        else {
            if (self.state != -1) {
                attrString = [self attributedTitle];
            }
            else {
                attrString = [self attributedMixedTitle];
            }
        }
    }
    
    if ([self attributedDisabledTitle]) {
        attrString = [self attributedDisabledTitle];
    }
    
    return attrString;
}

- (NSImage*)currentImage:(float *)num {
    if (num) {
        *num = 1.0;
    }
    
    DSImageButtonCell* btnCell = [self cell];
    if ([self isEnabled]) {
        if ((self.state == NSControlStateValueMixed && !self->_imgMixed) || ((self.state == NSControlStateValueOn && !self->_imgOn) || !self.state)) {
            if (self.window.isKeyWindow) {
                if (btnCell.isHighlighted) {
                    if ([self imagePressed]) {
                        return self.imagePressed;
                    }
                }
                if (!self->_bMouseInView) {
                    return self.image;
                }
            }
        }
    }
    
    //TODO:
    
    return [super image];
}

- (void)mouseExited:(id)img {
    self->_bMouseInView = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(id)sender {
    self->_bMouseInView = YES;
    [self setNeedsDisplay:YES];
}

- (void)removeFromSuperviewWithoutNeedingDisplay { 
    [self removeTrackingRect];
    [super removeFromSuperviewWithoutNeedingDisplay];
}

- (void)removeFromSuperview { 
    [self removeTrackingRect];
    [super removeFromSuperview];
}

- (void)resetCursorRects { 
    [self resetTrackingRect];
}

- (BOOL)isFlipped { 
    return NO;
}

- (id)hitTest:(NSPoint)point {
    NSPoint hitPoint = [self.superview convertPoint:point toView:self];
    return [self _hitTest:hitPoint];
}

- (id)_hitTest:(NSPoint)point {
    id ret = self;
    NSRect rect;
    if (self) {
        rect = [self bounds];
    }
    else {
        rect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    if (!NSPointInRect(point, rect)) {
        return nil;
    }
    
    id hitMask = [self _hitMask];
    if (hitMask) {
        unsigned char* bitmap = [hitMask bitmapData];
        size_t bytesPerRow = [hitMask bytesPerRow];
        NSInteger bitsPerPixel = [hitMask bitsPerPixel];
        double x = trunc(point.x);
        double y = trunc(point.y);
        NSInteger totalRow = y * bytesPerRow;
        NSInteger totalBits = x * bitsPerPixel * 0.125;
        
        if (bitmap[totalRow + totalBits + 3] < 0x20) {
            ret = nil;
        }
    }
    
    return ret;
}

- (id)_hitMask { 
    NSImage* currentImage = [self currentImage:nil];
    NSImageRep* retRep = nil;
    if (currentImage) {
        id currReps = [currentImage representations];
        if ([currReps count]) {
            NSImageRep* imgRep = currReps[0];
            if (!imgRep) {
                return retRep;
            }
            if ([imgRep hasAlpha]) {
                if ([imgRep isKindOfClass:[NSBitmapImageRep class]]) {
                    if ([(NSBitmapImageRep*)imgRep isPlanar]) {
                        NSLog(@"Planar bitmap formats not supported");
                    }
                    else {
                        NSInteger bitsPerSample = [imgRep bitsPerSample];
                        NSInteger samplesPerPixel = [(NSBitmapImageRep*)imgRep samplesPerPixel];
                        NSInteger retain = bitsPerSample % samplesPerPixel;
                        if (bitsPerSample / samplesPerPixel == 8) {
                            retRep = imgRep;
                        }
                        else {
                            NSLog(@"Bits per Pixel/Samples per Pixel != 8: %ld/%ld", bitsPerSample, samplesPerPixel);
                        }
                    }
                }
            }
        }
    }
    return retRep;
}

- (void)dealloc { 
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTrackingRect];
}

- (BOOL)isOpaque { 
    return NO;
}

- (id)initWithFrame:(NSRect)rect {
    if (self = [super initWithFrame:rect]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super initWithCoder:coder]) {
        [self _init];
    }
    return self;
}

- (id)init { 
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (void)updateKey:(id)key {
    if (self.window) {
        if (self.window == [key object]) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)_init { 
    self->_imgOff = nil;
    self->_imgOn = nil;
    self->_imgMixed = nil;
    self->_imgDisabled = nil;
    self->_imgOffPressed = nil;
    self->_imgOnPressed = nil;
    self->_imgMixedPressed = nil;
    self->_imgOffInactive = nil;
    self->_imgOnInactive = nil;
    self->_imgMixedInactive = nil;
    self->_imgDisabledInactive = nil;
    self->_imgOffOver = nil;
    self->_imgOnOver = nil;
    self->_imgMixedOver = nil;
    self->_txtOff = nil;
    self->_txtOn = nil;
    self->_txtMixed = nil;
    self->_txtDisabled = nil;
    self->_fPressDeltaY = 0.0;
    self->_fPressDeltaX = 0.0;
    self->_trackingTag = 0LL;
    self->_bMouseInView = NO;
    
    DSImageButtonCell* btnCell = [self cell];
    [btnCell setHighlightsBy:NSNoCellMask];
    [self setBordered:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKey:) name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKey:) name:NSWindowDidResignKeyNotification object:nil];
}

- (void)resetTrackingRect { 
    self->_bMouseInView = 0;
    [self removeTrackingRect];
    if ([self superview]) {
        if ([self window]) {
            NSRect bounds = [self bounds];
            self->_trackingTag = [self addTrackingRect:bounds owner:self userData:nil assumeInside:NO];
        }
    }
}

- (void)removeTrackingRect { 
    if (self->_trackingTag) {
        [self removeTrackingRect:self->_trackingTag];
        self->_trackingTag = 0;
    }
}

@end
