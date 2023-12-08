//
//  ActivationWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CustomCursorButton, PatternBackgroundView, YDHorizontalLine;

@interface ActivationWindowController : NSWindowController
{
}

@property NSButton *btnActivate; // @synthesize btnActivate=_btnActivate;
@property NSButton *btnCancel; // @synthesize btnCancel=_btnCancel;
@property NSButton *btnBuyNow; // @synthesize btnBuyNow=_btnBuyNow;
@property CustomCursorButton *btnLostCode; // @synthesize btnLostCode=_btnLostCode;
@property YDHorizontalLine *rightVerticalLine; // @synthesize rightVerticalLine=_rightVerticalLine;
@property YDHorizontalLine *bottomHorizontalLine; // @synthesize bottomHorizontalLine=_bottomHorizontalLine;
@property PatternBackgroundView *rightSideView; // @synthesize rightSideView=_rightSideView;
@property NSImageView *imgLogo; // @synthesize imgLogo=_imgLogo;
@property NSTextField *lblEnterActivationCode; // @synthesize lblEnterActivationCode=_lblEnterActivationCode;
@property NSTextField *txtActivationInfo; // @synthesize txtActivationInfo=_txtActivationInfo;
@property NSTextField *txtActivationCode; // @synthesize txtActivationCode=_txtActivationCode;
- (BOOL)checkIsValidKey:(id)arg1;
- (void)controlTextDidChange:(id)arg1;
- (void)customizingAppearance;
- (void)btnActivateStreamupClick:(id)arg1;
- (void)btnCancelClick:(id)arg1;
- (void)btnBuyNowClick:(id)arg1;
- (void)btnLostCodeClick:(id)arg1;
- (void)windowDidLoad;
- (id)initWithWindow:(id)arg1;

@end

