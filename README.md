# FireFury Stream Downloader

Enjoy your YouTube videos and music even when offline! FireFury Stream Downloader can download YouTube videos in MP4, 3GP, FLV formats. It supports HD and Ultra HD videos perfectly well. With Airy you can easily convert YouTube videos to MP3.

### How to use

**DRM Removal For Audio** exposes a set of interfaces for client to use and all interations with iTunes are done internally, which are transparent to the client.

```objectivec
//FireFury Stream Downloader

@class DSImageButton, DSImagePopUpButton, NSAlert, NSMutableArray, NSMutableDictionary, NSOperationQueue, NSProgressIndicator, NSScrollView, NSString, NSTableView, NSTextField, NSView, PageUrlTextView, PatternBackgroundView, ProcessingLinksWindowController, YDHorizontalLine;

@interface MainWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSURLConnectionDelegate, NSXMLParserDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, MouseDownTextFieldDelegate>
{
    NSOperationQueue *_queueReceiveLinks;
    NSOperationQueue *_queueReceivePlaylist;
    NSOperationQueue *_queueOfUpdatingLinks;
    BOOL _isProVersion;
    BOOL _needSignIn;
    NSMutableArray *_allLinks;
    NSMutableArray *_temporaryPacket;
    NSMutableDictionary *_cachedImages;
    unsigned long long httpStatusCode;
    long long quantityPlaylists;
    NSMutableArray *_appstaticoIfo;
    NSView *_mainView;
    PageUrlTextView *_txtVideoUrl;
    PatternBackgroundView *_viewUnderVideoUrl;
    NSTextField *_lblInvitation;
    DSImageButton *_btnDownload;
    DSImagePopUpButton *_btnResolutions;
    YDHorizontalLine *_horizontalLine;
    NSScrollView *_scrollView;
    NSTableView *_tableDownloadList;
    NSTextField *_lblCountDownloads;
    NSProgressIndicator *_progressDownload;
    ProcessingLinksWindowController *_processingWindow;
    BOOL _inProcessParsing;
    BOOL _parsingCanceled;
    NSAlert *_alertConnectionLost;
    NSAlert *_alertconnectionOffline;
    BOOL alertFileWasDeletedAlreadyShown;
}

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
@property(nonatomic) NSProgressIndicator *progressDownload; // @synthesize progressDownload=_progressDownload;
@property(nonatomic) NSScrollView *scrollView; // @synthesize scrollView=_scrollView;
@property(nonatomic) YDHorizontalLine *horizontalLine; // @synthesize horizontalLine=_horizontalLine;
@property(nonatomic) NSTextField *lblCountDownloads; // @synthesize lblCountDownloads=_lblCountDownloads;
@property(nonatomic) NSTableView *tableDownloadList; // @synthesize tableDownloadList=_tableDownloadList;
@property(nonatomic) DSImagePopUpButton *btnResolutions; // @synthesize btnResolutions=_btnResolutions;
@property(nonatomic) DSImageButton *btnDownload; // @synthesize btnDownload=_btnDownload;
@property(nonatomic) PatternBackgroundView *viewUnderVideoUrl; // @synthesize viewUnderVideoUrl=_viewUnderVideoUrl;
@property(nonatomic) PageUrlTextView *txtVideoUrl; // @synthesize txtVideoUrl=_txtVideoUrl;
@property(nonatomic) NSTextField *lblInvitation; // @synthesize lblInvitation=_lblInvitation;
@property(nonatomic) NSView *mainView; // @synthesize mainView=_mainView;
- (BOOL)userNotificationCenter:(id)arg1 shouldPresentNotification:(id)arg2;
- (void)updatingWhenActivationInfoChanged;
- (void)registerOtherNotificationMessages;
- (void)assignmentValueNeedSignIn;
- (void)bookmarkWithUrl:(id)arg1;
- (void)actionOfContextMenuForDownloadList:(id)arg1;
- (id)contextualMenuForTableView:(id)arg1 withClickedRow:(long long)arg2;
- (id)tableView:(id)arg1 rowViewForRow:(long long)arg2;
- (id)tableView:(id)arg1 viewForTableColumn:(id)arg2 row:(long long)arg3;
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
- (void)buttonResolutionSelectionWasChanged:(id)arg1;
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
- (void)buttonDownloadWasClicked:(id)arg1;
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
- (void)dealloc;
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
- (long long)determineFreeSpaceOnDevice:(id)arg1 withError:(id *)arg2;
- (BOOL)updateErrorForItem:(id)arg1;
- (void)noSpaceLeftOnDevice:(id)arg1;
- (void)deviceNotConfiguredWhenLoading;
- (void)fileProbablyWasDeleted:(id)arg1;
- (id)convertLinkToStandardView:(id)arg1;
- (BOOL)isPlaylistOrChannel:(id)arg1;
- (id)getPlaylistId:(id)arg1;
- (id)getVideoId:(id)arg1;
- (BOOL)isValidLink:(id *)arg1;
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
- (void)parser:(id)arg1 didEndElement:(id)arg2 namespaceURI:(id)arg3 qualifiedName:(id)arg4;
- (void)parser:(id)arg1 foundCharacters:(id)arg2;
- (void)parser:(id)arg1 didStartElement:(id)arg2 namespaceURI:(id)arg3 qualifiedName:(id)arg4 attributes:(id)arg5;
- (id)getDownloadItemByXmlParser:(id)arg1;
- (void)requestOfDownloaditemSubtitleTrack:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
```

### How to contribute

**Gathering context**

Before doing anything, do a quick check to make sure your idea hasn’t been discussed elsewhere. Skim the project’s README, issues (open and closed), mailing list, and Stack Overflow. You don’t have to spend hours going through everything, but a quick search for a few key terms goes a long way.

If you can’t find your idea elsewhere, you’re ready to make a move. You’ll likely communicate by opening an issue or pull request:

* Issues are like starting a conversation or discussion
* Pull requests are for starting work on a solution
* For lightweight communication, such as a clarifying or how-to question, try asking on Stack Overflow, IRC, Slack, or other chat channels, if the project has one

Before you open an issue or pull request, check the project’s contributing docs (usually a file called CONTRIBUTING, or in the README), to see whether you need to include anything specific. For example, they may ask that you follow a template, or require that you use tests.

If you want to make a substantial contribution, open an issue to ask before working on it. It’s helpful to watch the project for a while, and get to know community members, before doing work that might not get accepted.

**Opening an issue**

You should usually open an issue in the following situations:

* Report an error you can’t solve yourself
* Discuss a high-level topic or idea (for example, community, vision or policies)
* Propose a new feature or other project idea

Tips for communicating on issues:

* If you see an open issue that you want to tackle, comment on the issue to let people know you’re on it. That way, people are less likely to duplicate your work.
* If an issue was opened a while ago, it’s possible that it’s being addressed somewhere else, or has already been resolved, so comment to ask for confirmation before starting work.
* If you opened an issue, but figured out the answer later on your own, comment on the issue to let people know, then close the issue. Even documenting that outcome is a contribution to the project.

**Opening a pull request**

You should usually open a pull request in the following situations:

* Submit trivial fixes (for example, a typo, a broken link or an obvious error)
* Start work on a contribution that was already asked for, or that you’ve already discussed, in an issue

A pull request doesn’t have to represent finished work. It’s usually better to open a pull request early on, so others can watch or give feedback on your progress. Just mark it as a “WIP” (Work in Progress) in the subject line. You can always add more commits later.

Here’s how to submit a pull request:

* Fork the repository and clone it locally. Connect your local to the original “upstream” repository by adding it as a remote. Pull in changes from “upstream” often so that you stay up to date so that when you submit your pull request, merge conflicts will be less likely. (See more detailed instructions here.)
* Create a branch for your edits.
* Reference any relevant issues or supporting documentation in your PR (for example, “Closes #37.”)
* Include screenshots of the before and after if your changes include differences in HTML/CSS. Drag and drop the images into the body of your pull request.
* Test your changes! Run your changes against any existing tests if they exist and create new ones when needed. Whether tests exist or not, make sure your changes don’t break the existing project.
* Contribute in the style of the project to the best of your abilities. This may mean using indents, semi-colons or comments differently than you would in your own repository, but makes it easier for the maintainer to merge, others to understand and maintain in the future.

### Support or Contact

Having trouble with Pages? Check out project [wiki](https://bitbucket.org/tedzhang2891/injectorhelper/wiki/Home) or contact me via email (tedzhang2891@gmail.com) and I’ll help you sort it out.
