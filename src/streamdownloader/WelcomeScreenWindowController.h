//
//  WelcomeScreenWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WelcomeScreenWindowController : NSWindowController
{
    id eventMonitor;
}

@property NSTextField *lblPlaylistChannelText; // @synthesize lblPlaylistChannelText;
@property NSTextField *lblPlaylistChannelHead; // @synthesize lblPlaylistChannelHead;
@property NSTextField *lblExtractAudioText; // @synthesize lblExtractAudioText;
@property NSTextField *lblExtractAudioHead; // @synthesize lblExtractAudioHead;
@property NSTextField *lblStartPauseText; // @synthesize lblStartPauseText;
@property NSTextField *lblStartPauseHead; // @synthesize lblStartPauseHead;
@property NSTextField *lblTypeResolutionText; // @synthesize lblTypeResolutionText;
@property NSTextField *lblTypeResolutionHead; // @synthesize lblTypeResolutionHead;
@property NSTextField *lblEasyDownloadText; // @synthesize lblEasyDownloadText;
@property NSTextField *lblEasyDownloadHead; // @synthesize lblEasyDownloadHead;
@property NSImageView *imgPlaylistChannel; // @synthesize imgPlaylistChannel;
@property NSImageView *imgExtractAudio; // @synthesize imgExtractAudio;
@property NSImageView *imgStartPause; // @synthesize imgStartPause;
@property NSImageView *imgTypeResolution; // @synthesize imgTypeResolution;
@property NSImageView *imgEasyDownload; // @synthesize imgEasyDownload;
@property NSButton *btnContinue; // @synthesize btnContinue;
- (void)customizingAppearance;
- (void)buttonContinueWasClicked:(id)arg1;
- (void)windowWillClose:(id)arg1;
- (void)windowDidLoad;

@end
