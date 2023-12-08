//
//  YDProgressView.h
//  streamdownloader
//
//  Created by ted zhang on 5/29/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface YDProgressView : NSView
{
}

@property(retain) NSColor *colorRect; // @synthesize colorRect=_colorRect;
@property float colorRectWidth; // @synthesize colorRectWidth=_colorRectWidth;
- (void)drawRect:(NSRect)dirtyRect;
- (id)initWithFrame:(NSRect)frameRect;

@end
