//
//  RegCodeController.m
//  ProductionAuthentication
//
//  Created by ted zhang on 3/14/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "RegCodeController.h"

void CAssignErrorWithDescriptionAndCode(NSError **err, NSString *description, NSInteger code)
{
    if (err != NULL)
        *err = [NSError errorWithDomain:[[NSBundle bundleForClass:[RegCodeController class]] bundleIdentifier] code:code userInfo:[NSDictionary dictionaryWithObject:NSLocalizedStringFromTableInBundle(description, nil, [NSBundle bundleForClass:[RegCodeController class]], nil) forKey:NSLocalizedDescriptionKey]];
}

@interface RegCodeController ()
@property (retain) __attribute__((NSObject)) SecKeyRef publicKey;
@end

@implementation RegCodeController

@synthesize blacklist = _blacklist;
@synthesize publicKey = _publicKey;

#pragma mark -
#pragma mark Class methods

+ (NSString *)completePublicKeyPEM:(NSString *)partialPEM {
    NSString *dashes = @"-----";
    NSString *begin = @"BEGIN";
    NSString *end = @"END";
    NSString *key = @"KEY";
    NSString *public = @"DSA PUBLIC";
    NSMutableString *pem = [NSMutableString string];
    [pem appendString:dashes];
    [pem appendString:begin];
    [pem appendString:@" "];
    [pem appendString:public];
    [pem appendString:@" "];
    [pem appendString:key];
    [pem appendString:dashes];
    [pem appendString:@"\n"];
    [pem appendString:partialPEM];
    [pem appendString:dashes];
    [pem appendString:end];
    [pem appendString:@" "];
    [pem appendString:public];
    [pem appendString:@" "];
    [pem appendString:key];
    [pem appendString:dashes];
    [pem appendString:@"\n"];
    return [NSString stringWithString:pem];
}

#pragma mark -
#pragma mark Lifecycle

#if !__has_feature(objc_arc)
- (void)finalize
{
    self.publicKey = nil;
    [super finalize];
}

- (void)dealloc
{
    self.publicKey = nil;
    self.blacklist = nil;
    [super dealloc];
}
#endif

#pragma mark -
#pragma mark API

- (BOOL)setPublicKey:(NSString *)pubKey error:(NSError **)err
{
    self.publicKey = nil;
    
    // Validate the argument.
    if (pubKey == nil || [pubKey length] < 1) {
        CAssignErrorWithDescriptionAndCode(err, @"Invalid key.", CErrorCodeInvalidKey);
        return NO;
    }
    
    SecItemImportExportKeyParameters params = {};
    SecExternalItemType keyType = kSecItemTypePublicKey;
    SecExternalFormat keyFormat = kSecFormatPEMSequence;
    CFArrayRef importArray = NULL;
    
    NSData *pubKeyData = [pubKey dataUsingEncoding:NSUTF8StringEncoding];
#if __has_feature(objc_arc)
    CFDataRef pubKeyDataRef = (__bridge CFDataRef)pubKeyData;
#else
    CFDataRef pubKeyDataRef = (CFDataRef)pubKeyData;
#endif
    
    OSStatus importError = SecItemImport(pubKeyDataRef, NULL, &keyFormat, &keyType, 0, &params, NULL, &importArray);
    
    if (importError) {
        CAssignErrorWithDescriptionAndCode(err, @"Unable to decode key.", CErrorCodeCouldNotDecode);
        if (importArray) {
            CFRelease(importArray);
        }
        return NO;
    }
    
    self.publicKey = (SecKeyRef)CFArrayGetValueAtIndex(importArray, 0);
    CFRelease(importArray);
    return YES;
}

- (BOOL)verifyRegCode:(NSString *)regCode forName:(NSString *)name error:(NSError **)err
{
    if (name == nil || [name length] < 1) {
        CAssignErrorWithDescriptionAndCode(err, @"No name for the registration code.", CErrorCodeNoName);
        return NO;
    }
    
    if (!self.publicKey) {
        CAssignErrorWithDescriptionAndCode(err, @"Invalid key.", CErrorCodeInvalidKey);
        return NO;
    }
    
    // Replace 9s with Is and 8s with Os
    NSString *regKeyTemp = [regCode stringByReplacingOccurrencesOfString:@"9" withString:@"I"];
    NSString *regKeyBase32 = [regKeyTemp stringByReplacingOccurrencesOfString:@"8" withString:@"O"];
    // Remove dashes from the registration key if they are there (dashes are optional).
    NSString *keyNoDashes = [regKeyBase32 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *keyData = [keyNoDashes dataUsingEncoding:NSUTF8StringEncoding];
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
#if __has_feature(objc_arc)
    CFDataRef keyDataRef = (__bridge CFDataRef)keyData;
    CFDataRef nameDataRef = (__bridge CFDataRef)nameData;
#else
    CFDataRef keyDataRef = (CFDataRef)keyData;
    CFDataRef nameDataRef = (CFDataRef)nameData;
#endif
    
    // Note: A transform group is not used here because there appears to be a bug connecting the output of a decode transform to kSecSignatureAttributeName. Execution of the group randomly fails.
    
    BOOL result = NO;
    SecTransformRef decoder = SecDecodeTransformCreate(kSecBase32Encoding, NULL);
    if (decoder) {
        SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, keyDataRef, NULL);
        CFDataRef signature = SecTransformExecute(decoder, NULL);
        if (signature) {
            SecTransformRef verifier = SecVerifyTransformCreate(self.publicKey, signature, NULL);
            if (verifier) {
                SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, nameDataRef, NULL);
                SecTransformSetAttribute(verifier, kSecDigestTypeAttribute, kSecDigestSHA1, NULL);
                CFErrorRef error;
                CFBooleanRef transformResult = SecTransformExecute(verifier, &error);
                if (transformResult) {
                    result = (transformResult == kCFBooleanTrue);
                    CFRelease(transformResult);
                }
                CFRelease(verifier);
            }
            CFRelease(signature);
        }
        CFRelease(decoder);
    }
    return result;
}

@end
