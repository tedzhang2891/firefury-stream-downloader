//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSView.h"

@class NSColor;

@interface YDProgressView : NSView
{
    float _colorRectWidth;
    NSColor *_colorRect;
}

@property(retain) NSColor *colorRect; // @synthesize colorRect=_colorRect;
@property float colorRectWidth; // @synthesize colorRectWidth=_colorRectWidth;
- (void)drawRect:(struct CGRect)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

