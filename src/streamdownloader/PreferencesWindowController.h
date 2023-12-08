//
//  PreferencesWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController
{
}

@property NSButton *checkboxSendStatistics; // @synthesize checkboxSendStatistics=_checkboxSendStatistics;
@property NSButton *btnUnchekAll; // @synthesize btnUnchekAll=_btnUnchekAll;
@property NSButton *btnChooseFolder; // @synthesize btnChooseFolder=_btnChooseFolder;
@property NSTextField *lblChooseFolder; // @synthesize lblChooseFolder=_lblChooseFolder;
@property NSTextField *txtPathToDefaultDir; // @synthesize txtPathToDefaultDir=_txtPathToDefaultDir;
@property NSButton *checkboxAskToSave; // @synthesize checkboxAskToSave=_checkboxAskToSave;
- (void)chooseFolderForDownloads;
- (void)toggleSendStatistics:(id)arg1;
- (void)buttonUncheckAllWasClicked:(id)arg1;
- (void)buttonChooseDefaultFolder:(id)arg1;
- (BOOL)windowShouldClose:(NSWindow*)sender;
- (void)windowWillClose:(NSNotification*)notification;
- (void)windowDidLoad;
- (id)initWithWindow:(NSWindow*)window;

@end
