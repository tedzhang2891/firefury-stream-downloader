//
//  DemoReminderWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PatternBackgroundView, YDHorizontalLine;

@interface DemoReminderWindowController : NSWindowController
{
    NSTextField *txtTrademark;
    NSTextField *txtPrice;
}

@property YDHorizontalLine *rightLine; // @synthesize rightLine;
@property YDHorizontalLine *bottomLine; // @synthesize bottomLine;
@property PatternBackgroundView *rightSideView; // @synthesize rightSideView;
@property NSTextField *lblActivateStreamup; // @synthesize lblActivateStreamup;
@property NSTextField *lblCountFreeDownloads; // @synthesize lblCountFreeDownloads;
@property NSTextField *lblTrademark; // @synthesize lblTrademark;
@property NSTextField *lblPrice; // @synthesize lblPrice;
@property NSButton *btnBuyNow; // @synthesize btnBuyNow;
@property NSButton *btnActivate; // @synthesize btnActivate;
@property NSButton *btnFreeMode; // @synthesize btnFreeMode;
- (void)customizingAppearance;
- (void)buttonBuyNowWasClicked:(id)arg1;
- (void)buttonActivateWasClicked:(id)arg1;
- (void)buttonContinueFreeWasClicked:(id)arg1;
- (void)windowDidLoad;

@end
