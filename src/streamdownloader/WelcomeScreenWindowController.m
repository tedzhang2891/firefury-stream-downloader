//
//  WelcomeScreenWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "WelcomeScreenWindowController.h"

@interface WelcomeScreenWindowController ()

@end

@implementation WelcomeScreenWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self customizingAppearance];
    NSButton* btn = [self.window standardWindowButton:NSWindowCloseButton];
    [btn setTarget:self];
    [btn setAction:@selector(buttonContinueWasClicked:)];
    self->eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull evt) {
        if (evt.window == self.window && evt.keyCode == 53) {
            [self buttonContinueWasClicked:nil];
        }
        return evt;
    }];
}

- (void)customizingAppearance { 
    [self.window setTitle:NSLocalizedString(@"welcomeWindowTitle", nil)];
    [self.imgEasyDownload setImage:[NSImage imageNamed:@"easily_icon"]];
    [self.lblEasyDownloadHead setStringValue:NSLocalizedString(@"lblEasyDownloadHead", nil)];
    [self.lblEasyDownloadHead setFont:[NSFont boldSystemFontOfSize:13.0]];
    [self.lblEasyDownloadText setStringValue:NSLocalizedString(@"lblEasyDownloadText", nil)];
    [self.imgTypeResolution setImage:[NSImage imageNamed:@"resolution_icon"]];
    [self.lblTypeResolutionHead setStringValue:NSLocalizedString(@"lblTypeResolutionHead", nil)];
    [self.lblTypeResolutionHead setFont:[NSFont boldSystemFontOfSize:13.0]];
    [self.lblTypeResolutionText setStringValue:NSLocalizedString(@"lblTypeResolutionText", nil)];
    [self.imgStartPause setImage:[NSImage imageNamed:@"startpause_icon"]];
    [self.lblStartPauseHead setStringValue:NSLocalizedString(@"lblStartPauseHead", nil)];
    [self.lblStartPauseHead setFont:[NSFont boldSystemFontOfSize:13.0]];
    [self.lblStartPauseText setStringValue:NSLocalizedString(@"lblStartPauseText", nil)];
    [self.imgExtractAudio setImage:[NSImage imageNamed:@"extract_icon"]];
    [self.lblExtractAudioHead setStringValue:NSLocalizedString(@"lblExtractAudioHead", nil)];
    [self.lblExtractAudioHead setFont:[NSFont boldSystemFontOfSize:13.0]];
    [self.lblExtractAudioText setStringValue:NSLocalizedString(@"lblExtractAudioText", nil)];
    [self.imgPlaylistChannel setImage:[NSImage imageNamed:@"playlist_icon"]];
    [self.lblPlaylistChannelHead setStringValue:NSLocalizedString(@"lblPlaylistChannelHead", nil)];
    [self.lblPlaylistChannelHead setFont:[NSFont boldSystemFontOfSize:13.0]];
    [self.lblPlaylistChannelText setStringValue:NSLocalizedString(@"lblPlaylistChannelText", nil)];
}

- (void)buttonContinueWasClicked:(id)sender {
    [self.window orderOut:self];
    [NSApp stopModalWithCode:0];
}

- (void)windowWillClose:(id)arg1 { 
    [NSEvent removeMonitor:self->eventMonitor];
}

@end
