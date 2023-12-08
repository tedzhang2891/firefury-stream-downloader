//
//  PreferencesWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "YDUserDefaults.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setTitle:NSLocalizedString(@"preferencesWindowTitle", nil)];
    [self.lblChooseFolder setStringValue:NSLocalizedString(@"lblChooseFolderText", nil)];
    [self.checkboxAskToSave setTitle:NSLocalizedString(@"checkboxAlwaysAskTitle", nil)];
    [self.btnChooseFolder setToolTip:NSLocalizedString(@"tooltipChooseFolder", nil)];
    [self.btnUnchekAll setTitle:NSLocalizedString(@"btnUncheckAllTitle", nil)];
    [self.checkboxSendStatistics setTitle:NSLocalizedString(@"checkboxSendStatisticsTitle", nil)];
    
    if ([YDUserDefaults currentUserPreferences]) {
        NSString* pathToDownloadsFolder = [[YDUserDefaults currentUserPreferences] objectForKey:@"PathToDownloadsFolder"];
        [self.txtPathToDefaultDir setStringValue:pathToDownloadsFolder];
        BOOL bSaveFile = [[[YDUserDefaults currentUserPreferences] objectForKey:@"AskWhereSaveFile"] boolValue];
        [self.checkboxAskToSave setState:bSaveFile];
    }
    else {
        NSString* downloadFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:@"Streamup"];
        [self.txtPathToDefaultDir setStringValue:downloadFolder];
        [self.checkboxAskToSave setState:NSControlStateValueOff];
    }
}

- (void)chooseFolderForDownloads { 
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    if ([openPanel runModal] == NSModalResponseOK) {
        [self.txtPathToDefaultDir setStringValue:openPanel.URL.path];
    }
}

- (void)toggleSendStatistics:(id)arg1 { 
    // TODO: app statistics
}

- (void)buttonUncheckAllWasClicked:(id)arg1 { 
    [YDUserDefaults resetAllDontAskMeAgainOptions];
}

- (void)buttonChooseDefaultFolder:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            [self.txtPathToDefaultDir setStringValue:openPanel.URL.path];
        }
    }];
}

- (BOOL)windowShouldClose:(NSWindow *)sender { 
    return YES;
}

- (void)windowWillClose:(NSNotification *)notification { 
    NSString* defaultDir = self.txtPathToDefaultDir.stringValue;
    if ([defaultDir isEqualToString:@""]) {
        defaultDir = [[YDUserDefaults currentUserPreferences] objectForKey:@"PathToDownloadsFolder"];
    }
    
    NSControlStateValue state = self.checkboxAskToSave.state;
    NSDictionary* info = @{@"PathToDownloadsFolder": defaultDir, @"AskWhereSaveFile": [NSNumber numberWithBool:state]};
    
    [YDUserDefaults setCurrentUserPreferences:info];
    
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
    [NSApp stopModal];
}

- (id)initWithWindow:(NSWindow *)window { 
    if (self = [super initWithWindow:window]) {
        ;
    }
    return self;
}

@end
