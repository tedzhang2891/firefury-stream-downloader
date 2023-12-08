//
//  RoundedCornerImageView.h
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RoundedCornerImageView : NSImageView
{

}

@property(nonatomic) double cornerRadius; // @synthesize cornerRadius;
@property(nonatomic) double strokeWidth; // @synthesize strokeWidth;
@property(retain, nonatomic) NSColor *strokeColor; // @synthesize strokeColor;
@property(retain, nonatomic) NSColor *fillColor; // @synthesize fillColor;
- (void)drawRect:(NSRect)rect;
- (id)initWithFrame:(NSRect)frameRect;

@end
