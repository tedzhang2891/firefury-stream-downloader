//
//  YDActivation.h
//  streamdownloader
//
//  Created by ted zhang on 5/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDActivation : NSObject
{
}

+ (BOOL)isPreviousTrialKey:(id)arg1;
+ (BOOL)isPreviousDemoKey:(id)arg1;
+ (void)setActivationCode:(id)arg1 silentMode:(BOOL)arg2 asyncMode:(BOOL)arg3;
+ (void)setActivationCode:(id)arg1 silentMode:(BOOL)arg2;
+ (void)setActivationCode:(id)arg1;

@end
