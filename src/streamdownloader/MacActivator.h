//
//  MacActivator.h
//  streamdownloader
//
//  Created by ted zhang on 5/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MacActivator : NSObject
{
    NSData *m_activationData;
    BOOL m_silent_mode;
    BOOL isOfflineMode;
    NSDictionary *m_eng_loc;
    NSString *m_productId;
    NSString *m_productVersion;
    NSString *m_key;
    NSString *m_productName;
    id m_delegate;
    int m_activation_result;
    NSMutableData *m_asyncData;
    int m_demo_days;
    NSDictionary *customParams;
}

+ (id)activatorForProductId:(id)arg1 version:(id)arg2 activationKey:(id)arg3 productName:(id)arg4;
- (void)connectionDidFinishLoading:(id)arg1;
- (void)connection:(id)arg1 didReceiveData:(id)arg2;
- (void)connection:(id)arg1 didFailWithError:(id)arg2;
- (void)scheduleInRunLoop:(id)arg1 forMode:(id)arg2;
- (void)unscheduleFromRunLoop:(id)arg1 forMode:(id)arg2;
- (int)daysFromFirstLaunch;
- (int)demoDaysLeft;
- (void)setDemoDaysLimit:(int)arg1;
- (void)activateAsync;
- (BOOL)checkIsValid:(id)arg1;
- (int)activate;
- (void)setCustomParameters:(id)arg1;
- (void)parseDic:(id)arg1 withActivationData:(id)arg2;
- (BOOL)failDialog:(id)arg1;
- (void)saveOfflineFile:(id)arg1;
- (void)copytoclip:(id)arg1;
- (id)localizeStr:(id)arg1;
- (id)activationInfoForData:(id)arg1;
- (id)activationInfo;
- (BOOL)silentMode;
- (void)setSilentMode:(BOOL)arg1;
- (id)getHardwareID;
- (void)setActivationKey:(id)arg1;
- (id)activationKey;
- (id)activationData;
- (void)setActivationData:(id)arg1;
- (void)dealloc;
- (id)init;
- (id)makeEscapeStr:(id)arg1;
- (void)setDelegate:(id)arg1;
- (id)delegate;
- (void)setVersion:(id)arg1;
- (void)setProductId:(id)arg1;
- (void)setProductName:(id)arg1;
- (BOOL)setAttributes:(id)arg1 ofItemAtPath:(id)arg2 error:(id *)arg3;

@end
