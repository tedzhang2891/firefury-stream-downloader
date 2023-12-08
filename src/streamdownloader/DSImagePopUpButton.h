//
//  DSImagePopUpButton.h
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DSImagePopUpButton : NSPopUpButton
{
}

+ (Class)cellClass;
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
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (id)initWithCoder:(id)arg1;

@end


