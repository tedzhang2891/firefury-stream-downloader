//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSButton.h"

@class NSAttributedString, NSImage;

@interface DSImageButton : NSButton
{
    NSImage *_imgLeftN;
    NSImage *_imgRightN;
    NSImage *_imgFillN;
    NSImage *_imgLeftP;
    NSImage *_imgRightP;
    NSImage *_imgFillP;
    NSImage *_imgLeftD;
    NSImage *_imgRightD;
    NSImage *_imgFillD;
    NSImage *_imgOff;
    NSImage *_imgOn;
    NSImage *_imgMixed;
    NSImage *_imgDisabled;
    NSImage *_imgOffPressed;
    NSImage *_imgOnPressed;
    NSImage *_imgMixedPressed;
    NSImage *_imgOffInactive;
    NSImage *_imgOnInactive;
    NSImage *_imgMixedInactive;
    NSImage *_imgDisabledInactive;
    NSImage *_imgOffOver;
    NSImage *_imgOnOver;
    NSImage *_imgMixedOver;
    NSAttributedString *_txtOff;
    NSAttributedString *_txtOn;
    NSAttributedString *_txtMixed;
    NSAttributedString *_txtDisabled;
    float _fPressDeltaY;
    float _fPressDeltaX;
    long long _trackingTag;
    BOOL _bMouseInView;
}

- (float)pressDeltaY;
- (void)setPressDeltaY:(float)arg1;
- (float)pressDeltaX;
- (void)setPressDeltaX:(float)arg1;
- (id)attributedDisabledTitle;
- (void)setAttributedDisabledTitle:(id)arg1;
- (id)attributedMixedTitle;
- (void)setAttributedMixedTitle:(id)arg1;
- (id)attributedAlternateTitle;
- (void)setAttributedAlternateTitle:(id)arg1;
- (id)attributedTitle;
- (void)setAttributedTitle:(id)arg1;
- (id)mixedImageOver;
- (void)setMixedImageOver:(id)arg1;
- (id)alternateImageOver;
- (void)setAlternateImageOver:(id)arg1;
- (id)imageOver;
- (void)setImageOver:(id)arg1;
- (id)disabledImageInactive;
- (void)setDisabledImageInactive:(id)arg1;
- (id)mixedImageInactive;
- (void)setMixedImageInactive:(id)arg1;
- (id)alternateImageInactive;
- (void)setAlternateImageInactive:(id)arg1;
- (id)imageInactive;
- (void)setImageInactive:(id)arg1;
- (id)mixedImagePressed;
- (void)setMixedImagePressed:(id)arg1;
- (id)alternateImagePressed;
- (void)setAlternateImagePressed:(id)arg1;
- (id)imagePressed;
- (void)setImagePressed:(id)arg1;
- (id)disabledImage;
- (void)setDisabledImage:(id)arg1;
- (id)mixedImage;
- (void)setMixedImage:(id)arg1;
- (id)alternateImage;
- (void)setAlternateImage:(id)arg1;
- (id)image;
- (void)setImage:(id)arg1;
- (id)rightDisabledImage;
- (void)setRightDisabledImage:(id)arg1;
- (id)fillDisabledImage;
- (void)setFillDisabledImage:(id)arg1;
- (id)leftDisabledImage;
- (void)setLeftDisabledImage:(id)arg1;
- (id)rightPressedImage;
- (void)setRightPressedImage:(id)arg1;
- (id)fillPressedImage;
- (void)setFillPressedImage:(id)arg1;
- (id)leftPressedImage;
- (void)setLeftPressedImage:(id)arg1;
- (id)rightImage;
- (void)setRightImage:(id)arg1;
- (id)fillImage;
- (void)setFillImage:(id)arg1;
- (id)leftImage;
- (void)setLeftImage:(id)arg1;
- (id)currentTitle;
- (id)currentImage:(float *)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)removeFromSuperviewWithoutNeedingDisplay;
- (void)removeFromSuperview;
- (void)resetCursorRects;
- (BOOL)isFlipped;
- (void)drawRect:(struct CGRect)arg1;
- (id)hitTest:(struct CGPoint)arg1;
- (id)_hitTest:(struct CGPoint)arg1;
- (id)_hitMask;
- (void)dealloc;
- (BOOL)isOpaque;
- (id)initWithFrame:(struct CGRect)arg1;
- (id)initWithCoder:(id)arg1;
- (id)init;
- (void)updateKey:(id)arg1;
- (void)_init;
- (void)resetTrackingRect;
- (void)removeTrackingRect;

@end

