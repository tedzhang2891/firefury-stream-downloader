//
//  PatternBackgroundView.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PatternBackgroundView : NSView {

}

@property(retain, nonatomic) NSColor *backColor; // @synthesize backColor=_backColor;
@property(retain, nonatomic) NSImage *rightImage; // @synthesize rightImage=_rightImage;
@property(retain, nonatomic) NSImage *fillImage; // @synthesize fillImage=_fillImage;
@property(retain, nonatomic) NSImage *leftImage; // @synthesize leftImage=_leftImage;
@property(retain, nonatomic) NSString *backImageName; // @synthesize backImageName=_backImageName;
- (void)drawRect:(NSRect)dirtyRect;
- (id)initWithFrame:(NSRect)frameRect;
@end
