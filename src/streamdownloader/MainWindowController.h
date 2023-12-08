//
//  MainWindowController.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseDownTextFieldDelegateProtocol.h"
#import "DSImageButton.h"
#import "DSImagePopUpButton.h"
#import "PageUrlTextView.h"
#import "PatternBackgroundView.h"
#import "YDHorizontalLine.h"

@class ProcessingLinksWindowController;

@interface MainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSURLConnectionDelegate, NSXMLParserDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, MouseDownTextFieldDelegate>
{
    unsigned long long httpStatusCode;
    long long quantityPlaylists;
    BOOL alertFileWasDeletedAlreadyShown;
}

@property(retain, nonatomic) NSMutableDictionary *cachedImages;
@property(retain, nonatomic) NSMutableArray *appstaticoIfo; // @synthesize appstaticoIfo=_appstaticoIfo;
@property(retain, nonatomic) NSAlert *alertconnectionOffline; // @synthesize alertconnectionOffline=_alertconnectionOffline;
@property(retain, nonatomic) NSAlert *alertConnectionLost; // @synthesize alertConnectionLost=_alertConnectionLost;
@property(retain, nonatomic) NSMutableArray *temporaryPacket; // @synthesize temporaryPacket=_temporaryPacket;
@property(retain, nonatomic) NSMutableArray *allLinks; // @synthesize allLinks=_allLinks;
@property(nonatomic) BOOL needSignIn; // @synthesize needSignIn=_needSignIn;
@property(retain, nonatomic) NSOperationQueue *queueOfUpdatingLinks; // @synthesize queueOfUpdatingLinks=_queueOfUpdatingLinks;
@property(retain, nonatomic) NSOperationQueue *queueReceivePlaylist; // @synthesize queueReceivePlaylist=_queueReceivePlaylist;
@property(retain, nonatomic) NSOperationQueue *queueReceiveLinks; // @synthesize queueReceiveLinks=_queueReceiveLinks;
@property(nonatomic) BOOL parsingCanceled; // @synthesize parsingCanceled=_parsingCanceled;
@property(nonatomic) BOOL inProcessParsing; // @synthesize inProcessParsing=_inProcessParsing;
@property(retain, nonatomic) ProcessingLinksWindowController *processingWindow; // @synthesize processingWindow=_processingWindow;
@property(nonatomic) IBOutlet NSProgressIndicator *progressDownload; // @synthesize progressDownload=_progressDownload;
@property(nonatomic) IBOutlet NSScrollView *scrollView; // @synthesize scrollView=_scrollView;
@property(nonatomic) IBOutlet YDHorizontalLine *horizontalLine; // @synthesize horizontalLine=_horizontalLine;
@property(nonatomic) IBOutlet NSTextField *lblCountDownloads; // @synthesize lblCountDownloads=_lblCountDownloads;
@property(nonatomic) IBOutlet NSTableView *tableDownloadList; // @synthesize tableDownloadList=_tableDownloadList;
@property(nonatomic) IBOutlet DSImagePopUpButton *btnResolutions; // @synthesize btnResolutions=_btnResolutions;
@property(nonatomic) IBOutlet DSImageButton *btnDownload; // @synthesize btnDownload=_btnDownload;
@property(nonatomic) IBOutlet PatternBackgroundView *viewUnderVideoUrl; // @synthesize viewUnderVideoUrl=_viewUnderVideoUrl;
@property(nonatomic) IBOutlet PageUrlTextView *txtVideoUrl; // @synthesize txtVideoUrl=_txtVideoUrl;
@property(nonatomic) IBOutlet NSTextField *lblInvitation; // @synthesize lblInvitation=_lblInvitation;
@property(nonatomic) IBOutlet NSView *mainView; // @synthesize mainView=_mainView;



- (BOOL)userNotificationCenter:(id)arg1 shouldPresentNotification:(id)arg2;
- (void)updatingWhenActivationInfoChanged;
- (void)registerOtherNotificationMessages;
- (void)assignmentValueNeedSignIn;
- (void)bookmarkWithUrl:(id)arg1;
- (void)actionOfContextMenuForDownloadList:(id)arg1;
- (id)contextualMenuForTableView:(id)arg1 withClickedRow:(long long)arg2;
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row;
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (long long)numberOfRowsInTableView:(id)arg1;
- (void)deleteRootItem:(id)arg1;
- (void)removeItemFromListOfDownloads:(id)arg1;
- (void)showAlertLinksNotAvailable;
- (void)showProcessingPlaylistWindow;
- (void)updateLabelCountDownloads;
- (void)updateInterfaceBeforeDownloading;
- (void)updateInterfaceAfterGettingLinks;
- (void)lockOfButtons;
- (void)clearListsOfLinks;
- (void)buttonCancelDeleteWasPressed:(id)arg1;
- (void)showInFinderDownloadItem:(id)arg1;
- (void)buttonStartStopFindWasPressed:(id)arg1;
- (IBAction)buttonResolutionSelectionWasChanged:(id)sender;
- (void)processOfUpdatingUrlIsCompleteForItem:(id)arg1;
- (void)startUpdatingLinks:(id)arg1;
- (id)indexesForUpdatingLinks;
- (void)resumeCalculateSizeOfSegmentsForItem:(id)arg1;
- (void)resumeConvertingForItem:(id)arg1;
- (void)resumeConcatenationOfSegmentsForItem:(id)arg1;
- (void)startLoadingOrConversionOfLinksIfNeeded;
- (void)restoreTheStateOfDownloadsList;
- (void)stopOfDownloadings;
- (void)convertSubtitlesToSrtFormat:(id)arg1;
- (void)loadingOfSubtitlesForDownloadItem:(id)arg1;
- (BOOL)createSubtitleFolderForDownloadItem:(id)arg1;
- (void)updateOfDownloadItem:(id)arg1 kindOf:(int)arg2;
- (IBAction)buttonDownloadWasClicked:(id)sender;
- (BOOL)itemIsLoadedOrQueued:(id)arg1;
- (void)processOfGettingPlaylistLinksIsComplete:(id)arg1;
- (void)processOfGettingLinksIsComplete:(id)arg1;
- (void)cancelProcessingOfLinksPlaylist;
- (void)requestOfDownloadItemSize:(id)arg1;
- (void)startGettingLinksForDownloadVideo;
- (void)downloadingLink:(id)arg1 withPlaylistID:(id)arg2 returnCode:(long long)arg3;
- (void)validateInsertedUrl:(id)arg1;
- (void)mouseDownOnTextField:(id)arg1;
- (id)validateSchemaForLink:(id)arg1;
- (void)escapeInsertedUrl:(id)arg1;
- (void)backspaceInsertedUrl:(id)arg1;
- (void)windowDidLoad;
- (id)initWithWindow:(id)arg1;
- (double)getConvertionTime:(id)arg1;
- (double)getDuration:(id)arg1;
- (BOOL)saveCoverImageForItem:(id)arg1;
- (void)startConcatenationOfItemSegments:(id)arg1;
- (void)startConversionOfItem:(id)arg1;
- (void)notifyAboutSavingAudioForItem:(id)arg1 withSuccess:(BOOL)arg2;
- (void)addCoverImageOfMp3ForItem:(id)arg1;
- (void)conversionOfAudioForItem:(id)arg1;
- (void)convertionWebmToMp4:(id)arg1;
- (void)conversionOfVideoForItem:(id)arg1;
- (void)concatenateSegmentsOfItem:(id)arg1 isSound:(BOOL)arg2;
- (void)concatenateSoundSegmentsOfItem:(id)arg1;
- (void)connection:(id)arg1 didFailWithError:(id)arg2;
- (void)connectionDidFinishLoading:(id)arg1;
- (void)connection:(id)arg1 didReceiveData:(id)arg2;
- (void)connection:(id)arg1 didReceiveResponse:(id)arg2;
- (id)connection:(id)arg1 willSendRequest:(id)arg2 redirectResponse:(id)arg3;
- (void)connection:(id)arg1 didSendBodyData:(long long)arg2 totalBytesWritten:(long long)arg3 totalBytesExpectedToWrite:(long long)arg4;
- (id)connection:(id)arg1 willCacheResponse:(id)arg2;
- (BOOL)downloadsFolderIsAvailableByPath:(id)arg1;
- (BOOL)haveFreeSpaceForItems:(id)arg1 onDevice:(id)arg2;
- (long long)spaceRequiredForAllDownloadsIncludingItems:(id)arg1;
- (long long)spaceRequiredForItem:(id)arg1;
- (long long)determineFreeSpaceOnDevice:(id)arg1 withError:(id)error;
- (BOOL)updateErrorForItem:(id)arg1;
- (void)noSpaceLeftOnDevice:(id)arg1;
- (void)deviceNotConfiguredWhenLoading;
- (void)fileProbablyWasDeleted:(id)arg1;
- (id)convertLinkToStandardView:(id)arg1;
- (BOOL)isPlaylistOrChannel:(id)arg1;
- (id)getPlaylistId:(id)arg1;
- (id)getVideoId:(id)arg1;
- (BOOL)isValidLink:(NSString*)arg1;
- (id)separationOfLinksByArray:(id)arg1;
- (id)timeLeftToLoadItem:(id)arg1;
- (double)changeProgress:(id)arg1;
- (void)removeProgressInFinderForItem:(id)arg1 kindOfItem:(int)arg2;
- (void)removeProgressInFinderForItem:(id)arg1;
- (void)progressInFinderForItem:(id)arg1 kindOfItem:(int)arg2;
- (void)progressInFinderForItem:(id)arg1;
- (void)refreshDataInRowView:(id)arg1 forItem:(id)arg2;
- (void)refreshDataInDownloadsListForItem:(id)arg1;
- (unsigned long long)rowForDownloadItem:(id)arg1;
- (void)multimediaWasSaved:(id)arg1;
- (id)titlesOfButtonFormatResolution:(id)arg1;
- (void)customWindowAppearance;
- (void)getSummarySizeOfSoundSegmentsForItem:(id)arg1;
- (void)getSummarySizeOfSegmentsForItem:(id)arg1;
- (void)getSizeforItem:(id)arg1 async:(BOOL)arg2;
- (void)startDownloadOfNextSegmentForItem:(id)arg1;
- (void)startDownloadOfNextSoundSegmentForItem:(id)arg1;
- (void)startDownloadOfNextVideo;
- (void)downloadVideo:(id)arg1 forMP3:(BOOL)arg2;
- (void)suspend:(id)arg1;
- (void)suspendDownloadForItem:(id)arg1;
- (void)resume:(id)arg1;
- (void)resumeDownloadForItem:(id)arg1 afterUpdating:(BOOL)arg2;
- (void)resumeDownloadForItem:(id)arg1;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict;
- (id)getDownloadItemByXmlParser:(id)arg1;
- (void)requestOfDownloaditemSubtitleTrack:(id)item;

@end
