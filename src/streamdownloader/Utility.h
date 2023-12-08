//
//  Utility.h
//  streamdownloader
//
//  Created by ted zhang on 5/23/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Utility : NSObject
{
}

+ (void)printTime:(id)arg1;
+ (void)showAlertNotAllLinksAvailable:(long long)arg1 skippedLinks:(long long)arg2 needSignIn:(BOOL)arg3;
+ (long long)showAlertLogInYoutubeExpired;
+ (long long)showAlertLogInYoutubeIfNeed;
+ (id)convertStringTime:(id)arg1;
+ (id)styleOfHyperlinkForString:(id)arg1 withFont:(id)arg2 andColor:(id)arg3 isEnabled:(BOOL)arg4;
+ (id)float2Template;
+ (id)floatTemplate;
+ (id)intTemplate;
+ (id)sizeSpecifier:(int)arg1;
+ (id)stringFromSize:(long long)arg1 showAsDecimal:(BOOL)arg2;
+ (id)multipleIntersectionOfArrays:(id)arg1 count:(int)arg2;
+ (id)intersecArray:(id)arg1 withArray:(id)arg2;
+ (BOOL)findNumber:(unsigned long long)arg1 inArray:(id)arg2;
+ (id)createFolderAtPath:(id)arg1;
+ (id)addSuffixForFileName:(id)arg1 fileExtension:(id)arg2 atPath:(id)arg3;
+ (id)removeInvalidSymbolsFromFilePath:(id)arg1;

@end


