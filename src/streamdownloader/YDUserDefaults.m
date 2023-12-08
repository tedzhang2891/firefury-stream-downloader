//
//  YDUserDefaults.m
//  streamdownloader
//
//  Created by ted zhang on 2018/5/19.
//  Copyright © 2018年 firefury. All rights reserved.
//

#import "YDUserDefaults.h"

@implementation YDUserDefaults

+ (BOOL)loggingIsEnabled { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"EnableLog"];
}

+ (void)resetAllDontAskMeAgainOptions { 
    [self setOptionDontAskAgainCancelDownloads:NO];
    [self setOptionDontAskAgainWhenAppTerminated:NO];
    [self setOptionDontShowAgainWhenFailedConnection:NO];
    [self setOptionRememberChoiceForVideoPartOfPlaylist:NO];
    [self setOptionDontAskAgainLogInYoutube:NO];
}

+ (BOOL)allowsSendStatistics { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"SendStatistics"];
}

+ (void)setYoutubeSubtitleFormat:(id)subtitles {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:subtitles forKey:@"SubtitlesFormat"];
}

+ (id)youtubeSubtitlesFormat { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"SubtitlesFormat"];
}

+ (void)setOptionDontAskAgainLogInYoutube:(BOOL)bAskAgainLogIn {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bAskAgainLogIn forKey:@"DontAskAgainLogInYoutube"];
}

+ (BOOL)optionDontAskAgainLogInYoutube { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"DontAskAgainLogInYoutube"];
}

+ (void)setLoggedInYoutube:(BOOL)bLogged {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bLogged forKey:@"UserLoggedInYoutube"];
}

+ (BOOL)loggedInYoutube { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"UserLoggedInYoutube"];
}

+ (void)setOptionRememberChoiceForVideoPartOfPlaylist:(BOOL)bState { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bState forKey:@"StateOfButtonRememberChoice"];
}

+ (BOOL)optionRememberChoiceForVideoPartOfPlaylist { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"StateOfButtonRememberChoice"];
}

+ (void)setChoiceDownloadCompletePlaylistOrVideoOnly:(long long)bDownloadingList { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:bDownloadingList forKey:@"DownloadingVideoOrPlaylist"];
}

+ (long long)choiceDownloadCompletePlaylistOrVideoOnly { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults integerForKey:@"DownloadingVideoOrPlaylist"];
}

+ (void)setOptionDontAskAgainWhenAppTerminated:(BOOL)bAskAgainWhenAppTerminated { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bAskAgainWhenAppTerminated forKey:@"DontAskAgainWhenAppTerminated"];
}

+ (BOOL)optionDontAskAgainWhenAppTerminated { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"DontAskAgainWhenAppTerminated"];
}

+ (void)setOptionDontShowAgainWhenUpdateError:(BOOL)bShowAgainWhenUpdateError { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bShowAgainWhenUpdateError forKey:@"DontShowAgainWhenUpdateError"];
}

+ (BOOL)optionDontShowAgainWhenUpdateError { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"DontShowAgainWhenFailedConnection"];
}

+ (void)setOptionDontShowAgainWhenFailedConnection:(BOOL)bShowAgainWhenFailedConnection { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bShowAgainWhenFailedConnection forKey:@"DontShowAgainWhenFailedConnection"];
}

+ (BOOL)optionDontShowAgainWhenFailedConnection { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"DontShowAgainWhenFailedConnection"];
}

+ (void)setOptionDontAskAgainCancelDownloads:(BOOL)bAskAgain { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bAskAgain forKey:@"DontAskAgainMeCancelDownloads"];
}

+ (BOOL)optionDontAskAgainCancelDownloads { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"DontAskAgainMeCancelDownloads"];
}

+ (void)setLastSelectedFormatResolution:(id)selectedFR { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:selectedFR forKey:@"LastSelectedFormatResolution"];
}

+ (id)lastSelectedFormatResolution { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"LastSelectedFormatResolution"];
}

+ (void)setDownloadsList:(id)downloads {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:downloads forKey:@"DownloadsList"];
}

+ (id)downloadsList { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"DownloadsList"];
}

+ (void)setCurrentUserPreferences:(id)userPrePerences { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:userPrePerences forKey:@"CurrentUserPreferences"];
}

+ (id)currentUserPreferences { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"CurrentUserPreferences"];
}

+ (void)setNumberOfDownloadsFreeVersion:(long long)num {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* numDownloads = [NSNumber numberWithInteger:num];
    NSData* downloads = [NSArchiver archivedDataWithRootObject:numDownloads];
    [standardUserDefaults setObject:downloads forKey:@"FreeVersionDownloads"];
}

+ (long long)numberOfDownloadsFreeVersion { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id freeVersionDownloads = [standardUserDefaults objectForKey:@"FreeVersionDownloads"];
    
    if (![freeVersionDownloads isKindOfClass:[NSData class]]) {
        return -1;
    }
    
    id unarchiver = [NSUnarchiver unarchiveObjectWithData:freeVersionDownloads];
    return [unarchiver integerValue];
}

+ (void)setWelcomeScreenShown:(BOOL)bWelcome {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bWelcome forKey:@"WelcomeScreenAlreadeShown"];
}

+ (BOOL)welcomeScreenShown { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"WelcomeScreenAlreadeShown"];
}

+ (void)setInstallationSource:(id)source {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:source forKey:@"YDSource"];
}

+ (NSString*)installationSource { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"YDSource"];
}

+ (void)setPurchaseLicenseLink:(id)purchaseLink { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:purchaseLink forKey:@"PurchaseLicenseLink"];
}

+ (id)purchaseLicenseLink { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"PurchaseLicenseLink"];
}

+ (void)setWasPurchasedPreviously:(BOOL)bPurchasedPreviously { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* numPurchasedPreviously = [NSNumber numberWithBool:bPurchasedPreviously];
    NSData* archiver = [NSArchiver archivedDataWithRootObject:numPurchasedPreviously];
    [standardUserDefaults setObject:archiver forKey:@"WasPurchasedPreviousVersion"];
}

+ (BOOL)wasPurchasedPreviously { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id purchasedPreviousVer = [standardUserDefaults objectForKey:@"WasPurchasedPreviousVersion"];
    if (![purchasedPreviousVer isKindOfClass:[NSData class]]) {
        return NO;
    }
    
    id unarchiver = [NSUnarchiver unarchiveObjectWithData:purchasedPreviousVer];
    return [unarchiver boolValue];
}

+ (void)setLicenseName:(id)licenseName {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:licenseName forKey:@"LicenseName"];
}

+ (id)licenseName { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"LicenseName"];
}

+ (void)setRegisteredName:(id)registeredName { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:registeredName forKey:@"RegisteredName"];
}

+ (id)registeredName { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:@"RegisteredName"];
}

+ (void)setActivationKey:(id)activeionKey { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:activeionKey forKey:@"ActivationKey"];
}

+ (id)activationKey { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults valueForKey:@"ActivationKey"];
}

+ (void)setNoticeOfThirdPartyCopyright:(BOOL)bCopyright { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:bCopyright forKey:@"CopyrightComplianceOfThirdParty"];
}

+ (BOOL)noticeOfThirdPartyCopyright { 
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults boolForKey:@"CopyrightComplianceOfThirdParty"];
}

+ (void)initialize { 
    NSNumber* numStatistics = [NSNumber numberWithBool:YES];
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* sendStatistics = @"SendStatistics";
    
    NSDictionary* dictStatistics = @{numStatistics: sendStatistics};
    [standardUserDefaults registerDefaults:dictStatistics];
}

@end
