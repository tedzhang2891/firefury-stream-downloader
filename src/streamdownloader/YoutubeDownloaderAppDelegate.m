//
//  AppDelegate.m
//  streamdownloader
//
//  Created by ted zhang on 5/18/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "YoutubeDownloaderAppDelegate.h"
#import "EPYoutubeHelper.h"
#import "MainWindowController.h"
#import "LoginYoutubeWindowController.h"
#import "ProcessingLinksWindowController.h"
#import "PreferencesWindowController.h"
#import "ActivationWindowController.h"
#import "AboutWindowController.h"
#import "WelcomeScreenWindowController.h"
#import "DemoReminderWindowController.h"
#import "OfferReminderWindowController.h"
#import "YDUserDefaults.h"
#import "YDActivation.h"
#import "MacActivator.h"
#import "DownloadItem.h"
#import "Utility.h"

#import <ProductionAuthentication/Authentication.h>

@interface YoutubeDownloaderAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation YoutubeDownloaderAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    MainWindowController* mainWindowCtrl = nil;
    NSWindow* mainWindow = nil;
    
    NSApplication* sharedApplication = [NSApplication sharedApplication];
    id delegate = [sharedApplication delegate];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    //[self activate];
    //self.purchaseLink = [self getPurchaseLink];
    if (![self mainWindowController]) {
        mainWindowCtrl = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
        [self setMainWindowController:mainWindowCtrl];
    }
    
    mainWindow = [self.mainWindowController window];
    [mainWindow makeKeyAndOrderFront:mainWindow];
    [mainWindow makeFirstResponder:nil];
    if (![YDUserDefaults welcomeScreenShown]) {
        [delegate showWelcomeScreen];
        [YDUserDefaults setWelcomeScreenShown:YES];
    }
    // FIXME: always show welcome screen
    //[delegate showWelcomeScreen];
    
    if (![ProductController isRegister]) {
        [YDUserDefaults setActivationKey:@"191a961b-bbb7-4803-8ab7-4447457c32d3"];
        [self setIsDemoVersion:YES];
        [delegate setNumberFreeDownloads:2];
        [mainWindowCtrl updateLabelCountDownloads];
        if ([self wasPurchased]) {
            [delegate showOfferReminderWindow];
        }
        
        [self blockLoadingLinks];
        [[mainWindowCtrl tableDownloadList] reloadData];
    }
    else {
        NSString* userKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserKey"];
        [YDUserDefaults setActivationKey:userKey];
        [mainWindowCtrl restoreTheStateOfDownloadsList];
    }
    
    [self performSelector:@selector(checkingLoginToYouTube) withObject:nil afterDelay:0.0];
    [self creatingFilesOfLogging];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [YDUserDefaults setYoutubeSubtitleFormat:@"vtt"];
    
    [EPYoutubeHelper globalInitialization];
    [notificationCenter addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    
    if (![YDUserDefaults noticeOfThirdPartyCopyright]) {
        long long copyright = [self copyrightComplianceOfThirdParty];
        if (copyright == 1001) {
            [sharedApplication terminate:nil];
        }
        else if (copyright == 1000) {
            [YDUserDefaults setNoticeOfThirdPartyCopyright:YES];
        }
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    ;
}


- (id)getPurchaseLink { 
    if (![self.installSource isEqualToString:@"site"]) {
        return @"https://eltima.cleverbridge.com/389/?scope=checkout&cart=143977";
    }
    
    id delegate = [NSApp delegate];
    if (![delegate isDemoVersion]) {
        return @"http://mac.eltima.com/youtube-downloader-purchase.html?utm_source=Streamup&utm_medium=software&utm_campaign=softwaretracking";
    }
    
    if ([YDUserDefaults wasPurchasedPreviously]) {
        return @"http://mac.eltima.com/youtube-downloader-purchase.html?coupon=STREAMUP3-UPG-DR";
    }
    else {
        return @"http://mac.eltima.com/youtube-downloader-purchase.html?utm_source=Streamup&utm_medium=software&utm_campaign=softwaretracking";
    }
}

- (id)appPrice { 
    id delegate = [NSApp delegate];
    double currPrice = [delegate currentPrice];
    double price = 0.0;
    
    if (currPrice == 0.0) {
        price = [self defaultPrice];
    }
    else {
        price = [self currentPrice];
    }
    
    return [NSString stringWithFormat:@"$ %.2f", price];
}

- (void)getCurrentAppPrice { 
    NSCharacterSet* whiteSpace = [NSCharacterSet whitespaceCharacterSet];
    NSString* urlString = [@"http://www.eltima.com/jcontroller/index.php" stringByTrimmingCharactersInSet:whiteSpace];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* mUrlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [mUrlRequest setHTTPMethod:@"POST"];
    [mUrlRequest setTimeoutInterval:5.0];
    
    NSString* requestString = [NSString stringWithFormat:@"ajaxmethod=defaultLicense&product_id=%@", @"142"];
    NSData* requestBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [mUrlRequest setHTTPBody:requestBody];
    
    [[NSURLSession sharedSession] dataTaskWithRequest:mUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSError* requestErr = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&requestErr];
            if (result) {
                double price = [[result objectForKey:@"license_price"] doubleValue];
                [self setCurrentPrice:price];
            }
        }
    }];
}

- (void)deliverNoticeWithText:(id)text {
    if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_8) {
        NSUserNotification* userNotification = [[NSUserNotification alloc] init];
        [userNotification setTitle:@"Streamup"];
        [userNotification setInformativeText:text];
        [userNotification setSoundName:NSUserNotificationDefaultSoundName];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
    }
}

- (BOOL)userNotificationCenter:(id)arg1 shouldPresentNotification:(id)arg2 { 
    return YES;
}

- (long long)copyrightComplianceOfThirdParty { 
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleInformational];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnAgreeTitle", nil)];
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnDeclineTitle", nil)];
    
    anAlert.messageText = NSLocalizedString(@"alertMessageCopyrightCompliance", nil);
    anAlert.informativeText = NSLocalizedString(@"alertInfoCopyrightCompliance", nil);
    
    return [anAlert runModal];
}

- (void)creatingFilesOfLogging {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* err = nil;
    NSURL *temporaryDirectoryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err];
    NSString* temporaryPath = [temporaryDirectoryURL path];
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* bundleInfo = [mainBundle infoDictionary];
    NSString* bundleName = [bundleInfo objectForKey:kCFBundleNameKey];
    NSString* appBundleName = [NSString stringWithFormat:@"Streamup Team/%@", bundleName];
    NSString* appFolder = [temporaryPath stringByAppendingPathComponent:appBundleName];
    
    BOOL bIsDir = NO;
    
    if (![fileManager fileExistsAtPath:appFolder isDirectory:&bIsDir]) {
        err = nil;
        [fileManager createDirectoryAtPath:appFolder withIntermediateDirectories:YES attributes:nil error:&err];
        
        if (err) {
            NSLog(@"Directory was not created: %@", [err localizedDescription]);
        }
    }
    
    NSString* ffmpegout = [appFolder stringByAppendingPathComponent:@"ffmpegout.log"];
    [self setPathToLogFile:ffmpegout];
    if ([fileManager fileExistsAtPath:self.pathToLogFile]) {
        [fileManager removeItemAtPath:self.pathToLogFile error:nil];
    }
    
    [fileManager createFileAtPath:self.pathToLogFile contents:nil attributes:nil];
    [self setLogIsEnabled:[YDUserDefaults loggingIsEnabled]];
    
    NSString* appLog = [appFolder stringByAppendingPathComponent:@"Streamup.log"];
    [self setPathToStreamupLogFile:appLog];
    if ([fileManager fileExistsAtPath:appLog]) {
        [fileManager removeItemAtPath:appLog error:nil];
    }
    
    if ([self logIsEnabled]) {
        [fileManager createFileAtPath:self.pathToStreamupLogFile contents:nil attributes:nil];
    }
    
    NSString* jsLog = [appFolder stringByAppendingPathComponent:@"js.log"];
    if ([fileManager fileExistsAtPath:jsLog]) {
        [fileManager removeItemAtPath:jsLog error:nil];
    }
}

- (void)saveInLogFile:(NSDictionary*)errorInfo {
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    
    if ([YDUserDefaults loggingIsEnabled]) {
        NSString* logFile = [self pathToStreamupLogFile];
        if (![defaultManager fileExistsAtPath:logFile]) {
            [defaultManager createFileAtPath:logFile contents:nil attributes:nil];
        }
        
        DownloadItem* item = [errorInfo objectForKey:@"item"];
        NSError* error = [errorInfo objectForKey:@"error"];
        NSString* pageUrl = nil;
        
        if (error) {
            NSData* data = [NSData data];
            id userInfo = [error userInfo];
            if ([userInfo objectForKey:@"errorReason"]) {
                id errorReason = [userInfo objectForKey:@"errorReason"];
                NSString* logError = [NSString stringWithFormat:@"%@ error: %@", [data description], errorReason];
                [logError writeToFile:logFile atomically:YES encoding:NSUnicodeStringEncoding error:nil];
            }
            else {
                if (![[error domain] isEqualToString:@"HTTP status"]) {
                    NSString* logError = [NSString stringWithFormat:@"%@ error: %@", [data description], [error localizedDescription]];
                    [logError writeToFile:logFile atomically:YES encoding:NSUnicodeStringEncoding error:nil];
                }
            }
            // TODO: continue finish the function
            
        }
    }
}

- (void)logoutOfYoutube { 
    NSHTTPCookieStorage* sharedHttpCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie* cookie in sharedHttpCookieStorage.cookies) {
        [sharedHttpCookieStorage deleteCookie:cookie];
    }
    
    [YDUserDefaults setLoggedInYoutube:NO];
}

- (void)checkingLoginToYouTube { 
    NSHTTPCookieStorage* sharedHttpCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString* cookieString = [NSMutableString stringWithString:@""];
    
    for (NSHTTPCookie* cookie in sharedHttpCookieStorage.cookies) {
        NSRange searchRange = [cookie.domain rangeOfString:@"youtube.com"];
        if (searchRange.location != NSNotFound) {
            NSString* nameAndValue = [NSString stringWithFormat:@"%@=%@;", cookie.name, cookie.value];
            [cookieString appendString:nameAndValue];
        }
    }
    
    NSRange searchRange = [cookieString rangeOfString:@"LOGIN_INFO"];
    if (cookieString.length && searchRange.location != NSNotFound) {
        [YDUserDefaults setLoggedInYoutube:YES];
        [self setCookies:cookieString];
    }
    else if (self.isProVersion || (!self.isProVersion && [self getNumberFreeDownloads])) {
        [YDUserDefaults setLoggedInYoutube:NO];
        if ([Utility showAlertLogInYoutubeIfNeed] == 1000) {
            [self performSelector:@selector(menuLoginOfYoutube:) withObject:self afterDelay:0.0];
        }
    }
    
    [self.mainWindowController.window makeFirstResponder:nil];
}

- (void)showOfferReminderWindow {
    /*
    if (!self.offerriminderWindow) {
        self.offerriminderWindow = [[OfferReminderWindowController alloc] initWithWindowNibName:@"OfferReminderWindowController"];
    }
    
    [self.offerriminderWindow.window center];
    [NSApp runModalForWindow:self.offerriminderWindow.window];
     */
}

- (void)showDemoReminderWindow {
    /*
    if (!self.demoreminderWindow) {
        self.demoreminderWindow = [[DemoReminderWindowController alloc] initWithWindowNibName:@"DemoReminderWindowController"];
    }
    
    [self.demoreminderWindow.window center];
    [NSApp runModalForWindow:self.demoreminderWindow.window];
     */
}

- (void)showWelcomeScreen { 
    if (!self.welcomeScreen) {
        self.welcomeScreen = [[WelcomeScreenWindowController alloc] initWithWindowNibName:@"WelcomeScreenWindowController"];
    }
    
    [self.welcomeScreen.window center];
    [NSApp runModalForWindow:self.welcomeScreen.window];
}

- (void)clearQueuedDownloads:(id)arg1 { 
    [NSApp stopModal];
    id delegate = [NSApp delegate];
    [delegate removeAllQueuedAndSuspendedDownloads];
    [delegate saveDownloadsInUserDefaults];
    [[delegate mainWindowController] updateLabelCountDownloads];
    
    if (![[delegate downloadsList] count]) {
        id mainWindowCtrl = [delegate mainWindowController];
        [[mainWindowCtrl lblInvitation] setHidden:NO];
    }
}

- (void)clearSavedDownloads:(id)arg1 { 
    [NSApp stopModal];
    [self removeAllSavedDownloads];
    
    if (!self.downloadsList.count) {
        [self.mainWindowController.lblInvitation setHidden:NO];
    }
}

- (void)clearAllDownloads:(id)arg1 { 
    [NSApp stopModal];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if ([each connectForDownloadVideo]) {
            [each setVideoFileWasDeleted:YES];
        }
        if ([each connectForDownloadMP3]) {
            [each setAudioFileWasDeleted:YES];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.mainWindowController.queueOfUpdatingLinks cancelAllOperations];
        for (NSTask* task in self.tasksExtractions) {
            if ([task isRunning]) {
                [task terminate];
            }
        }
        if (self.tasksExtractions.count) {
            [self.tasksExtractions removeAllObjects];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            id delegate = [NSApp delegate];
            [delegate removeAllNonActiveDownloads];
            [delegate removeAllActiveDownloadsAndReduceWindowSize:YES];
            [delegate saveDownloadsInUserDefaults];
            [delegate updateLabelCountDownloads];
            
            if (![[delegate downloadsList] count]) {
                id mainWindowCtrl = [delegate mainWindowController];
                [[mainWindowCtrl lblInvitation] setHidden:NO];
            }
        });
    });
}

- (void)clickedCancelButton:(id)arg1 { 
    [NSApp stopModal];
}

- (long long)showAlertClearDownloadsList { 
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleWarning];
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnClearAllTitle", nil)];
    
    if ([self haveSavedItems] && [self currentlyNumberOfActive]) {
        [anAlert addButtonWithTitle:NSLocalizedString(@"btnClearSavedTitle", nil)];
    }
    
    if ([self haveItemsQueuedOrSuspended]) {
        [anAlert addButtonWithTitle:NSLocalizedString(@"btnClearQueuedTitle", nil)];
    }
    
    for (NSButton* btn in anAlert.buttons) {
        [btn setTarget:self];
        if (btn.title == NSLocalizedString(@"btnClearAllTitle", nil)) {
            [btn setAction:@selector(clearAllDownloads:)];
        }
        if (btn.title == NSLocalizedString(@"button_cancel", nil)) {
            [btn setAction:@selector(clickedCancelButton:)];
            [anAlert.window makeFirstResponder:btn];
        }
        if (btn.title == NSLocalizedString(@"btnClearSavedTitle", nil)) {
            [btn setAction:@selector(clearSavedDownloads:)];
        }
        if (btn.title == NSLocalizedString(@"btnClearQueuedTitle", nil)) {
            [btn setAction:@selector(clearQueuedDownloads:)];
        }
    }
    
    anAlert.messageText = NSLocalizedString(@"alertClearDownloadListMessage", nil);
    id delegate = [NSApp delegate];
    
    unsigned long long currNumOfActive = [delegate currentlyNumberOfActive];
    NSString* information = nil;
    if (currNumOfActive == 1) {
        information = [NSString stringWithFormat:NSLocalizedString(@"alertClearDownloadListOneActiveInfo", nil), 1];
    }
    else if (currNumOfActive) {
        information = [NSString stringWithFormat:NSLocalizedString(@"alertClearDownloadListFewActiveInfo", nil), currNumOfActive];
    }
    else {
        information = [NSString stringWithFormat:NSLocalizedString(@"alertClearDownloadListInfo", nil), 0];
    }
    
    anAlert.informativeText = information;
    return [anAlert runModal];
}

- (void)menuHelpStreamup:(id)sender {
    //NSURL* helpUrl = [NSURL URLWithString:@"http://www.firefury.net/"];
    //[[NSWorkspace sharedWorkspace] openURL:helpUrl];
}

- (void)menuShowAboutWindow:(id)sender {
    /*
    if (!self.aboutWindow) {
        self.aboutWindow = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    
    NSWindow* window = self.aboutWindow.window;
    [window center];
    [window makeKeyAndOrderFront:nil];
    [self.aboutWindow showWindow:nil];
    */
}

- (void)menuClearListDownloads:(id)sender {
    if ([self.downloadsList count]) {
        [self showAlertClearDownloadsList];
    }
}

- (void)menuStartDownload:(id)sender {
    [self.mainWindowController buttonDownloadWasClicked:sender];
}

- (void)menuActivate:(id)arg1 {
    /*
    if (!self.activationWindow) {
        self.activationWindow = [[ActivationWindowController alloc] initWithWindowNibName:@"ActivationWindowController"];
    }
    
    [self.activationWindow.window center];
    [NSApp runModalForWindow:self.activationWindow.window];
    */
}

- (void)menuBuyNow:(id)arg1 { 
    id delegate = [NSApp delegate];
    NSString* purchaseLink = [delegate purchaseLink];
    NSURL* purchaseUrl = [NSURL URLWithString:purchaseLink];
    [[NSWorkspace sharedWorkspace] openURL:purchaseUrl];
}

- (void)menuLoginOfYoutube:(id)arg1 { 
    if ([YDUserDefaults loggedInYoutube]) {
        [self logoutOfYoutube];
        [self setCookies:@""];
        self.loginWindow = nil;
    }
    else {
        if (self.loginWindow) {
            self.loginWindow = nil;
        }
        LoginYoutubeWindowController* loginYoutubeWindowCtrl = [[LoginYoutubeWindowController alloc] initWithWindowNibName:@"LoginYoutubeWindowController"];
        self.loginWindow = loginYoutubeWindowCtrl;
        [self.loginWindow showWindow:nil];
    }
}

- (void)menuIntegratedIntoBrowser:(id)arg1 { 
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* intBrowser = [mainBundle pathForResource:@"IntegratedIntoBrowser" ofType:@"html"];
    if (intBrowser) {
        NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
        [sharedWorkspace openURL:[NSURL fileURLWithPath:intBrowser]];
    }
}

- (void)menuShowPreferencesWindow:(id)arg1 { 
    if (!self.preferencesWindow) {
        self.preferencesWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    }
    
    NSWindow* window = [self.preferencesWindow window];
    [window center];
    [window makeKeyAndOrderFront:nil];
    [self.preferencesWindow showWindow:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    if ([item action] == @selector(menuStartDownload:)) {
        if ([self.mainWindowController.allLinks count]) {
            return self.mainWindowController.inProcessParsing;
        }
        return NO;
    }
    
    if ([item action] != @selector(menuClearListDownloads:)) {
        if ([item action] == @selector(menuLoginOfYoutube:)) {
            if ([YDUserDefaults loggedInYoutube]) {
                [item setTitle:NSLocalizedString(@"MainMenu_Streamup_LogoutYoutube", nil)];
            }
            else {
                [item setTitle:NSLocalizedString(@"MainMenu_Streamup_LoginYoutube", nil)];
            }
        }
        return YES;
    }
    
    if (!self.downloadsList) {
        return NO;
    }
    
    return [self.downloadsList count] != 0;
}

- (void)reduceMainWindowSize { 
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    NSInteger count = [downloads count];
    NSWindow* mainWindow = [[delegate mainWindowController] window];
    
    NSRect mainWindowRect;
    NSRect Rect1;
    NSRect Rect2;
    
    CGFloat cy;
    CGFloat high1;
    CGFloat high2;
    
    CGFloat hight = 0.0;
    
    if (mainWindow) {
        mainWindowRect = [mainWindow frame];
    }
    else {
        mainWindowRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    if (!count) {
        mainWindowRect.size = NSMakeSize(482.0, 207.0);
        if (mainWindow) {
            Rect1 = [mainWindow frame];
            Rect2 = [mainWindow frame];
            cy = Rect1.origin.y;
            high1 = Rect1.size.height;
            high2 = Rect1.size.height;
        }
        else {
            Rect1 = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            Rect2 = NSMakeRect(0.0, 0.0, 0.0, 0.0);
            cy = 0.0;
            high1 = 0.0;
            high2 = 207.0;
        }
        mainWindowRect.origin.y = high1 + cy - high2;
        [mainWindow setFrame:mainWindowRect display:YES animate:YES];
    }
    if (count >= 6) {
        mainWindowRect.size.height = 486.0;
        [mainWindow setFrame:mainWindowRect display:YES animate:YES];
    }
    if (count > 0) {
        hight = (mainWindowRect.size.height - ((62 * count - 62) + 207.0)) / 62.0;
        if (mainWindowRect.size.height == 486.0) {
            mainWindowRect.size.height = 455.0;
            mainWindowRect.origin.y += 31.0;
            [mainWindow setFrame:mainWindowRect display:YES animate:YES];
        }
        if (hight > 0) {
            NSUInteger tmpHight = 0;
            while (tmpHight < hight) {
                mainWindowRect.size.height -= 62.0;
                mainWindowRect.origin.y += 62.0;
                [mainWindow setFrame:mainWindowRect display:YES animate:YES];
                tmpHight ++;
            }
        }
    }
    
    [mainWindow setMinSize:NSMakeSize(482.0, 207.0)];
    [mainWindow setMaxSize:mainWindowRect.size];
}

- (void)increaseMainWindowSize {
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    NSInteger count = [downloads count];
    NSWindow* mainWindow = [[delegate mainWindowController] window];
    
    NSRect mainWindowRect;

    CGFloat hight = 0.0;
    int tmpHight = 0;
    
    if (mainWindow) {
        mainWindowRect = [mainWindow frame];
    }
    else {
        mainWindowRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    }
    
    if (count > 0 && count < 6) {
        hight = count + (mainWindowRect.size.height - 207.0) / -62.0;
        if (hight >= 2) {
            mainWindowRect.size.height += 62.0;
            mainWindowRect.origin.y -= 62.0;
            [mainWindow setFrame:mainWindowRect display:YES animate:YES];
            if (hight != 2) {
                tmpHight = 2;
                while (tmpHight < hight) {
                    mainWindowRect.size.height += 62.0;
                    mainWindowRect.origin.y -= 62.0;
                    [mainWindow setFrame:mainWindowRect display:YES animate:YES];
                    tmpHight ++;
                }
            }
        }
    }
    else {
        //hight = mainWindowRect.size.height;
        //mainWindowRect.size.height = 0x407E600000000000LL;
        //mainWindowRect.origin.y -= 486.0 - hight;
        [mainWindow setFrame:mainWindowRect display:YES animate:YES];
    }
    
    [mainWindow setMinSize:NSMakeSize(482.0, 207.0)];
    [mainWindow setMaxSize:mainWindowRect.size];
}

- (unsigned long long)currentlyNumberOfQueued { 
    __block unsigned long long num = 0;
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState] == 2 ||
            [obj currentState] == 7) {
            num ++;
        }
    }];
    
    return num;
}

- (unsigned long long)currentlyNumberOfSuspended { 
    __block unsigned long long num = 0;
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState] == 5 ||
            [obj currentState] == 8) {
            num ++;
        }
    }];
    
    return num;
}

- (unsigned long long)currentlyNumberOfActive {
    __block unsigned long long num = 0;
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState] == 1 ||
            [obj currentState] == 10 ||
            [obj currentState] == 3 ||
            [obj currentState] == 4 ||
            [obj currentState] == 12 ||
            [obj currentState] == 11 ||
            [obj currentState] == 9) {
            num ++;
        }
    }];
    
    return num;
}

- (void)blockLoadingLinks { 
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    [downloads enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj currentState] == 1) {
            [obj setCurrentState:8];
            [[delegate mainWindowController] suspendDownloadForItem:obj];
        }
    }];
}

- (BOOL)haveSavedItems { 
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if (![each currentState]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)haveItemsQueuedOrSuspended { 
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if ([each currentState] == 2 || [each currentState] == 7 || [each currentState] == 5) {
            return YES;
        }
    }
    
    return NO;
}

- (void)removeAllActiveDownloadsAndReduceWindowSize:(BOOL)bUpdate {
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    NSError* error = nil;
    
    for (id each in downloads) {
        if ([each currentState] == 3 || [each currentState] == 4 || [each currentState] == 12 ||
            [each currentState] == 11 || [each currentState] == 9) {
            if ([each connectForDownloadSegment] || [each currentState] == 9) {
                NSString* mimeType = [each mimeType];
                if ([mimeType hasPrefix:@"video"]) {
                    NSOperationQueue* queueOfSavingVideoSegments = [each queueOfSavingVideoSegments];
                    [queueOfSavingVideoSegments cancelAllOperations];
                    [self cancelOfDownloadOfItem:each kindOf:5];
                    [each setVideoFileWasDeleted:YES];
                }
                else if ([mimeType hasPrefix:@"audio"]) {
                    NSOperationQueue* queueOfSavingAudioSegments = [each queueOfSavingAudioSegments];
                    [queueOfSavingAudioSegments cancelAllOperations];
                    [self cancelOfDownloadOfItem:each kindOf:7];
                    [each setAudioFileWasDeleted:YES];
                }
                [indexSet addIndex:[downloads indexOfObject:each]];
                NSString* packagePath = [each pathToPackageOfDownload];
                [defaultManager removeItemAtPath:packagePath error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
            
            if ([each connectForDownloadVideo] || [each currentState] == 3) {
                [each setVideoFileWasDeleted:YES];
                NSOperationQueue* queueOfSavingVideo = [each queueOfSavingVideo];
                [queueOfSavingVideo cancelAllOperations];
                int nType = 0;
                if ([each isVideoDASH]) {
                    NSOperationQueue* queueOfSavingSound = [each queueOfSavingSound];
                    [queueOfSavingSound cancelAllOperations];
                    nType = 1;
                }
                else {
                    nType = 4;
                }
                [self cancelOfDownloadOfItem:each kindOf:nType];
                [indexSet addIndex:[downloads indexOfObject:each]];
                NSString* packagePath = [each pathToPackageOfDownload];
                [defaultManager removeItemAtPath:packagePath error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
            
            if ([each connectForDownloadMP3] || [each currentState] == 4 || [each currentState] == 11 ||
                 [each currentState] == 12) {
                [each setAudioFileWasDeleted:YES];
                NSOperationQueue* queueOfSavingMp3 = [each queueOfSavingMp3];
                [queueOfSavingMp3 cancelAllOperations];
                [self cancelOfDownloadOfItem:each kindOf:3];
                [indexSet addIndex:[downloads indexOfObject:each]];
                NSString* packagePath = [each pathToPackageOfDownload];
                [defaultManager removeItemAtPath:packagePath error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
            
            if ([each currentState] == 10) {
                [indexSet addIndex:[downloads indexOfObject:each]];
                NSString* packagePath = [each pathToPackageOfDownload];
                [defaultManager removeItemAtPath:packagePath error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
        }
    }
    
    [downloads removeObjectsAtIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[delegate mainWindowController] tableDownloadList] reloadData];
        [delegate reduceMainWindowSize];
        [[delegate mainWindowController] updateLabelCountDownloads];
    });
}

- (void)removeAllNonActiveDownloads { 
    [self removeAllBlockedDownloads];
    [self removeAllQueuedAndSuspendedDownloads];
    [self removeAllSavedDownloads];
}

- (void)removeAllQueuedAndSuspendedDownloads {
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if ([each currentState] == 2 || [each currentState] == 7 || [each currentState] == 5) {
            if ([each currentState] == 5) {
                NSString* packagePath = [each pathToPackageOfDownload];
                if (packagePath) {
                    if ([defaultManager fileExistsAtPath:packagePath]) {
                        [defaultManager removeItemAtPath:packagePath error:nil];
                    }
                }
            }
            [indexSet addIndex:[downloads indexOfObject:each]];
        }
    }
    
    [downloads removeObjectsAtIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[delegate mainWindowController] tableDownloadList] reloadData];
        [delegate reduceMainWindowSize];
    });
}

- (void)removeAllQueuedDownloads { 
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if ([each currentState] == 2 || [each currentState] == 7) {
            [indexSet addIndex:[downloads indexOfObject:each]];
        }
    }
    
    [downloads removeObjectsAtIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[delegate mainWindowController] tableDownloadList] reloadData];
        [delegate reduceMainWindowSize];
    });
}

- (void)removeAllBlockedDownloads { 
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if ([each currentState] == 8) {
            NSString* packagePath = [each pathToPackageOfDownload];
            if (packagePath && [defaultManager fileExistsAtPath:packagePath]) {
                [defaultManager removeItemAtPath:packagePath error:nil];
            }
            
            [indexSet addIndex:[downloads indexOfObject:each]];
        }
    }
    
    [[delegate downloadsList] removeObjectsAtIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[delegate mainWindowController] tableDownloadList] reloadData];
        [delegate reduceMainWindowSize];
    });
}

- (void)removeAllSavedDownloads { 
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    
    for (id each in downloads) {
        if (![each currentState]) {
            [indexSet addIndex:[downloads indexOfObject:each]];
        }
    }
    
    [downloads removeObjectsAtIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[delegate mainWindowController] tableDownloadList] reloadData];
        [delegate reduceMainWindowSize];
    });
}

- (void)removeAllUnsavedDownloads {
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    NSFileManager* defaultManager = [NSFileManager defaultManager];
    id delegate = [NSApp delegate];
    NSMutableArray* downloads = [delegate downloadsList];
    NSError* error = nil;
    
    for (id each in downloads) {
        if ([each currentState]) {
            NSString* packagePath = [each pathToPackageOfDownload];
            [defaultManager removeItemAtPath:packagePath error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            [indexSet addIndex:[downloads indexOfObject:each]];
        }
    }
    
    [downloads removeObjectsAtIndexes:indexSet];
    [[[delegate mainWindowController] tableDownloadList] reloadData];
    [delegate reduceMainWindowSize];
}

- (id)getItemByConnection:(NSURLConnection*)conn typeOfItem:(int *)nType {
    NSMutableArray* packet = [self.mainWindowController temporaryPacket];
    for (id each in packet) {
        NSURLConnection* connSubTrack = [each connectGetInfoSubTrack];
        if (conn == connSubTrack) {
            *nType = 0;
            return each;
        }
        
        NSMutableArray* videos = [each videoResources];
        for (id each in videos) {
            NSURLConnection* connGetSize = [each connectForGetSize];
            if (conn == connGetSize) {
                *nType = 0;
                return each;
            }
        }
    }
    
    if (self.downloadsList.count) {
        for (id each in self.downloadsList) {
            NSURLConnection* connDownloadVideo = [each connectForDownloadVideo];
            if (conn == connDownloadVideo) {
                *nType = 3 * ([each isVideoDASH] == 0) + 1;
                return each;
            }
            NSURLConnection* connDownloadSound = [each connectForDownloadSound];
            if (conn == connDownloadSound) {
                *nType = 2;
                return each;
            }
            NSURLConnection* connDownloadMP3 = [each connectForDownloadMP3];
            if (conn == connDownloadMP3) {
                *nType = 3;
                return each;
            }
            NSURLConnection* connDownloadSegment = [each connectForDownloadSegment];
            if (conn == connDownloadSegment) {
                *nType = 2 * ([[each mimeType] hasPrefix:@"video"] == 0) + 5;
                return each;
            }
            NSURLConnection* connDownloadSoundSegment = [each connectForDownloadSoundSegment];
            if (conn == connDownloadSoundSegment) {
                *nType = 6;
                return each;
            }
        }
    }
    
    return nil;
}

- (void)cancelOfDownloadOfItem:(DownloadItem*)item kindOf:(int)category {
    if (item) {
        switch (category) {
            case YD_CATE_MPEG4:
            case YD_CATE_VIDEO_DASH:
                [item.connectForDownloadVideo cancel];
                [item setConnectForDownloadVideo:nil];
                [item setTotalReceivedBytes:0];
                [item setExpectedBytes:0];
                [item setReceivedBytes:0];
                
                if ([item isVideoDASH]) {
                    [item.connectForDownloadVideo cancel];
                    [item setConnectForDownloadSound:nil];
                    [item setTotalReceivedBytesSound:0];
                    [item setExpectedBytesSound:0];
                    [item setReceivedBytesSound:0];
                }
                break;
                
            case YD_CATE_MP3:
                [item.connectForDownloadMP3 cancel];
                [item setConnectForDownloadMP3:nil];
                [item setTotalReceivedBytes:0];
                [item setExpectedBytes:0];
                [item setReceivedBytes:0];
                break;
                
            case YD_CATE_SEGMENT:
            case YD_CATE_SEGMENT2:
                [item.connectForDownloadSegment cancel];
                [item setConnectForDownloadSegment:nil];
                [item setTotalReceivedBytes:0];
                [item setExpectedBytes:0];
                [item setReceivedBytes:0];
                
                if ([item.mimeType hasPrefix:@"video"]) {
                    [item.connectForDownloadSegment cancel];
                    [item setConnectForDownloadSoundSegment:nil];
                    [item setTotalReceivedBytesSound:0];
                    [item setExpectedBytesSound:0];
                    [item setReceivedBytesSound:0];
                }
                break;
            default:
                break;
        }
        
        id delegate = [NSApp delegate];
        if (![delegate isProVersion]) {
            if ([delegate isDemoVersion]) {
                long long numberOfDownloads = [YDUserDefaults numberOfDownloadsFreeVersion];
                [delegate setNumberFreeDownloads:numberOfDownloads + 1];
            }
        }
    }
}

- (void)saveDownloadsInUserDefaults { 
    NSMutableArray* array = [NSMutableArray array];
    id downloadslist = [YDUserDefaults downloadsList];
    
    for (id each in downloadslist) {
        if ([each currentState] == 1) {
            NSString* mimeType = [each mimeType];
            if ([mimeType hasPrefix:@"video"]) {
                NSOperationQueue* queueOfSavingVideo = [each queueOfSavingVideo];
                [queueOfSavingVideo cancelAllOperations];
                [queueOfSavingVideo waitUntilAllOperationsAreFinished];
                
                if ([each isVideoDASH]) {
                    NSOperationQueue* queueOfSavingSound = [each queueOfSavingSound];
                    [queueOfSavingSound cancelAllOperations];
                }
            }
            
            if ([mimeType hasPrefix:@"audio"]) {
                NSOperationQueue* queueOfSavingMp3 = [each queueOfSavingMp3];
                [queueOfSavingMp3 cancelAllOperations];
                [queueOfSavingMp3 waitUntilAllOperationsAreFinished];
            }
        }
        
        [array addObject:[each dictionaryRepresentation]];
    }
    
    [YDUserDefaults setDownloadsList:array];
}

- (void)getListOfDownloadableVideos { 
    id downloadslist = [YDUserDefaults downloadsList];
    if (downloadslist) {
        for (id each in downloadslist) {
            [self.downloadsList addObject:each];
        }
    }
}

- (void)setNumberFreeDownloads:(long long)num {
    long long numberOfDownloads = 2;
    if (num < 3) {
        numberOfDownloads = num;
    }
    
    long long numberOfFreeDownloads = 0;
    if (num > 0) {
        numberOfFreeDownloads = numberOfDownloads;
    }
    [YDUserDefaults setNumberOfDownloadsFreeVersion:numberOfFreeDownloads];
    
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id delegate = [NSApp delegate];
    [NSArchiver archiveRootObject:[standardUserDefaults objectForKey:@"FreeVersionDownloads"] toFile:[delegate dataFile1]];
}

- (long long)getNumberFreeDownloads { 
    long long numberOfDownloads = [YDUserDefaults numberOfDownloadsFreeVersion];
    id delegate = [NSApp delegate];
    id data = [NSUnarchiver unarchiveObjectWithFile:[delegate dataFile1]];
    if (data) {
        NSInteger dataValue = [[NSUnarchiver unarchiveObjectWithData:data] integerValue];
        
        if (numberOfDownloads != dataValue) {
            [YDUserDefaults setNumberOfDownloadsFreeVersion:dataValue];
            numberOfDownloads = dataValue;
        }
    }
    
    return numberOfDownloads;
}

- (void)showAlertNeedReactivation { 
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleCritical];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
    NSButton* firstBtn = [anAlert buttons][0];
    [firstBtn setKeyEquivalent:@"\r"];
    
    anAlert.messageText = NSLocalizedString(@"alertReactivateMessage", nil);
    anAlert.informativeText = NSLocalizedString(@"alertReactivateInfo", nil);;
    
    [anAlert runModal];
}

#if 0
- (void)activationFailedFor:(id)arg1 withError:(int)errCode {
    id activeKey = [YDUserDefaults activationKey];
    if (![activeKey isEqualToString:@"191a961b-bbb7-4803-8ab7-4447457c32d3"] && errCode <= 12) {
        int mask = 2082;
        // FIXME:
        if (1) {
            [self setIsProVersion:NO];
            [self setIsDemoVersion:YES];
            [YDActivation setActivationCode:@"191a961b-bbb7-4803-8ab7-4447457c32d3"];
        }
        else {
            mask = 4352;
            if (!1) {
                return;
            }
        }
        
        if ((errCode | 4) == 12) {
            [YDActivation setActivationCode:activeKey];
        }
        if (errCode != 5 && !self->alertReactivationAlreadyShown) {
            [self showAlertNeedReactivation];
            self->alertReactivationAlreadyShown = YES;
        }
    }
}

- (void)activationSuccessful:(MacActivator*)activator {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    id activationInfo = [activator activationInfo];
    int keyValue = [[activationInfo objectForKey:@"key_type"] intValue];
    [self setKeyType:keyValue];
    
    if (![self keyType]) {
        [self setIsDemoVersion:NO];
        [self setIsProVersion:YES];
    }
    
    if ([self keyType] == 2) {
        int demoDaysLeft = [activator demoDaysLeft];
        [self setDaysLeft:demoDaysLeft];
    }
    
    [defaultCenter postNotificationName:@"ActivationInfoDidChange" object:nil];
}

- (void)activate {
    id activeKey = [YDUserDefaults activationKey];
    [YDActivation setActivationCode:activeKey];
    
    if (![self isProVersion]) {
        NSLog(@"FREE Version!");
    }
}

#endif

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSWindow* mainWindow = [self.mainWindowController window];
    [mainWindow makeFirstResponder:nil];
    unsigned long long currentNum = [self currentlyNumberOfActive];
    
    if (![YDUserDefaults optionDontAskAgainWhenAppTerminated] && (currentNum || [self.mainWindowController inProcessParsing])) {
        NSAlert* anAlert = [[NSAlert alloc] init];
        [anAlert setAlertStyle:NSAlertStyleWarning];
        anAlert.messageText = NSLocalizedString(@"alertTerminateMessage", nil);
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_yes", nil)];
        [anAlert addButtonWithTitle:NSLocalizedString(@"button_no", nil)];
        [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_ask", nil)];
        
        unsigned long long currNumOfActive = [self currentlyNumberOfActive];
        unsigned long long currNumOfQueued = [self currentlyNumberOfQueued];
        unsigned long long currNumOfSuspended = [self currentlyNumberOfSuspended];
        
        NSString* information = nil;
        if ([self.mainWindowController inProcessParsing]) {
            information = NSLocalizedString(@"alertTerminateParsingInfo", nil);
        }
        else {
            NSString* format = NSLocalizedString(@"alertTerminateDownloadInfo", nil);
            information = [NSString stringWithFormat:format, currNumOfActive + currNumOfQueued, currNumOfSuspended];
        }
        anAlert.informativeText = information;
        
        NSUInteger action = [anAlert runModal];
        if (action == NSAlertFirstButtonReturn) {
            if ([self.mainWindowController inProcessParsing]) {
                ProcessingLinksWindowController* processingWindowCtrl = [self.mainWindowController processingWindow];
                [processingWindowCtrl buttonCancelWasClicked:nil];
            }
            
            [self saveDownloadsInUserDefaults];
            [EPYoutubeHelper globalCleaning];
            [NSApp replyToApplicationShouldTerminate:YES];
        }
        else {
            [NSApp replyToApplicationShouldTerminate:NO];
        }
        
        [YDUserDefaults setOptionDontAskAgainWhenAppTerminated:[anAlert.suppressionButton state]];
    }
    else {
        if ([self.mainWindowController inProcessParsing]) {
            ProcessingLinksWindowController* processingWindowCtrl = [self.mainWindowController processingWindow];
            [processingWindowCtrl buttonCancelWasClicked:nil];
        }
        [self saveDownloadsInUserDefaults];
        [EPYoutubeHelper globalCleaning];
        [NSApp replyToApplicationShouldTerminate:YES];
    }
    
    return NSTerminateLater;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    NSWindow* mainWindow = [self.mainWindowController window];
    [mainWindow makeKeyAndOrderFront:self];
    return flag;
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    if (!self.mainWindowController) {
        self.mainWindowController = [[MainWindowController alloc] init];
    }
    
    NSString* desc = [[event descriptorForKeyword:'----'] stringValue];
    NSRange range = [desc rangeOfString:@"Streamup://"];
    NSString* bookmarkUrl = [desc substringFromIndex:range.location];
    [self setBookmarkUrl:bookmarkUrl];
    
    NSWindow* mainWindow = [self.mainWindowController window];
    [mainWindow makeKeyAndOrderFront:nil];
    if ([mainWindow isVisible]) {
        NSDictionary* bookmarkDict = @{@"url": bookmarkUrl};
        [defaultCenter postNotificationName:@"BookmarkWithUrl" object:nil userInfo:bookmarkDict];
    }
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSApplication* sharedApplication = [NSApplication sharedApplication];
    NSAppleEventManager* sharedEventManager = [NSAppleEventManager sharedAppleEventManager];
    NSError* err = nil;
    
    NSURL *temporaryDirectoryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err];
    NSString* urlPath = [temporaryDirectoryURL path];
    NSString* preferencesPath = [urlPath stringByAppendingPathComponent:@"Preferences"];
    NSString* dataFile1 = [preferencesPath stringByAppendingPathComponent:@".4r81w6xkz"];
    [self setDataFile1:dataFile1];
    
    BOOL bDataFile1Exists = [fileManager fileExistsAtPath:dataFile1];
    long long downloadNum = 0;
    if (![standardUserDefaults objectForKey:@"FreeVersionDownloads"]) {
        if (!bDataFile1Exists) {
            downloadNum = 2;
        }
        else {
            id delegate = [sharedApplication delegate];
            id data = [NSUnarchiver unarchiveObjectWithFile:[delegate dataFile1]];
            if ([data isKindOfClass:[NSMutableDictionary class]]) {
                [fileManager removeItemAtPath:dataFile1 error:nil];
                downloadNum = 2;
            }
        }
    }
    else {
        if (bDataFile1Exists || [YDUserDefaults numberOfDownloadsFreeVersion] >= 0) {
            downloadNum = [self getNumberFreeDownloads];
        }
        else {
            downloadNum = 0;
        }
    }
    [self setNumberFreeDownloads:downloadNum];
    
    if (![YDUserDefaults currentUserPreferences]) {
        NSString* downloadsFolder = [urlPath stringByAppendingPathComponent:@"FireFury"];
        NSNumber* askWhereSaveFile = [NSNumber numberWithBool:NO];
        NSDictionary* appInfo = @{@"PathToDownloadsFolder":downloadsFolder, @"AskWhereSaveFile":askWhereSaveFile };
        [YDUserDefaults setCurrentUserPreferences:appInfo];
    }
    
    [self getListOfDownloadableVideos];
    [sharedEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:'GURL' andEventID:'GURL'];
}

- (void)windowWillClose:(NSNotification *)aNotification {
    id object = [aNotification object];
    LoginYoutubeWindowController* loginWindow = self.loginWindow;
    if (object == [loginWindow window]) {
        [loginWindow setWindow:nil];
    }
}

- (id)init { 
    if (self = [super init]) {
        self.downloadsList = [[NSMutableArray alloc] init];
        self.appTermination = 0;
        self.tasksExtractions = [[NSMutableArray alloc] init];
        self.defaultPrice = 19.95;
        self->alertReactivationAlreadyShown = NO;
        [self getCurrentAppPrice];
        
        
        // Add for replace about window and register window
        if (self->productController == nil) {
            self->productController = [[ProductController alloc] init];
        }
    }
    
    return self;
}

- (NSString*)installSource {
    NSString* installSrc = [YDUserDefaults installationSource];
    if (installSrc == nil) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        id ydSrc = [mainBundle objectForInfoDictionaryKey:@"YDSource"];
        installSrc = @"site";
        
        if ([ydSrc length]) {
            installSrc = (NSString*)ydSrc;
        }
        [YDUserDefaults setInstallationSource:installSrc];
    }
    
    return self.installSource;
}

@end
