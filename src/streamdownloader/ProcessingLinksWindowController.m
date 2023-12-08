//
//  ProcessingLinksWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "ProcessingLinksWindowController.h"
#import "YoutubeDownloaderAppDelegate.h"
#import "MainWindowController.h"

@interface ProcessingLinksWindowController ()

@end

@implementation ProcessingLinksWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString* windowTitle = nil;
    id delegate = [NSApp delegate];
    MainWindowController* mainWindowCtrl = [delegate mainWindowController];
    NSURL* videoUrl = [NSURL URLWithString:mainWindowCtrl.txtVideoUrl.string];
    if ([videoUrl.path hasPrefix:@"/channel"]) {
        windowTitle = NSLocalizedString(@"parcingChannelWindowTitle", nil);
    }
    else {
        windowTitle = NSLocalizedString(@"parcingPlaylistWindowTitle", nil);
    }
    [self.window setTitle:windowTitle];
    
    [self.txtAboutProcessing setStringValue:NSLocalizedString(@"parcingInProcess", nil)];
    [self.btnCancel setEnabled:NO];
    [self.btnCancel setTitle:NSLocalizedString(@"button_cancel", nil)];
    [self.window setPreventsApplicationTerminationWhenModal:NO];
}

- (void)buttonCancelWasClicked:(id)sender { 
    id delegate = [NSApp delegate];
    MainWindowController* mainWindowCtrl = [delegate mainWindowController];
    [mainWindowCtrl cancelProcessingOfLinksPlaylist];
    [self.progressProcessing setMinValue:0.0];
    [self.progressProcessing setMaxValue:0.0];
    [self.btnCancel setEnabled:NO];
    [self.btnCancel needsDisplay];
    
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
    [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (id)initWithWindow:(NSWindow *)window { 
    if (self = [super initWithWindow:window]) {
        ;
    }
    return self;
}

@end
