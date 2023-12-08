//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSData;

@interface SSCrypto : NSObject
{
    NSData *symmetricKey;
    NSData *cipherText;
    NSData *clearText;
    NSData *publicKey;
    NSData *privateKey;
    BOOL isSymmetric;
}

+ (id)getMD5ForData:(id)arg1;
+ (id)getSHA1ForData:(id)arg1;
+ (id)getKeyDataWithLength:(int)arg1 fromPassword:(id)arg2 withSalt:(id)arg3 withIterations:(int)arg4;
+ (id)getKeyDataWithLength:(int)arg1 fromPassword:(id)arg2 withSalt:(id)arg3;
+ (id)getKeyDataWithLength:(int)arg1;
+ (id)generateRSAPublicKeyFromPrivateKey:(id)arg1;
+ (id)generateRSAPrivateKeyWithLength:(int)arg1;
+ (void)setupOpenSSL;
+ (void)initialize;
- (id)description;
- (id)digest:(id)arg1;
- (id)sign;
- (id)encrypt:(id)arg1;
- (id)encrypt;
- (id)verify;
- (id)decryptAES256CCC:(id)arg1 initVector:(id)arg2;
- (id)decrypt:(id)arg1;
- (id)decrypt;
- (id)cipherTextAsBase64String;
- (void)setCipherTextFromBase64String:(id)arg1;
- (void)setCipherText:(id)arg1;
- (id)cipherTextAsString;
- (id)cipherTextAsData;
- (void)setClearTextWithString:(id)arg1;
- (void)setClearTextWithData:(id)arg1;
- (id)clearTextAsString;
- (id)clearTextAsData;
- (void)setPrivateKey:(id)arg1;
- (id)privateKey;
- (void)setPublicKey:(id)arg1;
- (id)publicKey;
- (void)setSymmetricKey:(id)arg1;
- (id)symmetricKey;
- (void)setIsSymmetric:(BOOL)arg1;
- (BOOL)isSymmetric;
- (void)cleanupOpenSSL;
- (void)dealloc;
- (id)initWithPublicKey:(id)arg1 privateKey:(id)arg2;
- (id)initWithPrivateKey:(id)arg1;
- (id)initWithPublicKey:(id)arg1;
- (id)initWithSymmetricKey:(id)arg1;
- (id)init;

@end

