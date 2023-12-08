//
//  RoundedCornerView.h
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RoundedCornerView : NSView
{

}

@property(nonatomic) double cornerRadius; // @synthesize cornerRadius;
@property(nonatomic) double strokeWidth; // @synthesize strokeWidth;
@property(retain, nonatomic) NSColor *strokeColor; // @synthesize strokeColor;
@property(retain, nonatomic) NSColor *fillColor; // @synthesize fillColor;
- (void)drawRect:(NSRect)arg1;
- (id)initWithFrame:(NSRect)arg1;

@end
