//
//  DSImagePopUpButton.m
//  streamdownloader
//
//  Created by ted zhang on 5/24/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DSImagePopUpButton.h"
#import "DSImagePopUpButtonCell.h"

@implementation DSImagePopUpButton

//- (void)drawRect:(NSRect)dirtyRect {
//[super drawRect:dirtyRect];
    
    // Drawing code here.
//}

+ (Class)cellClass { 
    return [DSImagePopUpButtonCell class];
}

- (id)rightDisabledImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.rightDisabledImage;
}

- (void)setRightDisabledImage:(id)rightDisabledImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setRightDisabledImage:rightDisabledImage];
}

- (id)fillDisabledImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.fillDisabledImage;
}

- (void)setFillDisabledImage:(id)fillDisabledImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setFillDisabledImage:fillDisabledImage];
}

- (id)leftDisabledImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.leftDisabledImage;
}

- (void)setLeftDisabledImage:(id)leftDisabledImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setLeftDisabledImage:leftDisabledImage];
}

- (id)rightPressedImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.rightPressedImage;
}

- (void)setRightPressedImage:(id)rightPressImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setRightPressedImage:rightPressImage];
}

- (id)fillPressedImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.fillPressedImage;
}

- (void)setFillPressedImage:(id)fillPressedImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setFillPressedImage:fillPressedImage];
}

- (id)leftPressedImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.leftPressedImage;
}

- (void)setLeftPressedImage:(id)leftPressedImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setLeftPressedImage:leftPressedImage];
}

- (id)rightImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.rightImage;
}

- (void)setRightImage:(id)rightImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setRightImage:rightImage];
}

- (id)fillImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.fillImage;
}

- (void)setFillImage:(id)fillImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setFillImage:fillImage];
}

- (id)leftImage { 
    DSImagePopUpButtonCell* cell = [self cell];
    return cell.leftImage;
}

- (void)setLeftImage:(id)leftImage {
    DSImagePopUpButtonCell* cell = [self cell];
    [cell setLeftImage:leftImage];
}

- (BOOL)isFlipped { 
    return NO;
}

- (BOOL)isOpaque { 
    return NO;
}

- (id)initWithCoder:(id)coder {
    if ([coder isKindOfClass:[NSKeyedUnarchiver class]]) {
        NSString* cellClassName = [[[self superclass] cellClass] className];
        Class cellClass = [coder classForClassName:cellClassName];
        if (!cellClass) {
            cellClass = [[super superclass] cellClass];
        }
        
        [coder setClass:[[self class] cellClass] forClassName:cellClassName];
        self = [super initWithCoder:coder];
        [coder setClass:cellClass forClassName:cellClassName];
    }
    else {
        self = [super initWithCoder:coder];
    }
    
    return self;
}

@end
