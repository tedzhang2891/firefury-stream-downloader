//
//  DSImageButtonCell.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DSImageButtonCell : NSButtonCell
{
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView;
- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
