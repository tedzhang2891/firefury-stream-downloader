//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSWindowController.h"

@class NSButton, NSTextField;

@interface PreferencesWindowController : NSWindowController
{
    NSButton *_checkboxAskToSave;
    NSTextField *_txtPathToDefaultDir;
    NSTextField *_lblChooseFolder;
    NSButton *_btnChooseFolder;
    NSButton *_btnUnchekAll;
    NSButton *_checkboxSendStatistics;
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
- (BOOL)windowShouldClose:(id)arg1;
- (void)windowWillClose:(id)arg1;
- (void)windowDidLoad;
- (id)initWithWindow:(id)arg1;

@end
