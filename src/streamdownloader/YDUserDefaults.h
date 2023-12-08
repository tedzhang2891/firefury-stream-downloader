//
//  YDUserDefaults.h
//  streamdownloader
//
//  Created by ted zhang on 2018/5/19.
//  Copyright © 2018年 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDUserDefaults : NSObject
{
}

+ (BOOL)loggingIsEnabled;
+ (void)resetAllDontAskMeAgainOptions;
+ (BOOL)allowsSendStatistics;
+ (void)setYoutubeSubtitleFormat:(id)subtitles;
+ (id)youtubeSubtitlesFormat;
+ (void)setOptionDontAskAgainLogInYoutube:(BOOL)bAskAgainLogIn;
+ (BOOL)optionDontAskAgainLogInYoutube;
+ (void)setLoggedInYoutube:(BOOL)bLogged;
+ (BOOL)loggedInYoutube;
+ (void)setOptionRememberChoiceForVideoPartOfPlaylist:(BOOL)bState;
+ (BOOL)optionRememberChoiceForVideoPartOfPlaylist;
+ (void)setChoiceDownloadCompletePlaylistOrVideoOnly:(long long)bDownloadingList;
+ (long long)choiceDownloadCompletePlaylistOrVideoOnly;
+ (void)setOptionDontAskAgainWhenAppTerminated:(BOOL)bAskAgainWhenAppTerminated;
+ (BOOL)optionDontAskAgainWhenAppTerminated;
+ (void)setOptionDontShowAgainWhenUpdateError:(BOOL)bShowAgainWhenUpdateError;
+ (BOOL)optionDontShowAgainWhenUpdateError;
+ (void)setOptionDontShowAgainWhenFailedConnection:(BOOL)bShowAgainWhenFailedConnection;
+ (BOOL)optionDontShowAgainWhenFailedConnection;
+ (void)setOptionDontAskAgainCancelDownloads:(BOOL)bAskAgain;
+ (BOOL)optionDontAskAgainCancelDownloads;
+ (void)setLastSelectedFormatResolution:(id)selectedFR;
+ (id)lastSelectedFormatResolution;
+ (void)setDownloadsList:(id)downloads;
+ (id)downloadsList;
+ (void)setCurrentUserPreferences:(id)userPrePerences;
+ (id)currentUserPreferences;
+ (void)setNumberOfDownloadsFreeVersion:(long long)num;
+ (long long)numberOfDownloadsFreeVersion;
+ (void)setWelcomeScreenShown:(BOOL)bWelcome;
+ (BOOL)welcomeScreenShown;
+ (void)setInstallationSource:(id)source;
+ (NSString*)installationSource;
+ (void)setPurchaseLicenseLink:(id)purchaseLink;
+ (id)purchaseLicenseLink;
+ (void)setWasPurchasedPreviously:(BOOL)bPurchasedPreviously;
+ (BOOL)wasPurchasedPreviously;
+ (void)setLicenseName:(id)licenseName;
+ (id)licenseName;
+ (void)setRegisteredName:(id)registeredName;
+ (id)registeredName;
+ (void)setActivationKey:(id)activeionKey;
+ (id)activationKey;
+ (void)setNoticeOfThirdPartyCopyright:(BOOL)bCopyright;
+ (BOOL)noticeOfThirdPartyCopyright;
+ (void)initialize;

@end
