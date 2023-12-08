//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSPopUpButtonCell.h"

@class NSImage;

@interface DSImagePopUpButtonCell : NSPopUpButtonCell
{
    NSImage *_imgLeftImage;
    NSImage *_imgFillImage;
    NSImage *_imgRightImage;
    NSImage *_imgLeftPressedImage;
    NSImage *_imgFillPressedImage;
    NSImage *_imgRightPressedImage;
    NSImage *_imgLeftDisabledImage;
    NSImage *_imgFillDisabledImage;
    NSImage *_imgRightDisabledImage;
}

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
- (id)copyWithZone:(struct _NSZone *)arg1;
- (struct CGRect)titleRectForBounds:(struct CGRect)arg1;
- (void)drawWithFrame:(struct CGRect)arg1 inView:(id)arg2;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (id)initTextCell:(id)arg1;
- (id)initTextCell:(id)arg1 pullsDown:(BOOL)arg2;
- (void)_initMembers;

@end
