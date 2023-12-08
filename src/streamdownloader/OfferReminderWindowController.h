//
//  OfferReminderWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PatternBackgroundView, RoundedCornerView, YDHorizontalLine;

@interface OfferReminderWindowController : NSWindowController
{
    NSButton *btnFreeMode;
    NSButton *btnActivate;
    NSButton *btnBuyNow;
    NSTextField *lblNewPrice;
    NSTextField *lblTrademark;
    RoundedCornerView *viewUnderLblCountFree;
    NSTextField *lblCountFreeDownloads;
    NSTextField *lblActivateStreamup;
    PatternBackgroundView *rightSideView;
    YDHorizontalLine *rightLine;
    YDHorizontalLine *bottomLine;
}

@property YDHorizontalLine *bottomLine; // @synthesize bottomLine;
@property YDHorizontalLine *rightLine; // @synthesize rightLine;
@property PatternBackgroundView *rightSideView; // @synthesize rightSideView;
@property NSTextField *lblActivateStreamup; // @synthesize lblActivateStreamup;
@property NSTextField *lblCountFreeDownloads; // @synthesize lblCountFreeDownloads;
@property RoundedCornerView *viewUnderLblCountFree; // @synthesize viewUnderLblCountFree;
@property NSTextField *lblTrademark; // @synthesize lblTrademark;
@property NSTextField *lblNewPrice; // @synthesize lblNewPrice;
@property NSButton *btnBuyNow; // @synthesize btnBuyNow;
@property NSButton *btnActivate; // @synthesize btnActivate;
@property NSButton *btnFreeMode; // @synthesize btnFreeMode;
- (void)customizingAppearance;
- (void)buttonBuyNowWasClicked:(id)arg1;
- (void)buttonActivateWasClicked:(id)arg1;
- (void)buttonContinueFreeWasClicked:(id)arg1;
- (void)windowDidLoad;

@end
