//
//  AppDelegate.h
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class LoginYoutubeWindowController, MainWindowController, PreferencesWindowController, WelcomeScreenWindowController, ProductController;

@interface YoutubeDownloaderAppDelegate : NSObject <NSApplicationDelegate, NSAlertDelegate, NSUserNotificationCenterDelegate>
{
    BOOL alertReactivationAlreadyShown;
    ProductController *productController;
}

@property(retain, nonatomic) NSString *purchaseLink; // @synthesize purchaseLink;
@property(nonatomic) BOOL wasPurchased; // @synthesize wasPurchased=_wasPurchased;
@property(retain, nonatomic) NSMutableArray *tasksExtractions; // @synthesize tasksExtractions=_tasksExtractions;
@property(nonatomic) BOOL appTermination; // @synthesize appTermination=_appTermination;
@property(retain, nonatomic) NSString *bookmarkUrl; // @synthesize bookmarkUrl=_bookmarkUrl;
@property(retain) NSString *cookies; // @synthesize cookies=_cookies;
@property(nonatomic) int daysLeft; // @synthesize daysLeft=_daysLeft;
@property(nonatomic) int keyType; // @synthesize keyType=_keyType;
@property(nonatomic) int maxFreeDownloads; // @synthesize maxFreeDownloads=_maxFreeDownloads;
@property(nonatomic) int activationErrorCode; // @synthesize activationErrorCode=_activationErrorCode;
@property(nonatomic) BOOL isProVersion; // @synthesize isProVersion=_isProVersion;
@property(nonatomic) BOOL isDemoVersion; // @synthesize isDemoVersion=_isDemoVersion;
@property(retain, nonatomic) NSMutableArray *downloadsList; // @synthesize downloadsList=_downloadsList;
@property(retain, nonatomic) NSString *pathToLogFile; // @synthesize pathToLogFile=_pathToLogFile;
@property(retain, nonatomic) NSString *pathToStreamupLogFile; // @synthesize pathToStreamupLogFile=_pathToStreamupLogFile;
@property(nonatomic) BOOL logIsEnabled; // @synthesize logIsEnabled=_logIsEnabled;
@property(retain, nonatomic) NSString *dataFile1; // @synthesize dataFile1=_dataFile1;
@property(nonatomic) double currentPrice; // @synthesize currentPrice=_currentPrice;
@property(nonatomic) double defaultPrice; // @synthesize defaultPrice=_defaultPrice;
@property(retain, nonatomic) WelcomeScreenWindowController *welcomeScreen; // @synthesize welcomeScreen=_welcomeScreen;
//@property(retain, nonatomic) OfferReminderWindowController *offerriminderWindow; // @synthesize offerriminderWindow=_offerriminderWindow;
//@property(retain, nonatomic) DemoReminderWindowController *demoreminderWindow; // @synthesize demoreminderWindow=_demoreminderWindow;
//@property(retain, nonatomic) AboutWindowController *aboutWindow; // @synthesize aboutWindow=_aboutWindow;
@property(retain, nonatomic) PreferencesWindowController *preferencesWindow; // @synthesize preferencesWindow=_preferencesWindow;
@property(retain, nonatomic) LoginYoutubeWindowController *loginWindow; // @synthesize loginWindow=_loginWindow;
//@property(retain, nonatomic) ActivationWindowController *activationWindow; // @synthesize activationWindow=_activationWindow;
@property(retain, nonatomic) MainWindowController *mainWindowController; // @synthesize mainWindowController=_mainWindowController;
@property(retain, nonatomic) NSString *installSource; // @dynamic installSource;

- (id)getPurchaseLink;
- (id)appPrice;
- (void)getCurrentAppPrice;
- (void)deliverNoticeWithText:(id)arg1;
- (BOOL)userNotificationCenter:(id)arg1 shouldPresentNotification:(id)arg2;
- (long long)copyrightComplianceOfThirdParty;
- (void)creatingFilesOfLogging;
- (void)saveInLogFile:(id)arg1;
- (void)logoutOfYoutube;
- (void)checkingLoginToYouTube;
- (void)showOfferReminderWindow;
- (void)showDemoReminderWindow;
- (void)showWelcomeScreen;
- (void)clearQueuedDownloads:(id)arg1;
- (void)clearSavedDownloads:(id)arg1;
- (void)clearAllDownloads:(id)arg1;
- (void)clickedCancelButton:(id)arg1;
- (long long)showAlertClearDownloadsList;
- (void)menuHelpStreamup:(id)arg1;
- (void)menuShowAboutWindow:(id)arg1;
- (void)menuClearListDownloads:(id)arg1;
- (void)menuStartDownload:(id)arg1;
- (void)menuActivate:(id)arg1;
- (void)menuBuyNow:(id)arg1;
- (void)menuLoginOfYoutube:(id)arg1;
- (void)menuIntegratedIntoBrowser:(id)arg1;
- (void)menuShowPreferencesWindow:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;
- (void)reduceMainWindowSize;
- (void)increaseMainWindowSize;
- (unsigned long long)currentlyNumberOfQueued;
- (unsigned long long)currentlyNumberOfSuspended;
- (unsigned long long)currentlyNumberOfActive;
- (void)blockLoadingLinks;
- (BOOL)haveSavedItems;
- (BOOL)haveItemsQueuedOrSuspended;
- (void)removeAllActiveDownloadsAndReduceWindowSize:(BOOL)arg1;
- (void)removeAllNonActiveDownloads;
- (void)removeAllQueuedAndSuspendedDownloads;
- (void)removeAllQueuedDownloads;
- (void)removeAllBlockedDownloads;
- (void)removeAllSavedDownloads;
- (void)removeAllUnsavedDownloads;
- (id)getItemByConnection:(id)arg1 typeOfItem:(int *)arg2;
- (void)cancelOfDownloadOfItem:(id)item kindOf:(int)category;
- (void)saveDownloadsInUserDefaults;
- (void)getListOfDownloadableVideos;
- (void)setNumberFreeDownloads:(long long)arg1;
- (long long)getNumberFreeDownloads;
- (void)showAlertNeedReactivation;
//- (void)activationFailedFor:(id)arg1 withError:(int)arg2;
//- (void)activationSuccessful:(id)arg1;
//- (void)activate;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag;;
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
- (void)applicationWillFinishLaunching:(id)arg1;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)windowWillClose:(NSNotification *)aNotification;
- (id)init;


@end

