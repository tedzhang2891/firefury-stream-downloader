//
//  YDHorizontalLine.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YDHorizontalLine : NSBox
{
}

@property(nonatomic) BOOL isHorizontal; // @synthesize isHorizontal=_isHorizontal;
@property(nonatomic) double dashDistance; // @synthesize dashDistance=_dashDistance;
@property(nonatomic) double dashWidth; // @synthesize dashWidth=_dashWidth;
@property(nonatomic) BOOL isDashed; // @synthesize isDashed=_isDashed;
@property(nonatomic) BOOL withShadow; // @synthesize withShadow=_withShadow;
@property(nonatomic) double lineWidth; // @synthesize lineWidth=_lineWidth;
@property(retain, nonatomic) NSColor *lineColor; // @synthesize lineColor=_lineColor;
- (void)drawRect:(NSRect)dirtyRect;

@end
