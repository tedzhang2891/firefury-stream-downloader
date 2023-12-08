//
//  MainWindowController.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "MainWindowController.h"
#import "DownloadItem.h"
#import "DSImageButton.h"
#import "DSImagePopUpButton.h"
#import "PageUrlTextView.h"
#import "PatternBackgroundView.h"
#import "YDHorizontalLine.h"
#import "YoutubeDownloaderAppDelegate.h"
#import "ProcessingLinksWindowController.h"
#import "OfferReminderWindowController.h"
#import "RoundedCornerView.h"
#import "RoundedCornerImageView.h"

// OperationQueue
#import "OperationLinkUpdating.h"
#import "OperationOfSavingData.h"
#import "OperationOfSavingAudioData.h"
#import "OperationOfSavingVideoData.h"
#import "OperationOfSavingSoundData.h"
#import "OperationSavingOfDataSegments.h"
#import "OperationReceivingLinksOfVideo.h"
#import "OperationReceivingLinksOfPlaylist.h"

// Common
#import "YDUserDefaults.h"
#import "DownloadItem.h"
#import "Utility.h"

// Utility
#import "DownloadsTableRowView.h"
#import "DownloadsTableCellView.h"
#import "YDProgressView.h"

#import <sys/time.h>

long long microseconds = 0;
@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self customWindowAppearance];
    if (![self.window setFrameUsingName:@"Streamup"]) {
        [self.window center];
    }
    
    [self.window setFrameAutosaveName:@"Streamup"];
    [self registerOtherNotificationMessages];
    self.appstaticoIfo = [NSMutableArray array];
}

- (BOOL)userNotificationCenter:(id)arg1 shouldPresentNotification:(id)arg2 { 
    return NO;
}

- (void)updatingWhenActivationInfoChanged { 
    if ([self.indexesForUpdatingLinks count]) {
        [self startUpdatingLinks:self.indexesForUpdatingLinks];
    }
    else {
        id delegate = [NSApp delegate];
        if ([delegate isProVersion]) {
            [self startLoadingOrConversionOfLinksIfNeeded];
            [self.tableDownloadList reloadData];
            [self updateLabelCountDownloads];
        }
    }
}

- (void)registerOtherNotificationMessages { 
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updatingWhenActivationInfoChanged) name:@"ActivationInfoDidChange" object:nil];
    [defaultCenter addObserver:self selector:@selector(bookmarkWithUrl:) name:@"BookmarkWithUrl" object:nil];
    [defaultCenter addObserver:self selector:@selector(validateInsertedUrl:) name:@"PasteInTextView" object:self.txtVideoUrl];
    [defaultCenter addObserver:self selector:@selector(validateInsertedUrl:) name:@"PressEnterInTextView" object:self.txtVideoUrl];
    [defaultCenter addObserver:self selector:@selector(escapeInsertedUrl:) name:@"PressEscape" object:self.txtVideoUrl];
    [defaultCenter addObserver:self selector:@selector(backspaceInsertedUrl:) name:@"PressBackspace" object:self.txtVideoUrl];
    [defaultCenter addObserver:self selector:@selector(assignmentValueNeedSignIn) name:@"SetValueNeedSignIn" object:nil];
}

- (void)assignmentValueNeedSignIn { 
    [self setNeedSignIn:NO];
    [YDUserDefaults setLoggedInYoutube:YES];
}

- (void)bookmarkWithUrl:(id)arg1 {
    if (self.inProcessParsing) {
        NSString* url = [[arg1 userInfo] objectForKey:@"url"];
        NSString* decodedUrl = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.txtVideoUrl setString:decodedUrl];
        [self validateInsertedUrl:self.txtVideoUrl];
    }
}

- (void)actionOfContextMenuForDownloadList:(id)cell {
    DownloadItem* cellObj = [cell representedObject];
    switch ([cell tag]) {
        case 2001:
            if (cellObj.currentState == 5) {
                [self resumeDownloadForItem:cellObj];
            }
            else if (cellObj.currentState == 6) {
                [self resumeConvertingForItem:cellObj];
            }
            else {
                [self suspendDownloadForItem:cellObj];
            }
            break;
        case 2002:
            [self removeItemFromListOfDownloads:cellObj];
            break;
        case 2003:
        {
            NSString* pageUrl = cellObj.pageUrl;
            if (!pageUrl) {
                pageUrl = cellObj.parent.pageUrl;
            }
            NSURL* url = [NSURL URLWithString:pageUrl];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
            break;
        case 2004:
            [self showInFinderDownloadItem:cellObj];
            break;
    }
}

- (id)contextualMenuForTableView:(id)view withClickedRow:(long long)row {
    if (row == -1) {
        return nil;
    }
    
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    DownloadItem* item = [downloads objectAtIndex:row];
    
    NSMenu* menu = [[NSMenu alloc] init];
    [menu setAutoenablesItems:NO];
    
    NSMenuItem* suspendDownload = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"tcmSuspendDownloadText", nil) action:@selector(actionOfContextMenuForDownloadList:) keyEquivalent:@""];
    [suspendDownload setKeyEquivalentModifierMask:0];
    [suspendDownload setTarget:self];
    [suspendDownload setTag:2001];
    [suspendDownload setRepresentedObject:item];
    
    if (item.currentState == 1 || item.currentState == 5) {
        [menu addItem:suspendDownload];
    }
    
    if (item.currentState == 5) {
        [suspendDownload setTitle:NSLocalizedString(@"tcmResumeDownloadText", nil)];
    }
    
    NSMenuItem* removeFromList = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"tcmRemoveFromListText", nil) action:@selector(actionOfContextMenuForDownloadList:) keyEquivalent:@""];
    [removeFromList setKeyEquivalentModifierMask:0];
    [removeFromList setTarget:self];
    [removeFromList setTag:2002];
    [removeFromList setRepresentedObject:item];
    
    if (item.currentState == 1) {
        [removeFromList setTitle:NSLocalizedString(@"tcmCancelDownloadText", nil)];
    }
    [removeFromList setEnabled:(item.currentState != 3 && item.currentState != 4 && item.currentState != 9)];
    [menu addItem:removeFromList];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* showInFinder = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"tcmShowInFinderText", nil) action:@selector(actionOfContextMenuForDownloadList:) keyEquivalent:@""];
    [showInFinder setKeyEquivalentModifierMask:0];
    [showInFinder setTarget:self];
    [showInFinder setTag:2004];
    [showInFinder setRepresentedObject:item];
    [showInFinder setEnabled:(item.currentState != 2 && item.currentState != 7)];
    [menu addItem:showInFinder];
    
    NSMenuItem* openPageOrigin = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"tcmOpenPageOriginText", nil) action:@selector(actionOfContextMenuForDownloadList:) keyEquivalent:@""];
    [openPageOrigin setKeyEquivalentModifierMask:0];
    [openPageOrigin setTarget:self];
    [openPageOrigin setTag:2003];
    [openPageOrigin setRepresentedObject:item];
    [menu addItem:openPageOrigin];
    
    return menu;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    DownloadsTableRowView* tableRowView = [[DownloadsTableRowView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 0.0, 0.0)];
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    DownloadItem* item = [downloads objectAtIndex:row];
    
    if (item.currentState > 12) {
        [tableRowView setHideBtnStartStopFind:NO];
        [tableRowView setHideBtnCancelDelete:NO];
    }
    
    int mask = 4632;
    if (mask & item.currentState) {
        [tableRowView setHideBtnStartStopFind:YES];
        [tableRowView setHideBtnCancelDelete:YES];
    }
    
    mask = 1028;
    if (mask & item.currentState || item.currentState == 11) {
        [tableRowView setHideBtnStartStopFind:YES];
        [tableRowView setHideBtnCancelDelete:NO];
    }
    else {
        [tableRowView setHideBtnStartStopFind:NO];
        [tableRowView setHideBtnCancelDelete:NO];
    }
    
    if (item.updatingLink) {
        [tableRowView setHideBtnStartStopFind:YES];
        [tableRowView setHideBtnCancelDelete:YES];
    }
    [tableRowView setRowIndex:row];
    return tableRowView;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (![tableColumn.identifier isEqualToString:@"DownloadsList"]) {
        return nil;
    }
    
    DownloadsTableCellView* downloadView = [tableView makeViewWithIdentifier:@"DownloadsListCell" owner:self];
    [downloadView.btnStartStopFind setHidden:YES];
    [downloadView.btnCancelDelete setHidden:YES];
    
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    DownloadItem* item = [downloads objectAtIndex:row];
    
    if ([downloadView isKindOfClass:[DownloadsTableCellView class]]) {
        [downloadView setObjectValue:item];
    }
    
    NSString* rowNum = [NSString stringWithFormat:@"Row%ld", row];
    const char* forQueueName = [rowNum UTF8String];
    dispatch_queue_t rowQueue = dispatch_queue_create(forQueueName, nil);
    
    if ([self->_cachedImages objectForKey:item.thumbnailUrl]) {
        id thumbnail = [self->_cachedImages valueForKey:item.thumbnailUrl];
        [downloadView.thumbnail setImage:thumbnail];
    }
    else {
        [downloadView.thumbnail setImage:[NSImage imageNamed:@"default"]];
        dispatch_async(rowQueue, ^{
            NSURL* thumbnailUrl = [NSURL URLWithString:item.thumbnailUrl];
            NSData* thumbnailData = [NSData dataWithContentsOfURL:thumbnailUrl];
            if (thumbnailData) {
                NSImage* thumbnailImg = [[NSImage alloc] initWithData:thumbnailData];
                [self->_cachedImages setValue:thumbnailImg forKey:item.thumbnailUrl];
                [downloadView.thumbnail performSelectorOnMainThread:@selector(setImage:) withObject:thumbnailImg waitUntilDone:NO];
            }
        });
    }
    
    NSString* title = nil;
    if (item.title) {
        title = item.title;
    }
    else {
        if (item.parentTitle) {
            title = item.parentTitle;
        }
        else if (item.parent) {
            title = item.parent.title;
        }
        else {
            title = @"";
        }
    }
    
    if (item.format) {
        NSString* titleFormat = [NSString stringWithFormat:@"%@.%@", title, item.format];
        [downloadView.txtTitle setStringValue:titleFormat];
    }
    else {
        [downloadView.txtTitle setStringValue:title];
    }
    
    [self refreshDataInRowView:downloadView forItem:item];
    return downloadView;
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    id delegate = [NSApp delegate];
    return [[delegate downloadsList] count];
}

- (void)deleteRootItem:(DownloadItem*)obj {
    if ([self.temporaryPacket containsObject:obj]) {
        [self.temporaryPacket removeObject:obj];
    }
    if (self.temporaryPacket.count) {
        NSString* txtVideoUrlString = [NSString stringWithFormat:@"[ %ld links added ]", self.temporaryPacket.count];
        [self.txtVideoUrl setString:txtVideoUrlString];
    }
    else {
        [self lockOfButtons];
        [self.txtVideoUrl setString:@""];
        [self.txtVideoUrl enableTextView:YES];
        [self.window makeFirstResponder:nil];
    }
    
    [self removeItemFromListOfDownloads:obj];
}

- (void)removeItemFromListOfDownloads:(DownloadItem*)downloadItem {
    BOOL bTen = YES;
    NSUInteger nKindOfItem = 0;
    
    id delegate = [NSApp delegate];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (downloadItem.currentState != 5 && downloadItem.currentState != 8 && downloadItem.currentState != 1) {
        bTen = (downloadItem.currentState == 10);
    }
    
    if (downloadItem.currentState == 1) {
        if ([downloadItem.mimeType hasPrefix:@"video"]) {
            [downloadItem setVideoFileWasDeleted:YES];
            if (downloadItem.connectForDownloadVideo) {
                [downloadItem.queueOfSavingVideo cancelAllOperations];
                [downloadItem.queueOfSavingVideo waitUntilAllOperationsAreFinished];
                if (downloadItem.isVideoDASH) {
                    [downloadItem.queueOfSavingSound cancelAllOperations];
                    nKindOfItem = 1;
                }
                else {
                    nKindOfItem = 4;
                }
            }
            else {
                if (downloadItem.connectForDownloadSegment) {
                    [downloadItem.queueOfSavingVideoSegments cancelAllOperations];
                    [downloadItem.queueOfSavingSoundSegments cancelAllOperations];
                    nKindOfItem = 5;
                }
            }
        }
        else if ([downloadItem.mimeType hasPrefix:@"audio"]) {
            [downloadItem setAudioFileWasDeleted:YES];
            if (downloadItem.connectForDownloadMP3) {
                [downloadItem.queueOfSavingMp3 cancelAllOperations];
                [downloadItem.queueOfSavingMp3 waitUntilAllOperationsAreFinished];
                nKindOfItem = 3;
            }
            else {
                if (downloadItem.connectForDownloadSegment) {
                    [downloadItem.queueOfSavingAudioSegments cancelAllOperations];
                    [downloadItem.queueOfSavingAudioSegments waitUntilAllOperationsAreFinished];
                    nKindOfItem = 7;
                }
            }
        }
    
        [delegate cancelOfDownloadOfItem:downloadItem kindOf:nKindOfItem];
    }
    
    NSError* error = nil;
    if (downloadItem.currentState) {
        if ([fileManager fileExistsAtPath:downloadItem.pathToPackageOfDownload]) {
            [fileManager removeItemAtPath:downloadItem.pathToPackageOfDownload error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        
        if (downloadItem.folderOfVideoWithSub) {
            error = nil;
            if ([fileManager fileExistsAtPath:downloadItem.folderOfVideoWithSub]) {
                [fileManager removeItemAtPath:downloadItem.folderOfVideoWithSub error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
                [downloadItem setFolderOfVideoWithSub:nil];
            }
        }
    }
    
    [[delegate downloadsList] removeObject:downloadItem];
    [self.tableDownloadList reloadData];
    [delegate reduceMainWindowSize];
    
    if (!bTen) {
        [delegate saveDownloadsInUserDefaults];
    }
    
    if ([delegate isProVersion]) {
        if ([delegate currentlyNumberOfActive] <= 4) {
            [self startDownloadOfNextVideo];
        }
    }
    
    if ([[YDUserDefaults activationKey] isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"] && [YDUserDefaults numberOfDownloadsFreeVersion] > 0) {
        [self startDownloadOfNextVideo];
    }
    
    if (![[delegate downloadsList] count]) {
        [self.lblInvitation setHidden:NO];
    }
    [self updateLabelCountDownloads];
}

- (void)showAlertLinksNotAvailable {
    NSUInteger packetCount = [[self temporaryPacket] count];
    NSUInteger linkCount = [[self allLinks] count];
    id delegate = [NSApp delegate];
    
    if (!self.needSignIn) {
        [Utility showAlertNotAllLinksAvailable:linkCount skippedLinks:packetCount needSignIn:self.needSignIn];
        return;
    }
    
    if (linkCount == 1) {
        if ([YDUserDefaults optionDontAskAgainLogInYoutube]) {
            [Utility showAlertNotAllLinksAvailable:linkCount skippedLinks:packetCount needSignIn:self.needSignIn];
            return;
        }
        
        if ([YDUserDefaults loggedInYoutube]) {
            long long youtubeExpired = [Utility showAlertLogInYoutubeExpired];
            if (youtubeExpired == 1002) {
                [delegate logoutOfYoutube];
            }
            else if (youtubeExpired == 1000) {
                [delegate logoutOfYoutube];
                [delegate menuLoginOfYoutube:nil];
                return;
            }
        }
        else if ([Utility showAlertLogInYoutubeIfNeed] == 1000) {
            [delegate menuLoginOfYoutube:nil];
        }
    }
    else {
        if (linkCount != packetCount) {
            [Utility showAlertNotAllLinksAvailable:linkCount skippedLinks:packetCount needSignIn:self.needSignIn];
            return;
        }
    }
}

- (void)showProcessingPlaylistWindow { 
    if (!self.processingWindow) {
        self.processingWindow = [[ProcessingLinksWindowController alloc] initWithWindowNibName:@"ProcessingLinksWindowController"];
    }
    
    id delegate = [NSApp delegate];
    MainWindowController* mainCtrl = [delegate mainWindowController];
    NSURL* downloadUrl = [NSURL URLWithString:mainCtrl.txtVideoUrl.string];
    
    if ([downloadUrl.path hasPrefix:@"/channel"]) {
        NSString* title = NSLocalizedString(@"parcingChannelWindowTitle", nil);
        [self.processingWindow.window setTitle:title];
    }
    else {
        NSString* title = NSLocalizedString(@"parcingPlaylistWindowTitle", nil);
        [self.processingWindow.window setTitle:title];
    }
    
    [self.processingWindow.txtAboutProcessing setStringValue:NSLocalizedString(@"parcingInProcess", nil)];
    [self.processingWindow.btnCancel setEnabled:NO];
    [self.processingWindow.progressProcessing startAnimation:nil];
    
    [self setInProcessParsing:YES];
    [self setParsingCanceled:NO];
    [self.processingWindow.window center];
    
    [NSApp runModalForWindow:self.processingWindow.window];
}

- (void)updateLabelCountDownloads { 
    id delegate = [NSApp delegate];
    
    
    unsigned long long numOfActive = [delegate currentlyNumberOfActive];
    unsigned long long numOfSuspended = [delegate currentlyNumberOfSuspended];
    unsigned long long numOfQueued = [delegate currentlyNumberOfQueued];
    
    if (![delegate isProVersion]) {
        if ([delegate isDemoVersion]) {
            long long freeDownloads = [delegate getNumberFreeDownloads];
            NSString* lblTextWithDownloadNum = [NSString stringWithFormat:NSLocalizedString(@"lblAvailableDowloadsText", nil), freeDownloads];
            [self.lblCountDownloads setStringValue:lblTextWithDownloadNum];
            [self.lblCountDownloads setNeedsDisplay];
            
            return;
        }
    }
    
    if (!(numOfActive || numOfSuspended || numOfQueued)) {
        [self.lblCountDownloads setStringValue:@""];
        [self.lblCountDownloads setNeedsDisplay];
        
        return;
    }
    
    if ((numOfSuspended == 0 && numOfActive != 0) && !numOfQueued) {
        NSString* lblTextWithActiveNum = [NSString stringWithFormat:NSLocalizedString(@"txtActiveDowloads", nil), numOfActive];
        [self.lblCountDownloads setStringValue:lblTextWithActiveNum];
        [self.lblCountDownloads setNeedsDisplay];
        
        return;
    }
    
    if ((numOfActive == 0 && numOfSuspended != 0) && !numOfQueued) {
        NSString* lblTextWithSuspendNum = [NSString stringWithFormat:NSLocalizedString(@"txtSuspendDowloads", nil), numOfSuspended];
        [self.lblCountDownloads setStringValue:lblTextWithSuspendNum];
        [self.lblCountDownloads setNeedsDisplay];
        
        return;
    }
    
    if (numOfQueued != 0 && (numOfSuspended == 0 && numOfActive != 0)) {
        NSString* lblTextWithActiveQueuedNum = [NSString stringWithFormat:NSLocalizedString(@"txtActiveQueuedDowloads", nil), numOfActive, numOfQueued];
        [self.lblCountDownloads setStringValue:lblTextWithActiveQueuedNum];
        [self.lblCountDownloads setNeedsDisplay];
        
        return;
    }
    
    if ((numOfQueued != 0 && (numOfActive == 0 && numOfSuspended != 0))) {
        NSString* lblTextWithSuspendedQueuedDownloadsNum = [NSString stringWithFormat:NSLocalizedString(@"txtSuspendedQueuedDowloads", nil), numOfSuspended, numOfQueued];
        [self.lblCountDownloads setStringValue:lblTextWithSuspendedQueuedDownloadsNum];
        [self.lblCountDownloads setNeedsDisplay];
        
        return;
    }
    
    if (numOfActive && numOfSuspended && !numOfQueued) {
        NSString* lblTextWithActiveSuspendDownloadsNum = [NSString stringWithFormat:NSLocalizedString(@"txtActiveSuspendDowloads", nil), numOfActive, numOfSuspended];
        [self.lblCountDownloads setStringValue:lblTextWithActiveSuspendDownloadsNum];
        [self.lblCountDownloads setNeedsDisplay];
    }
    else {
        NSString* lblTextWithActiveSuspendQueuedDownloadsNum = [NSString stringWithFormat:NSLocalizedString(@"txtActiveSuspendQueuedDowloads", nil), numOfActive, numOfSuspended, numOfQueued];
        [self.lblCountDownloads setStringValue:lblTextWithActiveSuspendQueuedDownloadsNum];
        [self.lblCountDownloads setNeedsDisplay];
    }
    
}

- (void)updateInterfaceBeforeDownloading { 
    [self.progressDownload stopAnimation:self];
    NSUInteger linkCount = [self.allLinks count];
    NSUInteger packetCount = [self.temporaryPacket count];
    
    if (linkCount != packetCount && !self.parsingCanceled) {
        [self showAlertLinksNotAvailable];
    }
    
    NSString* txtVideoUrl = nil;
    if (packetCount) {
        if (packetCount == 1) {
            id packet = self.temporaryPacket[0];
            txtVideoUrl = [packet pageUrl];
        }
        else {
            txtVideoUrl = [NSString stringWithFormat:@"[ %ld links added ]", packetCount];
        }
        [self.txtVideoUrl setString:txtVideoUrl];
        
        if ([self.btnResolutions numberOfItems] > 0) {
            [self.btnResolutions removeAllItems];
        }
        
        [self.btnResolutions addItemWithTitle:@""];
        
        if (packetCount >= 2) {
            [self.btnResolutions addItemWithTitle:NSLocalizedString(@"itemMaxQuality", nil)];
        }
        
        id btnFormat = [self titlesOfButtonFormatResolution:self.temporaryPacket];
        [self.btnResolutions addItemsWithTitles:btnFormat];
        [self.btnResolutions addItemWithTitle:@"mp3"];
        
        NSString* lastFormatResolution = [YDUserDefaults lastSelectedFormatResolution];
        NSInteger index = 0;
        if (lastFormatResolution) {
            index = [self.btnResolutions indexOfItemWithTitle:lastFormatResolution];
        }
        else {
            index = -1;
        }
        
        NSInteger lastIndex = (index != -1) ? index : 1;
        
        NSString* btnResTitle = [self.btnResolutions itemTitleAtIndex:lastIndex];
        [self.btnResolutions setTitle:btnResTitle];
        [self.btnResolutions selectItemAtIndex:lastIndex];
        [self.txtVideoUrl enableTextView:YES];
        [self.btnResolutions setEnabled:YES];
        [self.btnDownload setEnabled:YES];
    }
    else {
        [self lockOfButtons];
        [self.txtVideoUrl setString:@""];
        [self.txtVideoUrl enableTextView:YES];
        [self.window makeFirstResponder:nil];
    }
}

- (void)updateInterfaceAfterGettingLinks { 
    NSUInteger linkCount = [self.allLinks count];
    if (linkCount) {
        [self startGettingLinksForDownloadVideo];
    }
    else {
        [[self.processingWindow progressProcessing] stopAnimation:nil];
        
        if (self.processingWindow.window) {
            [NSApp endSheet:self.processingWindow.window returnCode:1];
            [self.processingWindow.window orderOut:nil];
        }
        
        [self showAlertLinksNotAvailable];
        [self lockOfButtons];
        [self.txtVideoUrl enableTextView:YES];
        [self.txtVideoUrl setPlaceholderString:NSLocalizedString(@"placeholderVideoUrl", nil)];
        [self.window makeFirstResponder:nil];
    }
}

- (void)lockOfButtons { 
    if ([self.btnResolutions numberOfItems] > 0) {
        [self.btnResolutions removeAllItems];
    }
    
    [self.btnResolutions setEnabled:NO];
    [self.btnDownload setEnabled:NO];
}

- (void)clearListsOfLinks { 
    if (self.allLinks.count) {
        [self.allLinks removeAllObjects];
    }
    
    if (self.temporaryPacket.count) {
        [self.temporaryPacket removeAllObjects];
    }
    
    self->quantityPlaylists = 0;
}

- (void)buttonCancelDeleteWasPressed:(id)sender {
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    NSInteger rowIndex = [self.tableDownloadList rowForView:[sender superview]];
    if (rowIndex == -1) {
        return;
    }
    
    NSTableCellView* ssuperview = [[sender superview] superview];
    if ([ssuperview isKindOfClass:[DownloadsTableCellView class]]) {
        DownloadItem* obj = [ssuperview objectValue];
        NSInteger itemIndex = [downloads indexOfObject:obj];
        if (itemIndex != NSNotFound) {
            if (obj.currentState != 3 && obj.currentState != 4 && obj.currentState != 9) {
                if ([YDUserDefaults optionDontAskAgainCancelDownloads] || !obj.currentState || obj.currentState == 2) {
                    [self removeItemFromListOfDownloads:obj];
                }
                else {
                    NSAlert* anAlert = [[NSAlert alloc] init];
                    [anAlert setAlertStyle:NSAlertStyleWarning];
                    
                    [anAlert addButtonWithTitle:NSLocalizedString(@"button_yes", nil)];
                    [anAlert addButtonWithTitle:NSLocalizedString(@"button_no", nil)];
                    [anAlert setShowsSuppressionButton:YES];
                    [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_ask", nil)];
                    
                    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"alertCancelDonloadMessage", nil), obj.title];
                    
                    anAlert.messageText = message;
                    anAlert.informativeText = NSLocalizedString(@"alertCancelDowloadInfo", nil);
                    
                    NSModalResponse action = [anAlert runModal];
                    if (action == NSAlertFirstButtonReturn) {
                        [self removeItemFromListOfDownloads:obj];
                    }
                    
                    [YDUserDefaults setOptionDontAskAgainCancelDownloads:(anAlert.suppressionButton.state == NSControlStateValueOn ? YES : NO)];
                }
            }
        }
    }
}

- (void)showInFinderDownloadItem:(DownloadItem*)item {
    NSString* downloadPath = nil;
    if (item.currentState) {
        downloadPath = item.pathToPackageOfDownload;
    }
    
    if (item.pathToTheSavedVideo) {
        NSRange searchRange = [item.pathToTheSavedVideo rangeOfString:@"streamup"];
        if (searchRange.location == NSNotFound) {
            downloadPath = item.pathToTheSavedVideo;
        }
        else {
            downloadPath = [item.downloadDir stringByAppendingPathComponent:[item.pathToTheSavedVideo lastPathComponent]];
        }
    }
    
    if (![[NSWorkspace sharedWorkspace] selectFile:downloadPath inFileViewerRootedAtPath:@""]) {
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleCritical];
        
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_yes", nil)];
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_no", nil)];
        
        anAlert.messageText = NSLocalizedString(@"alertNotExistInFinderMessage", nil);
        anAlert.informativeText = NSLocalizedString(@"alertNotExistInFinderInfo", nil);
        
        NSModalResponse action = [anAlert runModal];
        if (action == NSAlertFirstButtonReturn) {
            [self removeItemFromListOfDownloads:item];
        }
    }
}

- (void)buttonStartStopFindWasPressed:(id)sender {
    NSInteger rowIndex = [self.tableDownloadList rowForView:sender];
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    DownloadItem* item = [downloads objectAtIndex:rowIndex];
    
    if (item.currentState != 3 && item.currentState != 4 && item.currentState != 9) {
        if (item.currentState) {
            if (item.currentState != 5 && item.currentState != 8) {
                if (item.currentState == 6) {
                    [self resumeConvertingForItem:item];
                }
                else if (item.currentState == 1) {
                    [self suspendDownloadForItem:item];
                }
            }
            else {
                if ([[YDUserDefaults activationKey] isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"]) {
                    long long freeDownloads = [YDUserDefaults numberOfDownloadsFreeVersion];
                    [delegate setNumberFreeDownloads:freeDownloads];
                }
                [self resumeDownloadForItem:item];
            }
        }
        else {
            [self showInFinderDownloadItem:item];
        }
    }
}

- (IBAction)buttonResolutionSelectionWasChanged:(id)sender {
    NSMenuItem* selectedItem = [self.btnResolutions selectedItem];
    [self.btnResolutions setTitle:selectedItem.title];
    [YDUserDefaults setLastSelectedFormatResolution:selectedItem.title];
}

- (void)processOfUpdatingUrlIsCompleteForItem:(DownloadItem*)item {
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    if ([downloads containsObject:item]) {
        DownloadItem* soundItem = [item getSoundItem];
        [item setUrlSoundItem:soundItem.url];
        [item setUpdatingLink:NO];
        long long numOfActive = [delegate currentlyNumberOfActive];
        BOOL bIsMp3 = [item.format isEqualToString:@"mp3"];
        BOOL bIsActiveKey = [[YDUserDefaults activationKey] isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"];
        
        if (bIsActiveKey) {
            if ([delegate getNumberFreeDownloads] <= 0) {
                [self.tableDownloadList reloadData];
                return;
            }
            
            if (item.currentState != 1 && item.currentState != 8) {
                if (item.currentState != 2) {
                    [self.tableDownloadList reloadData];
                    return;
                }
                [self downloadVideo:item forMP3:bIsMp3];
            }
            else {
                [self resumeDownloadForItem:item afterUpdating:YES];
            }
            [self.tableDownloadList reloadData];
            return;
            
        }
        
        if (![delegate isProVersion]) {
            [self.tableDownloadList reloadData];
            return;
        }
        
        if (item.currentState == 1 || item.currentState == 8 || item.currentState == 5) {
            [self resumeDownloadForItem:item afterUpdating:YES];
            if (numOfActive == 5) {
                struct timeval sTime;
                gettimeofday(&sTime, nil);
            }
            [self.tableDownloadList reloadData];
            return;
        }
        
        if (item.currentState == 2) {
            if (numOfActive <= 4) {
                [self downloadVideo:item forMP3:bIsMp3];
                [self.tableDownloadList reloadData];
                return;
            }
        }
        else {
            if (numOfActive <= 4 && item.currentState == 7) {
                [self downloadVideo:item forMP3:bIsMp3];
                [self.tableDownloadList reloadData];
                return;
            }
        }
        
        if (numOfActive == 5) {
            struct timeval sTime;
            gettimeofday(&sTime, nil);
        }
        
        [self.tableDownloadList reloadData];
        return;
    }
}

- (void)startUpdatingLinks:(NSMutableIndexSet*)indexSet {
    struct timeval sTime;
    gettimeofday(&sTime, nil);
    microseconds = sTime.tv_usec + 1000000 * sTime.tv_sec;
    
    if (!self.queueOfUpdatingLinks) {
        NSOperationQueue* queueOfUpdatingLinks = [[NSOperationQueue alloc] init];
        [self setQueueOfUpdatingLinks:queueOfUpdatingLinks];
        [self.queueOfUpdatingLinks setMaxConcurrentOperationCount:1];
    }
    
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    [downloads enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setUpdatingLink:YES];
        [self refreshDataInDownloadsListForItem:obj];
        OperationLinkUpdating* opLinkUpdating = [[OperationLinkUpdating alloc] initOperationForDownloadItem:obj forController:self];
        [self.queueOfUpdatingLinks addOperation:opLinkUpdating];
    }];
}

- (NSMutableIndexSet*)indexesForUpdatingLinks {
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DownloadItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL bEqual9 = NO;
        if ([obj currentState] && [obj currentState] != 3 && [obj currentState] != 4) {
            bEqual9 = [obj currentState] != 9;
        }
        else {
            bEqual9 = NO;
        }
        
        NSString* url = nil;
        if ([obj url]) {
            url = obj.url;
        }
        else {
            NSMutableArray* urlOfSeg = obj.urlOfSegments;
            url = [urlOfSeg objectAtIndex:0];
        }
        
        if (bEqual9) {
            if ([obj expiryDateOfLinkEnded:url]) {
                [indexSet addIndex:idx];
            }
        }
    }];
    
    return indexSet;
}

- (void)resumeCalculateSizeOfSegmentsForItem:(DownloadItem*)downloadItem {
    [downloadItem setExpectedBytes:0];
    [downloadItem setExpectedBytesSound:0];
    [downloadItem setReceivedBytes:0];
    [downloadItem setReceivedBytesSound:0];
    [downloadItem setTotalExpectedBytes:0];
    
    BOOL bHasAudio = [[downloadItem mimeType] hasPrefix:@"audio"];
    [self downloadVideo:downloadItem forMP3:bHasAudio];
}

- (void)resumeConvertingForItem:(DownloadItem*)item {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (item.currentState == 3) {
        if (![fileManager fileExistsAtPath:item.pathToFileDashVideo]) {
            NSDictionary* itemKind = @{@"item": item, @"kindOfItem": [NSNumber numberWithInt:1]};
            [self fileProbablyWasDeleted:itemKind];
            return;
        }
        
        if ([fileManager fileExistsAtPath:item.pathToTheSavedVideo]) {
            NSError* error = nil;
            [fileManager removeItemAtPath:item.pathToTheSavedVideo error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }
        
        NSOperationQueue* opSavingVideo = [[NSOperationQueue alloc] init];
        [item setQueueOfSavingVideo:opSavingVideo];
        [item.queueOfSavingVideo setMaxConcurrentOperationCount:1];
        OperationOfSavingVideoData* opSavingVideoData = [[OperationOfSavingVideoData alloc] initWithData:nil forItem:item andController:self];
        [item.queueOfSavingVideo addOperation:opSavingVideoData];
    }
    
    if (item.currentState != 4) {
        return;
    }
    
    if (![fileManager fileExistsAtPath:item.pathToFileDashAudio]) {
        NSDictionary* itemKind = @{@"item": item, @"kindOfItem": [NSNumber numberWithInt:3]};
        [self fileProbablyWasDeleted:itemKind];
        return;
    }
    
    if ([fileManager fileExistsAtPath:item.pathToTheSavedAudio]) {
        NSError* error = nil;
        [fileManager removeItemAtPath:item.pathToTheSavedAudio error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    if ([fileManager fileExistsAtPath:item.pathToFileWithCover]) {
        NSError* error = nil;
        [fileManager removeItemAtPath:item.pathToFileWithCover error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    if ([fileManager fileExistsAtPath:item.coverImage]) {
        NSError* error = nil;
        [fileManager removeItemAtPath:item.coverImage error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    
    NSOperationQueue* opSavingMp3 = [[NSOperationQueue alloc] init];
    [item setQueueOfSavingMp3:opSavingMp3];
    [item.queueOfSavingMp3 setMaxConcurrentOperationCount:1];
    OperationOfSavingAudioData* opSavingAudioData = [[OperationOfSavingAudioData alloc] initWithData:nil forItem:item andController:self];
    [item.queueOfSavingMp3 addOperation:opSavingAudioData];
}

- (void)resumeConcatenationOfSegmentsForItem:(DownloadItem*)downloadItem {
    if (downloadItem.wasSavedSound && downloadItem.wasSavedVideo) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self conversionOfVideoForItem:downloadItem];
        });
        return;
    }
    
    NSString* downloadVideoPath = [NSString stringWithFormat:@"%@/%@", [downloadItem pathToPackageOfDownload], @"video.m4v"];
    NSString* downloadSoundPath = [NSString stringWithFormat:@"%@/%@", [downloadItem pathToPackageOfDownload], @"sound.m4a"];
    
    if (downloadItem.wasSavedSound) {
        if (downloadItem.numOfSoundSegment >= downloadItem.urlOfSoundSegments.count) {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:downloadSoundPath error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self concatenateSoundSegmentsOfItem:downloadItem];
            });
        }
    }
    
    if (!downloadItem.wasSavedVideo) {
        if (downloadItem.numOfSegment >= downloadItem.urlOfSegments.count) {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:downloadVideoPath error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                BOOL bIsAudio = [downloadItem.mimeType hasPrefix:@"audio"];
                [self concatenateSegmentsOfItem:downloadItem isSound:bIsAudio];
            });
        }
    }
}

- (void)startLoadingOrConversionOfLinksIfNeeded { 
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState]) {
            if ([obj isVideoDashMpd]) {
                NSString* downloadVideoPath = [NSString stringWithFormat:@"%@/%@", [obj pathToPackageOfDownload], @"video.m4v"];
                NSString* downloadSoundPath = [NSString stringWithFormat:@"%@/%@", [obj pathToPackageOfDownload], @"sound.m4a"];
                if (![obj wasSavedSound]) {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadSoundPath]) {
                        [obj setWasSavedSound:YES];
                    }
                }
                
                if ([obj wasSavedVideo] == YES) {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadVideoPath]) {
                        [obj setWasSavedVideo:YES];
                    }
                }
                
                if ([obj currentState] == 10) {
                    [self resumeCalculateSizeOfSegmentsForItem:obj];
                }
                
                if ([obj currentState] == 9) {
                    [self resumeConcatenationOfSegmentsForItem:obj];
                }
            }
            
            if ([obj currentState] == 3 || [obj currentState] == 4) {
                NSString* directoryPath = [[obj pathToPackageOfDownload] stringByDeletingLastPathComponent];
                if ([self downloadsFolderIsAvailableByPath:directoryPath]) {
                    [self resumeConvertingForItem:obj];
                }
            }
            
            if ([obj currentState] == 1 || [obj currentState] == 8) {
                NSString* directoryPath = [[obj pathToPackageOfDownload] stringByDeletingLastPathComponent];
                if ([self downloadsFolderIsAvailableByPath:directoryPath]) {
                    [self resumeDownloadForItem:obj];
                }
                else {
                    [self suspendDownloadForItem:obj];
                }
            }
            
            id delegate = [NSApp delegate];
            
            if ([delegate isProVersion]) {
                if ([delegate currentlyNumberOfActive] >= 5) {
                    return [self refreshDataInDownloadsListForItem:obj];
                }
            }
            else {
                if ([YDUserDefaults numberOfDownloadsFreeVersion] <= 0) {
                    return [self refreshDataInDownloadsListForItem:obj];
                }
            }
            
            if (([obj currentState] == 2 || [obj currentState] == 7) && ![obj updatingLink]) {
                BOOL bIsMp3 = [[obj format] isEqualToString:@"mp3"];
                [self downloadVideo:obj forMP3:bIsMp3];
            }
            return [self refreshDataInDownloadsListForItem:obj];
        }
    }];
}

- (void)restoreTheStateOfDownloadsList { 
    id userPreference = [YDUserDefaults currentUserPreferences];
    NSString* pathToDownload = [userPreference objectForKey:@"PathToDownloadsFolder"];
    
    id delegate = [NSApp delegate];
    if (![delegate currentlyNumberOfActive] || ([self downloadsFolderIsAvailableByPath:pathToDownload] && [self haveFreeSpaceForItems:nil onDevice:nil])) {
        id activeKey = [YDUserDefaults activationKey];
        if ([activeKey isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"]) {
            if ([delegate getNumberFreeDownloads] == 0) {
                if ([YDUserDefaults wasPurchasedPreviously]) {
                    [delegate showOfferReminderWindow];
                }
                else {
                    [delegate showDemoReminderWindow];
                }
            }
        }
        
        NSMutableIndexSet* indexes = [self indexesForUpdatingLinks];
        if ([indexes count]) {
            [self startUpdatingLinks:indexes];
        }
        [self startLoadingOrConversionOfLinksIfNeeded];
    }
    else {
        [self stopOfDownloadings];
        [self updateLabelCountDownloads];
    }
}

- (void)stopOfDownloadings { 
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DownloadItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState] == 3 || [obj currentState] == 4) {
            [obj setCurrentState:6];
        }
        
        if ([obj currentState] == 1) {
            [obj setCurrentState:5];
        }
        
        [self refreshDataInDownloadsListForItem:obj];
    }];
    
    [self.tableDownloadList reloadData];
}

- (void)convertSubtitlesToSrtFormat:(NSString*)subtitles {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* pathWithOutExt = [subtitles stringByDeletingPathExtension];
        NSString* srtFilename = [pathWithOutExt stringByAppendingString:@".srt"];
        NSArray* ffmpegCmd = @[@"-i", subtitles, srtFilename];
        
        NSTask* ffmpegExec = [[NSTask alloc] init];
        NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
        [ffmpegExec setLaunchPath:ffmpeg];
        [ffmpegExec setArguments:ffmpegCmd];
        [ffmpegExec launch];
        [ffmpegExec waitUntilExit];
        
        if ([ffmpegExec terminationStatus]) {
            NSLog(@"The task of converting of subtitled of video is complete with an error");
            return;
        }
        
        BOOL isDir;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:subtitles isDirectory:&isDir]) {
            NSError* error = nil;
            [fileManager removeItemAtPath:subtitles error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    });
}

- (void)loadingOfSubtitlesForDownloadItem:(DownloadItem*)item {
    NSMutableArray* subtitleTracks = nil;
    NSString* pageUrl = nil;
    if (item.parent) {
        subtitleTracks = item.parent.subtitleTracks;
        pageUrl = item.parent.pageUrl;
    }
    else {
        subtitleTracks = item.subtitleTracks;
        pageUrl = item.pageUrl;
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* pageUrlLink = [NSURL URLWithString:pageUrl];
    if ([subtitleTracks count]) {
        id valueKey = [pageUrlLink.query componentsSeparatedByString:@"="];
        NSString* value = [valueKey objectAtIndex:1];
        if (value) {
            for (id each in subtitleTracks) {
                NSString* langCode = [each objectForKey:@"langCode"];
                id youtubeSubtitlesFormat = [YDUserDefaults youtubeSubtitlesFormat];
                NSString* videoLink = [NSString stringWithFormat:@"http://video.google.com/timedtext?type=track&name=&lang=%@&v=%@&fmt=%@", langCode, value, youtubeSubtitlesFormat];
                NSURL* videoUrl = [NSURL URLWithString:videoLink];
                NSString* videoUrlEncode = [NSString stringWithContentsOfURL:videoUrl encoding:NSUTF8StringEncoding error:nil];
                
                if (![fileManager fileExistsAtPath:item.folderOfVideoWithSub]) {
                    NSLog(@"Folder for loading video with subtitles not exists");
                    return;
                }
                
                NSString* infoString = [NSString stringWithFormat:@"%@.%@.%@", item.title, langCode, youtubeSubtitlesFormat];
                NSString* fullPath = [item.folderOfVideoWithSub stringByAppendingPathComponent:infoString];
                NSString* realUrl = [videoUrlEncode stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                NSString* xmlString = (__bridge NSString *)CFXMLCreateStringByUnescapingEntities(nil, (CFStringRef)realUrl, nil);
                
                NSError* error = nil;
                if (![fileManager fileExistsAtPath:fullPath]) {
                    [xmlString writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    [self convertSubtitlesToSrtFormat:fullPath];
                    if (error) {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }
            }
        }
    }
}

- (BOOL)createSubtitleFolderForDownloadItem:(DownloadItem*)item {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    DownloadItem* media = nil;
    if (item.parent) {
        media = item.parent;
    }
    else {
        media = nil;
    }
    
    if (media) {
        if (media.subtitleTracks.count && !item.folderOfVideoWithSub) {
            NSString* onlyTitle = [item.title stringByDeletingPathExtension];
            NSString* fullPath = [item.downloadDir stringByAppendingPathComponent:onlyTitle];
            [item setFolderOfVideoWithSub:fullPath];
            if ([fileManager fileExistsAtPath:item.folderOfVideoWithSub]) {
                NSString* filename = [Utility addSuffixForFileName:item.folderOfVideoWithSub fileExtension:nil atPath:nil];
                [item setFolderOfVideoWithSub:filename];
            }
            
            NSError* error = nil;
            [fileManager createDirectoryAtPath:item.folderOfVideoWithSub withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (!error) {
                return YES;
            }
            else {
                NSLog(@"%@", error.localizedDescription);
                return NO;
            }
        }
        return NO;
    }
    
    if (!item.subtitleTracks.count) {
        return NO;
    }
    
    if (![fileManager fileExistsAtPath:item.folderOfVideoWithSub]) {
        [fileManager createDirectoryAtPath:item.folderOfVideoWithSub withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return YES;
}

- (void)updateOfDownloadItem:(DownloadItem*)item kindOf:(int)nType { 
    if (nType != 3 && [self createSubtitleFolderForDownloadItem:item]) {
        [self performSelectorInBackground:@selector(loadingOfSubtitlesForDownloadItem:) withObject:item];
    }
    
    BOOL bHasSubtitle = YES;
    NSString* clearFilePath = [Utility removeInvalidSymbolsFromFilePath:item.title];
    NSInteger count = 0;
    if (!item.pathToPackageOfDownload) {
        if (item.parent) {
            if (item.parent.subtitleTracks) {
                count = item.parent.subtitleTracks.count;
            }
        }
        else {
            bHasSubtitle = NO;
        }
        
        NSString* folderForDownload = nil;
        if (nType != 3 && bHasSubtitle && count) {
            folderForDownload = item.folderOfVideoWithSub;
        }
        else {
            folderForDownload = item.downloadDir;
        }
        
        // FIXME: I don't know why item.downloadDir wasn't initialized. So below line is just to init it by manual.
        
        if ([folderForDownload isEqualToString:@""]) {
            NSLog(@"Something wrong, the folderOfVideo is empty.");
            return;
        }
        
        NSString* filename = [Utility addSuffixForFileName:clearFilePath fileExtension:item.format atPath:folderForDownload];
        
        NSString* streamupFile = [NSString stringWithFormat:@"%@.streamup", filename];
        [item setPathToPackageOfDownload:streamupFile];
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:item.pathToPackageOfDownload withIntermediateDirectories:YES attributes:nil error:nil];
    id components = [[item.pathToPackageOfDownload lastPathComponent] componentsSeparatedByString:@"."];
    NSString* filename = [components objectAtIndex:0];
    
    switch (nType) {
        case 1:
        case 4:
        {
            NSString* folder = nil;
            NSString* streamupFile = [NSString stringWithFormat:@"%@.%@", filename, item.format];
            NSString* mediaFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:streamupFile];
            [item setPathToTheSavedVideo:mediaFile];
            if (item.isVideoDASH) {
                NSString* clearFile = [Utility removeInvalidSymbolsFromFilePath:item.title];
                NSString* fullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:clearFile];
                [item setPathToFileDashVideo:fullPath];
                folder = item.pathToFileDashVideo;
            }
            else {
                folder = item.pathToTheSavedVideo;
            }
            
            if ([fileManager createFileAtPath:folder contents:nil attributes:nil]) {
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                [item setQueueOfSavingVideo:opQueue];
                [item.queueOfSavingVideo setMaxConcurrentOperationCount:1];
                [item setNeedAllocMemForSavedUpVideoData:YES];
                [item setVideoFileWasDeleted:NO];
                [item setDeviceWasDeleted:NO];
                [item setWasSavedVideo:NO];
                [self.tableDownloadList reloadData];
                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"Video file was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
        }
            break;
            
        case 2:
        {
            NSString* clearFile = [Utility removeInvalidSymbolsFromFilePath:item.title];
            NSString* streamupFile = [NSString stringWithFormat:@"%@.%@", clearFile, @"m4a"];
            NSString* mediaFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:streamupFile];
            [item setPathToFileDashSound:mediaFile];
            
            if ([fileManager createFileAtPath:item.pathToFileDashSound contents:nil attributes:nil]) {
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                [item setQueueOfSavingSound:opQueue];
                [item.queueOfSavingSound setMaxConcurrentOperationCount:1];
                [item setNeedAllocMemForSavedUpSoundData:YES];
                [item setWasSavedSound:NO];

                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"Sound file was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
            
        }
            break;
            
        case 3:
        {
            NSString* streamFile = [NSString stringWithFormat:@"%@.%@", filename, item.format];
            NSString* mediaFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:streamFile];
            [item setPathToTheSavedAudio:mediaFile];
            
            NSString* coverStreamFile = [NSString stringWithFormat:@"(cover)%@.%@", filename, item.format];
            NSString* coverMediaFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:coverStreamFile];
            [item setPathToFileWithCover:coverMediaFile];
            
            NSString* imageStreamFile = [NSString stringWithFormat:@"%@.%@", filename, @"jpg"];
            NSString* imageFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:imageStreamFile];
            [item setCoverImage:imageFile];
            
            NSString* audioFile = [Utility removeInvalidSymbolsFromFilePath:item.title];
            NSString* audioFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:audioFile];
            [item setPathToFileDashAudio:audioFullPath];
            
            if ([fileManager createFileAtPath:item.pathToFileDashAudio contents:nil attributes:nil]) {
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                [item setQueueOfSavingMp3:opQueue];
                [item.queueOfSavingMp3 setMaxConcurrentOperationCount:1];
                [item setNeedAllocMemForSavedUpMp3Data:YES];
                [item setAudioFileWasDeleted:NO];
                [item setDeviceWasDeleted:NO];
                [self.tableDownloadList reloadData];
                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"File for mp3 was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
        }
            break;
            
        case 5:
        {
            NSString* videoFile = [NSString stringWithFormat:@"%@.%@", filename, item.format];
            NSString* videoFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:videoFile];
            [item setPathToTheSavedVideo:videoFullPath];
            
            NSString* segFile = [NSString stringWithFormat:@"%lld_seg", item.numOfSegment];
            NSString* segmentFile = [NSString stringWithFormat:@"%@.%@", segFile, @"m4v"];
            NSString* segmentFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:segmentFile];
            [item setPathToFileDashVideo:segmentFullPath];
            
            if ([fileManager createFileAtPath:item.pathToFileDashVideo contents:nil attributes:nil]) {
                if (!item.queueOfSavingVideoSegments) {
                    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                    [item setQueueOfSavingVideoSegments:opQueue];
                    [item.queueOfSavingVideoSegments setMaxConcurrentOperationCount:1];
                    
                    if (!item.numOfSegment) {
                        [self.tableDownloadList reloadData];
                    }
                }
                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"Video file was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
        }
            break;
            
        case 6:
        {
            NSString* segFile = [NSString stringWithFormat:@"%lld_seg", item.numOfSoundSegment];
            NSString* segmentFile = [NSString stringWithFormat:@"%@.%@", segFile, @"m4a"];
            NSString* segmentFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:segmentFile];
            [item setPathToFileDashSound:segmentFullPath];
            
            if ([fileManager createFileAtPath:item.pathToFileDashSound contents:nil attributes:nil]) {
                if (!item.queueOfSavingSoundSegments) {
                    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                    [item setQueueOfSavingSoundSegments:opQueue];
                    [item.queueOfSavingSoundSegments setMaxConcurrentOperationCount:1];
                }
                if (item.currentState == 10) {
                    return;
                }
                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"File for mp3 was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
        }
            break;
            
        case 7:
        {
            NSString* audioFile = [NSString stringWithFormat:@"%@.%@", filename, item.format];
            NSString* audioFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:audioFile];
            [item setPathToTheSavedAudio:audioFullPath];
            
            NSString* coverStreamFile = [NSString stringWithFormat:@"(cover)%@.%@", filename, item.format];
            NSString* coverMediaFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:coverStreamFile];
            [item setPathToFileWithCover:coverMediaFile];
            
            NSString* imageStreamFile = [NSString stringWithFormat:@"%@.%@", filename, @"jpg"];
            NSString* imageFile = [item.pathToPackageOfDownload stringByAppendingPathComponent:imageStreamFile];
            [item setCoverImage:imageFile];
            
            NSString* segFile = [NSString stringWithFormat:@"%lld_seg", item.numOfSegment];
            NSString* segmentFile = [NSString stringWithFormat:@"%@.%@", segFile, @"m4a"];
            NSString* segmentFullPath = [item.pathToPackageOfDownload stringByAppendingPathComponent:segmentFile];
            [item setPathToFileDashAudio:segmentFullPath];
            
            if ([fileManager createFileAtPath:item.pathToFileDashAudio contents:nil attributes:nil]) {
                if (!item.queueOfSavingAudioSegments) {
                    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                    [item setQueueOfSavingAudioSegments:opQueue];
                    [item.queueOfSavingAudioSegments setMaxConcurrentOperationCount:1];
                }
                if (!item.numOfSegment) {
                    [self.tableDownloadList reloadData];
                }
                
                [self refreshDataInDownloadsListForItem:item];
            }
            else {
                NSLog(@"File for mp3 was not created. Error with code: %d - %s", 1, "unknown");
                return;
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)buttonDownloadWasClicked:(id)sender {
    id currentUserPreferences = [YDUserDefaults currentUserPreferences];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* downloadPath = [currentUserPreferences objectForKey:@"PathToDownloadsFolder"];
    BOOL bAskWhereSaveFile = [[currentUserPreferences objectForKey:@"AskWhereSaveFile"] boolValue];
    if (bAskWhereSaveFile && self.temporaryPacket.count == 1) {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseDirectories:YES];
        [openPanel setCanCreateDirectories:YES];
        [openPanel setCanChooseFiles:NO];
        
        NSError* err = nil;
        
        NSURL *temporaryDirectoryURL = [fileManager URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err];
        [openPanel setDirectoryURL:temporaryDirectoryURL];
        if ([openPanel runModal] != NSModalResponseOK) {
            return;
        }
        
        downloadPath = openPanel.URL.path;
    }
    
    [Utility createFolderAtPath:downloadPath];
    if ([self downloadsFolderIsAvailableByPath:downloadPath]) {
        BOOL bIsMp3 = [self.btnResolutions.titleOfSelectedItem hasPrefix:@"mp3"];
        NSString* itemMaxQuality = NSLocalizedString(@"itemMaxQuality", nil);
        NSString* specification = nil;
        NSInteger resolution = 0;
        NSInteger fps = 0;
        NSInteger lastResolution = 0;
        if ([self.btnResolutions.titleOfSelectedItem isEqualToString:itemMaxQuality]) {
            specification = @"";
        }
        else {
            id desResolution = [self.btnResolutions.titleOfSelectedItem componentsSeparatedByString:@" "];
            specification = [desResolution firstObject];
            if (!bIsMp3) {
                resolution = [desResolution[1] integerValue];
                if ([desResolution count] < 3) {
                    fps = 0;
                }
                else {
                    fps = [desResolution[2] integerValue];
                }
            }
        }
        
        NSString* lastSelectedFormatResolution = [YDUserDefaults lastSelectedFormatResolution];
        if ([lastSelectedFormatResolution hasPrefix:@"mp3"] || [lastSelectedFormatResolution isEqualToString:itemMaxQuality]) {
            lastResolution = 0;
        }
        else {
            id lastDesResolution = [lastSelectedFormatResolution componentsSeparatedByString:@" "];
            lastResolution = [lastDesResolution[1] integerValue];
        }
        
        if (!resolution || resolution > lastResolution) {
            [YDUserDefaults setLastSelectedFormatResolution:self.btnResolutions.titleOfSelectedItem];
        }
        
        NSMutableIndexSet* needDownloadSet = [[NSMutableIndexSet alloc] init];
        NSMutableArray* itemNeedDownload = [NSMutableArray array];
        
        BOOL bIsEmpty = [specification isEqualToString:@""];
        
        for (DownloadItem* each in self.temporaryPacket) {
            DownloadItem* item = nil;
            if (bIsMp3) {
                item = [each getMp3Item];
            }
            else {
                if (!(resolution == 0 && bIsEmpty && self.temporaryPacket.count > 1)) {
                    item = [each getItemWithFormat:specification resolution:resolution fps:fps];
                }
                else {
                    item = [each getItemWithMaxResolution];
                }
            }
            
            if (item) {
                // FIXME: the feature added by Ted for solve the problem that show title issue.
                // This bug already fix in operationReceivingLinksOfVideo
                // item.title = [item.title stringByReplacingOccurrencesOfString:@"(null)" withString:each.title];
                
                if ([self itemIsLoadedOrQueued:item]) {
                    NSAlert* anAlert = [[NSAlert alloc] init];
                    [anAlert setAlertStyle:NSAlertStyleWarning];
                    
                    [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
                    
                    anAlert.messageText = NSLocalizedString(@"alertVideoIsLoadingMessage", nil);
                    anAlert.informativeText = NSLocalizedString(@"alertVideoIsLoadingInfo", nil);
                    
                    [anAlert runModal];
                    
                    [self lockOfButtons];
                    [self.txtVideoUrl setString:@""];
                    [self.window makeFirstResponder:nil];
                }
                else {
                    [item setDownloadDir:downloadPath];
                    [itemNeedDownload insertObject:item atIndex:0];
                    [needDownloadSet addIndex:[self.temporaryPacket indexOfObject:each]];
                }
            }
        }
        
        if (itemNeedDownload.count) {
            [self lockOfButtons];
            [self.lblInvitation setHidden:YES];
            [self.txtVideoUrl setString:@""];
            [self.txtVideoUrl enableTextView:YES];
            [self.window makeFirstResponder:nil];
            
            NSMutableIndexSet* expiryIndexSet = [[NSMutableIndexSet alloc] init];
            [needDownloadSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadItem* item = [itemNeedDownload objectAtIndex:idx];
                [item setCurrentState:2];
                id delegate = [NSApp delegate];
                id downloads = [delegate downloadsList];
                [downloads insertObject:item atIndex:0];
                
                if (item.isVideoDASH) {
                    if (!item.urlSoundItem) {
                        DownloadItem* soundItem = [item getSoundItem];
                        if (soundItem) {
                            [self getSizeforItem:soundItem async:YES];
                            [item setUrlSoundItem:soundItem.url];
                            [item setTotalExpectedBytesOfSound:soundItem.totalExpectedBytes];
                        }
                    }
                }
                
                if (item.isVideoDashMpd) {
                    DownloadItem* soundItem = [item getSoundItem];
                    [item setUrlSoundItem:soundItem.url];
                    [item setUrlOfSoundSegments:soundItem.urlOfSegments];
                    [self getSummarySizeOfSoundSegmentsForItem:soundItem];
                    [item setTotalExpectedBytesOfSound:soundItem.totalExpectedBytes];
                }
                
                NSString* pageUrl = nil;
                if (item.url) {
                    pageUrl = item.url;
                }
                else {
                    pageUrl = [item.urlOfSegments objectAtIndex:0];
                }
                
                BOOL bExpiry = [item expiryDateOfLinkEnded:pageUrl];
                if (bExpiry) {
                    [expiryIndexSet addIndex:idx];
                }
            }];
            
            [self.tableDownloadList reloadData];
            
            id delegate = [NSApp delegate];
            id downloads = [delegate downloadsList];
            [delegate increaseMainWindowSize];
            [self startUpdatingLinks:expiryIndexSet];
            
            if (expiryIndexSet && [itemNeedDownload count] == [expiryIndexSet count]) {
                [needDownloadSet removeAllIndexes];
            }
            else {
                NSString* activeKey = [YDUserDefaults activationKey];
                // 191a961b-bbb7-4803-8ab7-4447457c32d3 means free version
                if ([activeKey isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"]) {
                    long long freeDownloads = [delegate getNumberFreeDownloads];
                    if (freeDownloads) {
                        [downloads enumerateObjectsAtIndexes:needDownloadSet options:NSEnumerationReverse usingBlock:^(DownloadItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (![obj updatingLink]) {
                                long long freeDownloads = [delegate getNumberFreeDownloads];
                                if (freeDownloads > 0) {
                                    [self downloadVideo:obj forMP3:bIsMp3];
                                }
                            }
                        }];
                    }
                    else {
                        if ([YDUserDefaults wasPurchasedPreviously]) {
                            [delegate showOfferReminderWindow];
                        }
                        else {
                            [delegate showDemoReminderWindow];
                        }
                    }
                }
                else {
                    [downloads enumerateObjectsAtIndexes:needDownloadSet options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj updatingLink]) {
                            long long numOfActive = [delegate currentlyNumberOfActive];
                            if (numOfActive <= 4) {
                                [self downloadVideo:obj forMP3:bIsMp3];
                            }
                        }
                    }];
                }
                [self updateLabelCountDownloads];
                [needDownloadSet removeAllIndexes];
                [self clearListsOfLinks];
            }
        }
    }
}

- (BOOL)itemIsLoadedOrQueued:(DownloadItem*)item {
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    for (DownloadItem* each in downloads) {
        if ([item.title isEqualToString:each.title] && item.itag == each.itag && each.currentState) {
            id itemComponents = [item.url componentsSeparatedByString:@"?"];
            NSString* itemFirstPart = [itemComponents objectAtIndex:0];
            id eachComponents = [each.url componentsSeparatedByString:@"?"];
            NSString* eachFirstPart = [eachComponents objectAtIndex:0];
            
            if ([itemFirstPart isEqualToString:eachFirstPart]) {
                if (item.parent.lengthSeconds == each.parent.lengthSeconds) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)processOfGettingPlaylistLinksIsComplete:(id)playlist {
    id urls = [playlist objectForKey:@"urls"];
    NSInteger nPlaylist = [[playlist objectForKey:@"playlistNumber"] integerValue];
    // FIXME: staticoIfo
    if ([urls count]) {
        [self.allLinks addObjectsFromArray:urls];
    }
    if (nPlaylist == self->quantityPlaylists) {
        [self updateInterfaceAfterGettingLinks];
    }
}

- (void)processOfGettingLinksIsComplete:(id)downloadInfo {
    DownloadItem* root = [downloadInfo objectForKey:@"root"];
    id linksNumber = [downloadInfo objectForKey:@"linksNumber"];
    NSUInteger nLinks = [linksNumber unsignedIntegerValue];
    
    if (self.processingWindow) {
        if (nLinks == 1) {
            [self.processingWindow.progressProcessing setIndeterminate:NO];
            [self.processingWindow.progressProcessing setMinValue:0.0];
            [self.processingWindow.progressProcessing setMaxValue:[self.allLinks count]];
            
            if ([self.processingWindow.txtAboutProcessing isHidden]) {
                [self.processingWindow.txtAboutProcessing setHidden:NO];
            }
            
            if (![self.processingWindow.btnCancel isEnabled]) {
                [self.processingWindow.btnCancel setEnabled:YES];
            }
        }
        
        [self.processingWindow.progressProcessing setDoubleValue:nLinks];
        
        NSString* parcingProcessedLinks = [NSString stringWithFormat:NSLocalizedString(@"parcingProcessedLinks", nil), nLinks, self.allLinks.count];
        [self.processingWindow.txtAboutProcessing setStringValue:parcingProcessedLinks];
        [self.processingWindow.txtAboutProcessing sizeToFit];
    }
    
    if (root && root.videoResources.count) {
        [self requestOfDownloaditemSubtitleTrack:root];
        [self.temporaryPacket addObject:root];
    }
    else {
        NSLog(@"No links for video downloads...");
        id errReason = [downloadInfo objectForKey:@"errorReason"];
        if (errReason) {
            NSRange searchRangeSign = [errReason rangeOfString:@"sign in" options:NSCaseInsensitiveSearch];
            NSRange searchRangePrivate = [errReason rangeOfString:@"is private" options:NSCaseInsensitiveSearch];
            
            if (searchRangeSign.location != NSNotFound || searchRangePrivate.location != NSNotFound) {
                [self setNeedSignIn:YES];
            }
        }
    }
    
    struct timeval sTime;
    if (nLinks == self.allLinks.count) {
        gettimeofday(&sTime, nil);
        if (self.processingWindow) {
            [self.processingWindow.progressProcessing stopAnimation:nil];
            [NSApp endSheet:self.processingWindow.window returnCode:1];
            [self.processingWindow.window orderOut:nil];
        }
        
        [self updateInterfaceBeforeDownloading];
        [self setInProcessParsing:NO];
    }
}

- (void)cancelProcessingOfLinksPlaylist { 
    [self.txtVideoUrl setString:@""];
    [self.txtVideoUrl enableTextView:YES];
    [self lockOfButtons];
    
    [self.window makeFirstResponder:nil];
    [self setInProcessParsing:NO];
    [self.queueReceiveLinks waitUntilAllOperationsAreFinished];
    [self clearListsOfLinks];
}

- (void)requestOfDownloadItemSize:(DownloadItem*)downloadItem {
    for (id video in downloadItem.videoResources) {
        NSURL* url = [NSURL URLWithString:[video url]];
        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        [mRequest setHTTPMethod:@"HEAD"];
        NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
        [video setConnectForGetSize:urlConn];
        [[video connectForGetSize] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [[video connectForGetSize] start];
    }
}

- (void)startGettingLinksForDownloadVideo {
    struct timeval sTime;
    if (self.allLinks.count) {
        gettimeofday(&sTime, nil);
        microseconds = sTime.tv_usec + 1000000 * sTime.tv_sec;
        NSOperationQueue* receiveLinksQueue = [[NSOperationQueue alloc] init];
        [self setQueueReceiveLinks:receiveLinksQueue];
        [self.queueReceiveLinks setMaxConcurrentOperationCount:1];
        
        OperationReceivingLinksOfVideo* opReceivingLinksOfVideo = [[OperationReceivingLinksOfVideo alloc] initOperationForVideos:self.allLinks forController:self];
        
        [self.queueReceiveLinks addOperation:opReceivingLinksOfVideo];
        
        [self setInProcessParsing:YES];
        [self setParsingCanceled:NO];
        
        if (self.allLinks.count == 1) {
            [self.progressDownload startAnimation:self];
            [self.txtVideoUrl setString:self.allLinks[0]];
        }
        else {
            if (self.allLinks.count >= 2) {
                if (![self.processingWindow.window isVisible]) {
                    [self showProcessingPlaylistWindow];
                }
            }
        }
    }
}

- (void)downloadingLink:(NSString*)url withPlaylistID:(id)playlist returnCode:(long long)retCode {
    if (retCode == 1001) {
        ++ self->quantityPlaylists;
        OperationReceivingLinksOfPlaylist* opRecvLinkPlaylist = [[OperationReceivingLinksOfPlaylist alloc] initOperationForPlaylist:url forController:self currentLinksNumber:self->quantityPlaylists];
        
        [self.queueReceivePlaylist addOperation:opRecvLinkPlaylist];
        if (!self.processingWindow.window.isVisible) {
            [self showProcessingPlaylistWindow];
        }
    }
    else if (retCode == 1000) {
        id youtubeUrl = [self convertLinkToStandardView:url];
        if (youtubeUrl) {
            [self.allLinks addObject:youtubeUrl];
        }
        [self updateInterfaceAfterGettingLinks];
    }
}

- (void)validateInsertedUrl:(id)txtUrl {
    id delegate = [NSApp delegate];
    
    [self lockOfButtons];
    [self clearListsOfLinks];
    
    [self.txtVideoUrl enableTextView:YES];
    
    if ([delegate activationErrorCode] == 8) {
        [delegate showAlertNeedReactivation];
        [self.txtVideoUrl setPlaceholderString:NSLocalizedString(@"placeholderVideoUrl", nil)];
        [self.window makeFirstResponder:nil];
        return;
    }
    
    if ([self.txtVideoUrl.string isEqualToString:@""]) {
        [self.txtVideoUrl setPlaceholderString:NSLocalizedString(@"placeholderVideoUrl", nil)];
        [self.window makeFirstResponder:nil];
        return;
    }
    
    [self.txtVideoUrl enableTextView:NO];
    
    NSOperationQueue* opRecvPlaylist = [[NSOperationQueue alloc] init];
    [self setQueueReceivePlaylist:opRecvPlaylist];
    [self.queueReceivePlaylist setMaxConcurrentOperationCount:1];
    
    BOOL bPlaylist = NO;
    NSMutableArray* invalidLinks = [NSMutableArray array];
    NSMutableOrderedSet* orderedSet = [NSMutableOrderedSet orderedSet];
    NSMutableArray* links = [self separationOfLinksByArray:self.txtVideoUrl.string];
    for (NSString* link in links) {
        if (![self isValidLink:link]) {
            [invalidLinks addObject:link];
            continue;
        }
        
        if ([self isPlaylistOrChannel:link]) {
            struct timeval sTime;
            gettimeofday(&sTime, nil);
            microseconds = sTime.tv_usec + 1000000 * sTime.tv_sec;
            
            ++ self->quantityPlaylists;
            
            OperationReceivingLinksOfPlaylist* opRecvLinkPlaylist = [[OperationReceivingLinksOfPlaylist alloc] initOperationForPlaylist:link forController:self currentLinksNumber:self->quantityPlaylists];
            
            [self.queueReceivePlaylist addOperation:opRecvLinkPlaylist];
            bPlaylist = YES;
            continue;
        }
        
        id playlistID = [self getPlaylistId:link];
        if (playlistID && links.count == 1) {
            if ([YDUserDefaults optionRememberChoiceForVideoPartOfPlaylist]) {
                long long playlistOrVideoOnly = [YDUserDefaults choiceDownloadCompletePlaylistOrVideoOnly];
                [self downloadingLink:link withPlaylistID:playlistID returnCode:playlistOrVideoOnly];
            }
            else {
                NSAlert* anAlert = [[NSAlert alloc] init];
                [anAlert setAlertStyle:NSAlertStyleWarning];
                
                [anAlert addButtonWithTitle:NSLocalizedString(@"btnDownloadVideoTitle", nil)];
                [anAlert addButtonWithTitle:NSLocalizedString(@"btnDownloadPlaylistTitle", nil)];
                [anAlert setShowsSuppressionButton:YES];
                [anAlert.suppressionButton setTitle:NSLocalizedString(@"btnRememberChoiceTitle", nil)];
                
                anAlert.messageText = NSLocalizedString(@"alertVideoPartPlaylistMessage", nil);
                anAlert.informativeText = NSLocalizedString(@"alertVideoPartPlaylistInfo", nil);
                
                NSModalResponse action = [anAlert runModal];
                if (anAlert.suppressionButton.state == NSControlStateValueOn) {
                    [YDUserDefaults setChoiceDownloadCompletePlaylistOrVideoOnly:action];
                }
                [YDUserDefaults setOptionRememberChoiceForVideoPartOfPlaylist:anAlert.suppressionButton.state];
                [self downloadingLink:link withPlaylistID:playlistID returnCode:action];
            }
            return;
        }
        
        id youtubeUrl = [self convertLinkToStandardView:link];
        if (youtubeUrl) {
            [orderedSet addObject:youtubeUrl];
        }
    }
    
    if (orderedSet.count) {
        [self.allLinks addObjectsFromArray:[orderedSet array]];
    }
    
    if (bPlaylist) {
        if (!self.processingWindow.window.isVisible) {
            [self showProcessingPlaylistWindow];
        }
    }
    else {
        [self updateInterfaceAfterGettingLinks];
    }
}

- (void)mouseDownOnTextField:(id)sender {
    if ([self.txtVideoUrl isEditable]) {
        [self.txtVideoUrl setString:@""];
        [self.txtVideoUrl setTextColor:[NSColor controlTextColor]];
        [self lockOfButtons];
        [self clearListsOfLinks];
    }
}

- (id)validateSchemaForLink:(NSString*)url {
    NSString* validateScheme = nil;
    if (![url hasPrefix:@"https://"] && ![url hasPrefix:@"http://"]) {
        validateScheme = [NSString stringWithFormat:@"https://%@", url];
    }
    else {
        validateScheme = url;
    }
    return validateScheme;
}

- (void)escapeInsertedUrl:(id)url {
    [self mouseDownOnTextField:url];
}

- (void)backspaceInsertedUrl:(id)sender {
    ;
}

- (id)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        self.temporaryPacket = [NSMutableArray array];
        self.allLinks = [NSMutableArray array];
        self.cachedImages = [[NSMutableDictionary alloc] init];
        self.inProcessParsing = NO;
        self->alertFileWasDeletedAlreadyShown = 0;
        return self;
    } else {
        return nil;
    }
}

- (double)getConvertionTime:(NSString*)datetime {
    if (!datetime) {
        return 0.0;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:datetime];
    double time = 0.0;
    
    NSString* infoString = nil;
    
    if ([scanner scanUpToString:@"time=" intoString:nil]) {
        [scanner scanUpToString:@" bitrate" intoString:&infoString];
        if (infoString) {
            id strInfo = [infoString componentsSeparatedByString:@"="];
            id bitInfo = strInfo[1];
            NSCharacterSet* charSet = [NSCharacterSet decimalDigitCharacterSet];
            id info = [bitInfo componentsSeparatedByCharactersInSet:[charSet invertedSet]];
            time = [[info componentsJoinedByString:@""] longLongValue];
        }
    }
    
    return time;
}

- (double)getDuration:(NSString*)duration {
    double retDuration = 0.0;
    if (duration) {
        NSString* infoString = nil;
        NSScanner* scanner = [NSScanner scannerWithString:duration];
        if (duration.length && [scanner scanUpToString:@"Duration: " intoString:nil]) {
            [scanner scanUpToString:@", " intoString:&infoString];
            if (infoString) {
                id separated = [infoString componentsSeparatedByString:@" "];
                NSCharacterSet* charSet = [NSCharacterSet decimalDigitCharacterSet];
                id bitInfo = separated[1];
                id info = [bitInfo componentsSeparatedByCharactersInSet:[charSet invertedSet]];
                retDuration = [[info componentsJoinedByString:@""] longLongValue];
            }
        }
    }
    
    return retDuration;
}

- (BOOL)saveCoverImageForItem:(DownloadItem*)item { 
    // TODO: Implement the function
    return NO;
}

- (void)startConcatenationOfItemSegments:(DownloadItem*)item {
    [item setCurrentState:9];
    [self.tableDownloadList reloadData];
    [self refreshDataInDownloadsListForItem:item];
}

- (void)startConversionOfItem:(DownloadItem*)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([item.mimeType hasPrefix:@"audio"] || item.connectForDownloadMP3) {
            [item setCurrentState:4];
        }
        if ([item.mimeType hasPrefix:@"video"] || item.connectForDownloadVideo) {
            [item setCurrentState:3];
        }
        [self.tableDownloadList reloadData];
        [self refreshDataInDownloadsListForItem:item];
    });
}

- (void)notifyAboutSavingAudioForItem:(DownloadItem*)item withSuccess:(BOOL)bSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* itemKind = @{@"item": item, @"kindOfItem": [NSNumber numberWithInt:3], @"success": [NSNumber numberWithBool:bSuccess]};
        [self multimediaWasSaved:itemKind];
    });
}

- (void)addCoverImageOfMp3ForItem:(DownloadItem*)item {
    if ([self saveCoverImageForItem:item]) {
        NSString* titleInfo = nil;
        if (item.parent) {
            titleInfo = item.parent.title;
        }
        else {
            titleInfo = item.title;
        }
        
        NSString* argTitle = [NSString stringWithFormat:@"title=%@", titleInfo];
        NSString* argComment = [NSString stringWithFormat:@"comment=%@", @"Cover (Front)"];
        
        NSArray* ffmpegCmd = @[@"-i", item.pathToTheSavedAudio, @"-i", item.coverImage, @"-c", @"copy", @"-map", @"0", @"-map", @"1", @"-metadata:s:v", argTitle, @"-metadata:s:v", argComment, @"-metadata", argTitle, item.pathToFileWithCover];
        
        NSTask* ffmpegExec = [[NSTask alloc] init];
        NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
        [ffmpegExec setLaunchPath:ffmpeg];
        [ffmpegExec setArguments:ffmpegCmd];
        
        NSPipe* errPipe = [NSPipe pipe];
        [ffmpegExec setStandardError:errPipe];
        NSFileHandle* readFileHandleFFMpegErr = [[ffmpegExec standardError] fileHandleForReading];
        
        [readFileHandleFFMpegErr setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
            //TODO: Implement error file handle
        }];
        
        [ffmpegExec launch];
        id delegate = [NSApp delegate];
        id tasks = [delegate tasksExtractions];
        [tasks addObject:ffmpegExec];
        [ffmpegExec waitUntilExit];
        [readFileHandleFFMpegErr setReadabilityHandler:nil];
        
        if (![ffmpegExec isRunning]) {
            if ([ffmpegExec terminationStatus]) {
                NSLog(@"The task of adding ID3 tags ended with error for %@ ", item.title);
                [self notifyAboutSavingAudioForItem:item withSuccess:YES];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDataInDownloadsListForItem:item];
                });
                [self notifyAboutSavingAudioForItem:item withSuccess:YES];
            }
        }
    }
    else {
        [self notifyAboutSavingAudioForItem:item withSuccess:YES];
    }
}

- (void)conversionOfAudioForItem:(DownloadItem*)item {
    if (!item) {
        NSLog(@"Cannot get sound because there is no item for extracting.");
        return;
    }
    
    if (!item.pathToFileDashAudio || item.pathToTheSavedAudio) {
        NSLog(@"Cannot get sound because missing one of required paths.");
        return;
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:item.pathToTheSavedAudio contents:nil attributes:nil]) {
        [self startConversionOfItem:item];
        NSArray* ffmpegCmd = @[@"-i", item.pathToFileDashAudio, @"-acodec", @"libmp3lame", @"-ac", @"2", @"-ab", @"256k", @"-f", @"mp3", @"-"];
        
        NSTask* ffmpegExec = [[NSTask alloc] init];
        NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
        [ffmpegExec setLaunchPath:ffmpeg];
        [ffmpegExec setArguments:ffmpegCmd];
        if ([ffmpegExec isRunning] && item.audioFileWasDeleted) {
            [ffmpegExec terminate];
        }
        
        NSFileHandle* audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:item.pathToTheSavedAudio];
        
        NSPipe* audioPipe = [NSPipe pipe];
        [ffmpegExec setStandardOutput:audioPipe];
        NSFileHandle* readFileHandleFFMpegOut = [[ffmpegExec standardOutput] fileHandleForReading];
        
        [readFileHandleFFMpegOut setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
            NSData* availableData = [handle availableData];
            @try {
                [audioFileHandle seekToEndOfFile];
                [audioFileHandle writeData:availableData];
            }
            @catch(...) {
                
            }
        }];
        
        NSString* stringDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        
        NSMutableString* mdateString = [NSMutableString stringWithString:stringDate];
        [mdateString appendString:@"\r"];
        
        id delegate = [NSApp delegate];
        NSFileHandle* logFileHandle = [NSFileHandle fileHandleForWritingAtPath:[delegate pathToLogFile]];
        if (logFileHandle) {
            [logFileHandle seekToEndOfFile];
            [logFileHandle writeData:[mdateString dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSPipe* errPipe = [NSPipe pipe];
        [ffmpegExec setStandardError:errPipe];
        NSFileHandle* readFileHandleFFMpegErr = [[ffmpegExec standardError] fileHandleForReading];
        
        [readFileHandleFFMpegErr setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
            //TODO: implement error file handle
        }];
        
        [ffmpegExec launch];
        id tasks = [delegate tasksExtractions];
        [tasks addObject:ffmpegExec];
        [ffmpegExec waitUntilExit];
        
        [readFileHandleFFMpegOut setReadabilityHandler:nil];
        [readFileHandleFFMpegErr setReadabilityHandler:nil];
        
        if (![ffmpegExec isRunning]) {
            if ([ffmpegExec terminationStatus]) {
                NSLog(@"The task of sound extraction completed with error for %@", item.title);
                [self notifyAboutSavingAudioForItem:item withSuccess:NO];
            }
            else {
                [item setPercentageConvertion:0.0];
                [item setCurrentState:12];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDataInDownloadsListForItem:item];
                });
                [self addCoverImageOfMp3ForItem:item];
                [self notifyAboutSavingAudioForItem:item withSuccess:YES];
            }
        }
    }
    else {
        NSLog(@"Error with code: %d - %s", 1, "unknown");
    }
}

- (void)convertionWebmToMp4:(DownloadItem*)item {
    NSArray* ffmpegCmd = @[@"-i", item.pathTemporaryFolder, @"-c:v", @"libx264", @"-pix_fmt", @"yuv420p", @"-c:a", @"aac", @"-f", @"-strict", @"-2", item.pathToTheSavedVideo];
    
    NSTask* ffmpegExec = [[NSTask alloc] init];
    NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
    [ffmpegExec setLaunchPath:ffmpeg];
    [ffmpegExec setArguments:ffmpegCmd];
    
    NSString* stringDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
    
    NSMutableString* mdateString = [NSMutableString stringWithString:stringDate];
    [mdateString appendString:@"\r"];
    
    id delegate = [NSApp delegate];
    NSFileHandle* logFileHandle = [NSFileHandle fileHandleForWritingAtPath:[delegate pathToLogFile]];
    if (logFileHandle) {
        [logFileHandle seekToEndOfFile];
        [logFileHandle writeData:[mdateString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSPipe* errPipe = [NSPipe pipe];
    [ffmpegExec setStandardError:errPipe];
    NSFileHandle* readFileHandleFFMpegErr = [[ffmpegExec standardError] fileHandleForReading];
    
    [readFileHandleFFMpegErr setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
        //TODO: implement error file handle
    }];
    
    [ffmpegExec launch];
    id tasks = [delegate tasksExtractions];
    [tasks addObject:ffmpegExec];
    [ffmpegExec waitUntilExit];
    [readFileHandleFFMpegErr setReadabilityHandler:nil];
    
    if (![ffmpegExec isRunning] && [ffmpegExec terminationStatus]) {
        NSLog(@"The task of conversion webm video to mp4 completed with error for %@", item.title);
    }
}

- (void)conversionOfVideoForItem:(DownloadItem*)downloadItem {
    if (downloadItem && downloadItem.wasSavedVideo && downloadItem.wasSavedSound) {
        if (downloadItem.pathToFileDashVideo && downloadItem.pathToFileDashSound && downloadItem.pathToTheSavedVideo) {
            [self performSelectorOnMainThread:@selector(startConversionOfItem:) withObject:downloadItem waitUntilDone:NO];
            NSArray* ffmpegCmd = @[@"-i", downloadItem.pathToFileDashVideo, @"-i", downloadItem.pathToFileDashSound, @"-vcodec", @"copy", @"-acodec", @"copy", downloadItem.pathToTheSavedVideo];
            
            NSTask* ffmpegExec = [[NSTask alloc] init];
            NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
            [ffmpegExec setLaunchPath:ffmpeg];
            [ffmpegExec setArguments:ffmpegCmd];
            if ([ffmpegExec isRunning] && downloadItem.videoFileWasDeleted) {
                [ffmpegExec terminate];
            }
            
            NSDate* date = [NSDate date];
            NSString* dateString =[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
            NSMutableString* mdateString = [NSMutableString stringWithString:dateString];
            [mdateString appendString:@"\r"];
            
            id delegate = [NSApp delegate];
            NSFileHandle* logFileHandle = [NSFileHandle fileHandleForWritingAtPath:[delegate pathToLogFile]];
            if (logFileHandle) {
                [logFileHandle seekToEndOfFile];
                [logFileHandle writeData:[mdateString dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            NSPipe* errPipe = [NSPipe pipe];
            [ffmpegExec setStandardError:errPipe];
            NSFileHandle* readFileHandleFFMpegErr = [[ffmpegExec standardError] fileHandleForReading];
            
            __block double duration = 0.0;
            __block double time = 0.0;
            
            [readFileHandleFFMpegErr setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
                NSData* availableData = [handle availableData];
                NSString* errString = [[NSString alloc] initWithData:availableData encoding:NSUTF8StringEncoding];
                
                double percent = 0.0;
                
                NSRange searchRangeDuration = [errString rangeOfString:@"Duration:"];
                if (duration == 0.0 && searchRangeDuration.location != NSNotFound) {
                    duration = [self getDuration:errString];
                }
                
                NSRange searchRangeTime = [errString rangeOfString:@"time="];
                if (searchRangeDuration.location != NSNotFound) {
                    time = [self getConvertionTime:errString];
                    
                    if (duration > 0.0) {
                        percent = MIN(100.0, time / duration * 100.0);
                        [downloadItem setPercentageConvertion:percent];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self progressInFinderForItem:downloadItem];
                            [self refreshDataInDownloadsListForItem:downloadItem];
                            [self.tableDownloadList reloadData];
                        });
                    }
                }
            }];
            
            [ffmpegExec launch];
            NSMutableArray* tasks = [delegate tasksExtractions];
            [tasks addObject:ffmpegExec];
            [ffmpegExec waitUntilExit];
            
            [readFileHandleFFMpegErr setReadabilityHandler:nil];
            
            if ([ffmpegExec terminationStatus]) {
                NSLog(@"The task of conversion video completed with error for %@", downloadItem.title);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* itemKind = @{@"item":downloadItem, @"kindOfItem":[NSNumber numberWithInt:1]};
                [self multimediaWasSaved:itemKind];
            });
        }
        else {
            NSLog(@"Missing one of required paths.");
        }
    }
}

- (void)concatenateSegmentsOfItem:(DownloadItem*)item isSound:(BOOL)bAudio {
    [self performSelectorOnMainThread:@selector(startConcatenationOfItemSegments:) withObject:item waitUntilDone:NO];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    id contents = [fileManager contentsOfDirectoryAtPath:item.pathToPackageOfDownload error:nil];
    id compared = [contents sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 intValue] - [obj2 intValue];
    }];
    
    NSMutableString* concat = [[NSMutableString alloc] initWithString:@"concat:"];
    
    for (NSString* obj in compared) {
        NSRange searchRange = [obj rangeOfString:@"_seg"];
        if (bAudio) {
            if ([[obj pathExtension] isEqualToString:@"m4a"] && searchRange.location != NSNotFound) {
                NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
                NSString* slashPath = [NSString stringWithFormat:@"%@|", fullPath];
                [concat appendString:slashPath];
                continue;
            }
        }
        
        if ([[obj pathExtension] isEqualToString:@"m4v"] && searchRange.location != NSNotFound) {
            NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
            NSString* slashPath = [NSString stringWithFormat:@"%@|", fullPath];
            [concat appendString:slashPath];
        }
    }
    
    // remove the last |
    [concat deleteCharactersInRange:NSMakeRange(concat.length - 1, 1)];
    NSString* mediaFile = nil;
    NSArray* ffmpegCmd = nil;
    if (bAudio) {
        mediaFile = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"sound.m4a"];
        ffmpegCmd = @[@"-i", concat, @"-c:a", @"copy", mediaFile];
    }
    else {
        mediaFile = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"video.m4v"];
        ffmpegCmd = @[@"-i", concat, @"-c:v", @"libx264", @"-preset:v", @"superfast", @"-threads", @"1", mediaFile];
    }
    __block double duration = 0.0;
    __block double time = 0.0;
    
    NSTask* ffmpegExec = [[NSTask alloc] init];
    NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
    [ffmpegExec setLaunchPath:ffmpeg];
    [ffmpegExec setArguments:ffmpegCmd];
    NSPipe* pipe = [NSPipe pipe];
    [ffmpegExec setStandardError:pipe];
    NSFileHandle* errorReadHandle = [ffmpegExec.standardError fileHandleForReading];
    [errorReadHandle setReadabilityHandler:^(NSFileHandle * _Nonnull handle) {
        ;
    }];
    
    [ffmpegExec launch];
    id delegate = [NSApp delegate];
    NSMutableArray* tasks = [delegate tasksExtractions];
    [tasks addObject:ffmpegExec];
    
    [ffmpegExec waitUntilExit];
    [errorReadHandle setReadabilityHandler:nil];
    
    if (![ffmpegExec terminationStatus]) {
        [item setNumOfSegment:0];
        
        if (bAudio) {
            for (NSString* obj in contents) {
                NSRange searchRange = [obj rangeOfString:@"_seg"];
                NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
                if ([[obj pathExtension] isEqualToString:@"m4a"] && searchRange.location != NSNotFound) {
                    [fileManager removeItemAtPath:fullPath error:nil];
                }
            }
            NSString* sound = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"sound.m4a"];
            [item setPathToFileDashAudio:sound];
            [self conversionOfAudioForItem:item];
        }
        else {
            for (NSString* obj in contents) {
                NSRange searchRange = [obj rangeOfString:@"_seg"];
                NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
                if ([[obj pathExtension] isEqualToString:@"m4a"] && searchRange.location != NSNotFound) {
                    [fileManager removeItemAtPath:fullPath error:nil];
                }
            }
            
            [item setWasSavedVideo:YES];
            if ([item wasSavedVideo] && [item wasSavedSound]) {
                NSString* video = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"video.m4v"];
                NSString* sound = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"sound.m4a"];
                [item setPathToFileDashVideo:video];
                [item setPathToFileDashSound:sound];
                [self conversionOfVideoForItem:item];
            }
        }
    }
}

- (void)concatenateSoundSegmentsOfItem:(DownloadItem*)item {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    id contents = [fileManager contentsOfDirectoryAtPath:item.pathToPackageOfDownload error:nil];
    id compared = [contents sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 intValue] - [obj2 intValue];
    }];
    
    NSMutableString* concat = [[NSMutableString alloc] initWithString:@"concat:"];
    
    for (NSString* obj in compared) {
        NSRange searchRange = [obj rangeOfString:@"_seg"];
        if ([[obj pathExtension] isEqualToString:@"m4a"] && searchRange.location != NSNotFound) {
            NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
            NSString* slashPath = [NSString stringWithFormat:@"%@|", fullPath];
            [concat appendString:slashPath];
        }
    }
    
    // remove the last |
    [concat deleteCharactersInRange:NSMakeRange(concat.length - 1, 1)];
    NSString* soundFile = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"sound.m4a"];
    
    NSArray* ffmpegCmd = @[@"-i", concat, @"-c:a", @"copy", soundFile];
    
    NSTask* ffmpegExec = [[NSTask alloc] init];
    NSString* ffmpeg = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
    [ffmpegExec setLaunchPath:ffmpeg];
    [ffmpegExec setArguments:ffmpegCmd];
    [ffmpegExec launch];
    
    id delegate = [NSApp delegate];
    NSMutableArray* tasks = [delegate tasksExtractions];
    [tasks addObject:ffmpegExec];
    
    [ffmpegExec waitUntilExit];
    
    if ([ffmpegExec terminationStatus]) {
        NSLog(@"The task of concatenation of sound segments for item %@ complete with an error", item.title);
        return;
    }
    else {
        [item setNumOfSoundSegment:0];
        for (NSString* obj in contents) {
            NSRange searchRange = [obj rangeOfString:@"_seg"];
            NSString* fullPath = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, obj];
            if ([[obj pathExtension] isEqualToString:@"m4a"] && searchRange.location != NSNotFound) {
                [fileManager removeItemAtPath:fullPath error:nil];
            }
        }
        
        [item setWasSavedSound:YES];
        if ([item wasSavedSound]) {
            if ([item wasSavedVideo]) {
                NSString* video = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"video.m4v"];
                NSString* sound = [NSString stringWithFormat:@"%@/%@", item.pathToPackageOfDownload, @"sound.m4a"];
                [item setPathToFileDashVideo:video];
                [item setPathToFileDashSound:sound];
                [self conversionOfVideoForItem:item];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@ (code = %ld)", error.localizedDescription, error.code);
    id delegate = [NSApp delegate];
    int nType = 0;
    DownloadItem* item = [delegate getItemByConnection:connection typeOfItem:&nType];
    if (!item) {
        NSDictionary* errorInfo = @{@"error": error};
        [delegate saveInLogFile:errorInfo];
        return;
    }
    
    NSDictionary* errorInfo = @{@"error": error, @"item": item};
    [delegate saveInLogFile:errorInfo];
    NSLog(@"%@: %@(error code: %ld)", item.title, error.localizedDescription, error.code);
    
    if (error.code == NSURLErrorNotConnectedToInternet) {
        if ([self alertconnectionOffline]) {
            return;
        }
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleWarning];
        
        [self setAlertconnectionOffline:anAlert];
        
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
        
        anAlert.messageText = error.localizedDescription;
        anAlert.informativeText = NSLocalizedString(@"alertInfoFailConnection", nil);
        
        NSModalResponse action = [anAlert runModal];
        if (action == NSAlertFirstButtonReturn) {
            [self setAlertconnectionOffline:nil];
        }
        [delegate blockLoadingLinks];
        [self updateLabelCountDownloads];
    }
    
    if (error.code == NSURLErrorNetworkConnectionLost) {
        if (![self alertConnectionLost]) {
            NSAlert* anAlert = [[NSAlert alloc] init];
            [anAlert setAlertStyle:NSAlertStyleWarning];
            
            [self setAlertConnectionLost:anAlert];
            
            [anAlert addButtonWithTitle:NSLocalizedString(@"button_yes", nil)];
            [anAlert addButtonWithTitle:NSLocalizedString(@"button_no", nil)];
            
            anAlert.messageText = error.localizedDescription;
            anAlert.informativeText = NSLocalizedString(@"alertInfoFailConnection", nil);
            
            NSModalResponse action = [anAlert runModal];
            if (action == NSAlertFirstButtonReturn) {
                id downloads = [delegate downloadsList];
                for (id download in downloads) {
                    if ([download currentState] == 1) {
                        [self resume:download];
                    }
                }
            }
            else {
                [delegate blockLoadingLinks];
                [self setAlertconnectionOffline:nil];
            }
            [self updateLabelCountDownloads];
        }
    }
    
    if (error.code == NSURLErrorTimedOut) {
        if (![YDUserDefaults optionDontShowAgainWhenFailedConnection]) {
            NSAlert* anAlert = [[NSAlert alloc] init];
            [anAlert setAlertStyle:NSAlertStyleWarning];
            
            [self setAlertconnectionOffline:anAlert];
            
            [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
            [anAlert setShowsSuppressionButton:YES];
            [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_show", nil)];
            
            anAlert.messageText = error.localizedDescription;
            anAlert.informativeText = NSLocalizedString(@"alertInfoFailConnection", nil);
            
            NSModalResponse action = [anAlert runModal];
            if (action == NSAlertFirstButtonReturn) {
                [YDUserDefaults setOptionDontShowAgainWhenFailedConnection:(anAlert.suppressionButton.state == NSControlStateValueOn ? YES : NO)];
            }
            [self suspendDownloadForItem:item];
            [self updateLabelCountDownloads];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id delegate = [NSApp delegate];
    int nType = 0;
    DownloadItem* item = [delegate getItemByConnection:connection typeOfItem:&nType];
    if (item) {
        if (item.connectGetInfoSubTrack == connection) {
            NSMutableArray* subtitleTracks = [[NSMutableArray alloc] init];
            [item setSubtitleTracks:subtitleTracks];
            NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:item.dataSubTrack];
            [item setXmlParser:xmlParser];
            [item.xmlParser setDelegate:self];
            [item.xmlParser parse];
            [item setConnectGetInfoSubTrack:nil];
        }
        
        switch (nType) {
            case 1:
            case 4:
            {
                if (item.savedUpVideoData.length) {
                    [item setReceivedBytes:(item.savedUpVideoData.length + item.receivedBytes)];
                    OperationOfSavingVideoData* opSavingVideoData = [[OperationOfSavingVideoData alloc] initWithData:item.savedUpVideoData forItem:item andController:self];
                    [opSavingVideoData setIsLastOperation:YES];
                    
                    [item.queueOfSavingVideo addOperation:opSavingVideoData];
                    [item setSavedUpVideoData:nil];
                }
            }
                break;
                
            case 2:
            {
                if (item.savedUpSoundData.length) {
                    [item setReceivedBytesSound:(item.savedUpSoundData.length + item.receivedBytesSound)];
                    OperationOfSavingSoundData* opSavingSoundData = [[OperationOfSavingSoundData alloc] initWithData:item.savedUpSoundData forItem:item andController:self];
                    [opSavingSoundData setIsLastOperation:YES];
                    
                    [item.queueOfSavingSound addOperation:opSavingSoundData];
                    [item setSavedUpSoundData:nil];
                }
            }
                break;
                
            case 3:
            {
                if (item.savedUpMp3Data.length) {
                    [item setReceivedBytes:(item.savedUpMp3Data.length + item.receivedBytes)];
                    OperationOfSavingAudioData* opSavingAudioData = [[OperationOfSavingAudioData alloc] initWithData:item.savedUpMp3Data forItem:item andController:self];
                    [opSavingAudioData setIsLastOperation:YES];
                    
                    [item.queueOfSavingMp3 addOperation:opSavingAudioData];
                    [item setSavedUpMp3Data:nil];
                }
            }
                
            default:
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    id delegate = [NSApp delegate];
    int nType = 0;
    DownloadItem* item = [delegate getItemByConnection:connection typeOfItem:&nType];
    if (item) {
        if (item.connectForDownloadVideo == connection) {
            if ([item needAllocMemForSavedUpVideoData]) {
                NSMutableData* mData = [NSMutableData alloc];
                [item setSavedUpVideoData:mData];
                [item setNeedAllocMemForSavedUpVideoData:NO];
            }
            [item.savedUpVideoData appendData:data];
            if (item.savedUpVideoData.length > item.multiplier * 1048576.0) {
                [item setReceivedBytes:(item.savedUpVideoData.length + item.receivedBytes)];
                OperationOfSavingVideoData* opSavingVideoData = [[OperationOfSavingVideoData alloc] initWithData:item.savedUpVideoData forItem:item andController:self];
                if (item.receivedBytes + item.totalReceivedBytes == item.totalExpectedBytes) {
                    [opSavingVideoData setIsLastOperation:YES];
                }
                [item.queueOfSavingVideo addOperation:opSavingVideoData];
                [item setNeedAllocMemForSavedUpVideoData:YES];
                [item setSavedUpVideoData:nil];
            }
        }
        
        if (item.connectForDownloadSound == connection) {
            if (item.needAllocMemForSavedUpSoundData) {
                [item setSavedUpSoundData:nil];
                NSMutableData* mData = [NSMutableData alloc];
                [item setSavedUpSoundData:mData];
                [item setNeedAllocMemForSavedUpSoundData:NO];
            }
            [item.savedUpSoundData appendData:data];
            if (item.savedUpSoundData.length > item.multiplier * 1048576.0) {
                [item setReceivedBytesSound:(item.savedUpSoundData.length + item.receivedBytesSound)];
                OperationOfSavingSoundData* opSavingSoundData = [[OperationOfSavingSoundData alloc] initWithData:item.savedUpSoundData forItem:item andController:self];
                if (item.receivedBytesSound + item.totalReceivedBytesSound == item.totalExpectedBytesOfSound) {
                    [opSavingSoundData setIsLastOperation:YES];
                }
                [item.queueOfSavingSound addOperation:opSavingSoundData];
                [item setNeedAllocMemForSavedUpSoundData:YES];
                [item setSavedUpSoundData:nil];
            }
        }
        
        if (item.connectForDownloadMP3 != connection) {
            if (item.connectForDownloadSegment == connection) {
                OperationSavingOfDataSegments* opSavingDataSegment = [[OperationSavingOfDataSegments alloc] initWithData:data forItem:item type:nType andController:self];
                if (nType == 7) {
                    [item.queueOfSavingAudioSegments addOperation:opSavingDataSegment];
                }
                else {
                    [item.queueOfSavingVideoSegments addOperation:opSavingDataSegment];
                }
            }
            else if (item.connectForDownloadSoundSegment == connection) {
                OperationSavingOfDataSegments* opSavingDataSegment = [[OperationSavingOfDataSegments alloc] initWithData:data forItem:item type:nType andController:self];
                [item.queueOfSavingSoundSegments addOperation:opSavingDataSegment];
            }
        }
        
        if (item.connectForDownloadMP3 == connection) {
            if (item.needAllocMemForSavedUpMp3Data) {
                [item setSavedUpMp3Data:nil];
                NSMutableData* mData = [NSMutableData alloc];
                [item setSavedUpMp3Data:mData];
                [item setNeedAllocMemForSavedUpMp3Data:NO];
            }
            [item.savedUpMp3Data appendData:data];
            if (item.savedUpMp3Data.length > item.multiplier * 1048576.0) {
                [item setReceivedBytes:(item.savedUpMp3Data.length + item.receivedBytes)];
                OperationOfSavingAudioData* opSavingAudioData = [[OperationOfSavingAudioData alloc] initWithData:item.savedUpMp3Data forItem:item andController:self];
                if (item.receivedBytes + item.totalReceivedBytes == item.totalExpectedBytes) {
                    [opSavingAudioData setIsLastOperation:YES];
                }
                [item.queueOfSavingMp3 addOperation:opSavingAudioData];
                [item setNeedAllocMemForSavedUpMp3Data:YES];
                [item setSavedUpMp3Data:nil];
            }
        }
        
        if (item.connectGetInfoSubTrack == connection) {
            [item.dataSubTrack appendData:data];
        }
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }
    
    self->httpStatusCode = response.statusCode;
    
    int nType = 0;
    id delegate = [NSApp delegate];
    DownloadItem* item = [delegate getItemByConnection:connection typeOfItem:&nType];
    if (!item) {
        return;
    }
    
    if (self->httpStatusCode != 206) {
        if (self->httpStatusCode == 200) {
            switch (nType) {
                case 1:
                case 3:
                case 4:
                {
                    if (!item.totalExpectedBytes) {
                        [item setTotalExpectedBytes:response.expectedContentLength];
                    }
                    [item setExpectedBytes:response.expectedContentLength];
                    [item setReceivedBytes:0];
                }
                    break;
                case 2:
                {
                    if (![item.getSoundItem totalExpectedBytes]) {
                        [item.getSoundItem setTotalExpectedBytes:response.expectedContentLength];
                    }
                    [item setTotalExpectedBytesOfSound:response.expectedContentLength];
                    [item setExpectedBytesSound:response.expectedContentLength];
                }
                    break;
                case 5:
                case 7:
                {
                    [item setExpectedBytes:response.expectedContentLength];
                }
                    break;
                case 6:
                {
                    if (item.getSoundItem) {
                        [item setTotalExpectedBytesOfSound:[item.getSoundItem totalExpectedBytes]];
                    }
                    [item setExpectedBytesSound:response.expectedContentLength];
                }
                    break;
                default:
                    break;
            }
            [self updateOfDownloadItem:item kindOf:nType];
        }
        else {
            NSString* statusString = [NSHTTPURLResponse localizedStringForStatusCode:self->httpStatusCode];
            NSString* statusFormat = [NSString stringWithFormat:@"HTTP status code %llu: %@", self->httpStatusCode, statusString];
            NSLog(@"%@ (%@): %@", statusFormat, item.title, item.parent.pageUrl);
            if (self->httpStatusCode >= 300) {
                NSDictionary* httpDict = @{NSLocalizedDescriptionKey: statusFormat};
                NSError* httpErr = [NSError errorWithDomain:@"HTTP status" code:self->httpStatusCode userInfo:httpDict];
                NSDictionary* errorInfo = @{@"error": httpErr, @"item": item};
                [delegate saveInLogFile:errorInfo];
                
                NSAlert* anAlert = [[NSAlert alloc] init];
                [anAlert setAlertStyle:NSAlertStyleWarning];
                
                [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
                
                anAlert.messageText = NSLocalizedString(@"alertError404Message", nil);
                anAlert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"alertError404Info", nil), item.title];
                
                [anAlert runModal];
                [self removeItemFromListOfDownloads:item];
            }
        }
        return;
    }
    
    if (nType != 2 && nType != 1) {
        return;
    }
    
    if (nType - 3 < 2) {
        if (!item.totalExpectedBytes) {
            [item setTotalExpectedBytes:response.expectedContentLength];
        }
        [item setExpectedBytes:response.expectedContentLength];
        [item setReceivedBytes:0];
        [item setStartDownload:[NSDate date]];
        return ;
    }
    
    if (!item.totalExpectedBytesOfSound) {
        [item setTotalExpectedBytesOfSound:response.expectedContentLength];
    }
    [item setExpectedBytesSound:response.expectedContentLength];
    [item setReceivedBytesSound:0];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    return request;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    ;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (BOOL)downloadsFolderIsAvailableByPath:(NSString*)downloadFolder {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL bExists = [fileManager fileExistsAtPath:downloadFolder];
    if (!bExists) {
        NSLog(@"Make sure that the indicated path exists.");
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleWarning];
        
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
        
        anAlert.messageText = NSLocalizedString(@"alertPathNotExistsMessage", nil);
        anAlert.informativeText = NSLocalizedString(@"alertPathNotExistsInfo", nil);
        
        [anAlert runModal];
    }
    
    return bExists;
}

- (BOOL)haveFreeSpaceForItems:(NSArray*)array onDevice:(NSString*)dir {
    BOOL bRet = YES;
    
    long long freeSpace = [self determineFreeSpaceOnDevice:dir withError:nil];
    
    if (freeSpace < [self spaceRequiredForAllDownloadsIncludingItems:array]) {
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleWarning];
        
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
        
        anAlert.messageText = NSLocalizedString(@"alertFreeSpaceMessage", nil);
        anAlert.informativeText = NSLocalizedString(@"alertFreeSpaceInfo", nil);
        
        [anAlert runModal];
        bRet = NO;
    }
    
    return bRet;
}

- (long long)spaceRequiredForAllDownloadsIncludingItems:(NSArray*)array {
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];

    long long spaceRequire = 0;
    
    for (DownloadItem* item in downloads) {
        if (item.currentState == 1) {
            spaceRequire += [self spaceRequiredForItem:item];
        }
    }
    
    for (id each in array) {
        spaceRequire += [self spaceRequiredForItem:each];
    }
    
    return spaceRequire;
}

- (long long)spaceRequiredForItem:(DownloadItem*)item {
    if ([item.mimeType hasPrefix:@"audio"]) {
        return 2 * item.totalExpectedBytes;
    }
    
    if (![item.mimeType hasPrefix:@"video"]) {
        return 0;
    }
    
    long long totalExpectedBytes = item.totalExpectedBytes;
    
    if (item.isVideoDASH) {
        totalExpectedBytes += [item.getSoundItem totalExpectedBytes];
    }
    
    return totalExpectedBytes;
}

- (long long)determineFreeSpaceOnDevice:(id)dir withError:(id)err {
    long long freesize = 0;
    NSString* downloadFolder = dir;
    if (!dir) {
        downloadFolder = [[YDUserDefaults currentUserPreferences] objectForKey:@"PathToDownloadsFolder"];
    }
    NSError* error = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDictionary* fileDict = [fileManager attributesOfFileSystemForPath:downloadFolder error:&error];
    if (error) {
        NSLog(@"Can't determine free space: %@ (error code: %ld)", error.localizedDescription, error.code);
    }
    else {
        NSString* fileSize = [fileDict valueForKey:NSFileSystemFreeSize];
        freesize = [fileSize longLongValue];
    }
    
    return freesize;
}

- (BOOL)updateErrorForItem:(DownloadItem*)item {
    if (!item || !item.updateError) {
        return NO;
    }
    
    if (![YDUserDefaults optionDontShowAgainWhenUpdateError]) {
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleWarning];
        
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
        [anAlert setShowsSuppressionButton:YES];
        [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_show", nil)];
        
        
        anAlert.messageText = NSLocalizedString(@"alertError404Message", nil);
        anAlert.informativeText = NSLocalizedString(@"alertError404Info", nil);
        
        NSModalResponse action = [anAlert runModal];
        if (action == NSAlertFirstButtonReturn) {
            [YDUserDefaults setOptionDontShowAgainWhenFailedConnection:(anAlert.suppressionButton.state == NSControlStateValueOn ? YES : NO)];
        }
    }
    
    if (item.queueOfSavingVideo) {
        [item.queueOfSavingVideo setSuspended:YES];
    }
    [item setCurrentState:5];
    [item setUpdateError:NO];
    [self refreshDataInDownloadsListForItem:item];
    
    return YES;
}

- (void)noSpaceLeftOnDevice:(NSError*)error {
    id userInfo = error.userInfo;
    DownloadItem* item = [userInfo objectForKey:@"item"];
    id delegate = [NSApp delegate];
    
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleWarning];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnClearQueuedTitle", nil)];
    
    anAlert.messageText = NSLocalizedString(@"alertFreeSpaceMessage", nil);
    anAlert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"alertFreeSpaceInfo", nil), item.title];
    
    id buttons = anAlert.buttons;
    id btn = buttons[1];
    
    [btn setEnabled:[delegate haveItemsQueuedOrSuspended]];
    
    NSModalResponse action = [anAlert runModal];
    if (action == NSAlertSecondButtonReturn) {
        [delegate removeAllQueuedDownloads];
    }
    else if (action == NSAlertFirstButtonReturn) {
        [self removeItemFromListOfDownloads:item];
    }
    
    [self updateLabelCountDownloads];
}

- (void)deviceNotConfiguredWhenLoading { 
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleWarning];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
    
    
    anAlert.messageText = NSLocalizedString(@"alertNoDeviceMessage", nil);
    anAlert.informativeText = NSLocalizedString(@"alertNoDeviceInfo", nil);
    
    [anAlert runModal];
    
    id delegate = [NSApp delegate];
    [delegate removeAllQueuedDownloads];
    [delegate removeAllActiveDownloadsAndReduceWindowSize:YES];
    [self updateLabelCountDownloads];
}

- (void)fileProbablyWasDeleted:(NSDictionary*)itemInfo {
    NSDictionary* currentUserPreference = [YDUserDefaults currentUserPreferences];
    NSString* downloadFolder = [currentUserPreference objectForKey:@"PathToDownloadsFolder"];
    if ([self downloadsFolderIsAvailableByPath:downloadFolder]) {
        if (!self->alertFileWasDeletedAlreadyShown) {
            self->alertFileWasDeletedAlreadyShown = YES;
            
            NSAlert* anAlert = [[NSAlert alloc] init];
            [anAlert setAlertStyle:NSAlertStyleWarning];
            
            [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
            
            anAlert.messageText = NSLocalizedString(@"alertNotExistMessage", nil);
            anAlert.informativeText = NSLocalizedString(@"alertNotExistInfo", nil);
            
            if ([anAlert runModal] == NSAlertFirstButtonReturn) {
                // TODO: finish the action
            }
            
            DownloadItem* downloadItem = [itemInfo objectForKey:@"item"];
            [self removeItemFromListOfDownloads:downloadItem];
        }
    }
    else {
        id delegate = [NSApp delegate];
        [delegate removeAllUnsavedDownloads];
    }
    [self updateLabelCountDownloads];
}

- (NSString*)convertLinkToStandardView:(NSString*)url {
    if (!url) {
        return nil;
    }
    
    NSURL* videoUrl = [NSURL URLWithString:url];
    NSString* schemeTmp = nil;
    NSString* scheme = nil;
    
    if (!videoUrl) {
        schemeTmp = @"http";
    }
    else {
        schemeTmp = videoUrl.scheme;
    }
    
    if (![schemeTmp isEqualToString:@""]) {
        scheme = [videoUrl scheme];
    }
    else {
        scheme = @"https";
    }
    
    NSString* youtubeUrl = nil;
    NSString* videoID = [self getVideoId:url];
    if (videoID != nil) {
        youtubeUrl = [NSString stringWithFormat:@"%@://www.youtube.com/watch?v=%@", scheme, videoID];
    }
    else {
        youtubeUrl = nil;
    }
    
    return youtubeUrl;
}

- (BOOL)isPlaylistOrChannel:(NSString*)url {
    BOOL bRet = NO;
    if (!url) {
        return bRet;
    }
    
    NSURL* queryUrl = [NSURL URLWithString:url];
    NSString* urlPath = [queryUrl path];
    NSString* lastPath = [urlPath lastPathComponent];
    id pathItems = [urlPath componentsSeparatedByString:@"/"];
    
    BOOL bIS = [pathItems count] >= 4 && ![lastPath isEqualToString:@"featured"];
    
    if ((![lastPath isEqualToString:@"playlist"] && ![urlPath hasPrefix:@"/channel"] && ![urlPath hasPrefix:@"/user"] && ![urlPath hasPrefix:@"/c/"]) || ([pathItems count] >= 4 && ![lastPath isEqualToString:@"featured"])) {
        bRet = NO;
    }
    else {
        bRet = YES;
    }
    
    return bRet;
}

- (id)getPlaylistId:(NSString*)url {
    if (!url) {
        return nil;
    }
    
    NSURL* queryUrl = [NSURL URLWithString:url];
    NSString* query = [queryUrl query];
    id queryItems = [query componentsSeparatedByString:@"&"];
    
    NSString* playlist = nil;
    
    for (id queryItem in queryItems) {
        if ([queryItem hasPrefix:@"list="]) {
            playlist = queryItem;
            break;
        }
    }
    
    return playlist;
}

- (id)getVideoId:(NSString*)videoLink {
    NSURL* videoUrl = [NSURL URLWithString:videoLink];
    NSRange youtubeRange = [videoUrl.host rangeOfString:@"youtu.be" options:NSCaseInsensitiveSearch];
    NSRange youtubeDotComRange = [videoUrl.host rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch];
    NSRange embedRange = [videoUrl.path rangeOfString:@"embed" options:NSCaseInsensitiveSearch];
    
    NSString* videoId = nil;
    
    if (youtubeRange.location != NSNotFound || youtubeDotComRange.location != NSNotFound && embedRange.location != NSNotFound) {
        videoId = [videoUrl lastPathComponent];
    }
    else {
        NSString* query = [videoUrl query];
        id queryItems = [query componentsSeparatedByString:@"&"];
        for (id queryItem in queryItems) {
            id subItems = [queryItem componentsSeparatedByString:@"="];
            if ([subItems count] == 2) {
                id item = subItems[0];
                if ([item isEqualToString:@"v"]) {
                    videoId = subItems[1];
                    break;
                }
            }
        }
    }
    
    return videoId;
}

- (BOOL)isValidLink:(NSString*)linkStr {
    if (![linkStr length]) {
        return NO;
    }
    
    NSURL* linkUrl = [NSURL URLWithString:linkStr];
    if (!linkStr) {
        return NO;
    }
    
    NSString* videoLink = nil;
    if ([linkUrl scheme]) {
        if (![linkUrl.scheme isEqualToString:@"http"] && ![linkUrl.scheme isEqualToString:@"https"]) {
            return NO;
        }
        videoLink = linkStr;
    }
    else {
        videoLink = [NSString stringWithFormat:@"https://%@", linkStr];
    }
    
    id videoId = [self getVideoId:videoLink];
    
    if (!videoId) {
        NSRange searchRange = [linkUrl.host rangeOfString:@"youtube.com" options:NSCaseInsensitiveSearch];
        if (searchRange.location == NSNotFound) {
            return NO;
        }
        
        if (![[linkUrl.path lastPathComponent] isEqualToString:@"playlist"]) {
            if (![linkUrl.path hasPrefix:@"/channel"]) {
                if (![linkUrl.path hasPrefix:@"/user"]) {
                    if (![linkUrl.path hasPrefix:@"/c/"]) {
                        return NO;
                    }
                }
            }
        }
    }
    
    return YES;
}

- (id)separationOfLinksByArray:(NSString*)videoUrl {
    NSMutableArray* mArrUrl = [[NSMutableArray alloc] init];
    NSCharacterSet* charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    id urls = [videoUrl componentsSeparatedByCharactersInSet:charSet];
    for (NSString* url in urls) {
        if (url.length && ![url isEqualToString:@""]) {
            [mArrUrl addObject:url];
        }
    }
    
    return mArrUrl;
}

- (NSString*)timeLeftToLoadItem:(DownloadItem*)item {
    NSDate* someDate = [NSDate date];
    NSTimeInterval startInterval = [someDate timeIntervalSinceDate:item.startDownload];
    
    double recvRate = 0.0;
    long long totalExpectedBytes = item.totalExpectedBytes;
    long long totalReceivedBytes = item.totalExpectedBytes + item.receivedBytes;
    if (item.isVideoDASH || item.isVideoDashMpd) {
        totalExpectedBytes += item.totalExpectedBytesOfSound;
        totalReceivedBytes += item.totalReceivedBytesSound + item.receivedBytesSound;
    }
    
    if (totalReceivedBytes > 0) {
        recvRate = startInterval * totalExpectedBytes / totalReceivedBytes;
    }
    
    long roundRecvRate = lround(recvRate);
    long finalRate = roundRecvRate - lround(startInterval);
    long absoluteRate = (-finalRate < 1) ? finalRate : -finalRate;
    
    long nValue = absoluteRate;
    long p1 = ((1250999897 * nValue) >> 63) + (((1250999897 * nValue) >> 32) >> 20);
    long p2 = (((274877907 * nValue) >> 63) + (((274877907 * nValue) >> 32) >> 6) - 3600 * p1);
    long p3 = ((p2 + ((-2004318071 * p2) >> 32)) >>31) + ((p2 + ((-2004318071 * p2) >> 32)) >> 5);
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", p1,p3,(p2 - 60 * p3)];
}

- (double)changeProgress:(DownloadItem*)item {
    double totalReceivedBytesSound = 0;
    double totalExpectedBytes = item.totalExpectedBytes;
    double totalReceivedBytes = item.totalReceivedBytes + item.receivedBytes;
    
    if (totalExpectedBytes == 0) {
        return 0.0;
    }
    
    if (item.urlOfSegments || !item.isVideoDASH) {
        if (!item.urlOfSegments) {
            double progress = totalReceivedBytes / totalExpectedBytes * 100.0;
            progress *= 422.0;  // the window width
            progress /= 100;
            return progress;
        }
        totalExpectedBytes += item.totalExpectedBytesOfSound;
        totalReceivedBytesSound = item.receivedBytesSound;
    }
    else {
        totalExpectedBytes += item.totalExpectedBytesOfSound;
        totalReceivedBytesSound += item.receivedBytesSound;
    }
    
    totalReceivedBytes += totalReceivedBytesSound;
    
    double progress = totalReceivedBytes / totalExpectedBytes * 100.0;
    progress *= 422.0;  // the window width
    progress /= 100;
    return progress;
}

- (void)removeProgressInFinderForItem:(DownloadItem*)item kindOfItem:(int)type {
    NSString* filePath = nil;
    
    switch (type) {
        case 1:
        case 5:
            filePath = [item pathToFileDashVideo];
            break;
            
        case 2:
            filePath = [item pathToFileDashSound];
            break;
            
        case 3:
            filePath = [item pathToFileDashAudio];
            break;
            
        case 4:
            filePath = [item pathToTheSavedVideo];
            break;
            
        default:
            break;
    }
    
    if (filePath) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSDictionary* fileDict = [fileManager attributesOfItemAtPath:filePath error:nil];
        if (fileDict) {
            NSMutableDictionary* mfileAttr = [NSMutableDictionary dictionaryWithDictionary:fileDict];
            [mfileAttr removeObjectForKey:@"NSFileExtendedAttributes"];
            NSDate* modifyDate = [fileDict objectForKey:NSFileModificationDate];
            [mfileAttr setObject:modifyDate forKey:NSFileCreationDate];
            
            NSError* error = nil;
            [fileManager setAttributes:mfileAttr ofItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"%@", error.description);
            }
        }
    }
}

- (void)removeProgressInFinderForItem:(id)itemKind {
    DownloadItem* item = [itemKind objectForKey:@"item"];
    int nType = [[itemKind objectForKey:@"kindOfItem"] intValue];
    [self removeProgressInFinderForItem:item kindOfItem:nType];
}

- (void)progressInFinderForItem:(DownloadItem*)item kindOfItem:(int)nType {
    NSString* pathToFile = nil;
    long long totalReceivedBytesSound = 0;
    long long totalReceivedBytes = 0;
    long long totalExpectedBytes = 0;
    switch (nType) {
        case 1:
        {
            pathToFile = item.pathToFileDashVideo;
        }
            break;
            
        case 2:
        {
            pathToFile = item.pathToFileDashSound;
            totalReceivedBytesSound = item.totalReceivedBytesSound + item.receivedBytesSound;
            totalExpectedBytes = [[item getSoundItem] totalExpectedBytes];
        }
            break;
            
        case 3:
        {
            pathToFile = item.pathToFileDashAudio;
        }
            break;
            
        case 4:
        {
            pathToFile = item.pathToTheSavedVideo;
        }
            break;
            
        default:
        {
            pathToFile = @"";
        }
            break;
    }
    
    totalReceivedBytes = item.receivedBytes + item.totalReceivedBytes;
    if (totalExpectedBytes == 0 && nType != 2) {
        totalExpectedBytes = item.totalExpectedBytes;
    }
    
    NSString* percentage = [NSString stringWithFormat:@"%lld", totalReceivedBytes / totalExpectedBytes];
    
    NSMutableDictionary* mDict = [NSMutableDictionary dictionary];
    [mDict setObject:[percentage dataUsingEncoding:NSASCIIStringEncoding] forKey:@"com.apple.progress.fractionCompleted"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDictionary* fileDict = [fileManager attributesOfItemAtPath:pathToFile error:nil];
    NSMutableDictionary* mFileDict = [NSMutableDictionary dictionaryWithDictionary:fileDict];
    NSDate* specialDate = [NSDate dateWithString:@"1984-01-24 08:00:00 +0000"];
    [mFileDict setObject:specialDate forKey:NSFileCreationDate];
    
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:mDict];
    [mFileDict setObject:dict forKey:@"NSFileExtendedAttributes"];
    
    [fileManager setAttributes:mFileDict ofItemAtPath:pathToFile error:nil];
}

- (void)progressInFinderForItem:(DownloadItem*)downloadItem {
    double percent = 0.0;
    
    if (downloadItem.currentState != 3 && downloadItem.currentState != 4) {
        unsigned long long totalExptBytes = downloadItem.totalExpectedBytes;
        unsigned long long totalRecvBytes = downloadItem.totalReceivedBytes;
        unsigned long long recvBytes = totalRecvBytes + downloadItem.receivedBytes;
        
        double totalRecv = 0.0;
        double totalBytes = 0.0;
        
        totalBytes = (double)totalExptBytes;
        
        if (downloadItem.isVideoDASH) {
            unsigned long long totalExptBytesSound = downloadItem.totalExpectedBytesOfSound;
            unsigned long long totalRecvBytesSound = downloadItem.totalReceivedBytesSound;
            unsigned long long recvBytesSound = totalRecvBytesSound + downloadItem.receivedBytesSound;
            
            totalRecv = recvBytes + recvBytesSound;
            totalBytes += (double)totalExptBytesSound;
        }
        else {
            totalRecv = recvBytes;
        }
        percent = totalRecv / totalBytes;
    }
    else {
        percent = downloadItem.percentageConvertion / 100.0;
    }
    
    NSString* percentString = [NSString stringWithFormat:@"%f", percent];
    NSData* percentData = [percentString dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableDictionary* mPercentDict = [NSMutableDictionary dictionary];
    [mPercentDict setObject:percentData forKey:@"com.apple.progress.fractionCompleted"];
    
    NSDictionary* fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:downloadItem.pathToPackageOfDownload error:nil];
    
    NSMutableDictionary* mfileDict = [NSMutableDictionary dictionaryWithDictionary:fileDict];
    NSDate* date = [NSDate dateWithString:@"1984-01-24 08:00:00 +0000"];
    [mfileDict setObject:date forKey:NSFileCreationDate];
    
    NSDictionary* percentDict = [NSDictionary dictionaryWithDictionary:mPercentDict];
    [mfileDict setObject:percentDict forKey:@"NSFileExtendedAttributes"];
    [[NSFileManager defaultManager] setAttributes:mfileDict ofItemAtPath:downloadItem.pathToPackageOfDownload error:nil];
}

- (void)refreshDataInRowView:(DownloadsTableCellView*)rowView forItem:(DownloadItem*)item {
    NSInteger state = item.currentState;

    switch (state) {
        case 0:
        {
            unsigned long long expectedBytes = item.totalExpectedBytes;
            if (item.isVideoDASH) {
                expectedBytes += item.totalExpectedBytesOfSound;
            }
            NSString* expectedBytes_Str = [Utility stringFromSize:expectedBytes showAsDecimal:YES];
            [rowView.txtInformation setStringValue:expectedBytes_Str];
            
            NSImage* findImg = [NSImage imageNamed:@"find"];
            [rowView.btnStartStopFind setImage:findImg];
            [rowView.btnStartStopFind setToolTip:NSLocalizedString(@"tcmShowInFinderText", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmRemoveFromListText", nil)];
            [rowView.progressView setColorRectWidth:0.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 1:
        {
            unsigned long long expectedBytes = item.totalExpectedBytes;
            unsigned long long recvedBytes = 0;
            if (!item.urlOfSegments) {
                recvedBytes = item.totalReceivedBytes + item.receivedBytes;
                if (item.isVideoDASH) {
                    expectedBytes += item.totalExpectedBytesOfSound;
                    recvedBytes += item.totalReceivedBytesSound + item.receivedBytesSound;
                }
            }
            if (item.urlOfSegments) {
                recvedBytes = item.receivedBytes;
                if (item.isVideoDashMpd) {
                    expectedBytes += item.totalExpectedBytesOfSound;
                    recvedBytes += item.receivedBytesSound;
                }
            }
            
            NSImage* findImg = [NSImage imageNamed:@"suspend"];
            [rowView.btnStartStopFind setImage:findImg];
            [rowView.btnStartStopFind setToolTip:NSLocalizedString(@"tcmSuspendDownloadText", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmCancelDownloadText", nil)];
            double progress = [self changeProgress:item];
            [rowView.progressView setColorRectWidth:progress];
            [rowView.progressView setNeedsDisplay:YES];
            
            NSString* expectedBytes_Str = [Utility stringFromSize:expectedBytes showAsDecimal:YES];
            NSString* recvedBytes_Str = [Utility stringFromSize:recvedBytes showAsDecimal:YES];
            NSString* leftTime = [self timeLeftToLoadItem:item];
            
            NSString* txtInformation = [NSString stringWithFormat:@"%@ of %@ / %@", recvedBytes_Str, expectedBytes_Str, leftTime];
            
            [rowView.txtInformation setStringValue:txtInformation];
        }
            break;
        case 2:
        {
            [rowView.txtInformation setStringValue:NSLocalizedString(@"txtStateQueued", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmRemoveFromListText", nil)];
            double progress = [self changeProgress:item];
            [rowView.progressView setColorRectWidth:progress];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 3:
        {
            NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateVideoConverted", nil), item.percentageConvertion];
            [rowView.txtInformation setStringValue:percentageCon];
            [rowView.progressView setColorRectWidth:442.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 4:
        {
            NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateSoundExtracting", nil), item.percentageConvertion];
            [rowView.txtInformation setStringValue:percentageCon];
            [rowView.progressView setColorRectWidth:442.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 5:
            // Through fall
        case 8:
        {
            NSString* txtInfo = NSLocalizedString(@"txtStateSuspended", nil);
            [rowView.txtInformation setStringValue:txtInfo];
            
            NSImage* resumeImg = [NSImage imageNamed:@"resume"];
            [rowView.btnStartStopFind setImage:resumeImg];
            [rowView.btnStartStopFind setToolTip:NSLocalizedString(@"tcmResumeDownloadText", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmRemoveFromListText", nil)];
            double progress = [self changeProgress:item];
            [rowView.progressView setColorRectWidth:progress];
            [rowView.progressView setNeedsDisplay:YES];
            
        }
            break;
        case 6:
        {
            NSString* txtInfo = NSLocalizedString(@"txtStateSuspendedConvert", nil);
            [rowView.txtInformation setStringValue:txtInfo];
            
            NSImage* resumeImg = [NSImage imageNamed:@"resume"];
            [rowView.btnStartStopFind setImage:resumeImg];
            [rowView.btnStartStopFind setToolTip:NSLocalizedString(@"tcmResumeDownloadText", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmRemoveFromListText", nil)];
            double progress = [self changeProgress:item];
            [rowView.progressView setColorRectWidth:progress];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 7:
        {
            [rowView.txtInformation setStringValue:NSLocalizedString(@"txtStateResumedAndQueued", nil)];
            
            NSImage* suspendImg = [NSImage imageNamed:@"suspend"];
            [rowView.btnStartStopFind setImage:suspendImg];
            [rowView.btnStartStopFind setToolTip:NSLocalizedString(@"tcmSuspendDownloadText", nil)];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmCancelDownloadText", nil)];
            double progress = [self changeProgress:item];
            [rowView.progressView setColorRectWidth:progress];
            [rowView.progressView setNeedsDisplay:YES];
            
        }
            break;
        case 9:
        {
            if ([item.mimeType hasPrefix:@"video"]) {
                NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateVideoConverted", nil), item.percentageConvertion];
                [rowView.txtInformation setStringValue:percentageCon];
                
            }
            else if ([item.mimeType hasPrefix:@"audio"]) {
                NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateSoundExtracting", nil), item.percentageConvertion];
                [rowView.txtInformation setStringValue:percentageCon];
            }
            
            [rowView.progressView setColorRectWidth:442.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 10:
        {
            [rowView.txtInformation setStringValue:NSLocalizedString(@"txtStateSizeCalculation", nil)];
            [rowView.txtInformation setNeedsDisplay:YES];
            [rowView.btnCancelDelete setToolTip:NSLocalizedString(@"tcmRemoveFromListText", nil)];
            [rowView.progressView setColorRectWidth:0.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 11:
        {
            if ([item.mimeType hasPrefix:@"audio"]) {
                NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateSoundExtracting", nil), item.percentageConvertion];
                [rowView.txtInformation setStringValue:percentageCon];
            }
            else if ([item.mimeType hasPrefix:@"video"]) {
                NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateVideoConverted", nil), item.percentageConvertion];
                [rowView.txtInformation setStringValue:percentageCon];
            }
            
            [rowView.progressView setColorRectWidth:442.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        case 12:
        {
            NSString* percentageCon = [NSString stringWithFormat:NSLocalizedString(@"txtStateAddingCover", nil), item.percentageConvertion];
            [rowView.txtInformation setStringValue:percentageCon];
            
            [rowView.progressView setColorRectWidth:442.0];
            [rowView.progressView setNeedsDisplay:YES];
        }
            break;
        default:
            break;
    }
    
    if (item.updatingLink) {
        [rowView.txtInformation setStringValue:NSLocalizedString(@"txtStateUpdateLinks", nil)];
    }
}

- (void)refreshDataInDownloadsListForItem:(DownloadItem*)downloadItem {
    if ((!downloadItem.audioFileWasDeleted && !downloadItem.videoFileWasDeleted) || !downloadItem.currentState ) {
        unsigned long long row = [self rowForDownloadItem:downloadItem];
        if (row != -1) {
            if (row <= self.tableDownloadList.numberOfRows) {
                NSView* rowView = [self.tableDownloadList viewAtColumn:0 row:row makeIfNecessary:NO];
                [self refreshDataInRowView:rowView forItem:downloadItem];
            }
        }
    }
}

- (unsigned long long)rowForDownloadItem:(DownloadItem*)item {
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    __block unsigned long long val = 0;
    
    [downloads enumerateObjectsUsingBlock:^(DownloadItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* title = [obj title];
        if ([item.title isEqualToString:title]) {
            unsigned long long itag = [obj itag];
            if (item.itag == itag) {
                NSString* format = [obj format];
                if ([item.format isEqualToString:format]) {
                    id urlArg = [item.url componentsSeparatedByString:@"?"];
                    NSString* objUrl = [obj url];
                    id objUrlArg = [objUrl componentsSeparatedByString:@"?"];
                    if ([urlArg[0] isEqualToString:objUrlArg[0]]) {
                        id objParent = [obj parent];
                        unsigned long long lengthSec = [objParent lengthSeconds];
                        if (item.parent.lengthSeconds == lengthSec) {
                            val = idx;
                            *stop = YES;
                        }
                    }
                }
            }
        }
    }];
    
    return val;
}

- (void)multimediaWasSaved:(NSDictionary*)itemKind {
    DownloadItem* item = [itemKind objectForKey:@"item"];
    int nkind = [[itemKind objectForKey:@"kindOfItem"] intValue];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    id delegate = [NSApp delegate];
    
    if (nkind == 4) {
        [item setVideoFileWasDeleted:YES];
        NSString* package = [item.pathToPackageOfDownload stringByDeletingLastPathComponent];
        NSString* video = [item.pathToTheSavedVideo lastPathComponent];
        NSString* savedPath = [package stringByAppendingPathComponent:video];
        
        NSError* error = nil;
        [fileManager moveItemAtPath:item.pathToTheSavedVideo toPath:savedPath error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        else {
            [fileManager removeItemAtPath:item.pathToPackageOfDownload error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }
        
        NSDictionary* fileDict = [fileManager attributesOfItemAtPath:savedPath error:nil];
        unsigned long long fileSize = [fileDict fileSize];
        [item setTotalExpectedBytes:fileSize];
        [item.connectForDownloadVideo cancel];
        [item setConnectForDownloadVideo:nil];
        [item setCurrentState:0];
        [self refreshDataInDownloadsListForItem:item];
    }
    else if (nkind == 3) {
        [item setAudioFileWasDeleted:YES];
        NSString* package = [item.pathToPackageOfDownload stringByDeletingLastPathComponent];
        NSString* audio = [item.pathToTheSavedAudio lastPathComponent];
        NSString* savedPath = [package stringByAppendingPathComponent:audio];
        
        NSError* error = nil;
        if ([fileManager fileExistsAtPath:item.pathToFileWithCover]) {
            [fileManager moveItemAtPath:item.pathToFileWithCover toPath:savedPath error:&error];
        }
        else {
            if ([fileManager fileExistsAtPath:item.pathToTheSavedAudio]) {
                [fileManager moveItemAtPath:item.pathToTheSavedAudio toPath:savedPath error:&error];
            }
        }
        
        [item setPathToTheSavedAudio:savedPath];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        else {
            if ([fileManager removeItemAtPath:item.pathToPackageOfDownload error:&error]) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
            }
            [item setPathToFileDashAudio:nil];
        }
        
        NSDictionary* fileDict = [fileManager attributesOfItemAtPath:savedPath error:nil];
        unsigned long long fileSize = [fileDict fileSize];
        [item setTotalExpectedBytes:fileSize];
        [item.connectForDownloadMP3 cancel];
        [item setConnectForDownloadMP3:nil];
        [item setCurrentState:0];
        
        [self refreshDataInDownloadsListForItem:item];
        [self.tableDownloadList reloadData];
    }
    else if (nkind == 2 || nkind == 1) {
        if (item.wasSavedVideo && item.wasSavedSound) {
            [item setVideoFileWasDeleted:YES];
            NSString* package = [item.pathToPackageOfDownload stringByDeletingLastPathComponent];
            NSString* video = [item.pathToTheSavedVideo lastPathComponent];
            NSString* savedPath = [package stringByAppendingPathComponent:video];
            
            NSError* error = nil;
            [fileManager moveItemAtPath:item.pathToTheSavedVideo toPath:savedPath error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
            else {
                [fileManager removeItemAtPath:item.pathToPackageOfDownload error:&error];
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
                [item setPathToFileDashVideo:nil];
                [item setPathToFileDashSound:nil];
            }
            
            NSDictionary* fileDict = [fileManager attributesOfItemAtPath:savedPath error:nil];
            unsigned long long fileSize = [fileDict fileSize];
            [item setTotalExpectedBytes:fileSize];
            [item.connectForDownloadVideo cancel];
            [item setConnectForDownloadVideo:nil];
            [item.connectForDownloadSound cancel];
            [item setConnectForDownloadSound:nil];
            [item setCurrentState:0];
            [self refreshDataInDownloadsListForItem:item];
        }
    }
    
    [self.tableDownloadList reloadData];
    [delegate saveDownloadsInUserDefaults];
    [self updateLabelCountDownloads];
    
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray* tasksExtractions = [delegate tasksExtractions];
    [tasksExtractions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isRunning]) {
            [indexSet addIndex:idx];
        }
    }];
    [tasksExtractions removeObjectsAtIndexes:indexSet];
    
    if (![[YDUserDefaults activationKey] isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"]) {
        if ([delegate currentlyNumberOfActive] <= 4) {
            [self startDownloadOfNextVideo];
        }
    }
    else {
        long long numOfFreeDownloads = [delegate getNumberFreeDownloads];
        long long currNumOfActive = [delegate currentlyNumberOfActive];
        if ([YDUserDefaults wasPurchasedPreviously]) {
            //NSString* lblCountFreeDownloads_Str = [NSString stringWithFormat:NSLocalizedString(@"offerreminderCountFreeInfo", nil), numOfFreeDownloads, 2];
            //OfferReminderWindowController* offerWindow = [delegate offerriminderWindow];
            //[offerWindow.lblCountFreeDownloads setStringValue:lblCountFreeDownloads_Str];
            [delegate showOfferReminderWindow];
        }
        else {
            if (currNumOfActive || numOfFreeDownloads > 0) {
                ;
            } else {
                [delegate showDemoReminderWindow];
            }
        }
    }
    
    NSString* complete = [NSString stringWithFormat:@"Download complete\n%@", item.title];
    [delegate deliverNoticeWithText:complete];
    return;
}

- (NSString*)titlesOfButtonFormatResolution:(NSMutableArray*)temporaryPacket {
    if (!temporaryPacket.count) {
        return nil;
    }
    
    NSMutableArray* mArray = [NSMutableArray array];
    
    for (DownloadItem* item in temporaryPacket) {
        NSMutableArray* videos = item.videoResources;
        NSMutableArray* mResolution = [NSMutableArray arrayWithCapacity:videos.count];
        
        for (DownloadItem* video in videos) {
            if (video.isReasonableFormat) {
                [mResolution addObject:[NSNumber numberWithUnsignedInteger:video.itag]];
            }
        }
        
        [mArray addObject:mResolution];
    }
    
    NSMutableArray* newmArray = [NSMutableArray array];
    id array = [Utility multipleIntersectionOfArrays:mArray count:0];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [temporaryPacket enumerateObjectsUsingBlock:^(DownloadItem*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            [item.videoResources enumerateObjectsUsingBlock:^(DownloadItem*  _Nonnull video, NSUInteger idx, BOOL * _Nonnull stop) {
                int resolution = [obj intValue];
                if (video.itag == resolution) {
                    [newmArray addObject:video];
                    *stop = YES;
                }
            }];
        }];
    }];
    
    NSArray* videoInfo = @[[NSSortDescriptor sortDescriptorWithKey:@"format" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"resolution" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"fps" ascending:NO]];
    
    [newmArray sortUsingDescriptors:videoInfo];
    
    NSMutableArray* videoSpecArray = [NSMutableArray array];
    
    for (id each in newmArray) {
        long long fps = [each fps];
        NSString* format = [each format];
        long long resolution = [each resolution];
        NSString* videoSpec = nil;
        if (fps < 31) {
            videoSpec = [NSString stringWithFormat:@"%@ %lldp", format, resolution];
        }
        else {
            videoSpec = [NSString stringWithFormat:@"%@ %lldp %lld", format, resolution, fps];
        }
        [videoSpecArray addObject:videoSpec];
    }
    
    return videoSpecArray;
}

- (void)customWindowAppearance { 
    NSMenu* mainMenu = [NSApp mainMenu];
    
    [self.btnDownload setEnabled:NO];
    [self.btnResolutions removeAllItems];
    [self.btnResolutions setEnabled:NO];
    [self.btnResolutions setLeftImage:[NSImage imageNamed:@"PopUpLeftN"]];
    [self.btnResolutions setFillImage:[NSImage imageNamed:@"PopUpFillN"]];
    [self.btnResolutions setRightImage:[NSImage imageNamed:@"PopUpRightN"]];
    [self.btnResolutions setLeftPressedImage:[NSImage imageNamed:@"PopUpLeftP"]];
    [self.btnResolutions setFillPressedImage:[NSImage imageNamed:@"PopUpFillP"]];
    [self.btnResolutions setRightPressedImage:[NSImage imageNamed:@"PopUpRightP"]];
    [self.btnResolutions setLeftDisabledImage:[NSImage imageNamed:@"PopUpLeftD"]];
    [self.btnResolutions setFillDisabledImage:[NSImage imageNamed:@"PopUpFillD"]];
    [self.btnResolutions setRightDisabledImage:[NSImage imageNamed:@"PopUpRightD"]];
    
    NSFont* font = [NSFont systemFontOfSize:13.0];
    NSFontDescriptor* fontDescriptor = [font fontDescriptor];
    NSDictionary* dict1 = @{NSFontWeightTrait: [NSNumber numberWithDouble:-0.23]};
    NSDictionary* dict2 = @{NSFontTraitsAttribute: dict1};
    
    NSFont* newFont = [NSFont fontWithDescriptor:[fontDescriptor fontDescriptorByAddingAttributes:dict2] size:[fontDescriptor pointSize]];
    [self.btnResolutions setFont:newFont];
    
    [self.btnDownload setLeftImage:[NSImage imageNamed:@"DownloadLeftN"]];
    [self.btnDownload setFillImage:[NSImage imageNamed:@"DownloadFillN"]];
    [self.btnDownload setRightImage:[NSImage imageNamed:@"DownloadRightN"]];
    [self.btnDownload setLeftPressedImage:[NSImage imageNamed:@"DownloadLeftP"]];
    [self.btnDownload setFillPressedImage:[NSImage imageNamed:@"DownloadFillP"]];
    [self.btnDownload setRightPressedImage:[NSImage imageNamed:@"DownloadRightP"]];
    [self.btnDownload setLeftDisabledImage:[NSImage imageNamed:@"DownloadLeftD"]];
    [self.btnDownload setFillDisabledImage:[NSImage imageNamed:@"DownloadFillD"]];
    [self.btnDownload setRightDisabledImage:[NSImage imageNamed:@"DownloadRightD"]];
    
    NSColor* whiteColor = [NSColor whiteColor];
    NSDictionary* fontColorDict = @{NSFontAttributeName: newFont, NSForegroundColorAttributeName: whiteColor};
    
    NSAttributedString* btnDownloadTitleAttr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"btnDownloadTitle", nil) attributes:fontColorDict];
    [self.btnDownload setAttributedDisabledTitle:btnDownloadTitleAttr];
    
    [self.txtVideoUrl setFont:[NSFont systemFontOfSize:14.0]];
    [self.txtVideoUrl setBackgroundColor:[NSColor clearColor]];
    [self.txtVideoUrl initializePlaceholder];
    [self.txtVideoUrl setPlaceholderString:NSLocalizedString(@"placeholderVideoUrl", nil)];
    
    [self.viewUnderVideoUrl setLeftImage:[NSImage imageNamed:@"urlLeft"]];
    [self.viewUnderVideoUrl setFillImage:[NSImage imageNamed:@"urlFill"]];
    [self.viewUnderVideoUrl setRightImage:[NSImage imageNamed:@"urlRight"]];
    [self.viewUnderVideoUrl setNeedsDisplay:YES];
    
    NSMutableAttributedString* spAttr = [NSMutableAttributedString alloc];
    NSString* attrString = [NSLocalizedString(@"lblInvitationText", nil) stringByAppendingString:@" "];
    
    NSDictionary* fontColorDictForlblInvitation = @{NSFontAttributeName: [NSFont systemFontOfSize:13.0], NSForegroundColorAttributeName: [NSColor disabledControlTextColor]};
    NSMutableAttributedString* lblInvitationAttr = [[NSMutableAttributedString alloc] initWithString:attrString attributes:fontColorDictForlblInvitation];
    
    NSTextAttachmentCell* attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:@"arrow"]];
    NSTextAttachment* attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:attachmentCell];
    
    NSAttributedString* attachmentAttr = [NSAttributedString attributedStringWithAttachment:attachment];
    [lblInvitationAttr appendAttributedString:attachmentAttr];
    [lblInvitationAttr setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [lblInvitationAttr length])];
    
    [self.lblInvitation setAttributedStringValue:lblInvitationAttr];
    
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    [self.lblInvitation setHidden:downloads.count != 0];
    [[self.scrollView verticalScroller] setArrowsPosition:NSScrollerArrowsNone];
    [self.scrollView setFocusRingType:NSFocusRingTypeNone];
    
    [self.tableDownloadList setBackgroundColor:[NSColor clearColor]];
    [self.tableDownloadList setFocusRingType:NSFocusRingTypeNone];
    
    NSColor* customHorizontalLineColor = [NSColor colorWithCalibratedRed:0.6941176470588235 green:0.6941176470588235 blue:0.6941176470588235 alpha:1.0];
    
    [self.horizontalLine setIsHorizontal:YES];
    [self.horizontalLine setLineColor:customHorizontalLineColor];
    [self.horizontalLine setLineWidth:1.0];
    [self.horizontalLine setNeedsDisplay:YES];
    
    NSColor* customCountDownloadsColor = [NSColor colorWithCalibratedRed:0.196078431372549 green:0.196078431372549 blue:0.196078431372549 alpha:1.0];
    
    [self.lblCountDownloads setTextColor:customCountDownloadsColor];
    [self.tableDownloadList reloadData];
    
    [delegate increaseMainWindowSize];
    [self updateLabelCountDownloads];
}

- (void)getSummarySizeOfSoundSegmentsForItem:(DownloadItem*)item {
    if ([item.mimeType hasPrefix:@"audio"]) {
        NSString* urlEncoded = [item.url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/clen/(\\d*)/" options:0 error:nil];
        
        NSArray *array = [regex matchesInString:urlEncoded options:0 range:NSMakeRange(0, urlEncoded.length)];
        
        double expectedBytes = 0.0;
        if (array) {
            for (NSTextCheckingResult* obj in array) {
                NSRange range = [obj rangeAtIndex:1];
                NSString* subStr = [urlEncoded substringWithRange:range];
                expectedBytes = [subStr doubleValue];
            }
            
            [item setTotalExpectedBytes:expectedBytes];
        }
        else {
            [self getSummarySizeOfSegmentsForItem:item];
        }
    }
}

- (void)getSummarySizeOfSegmentsForItem:(DownloadItem*)item {
    [item setCurrentState:10];
    [Utility printTime:@"start calculate size"];
    
    __block unsigned long long expectedContentBytes = 0;
    __block unsigned long long totalContentBytes = 0;
    
    dispatch_queue_t summarySizeQueue = dispatch_queue_create("com.Streamup.SummarySizeQueue", 0);
    dispatch_async(summarySizeQueue, ^{
        for (id each in item.urlOfSegments) {
            NSURL* urlSeg = [NSURL URLWithString:each];
            NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:urlSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
            [mRequest setHTTPMethod:@"HEAD"];
            
            NSURLResponse* response = nil;
            NSError* error = nil;
            [NSURLConnection sendSynchronousRequest:mRequest returningResponse:&response error:&error];
            
            if (!error) {
                expectedContentBytes += [response expectedContentLength];
            }
        }
        
        [Utility printTime:@"end calculate size"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [item setTotalExpectedBytes:expectedContentBytes];
            [item setCurrentState:1];
            [self.tableDownloadList reloadData];
            [self refreshDataInDownloadsListForItem:item];
        });
    });
}

- (void)getSizeforItem:(DownloadItem*)item async:(BOOL)bAsync {
    NSURL* urlOfSeg = [NSURL URLWithString:item.url];
    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:urlOfSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [mRequest setHTTPMethod:@"HEAD"];
    
    if (bAsync) {
        [NSURLConnection sendAsynchronousRequest:mRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                [item setTotalExpectedBytes:[response expectedContentLength]];
            }
            [item calculateMultiplier];
        }];
    }
    else {
        NSURLResponse* response = nil;
        NSError* error = nil;
        [NSURLConnection sendSynchronousRequest:mRequest returningResponse:&response error:&error];
        
        if (!error) {
            [item setTotalExpectedBytes:[response expectedContentLength]];
        }
        [item calculateMultiplier];
    }
}

- (void)startDownloadOfNextSegmentForItem:(DownloadItem*)item {
    NSUInteger numOfSegment = item.numOfSegment + 1;
    [item setNumOfSegment:numOfSegment];
    if (!item.urlOfSegments || numOfSegment < item.urlOfSegments.count) {
        id nextUrlSeg = [item.urlOfSegments objectAtIndex:item.numOfSegment];
        NSURL* nextUrl = [NSURL URLWithString:nextUrlSeg];
        
        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:nextUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];

        NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
        [item setConnectForDownloadSegment:urlConn];
        [item.connectForDownloadSegment scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [item.connectForDownloadSegment start];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL bHasAudio = [item.mimeType hasPrefix:@"audio"];
        [self concatenateSegmentsOfItem:item isSound:bHasAudio];
    });
}

- (void)startDownloadOfNextSoundSegmentForItem:(DownloadItem*)item {
    NSUInteger numOfSoundSegment = item.numOfSoundSegment + 1;
    [item setNumOfSoundSegment:numOfSoundSegment];
    if (!item.urlOfSoundSegments || numOfSoundSegment < item.urlOfSoundSegments.count) {
        id nextUrlSoundSeg = [item.urlOfSoundSegments objectAtIndex:item.numOfSegment];
        NSURL* nextUrlSound = [NSURL URLWithString:nextUrlSoundSeg];
        
        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:nextUrlSound cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];

        NSURLConnection* urlSoundConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
        [item setConnectForDownloadSoundSegment:urlSoundConn];
        [item.connectForDownloadSoundSegment scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [item.connectForDownloadSoundSegment start];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self concatenateSoundSegmentsOfItem:item];
    });
}

- (void)startDownloadOfNextVideo { 
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    
    id delegate = [NSApp delegate];
    id downloads = [delegate downloadsList];
    
    BOOL bMp3 = NO;
    DownloadItem* nextItem = nil;
    
    for (DownloadItem* item in downloads) {
        if (item.currentState != 2 && item.currentState != 7) {
            continue;
        }
        
        [indexSet addIndex:[downloads indexOfObject:item]];
        bMp3 = [item.format isEqualToString:@"mp3"];
        nextItem = item;
        break;
    }
    
    NSString* url = nil;
    if (nextItem.url) {
        url = nextItem.url;
    }
    else {
        url = nextItem.urlOfSegments[0];
    }
    
    if ([nextItem expiryDateOfLinkEnded:url]) {
        [nextItem setCurrentState:8];
        [self startUpdatingLinks:indexSet];
    }
    else if (nextItem.currentState == 7) {
        [self resumeDownloadForItem:nextItem];
    }
    else if (nextItem.currentState == 2) {
        [self downloadVideo:nextItem forMP3:bMp3];
        [self.tableDownloadList reloadData];
    }
}

- (void)downloadVideo:(DownloadItem*)item forMP3:(BOOL)bAudio {
    if (![self updateErrorForItem:item]) {
        // TODO: appstatico
        // if enable appstatico, we could collect some user data for analyze our product.
        
        if (item.urlOfSegments && item.urlOfSegments.count) {
            [item setCurrentState:10];
            [self getSummarySizeOfSegmentsForItem:item];
            if (!bAudio) {
                if (!item.urlOfSoundSegments) {
                    if (item.getSoundItem) {
                        [item setUrlSoundItem:[item.getSoundItem url]];
                        [item setUrlOfSoundSegments:[item.getSoundItem urlOfSegments]];
                        [self getSummarySizeOfSoundSegmentsForItem:item];
                        [item setTotalExpectedBytesOfSound:[item.getSoundItem totalExpectedBytes]];
                    }
                }
                if (item.urlOfSoundSegments) {
                    NSURL* soundSeg = [NSURL URLWithString:item.urlOfSoundSegments[0]];
                    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:soundSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                    
                    NSURLConnection* soundConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
                    [item setConnectForDownloadSoundSegment:soundConn];
                    [item.connectForDownloadSoundSegment scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                    [item.connectForDownloadSoundSegment start];
                }
            }
            
            NSURL* urlOfSeg = [NSURL URLWithString:item.urlOfSegments[0]];
            NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:urlOfSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
            
            NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
            [item setConnectForDownloadSegment:urlConn];
            [item.connectForDownloadSegment scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            [item.connectForDownloadSegment start];
            [item setTotalReceivedBytes:0];
            [item setReceivedBytes:0];
            [item setStartDownload:[NSDate date]];
        }
        else {
            [self getSizeforItem:item async:YES];
            NSArray* arrItem = [NSArray arrayWithObjects:&item count:1];
            if (![self haveFreeSpaceForItems:arrItem onDevice:item.downloadDir]) {
                [item setCurrentState:8];
                [self refreshDataInDownloadsListForItem:item];
                return;
            }
            
            [item setCurrentState:1];
            if (bAudio) {
                NSURL* audioSeg = [NSURL URLWithString:item.url];
                NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:audioSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                
                NSURLConnection* audioConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
                [item setConnectForDownloadMP3:audioConn];
                [item.connectForDownloadMP3 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                [item.connectForDownloadSoundSegment start];
                [item setTotalReceivedBytes:0];
            }
            else {
                if (item.isVideoDASH) {
                    if (!item.urlSoundItem) {
                        DownloadItem* soundItem = item.getSoundItem;
                        if (soundItem) {
                            [self getSizeforItem:soundItem async:YES];
                            [item setUrlSoundItem:soundItem.url];
                            [item setTotalExpectedBytesOfSound:soundItem.totalExpectedBytes];
                        }
                    }
                }
                
                if (item.isVideoDASH && item.urlSoundItem) {
                    NSURL* soundSeg = [NSURL URLWithString:item.urlSoundItem];
                    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:soundSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                    
                    NSURLConnection* soundConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
                    [item setConnectForDownloadSound:soundConn];
                    [item.connectForDownloadSound scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                    [item.connectForDownloadSound start];
                }
                NSURL* dashSeg = [NSURL URLWithString:item.url];
                NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:dashSeg cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                
                NSURLConnection* dashConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
                [item setConnectForDownloadVideo:dashConn];
                [item.connectForDownloadVideo scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                [item.connectForDownloadVideo start];
                [item setReceivedBytes:0];
            }
            [item setTotalReceivedBytes:0];
            [item setStartDownload:[NSDate date]];
        }
        
        id delegate = [NSApp delegate];
        if (![delegate isProVersion]) {
            if ([delegate isDemoVersion]) {
                long long numOfFreeVersion = [YDUserDefaults numberOfDownloadsFreeVersion];
                [delegate setNumberFreeDownloads:numOfFreeVersion - 1];
            }
        }
        
        [self updateLabelCountDownloads];
    }
}

- (void)suspend:(DownloadItem*)item {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item.currentState != 8) {
                [item setCurrentState:5];
                [self refreshDataInDownloadsListForItem:item];
            }
        });
        
        if ([item.mimeType hasPrefix:@"video"]) {
            if (item.urlOfSegments) {
                [item.queueOfSavingVideoSegments waitUntilAllOperationsAreFinished];
                [item.queueOfSavingVideoSegments setSuspended:YES];
                [item.queueOfSavingSoundSegments setSuspended:YES];
            }
            else {
                [item.queueOfSavingVideo waitUntilAllOperationsAreFinished];
                [item.queueOfSavingVideo setSuspended:YES];
                
                unsigned long long recvBytes = item.receivedBytes + item.totalReceivedBytes;
                [item setTotalReceivedBytes:recvBytes];
                [item setReceivedBytes:0];
                
                if (item.isVideoDASH) {
                    [item.queueOfSavingSound waitUntilAllOperationsAreFinished];
                    [item.queueOfSavingSound setSuspended:YES];
                    
                    unsigned long long recvSoundBytes = item.receivedBytesSound + item.totalReceivedBytesSound;
                    [item setTotalReceivedBytesSound:recvSoundBytes];
                    [item setReceivedBytesSound:0];
                }
            }
        }
        
        if ([item.mimeType hasPrefix:@"audio"]) {
            if (item.urlOfSegments) {
                [item.queueOfSavingVideoSegments waitUntilAllOperationsAreFinished];
                [item.queueOfSavingVideoSegments setSuspended:YES];
            }
            else {
                [item.queueOfSavingMp3 waitUntilAllOperationsAreFinished];
                [item.queueOfSavingMp3 setSuspended:YES];
                
                unsigned long long recvMp3Bytes = item.receivedBytes + item.totalReceivedBytes;
                [item setTotalReceivedBytes:recvMp3Bytes];
                [item setReceivedBytes:0];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item.currentState != 8) {
                [item setCurrentState:5];
                [self refreshDataInDownloadsListForItem:item];
                [self updateLabelCountDownloads];
                
                id delegate = [NSApp delegate];
                if ([delegate isProVersion]) {
                    if ([delegate currentlyNumberOfActive] <= 4) {
                        [self startDownloadOfNextVideo];
                    }
                }
            }
        });
    });
}

- (void)suspendDownloadForItem:(DownloadItem*)item {
    if ([item.mimeType hasPrefix:@"video"]) {
        if (item.connectForDownloadSegment) {
            [item.connectForDownloadSegment cancel];
            [item.connectForDownloadSoundSegment cancel];
        }
        else {
            [item.connectForDownloadVideo cancel];
            [item setNeedAllocMemForSavedUpVideoData:YES];
            if (item.isVideoDASH) {
                [item.connectForDownloadSound cancel];
                [item setNeedAllocMemForSavedUpSoundData:YES];
            }
        }
    }
    
    if ([item.mimeType hasPrefix:@"audio"]) {
        if (item.connectForDownloadSegment) {
            [item.connectForDownloadSegment cancel];
        }
        else {
            [item.connectForDownloadMP3 cancel];
            [item setNeedAllocMemForSavedUpMp3Data:YES];
        }
    }
    [self suspend:item];
}

- (void)resume:(DownloadItem*)item {
    if ([item.mimeType hasPrefix:@"video"]) {
        if (item.urlOfSegments && item.urlOfSegments.count) {
            long long numOfSeg = item.numOfSegment;
            [item setNumOfSegment:numOfSeg - 1];
            
            long long numOfSoundSeg = item.numOfSoundSegment;
            [item setNumOfSoundSegment:numOfSoundSeg - 1];
            
            if (item.queueOfSavingVideoSegments) {
                [item.queueOfSavingVideoSegments setSuspended:NO];
                if ([item.mimeType hasPrefix:@"video"] && item.numOfSoundSegment >= 0 && !item.wasSavedSound) {
                    [item.queueOfSavingSoundSegments setSuspended:NO];
                }
            }
            else {
                NSOperationQueue* queueVideoSeg = [[NSOperationQueue alloc] init];
                [item setQueueOfSavingVideoSegments:queueVideoSeg];
                [item.queueOfSavingVideoSegments setMaxConcurrentOperationCount:1];
                
                if ([item.mimeType hasPrefix:@"video"] && item.urlOfSoundSegments && item.numOfSoundSegment >= 0 && !item.wasSavedSound) {
                    NSOperationQueue* queueSoundSeg = [[NSOperationQueue alloc] init];
                    [item setQueueOfSavingSoundSegments:queueSoundSeg];
                    [item.queueOfSavingSoundSegments setMaxConcurrentOperationCount:1];
                }
            }
            
            [self startDownloadOfNextSegmentForItem:item];
            if (item.urlOfSoundSegments && !item.wasSavedSound) {
                [self startDownloadOfNextSoundSegmentForItem:item];
            }
        }
        else {
            [item setNeedAllocMemForSavedUpVideoData:YES];
            NSURL* rangeUrl = [NSURL URLWithString:item.url];
            NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:rangeUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
            NSString* headerField = [NSString stringWithFormat:@"bytes=%lld-", item.totalReceivedBytes];
            [mRequest setValue:headerField forHTTPHeaderField:@"Range"];
            
            NSURLConnection* rangeConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
            [item setConnectForDownloadVideo:rangeConn];
            [item.connectForDownloadVideo scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            [item.connectForDownloadVideo start];
            
            if (item.queueOfSavingVideo) {
                [item.queueOfSavingVideo setSuspended:NO];
            }
            else {
                NSOperationQueue* queueVideo = [[NSOperationQueue alloc] init];
                [item setQueueOfSavingVideo:queueVideo];
                [item.queueOfSavingVideo setMaxConcurrentOperationCount:1];
            }
            
            if (item.isVideoDASH) {
                if (!item.wasSavedSound) {
                    if (item.totalReceivedBytesSound < item.totalExpectedBytesOfSound) {
                        [item setNeedAllocMemForSavedUpSoundData:YES];
                        if (!item.urlSoundItem) {
                            DownloadItem* soundItem = [item getSoundItem];
                            [item setUrlSoundItem:soundItem.url];
                        }
                        
                        NSURL* soundUrl = [NSURL URLWithString:item.urlSoundItem];
                        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:soundUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
                        NSString* headerField = [NSString stringWithFormat:@"bytes=%lld-", item.totalReceivedBytesSound];
                        [mRequest setValue:headerField forHTTPHeaderField:@"Range"];
                        
                        NSURLConnection* soundConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
                        [item setConnectForDownloadSound:soundConn];
                        [item.connectForDownloadSound scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                        [item.connectForDownloadSound start];
                        
                        if (item.queueOfSavingSound) {
                            [item.queueOfSavingSound setSuspended:NO];
                        }
                        else {
                            NSOperationQueue* queueSound = [[NSOperationQueue alloc] init];
                            [item setQueueOfSavingSound:queueSound];
                            [item.queueOfSavingSound setMaxConcurrentOperationCount:1];
                        }
                    }
                }
            }
        }
    }
    
    if ([item.mimeType hasPrefix:@"audio"]) {
        [item setNeedAllocMemForSavedUpMp3Data:YES];
        NSURL* soundUrl = [NSURL URLWithString:item.url];
        NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:soundUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
        NSString* headerField = [NSString stringWithFormat:@"bytes=%lld-", item.totalReceivedBytes];
        [mRequest setValue:headerField forHTTPHeaderField:@"Range"];
        
        NSURLConnection* soundConn = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:NO];
        [item setConnectForDownloadMP3:soundConn];
        [item.connectForDownloadMP3 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [item.connectForDownloadMP3 start];
        
        if (item.queueOfSavingMp3) {
            [item.queueOfSavingMp3 setSuspended:NO];
        }
        else {
            NSOperationQueue* queueSound = [[NSOperationQueue alloc] init];
            [item setQueueOfSavingMp3:queueSound];
            [item.queueOfSavingMp3 setMaxConcurrentOperationCount:1];
        }
    }
    
    [item setCurrentState:1];
    [self refreshDataInDownloadsListForItem:item];
    [self updateLabelCountDownloads]; 
}

- (void)resumeDownloadForItem:(DownloadItem*)item afterUpdating:(BOOL)bUpdate {
    NSString* downloadFolder = [[YDUserDefaults currentUserPreferences] objectForKey:@"PathToDownloadsFolder"];
    NSString* downloadUrl = nil;
    id delegate = [NSApp delegate];
    
    if ([self downloadsFolderIsAvailableByPath:downloadFolder] && ![self updateErrorForItem:item]) {
        if (item.url) {
            downloadUrl = item.url;
        }
        else {
            downloadUrl = item.urlOfSegments[0];
        }
        
        if (bUpdate || ![item expiryDateOfLinkEnded:downloadUrl]) {
            NSString* activeKey = [YDUserDefaults activationKey];
            if ([activeKey isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"]
                || item.currentState == 1
                || item.currentState == 8
                || [delegate currentlyNumberOfActive] < 5) {
                [self resume:item];
            }
            else {
                [item setCurrentState:7];
                [self refreshDataInDownloadsListForItem:item];
                [self updateLabelCountDownloads];
            }
        }
        else {
            NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
            id downloads = [delegate downloadsList];
            [indexSet addIndex:[downloads indexOfObject:item]];
            [item setCurrentState:8];
            [self startUpdatingLinks:indexSet];
        }
    }
}

- (void)resumeDownloadForItem:(DownloadItem*)downloadItem {
    [self resumeDownloadForItem:downloadItem afterUpdating:NO];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName; { 
    id item = [self getDownloadItemByXmlParser:parser];
    if (item) {
        if ([item captureTrackInfo]) {
            [item setCaptureTrackInfo:NO];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    ;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    id item = [self getDownloadItemByXmlParser:parser];
    if (item) {
        if ([elementName isEqual:@"track"]) {
            [item setCaptureTrackInfo:YES];
            id lang_code = [attributeDict objectForKey:@"lang_code"];
            NSDictionary* langCode = @{@"langCode": lang_code};
            [[item subtitleTracks] addObject:langCode];
        }
    }
}

- (DownloadItem*)getDownloadItemByXmlParser:(id)parser {
    NSUInteger count = self.temporaryPacket.count;
    if (!count) {
        return nil;
    }
    
    NSUInteger index = 0;
    
    DownloadItem* retItem = nil;
    
    while (YES) {
        id retItem = [self.temporaryPacket objectAtIndex:index];
        if ([retItem xmlParser] == parser) {
            break;
        }
        
        if (++index >= count) {
            break;
        }
    }
    
    return retItem;
}

- (void)requestOfDownloaditemSubtitleTrack:(DownloadItem*)item {
    NSMutableData* subTrack = [NSMutableData data];
    item.dataSubTrack = subTrack;
    NSURL* pageUrl = [NSURL URLWithString:item.pageUrl];
    NSString* pageQuery = [pageUrl query];
    id splitQuery = [pageQuery componentsSeparatedByString:@"="];
    NSString* vCode = splitQuery[1];
    
    NSString* requestString = [NSString stringWithFormat:@"http://video.google.com/timedtext?type=list&v=%@", vCode];
    NSURL* requestUrl = [NSURL URLWithString:requestString];
    NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    NSURLConnection* urlConn = [NSURLConnection connectionWithRequest:mRequest delegate:self];
    [item setConnectGetInfoSubTrack:urlConn];
    
    [item.connectGetInfoSubTrack scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [item.connectGetInfoSubTrack start];
}

@end
