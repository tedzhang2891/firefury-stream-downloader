//
//  Utility.m
//  streamdownloader
//
//  Created by ted zhang on 5/23/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "Utility.h"
#import "YDUserDefaults.h"

@implementation Utility

+ (void)printTime:(id)time {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter stringFromDate:[NSDate date]];
}

+ (void)showAlertNotAllLinksAvailable:(long long)total skippedLinks:(long long)skipLinks needSignIn:(BOOL)bNeedSignIn {
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleWarning];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_ok", nil)];
    anAlert.messageText = NSLocalizedString(@"alertMessageLinksNotAvailable", nil);
    
    NSString* informativeText = nil;
    if (total) {
        if (bNeedSignIn) {
            informativeText = [NSString stringWithFormat:NSLocalizedString(@"alertLinksNotAvailableInfo3", nil), skipLinks, total];
        }
        else {
            informativeText = [NSString stringWithFormat:NSLocalizedString(@"alertInfoLinksNotAvailable2", nil), skipLinks, total];
        }
    }
    else {
        informativeText = NSLocalizedString(@"alertInfoLinksNotAvailable", nil);
    }
    anAlert.informativeText = informativeText;
    
    [anAlert runModal];
}

+ (long long)showAlertLogInYoutubeExpired { 
    if ([YDUserDefaults optionDontAskAgainLogInYoutube]) {
        return NSModalResponseStop;
    }
    
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleInformational];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnLoginTitle", nil)];
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_cancel", nil)];
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnLogoutTitle", nil)];
    
    [anAlert setShowsSuppressionButton:YES];
    [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_ask", nil)];
    
    anAlert.messageText = NSLocalizedString(@"alertLoginYoutubeMessage", nil);
    anAlert.informativeText = NSLocalizedString(@"alertLoginYoutubeExpiredInfo", nil);
    
    id buttons = [anAlert buttons];
    NSButton* btn0 = [buttons objectAtIndex:0];
    [btn0 setKeyEquivalent:@"\r"];
    
    NSModalResponse action = [anAlert runModal];
    [YDUserDefaults setOptionDontAskAgainLogInYoutube:(anAlert.suppressionButton.state == NSControlStateValueOn ? YES : NO)];
    
    return action;
}

+ (long long)showAlertLogInYoutubeIfNeed { 
    if ([YDUserDefaults optionDontAskAgainLogInYoutube]) {
        return NSModalResponseStop;
    }
    
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert setAlertStyle:NSAlertStyleInformational];
    
    [anAlert addButtonWithTitle:NSLocalizedString(@"btnLoginTitle", nil)];
    [anAlert addButtonWithTitle:NSLocalizedString(@"button_cancel", nil)];
    
    [anAlert setShowsSuppressionButton:YES];
    [anAlert.suppressionButton setTitle:NSLocalizedString(@"button_dont_ask", nil)];
    
    anAlert.messageText = NSLocalizedString(@"alertLoginYoutubeMessage", nil);
    anAlert.informativeText = NSLocalizedString(@"alertLoginYoutubeInfo", nil);
    
    id buttons = [anAlert buttons];
    NSButton* btn0 = [buttons objectAtIndex:0];
    [btn0 setKeyEquivalent:@"\r"];
    
    NSModalResponse action = [anAlert runModal];
    [YDUserDefaults setOptionDontAskAgainLogInYoutube:(anAlert.suppressionButton.state == NSControlStateValueOn ? YES : NO)];
    
    return action;
}

+ (id)convertStringTime:(NSString*)in_str {
    id strings = [in_str componentsSeparatedByString:@"."];
    if (![strings count]) {
        return nil;
    }
    
    NSString* datePart = [strings objectAtIndex:0];
    NSString* millisecond = nil;
    if ([strings count] < 2) {
        millisecond = @"0";
    }
    else {
        millisecond = [strings objectAtIndex:1];
    }
    
    int totalSeconds = [datePart intValue];
    int hours = floor(totalSeconds / 3600);
    totalSeconds %= 3600;
    int minutes = floor(totalSeconds / 60);
    int seconds = totalSeconds % 60;
    
    return [NSString stringWithFormat:@"%d:%d:%d,%@", hours, minutes, seconds, millisecond];
}

+ (id)styleOfHyperlinkForString:(NSString*)hyperLink withFont:(NSFont*)font andColor:(NSColor*)color isEnabled:(BOOL)bEnable {
    if (!hyperLink) {
        return nil;
    }
    
    if (!font) {
        font = [NSFont systemFontOfSize:13.0];
    }
    
    if (!color) {
        color = [NSColor blackColor];
    }
    
    if (!bEnable) {
        color = [NSColor grayColor];
    }
    
    NSMutableAttributedString* mAttrString = [[NSMutableAttributedString alloc] initWithString:hyperLink];
    NSUInteger lenght = [mAttrString length];
    
    [mAttrString beginEditing];
    [mAttrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, lenght)];
    [mAttrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, lenght)];
    [mAttrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, lenght)];
    [mAttrString addAttribute:NSUnderlineColorAttributeName value:color range:NSMakeRange(0, lenght)];
    [mAttrString endEditing];
    
    return mAttrString;
}

+ (NSString*)float2Template {
    return @"%.2f";
}

+ (NSString*)floatTemplate {
    return @"%.1f";
}

+ (NSString*)intTemplate {
    return @"%.0f";
}

+ (NSString*)sizeSpecifier:(int)spec {
    NSString* specStr = nil;
    NSBundle* mainBundle = [NSBundle mainBundle];
    switch (spec) {
        case 0:
            specStr = [mainBundle localizedStringForKey:@"byte" value:@"B" table:nil];
            break;
        case 1:
            specStr = [mainBundle localizedStringForKey:@"kilobyte" value:@"KB" table:nil];
            break;
        case 2:
            specStr = [mainBundle localizedStringForKey:@"megabyte" value:@"MB" table:nil];
            break;
        case 3:
            specStr = [mainBundle localizedStringForKey:@"gigabyte" value:@"GB" table:nil];
            break;
        default:
            specStr = @"?";
            break;
    }
    return specStr;
}

+ (NSString*)stringFromSize:(long long)size showAsDecimal:(BOOL)bDecimal {
    if (size < 0) {
        return @"N/A";
    }
    
    NSString* stringNum = nil;
    NSString* spec = nil;
    if (size > 0xFFFFF) {
        if (size > 0x40000002) {
            if (bDecimal) {
                stringNum = [NSString stringWithFormat:[Utility float2Template], size * 9.313225746154785e-10];
            }
            else {
                stringNum = [NSString stringWithFormat:[Utility float2Template], size >> 30];
            }
            spec = [Utility sizeSpecifier:3];
        }
        else {
            if (bDecimal) {
                stringNum = [NSString stringWithFormat:[Utility float2Template], size * 9.5367431640625e-07];
            }
            else {
                stringNum = [NSString stringWithFormat:[Utility float2Template], size >> 30];
            }
            spec = [Utility sizeSpecifier:2];
        }
    }
    else {
        if (bDecimal) {
            stringNum = [NSString stringWithFormat:[Utility float2Template], size * 0.0009765625];
        }
        else {
            stringNum = [NSString stringWithFormat:[Utility float2Template], size >> 10];
        }
        spec = [Utility sizeSpecifier:1];
    }
    return [stringNum stringByAppendingString:spec];
}

+ (id)multipleIntersectionOfArrays:(id)array count:(int)num {
    id array1 = nil;
    id array2 = nil;
    
    if ([array count] == 1) {
        array1 = [array objectAtIndex:0];
        array2 = [array objectAtIndex:0];
    }
    else {
        array1 = [array objectAtIndex:num];
        if (num == [array count] - 2) {
            array2 = [array objectAtIndex:[array count] - 1];
        }
        else {
            array2 = [Utility multipleIntersectionOfArrays:array count:num+1];
        }
    }
    
    return [Utility intersecArray:array1 withArray:array2];
}

+ (id)intersecArray:(id)array1 withArray:(id)array2 {
    NSMutableSet* mSet1 = [NSMutableSet setWithArray:array1];
    NSMutableSet* mSet2 = [NSMutableSet setWithArray:array2];
    
    [mSet1 intersectSet:mSet2];
    
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:[mSet1 allObjects]];
    return newArray;
}

+ (BOOL)findNumber:(unsigned long long)number inArray:(id)searchArray {
    for (id each in searchArray) {
        if ([each unsignedIntegerValue] == number) {
            return YES;
        }
    }
    return NO;
}

+ (NSString*)createFolderAtPath:(NSString*)path {
    NSString* standardPath = [path stringByStandardizingPath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL bIsDir = YES;
    if (![fileManager fileExistsAtPath:standardPath isDirectory:&bIsDir]) {
        if (bIsDir) {
            NSError* error = nil;
            [fileManager createDirectoryAtPath:standardPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"Directory was not created: %@", error.localizedDescription);
            }
        }
    }
    
    return standardPath;
}

+ (NSString*)addSuffixForFileName:(NSString*)filename fileExtension:(NSString*)ext atPath:(NSString*)path {
    NSString* retFilename = nil;
    if (path && ![path isEqualToString:@""]) {
        retFilename = [NSString stringWithFormat:@"%@/%@", path, filename];
    }
    
    if (ext && ![ext isEqualToString:@""]) {
        retFilename = [NSString stringWithFormat:@"%@.%@", retFilename, ext];
    }
    
    NSUInteger index = 1;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* onlyPath = [retFilename stringByDeletingLastPathComponent];
    id contents = [fileManager contentsOfDirectoryAtPath:onlyPath error:nil];
    for (id each in contents) {
        NSString* onlyName = [retFilename lastPathComponent];
        NSRange searchRange = [each rangeOfString:onlyName];
        if (searchRange.location != NSNotFound) {
            NSString* theFile = nil;
            if (ext && [ext isEqualToString:@""] == 0) {
                theFile = [NSString stringWithFormat:@"%@%lu.%@", retFilename, (unsigned long)index, ext];
            }
            else {
                theFile = [NSString stringWithFormat:@"%@%lu", retFilename, (unsigned long)index];
            }
            retFilename = theFile;
            ++ index;
        }
    }
    
    return retFilename;
}

+ (NSString*)removeInvalidSymbolsFromFilePath:(NSString*)filepath {
    NSString* clearFilepath = [filepath stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@"'" withString:@" "];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@"?" withString:@" "];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@":" withString:@" "];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@"#" withString:@"_"];
    clearFilepath = [clearFilepath stringByReplacingOccurrencesOfString:@"|" withString:@"_"];
    
    if ([clearFilepath length] == 0) {
        clearFilepath = filepath;
    }
    
    return clearFilepath;
}

@end
