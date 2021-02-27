#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import<UIKit/UiKit.h>
@implementation NSData (AES)

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key
{
    return [self AES128EncryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key
{
    return [self AES128DecryptedDataWithKey:key iv:nil];
}

- (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
//    if (iv) {
//        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
//    }

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                        kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
- (NSData *)AES128EncryptedDataWithKeykp:(NSData *)key iv:(NSData *)iv withData:(NSData *)datas;
{
   return  [self aesCBCEncrypt:datas key:key error:nil];
    
//    return [self AES128OperationWithEncriptionMode:kCCEncrypt key:key iv:key];

}
- (NSData *)AES128EncryptedDataWithKeykp2:(NSData *)key iv:(NSData *)iv withData:(NSData *)datas;
{
    return [self AES128OperationWithEncriptionMode:kCCEncrypt key:key iv:key];
}
- (NSData *)AES128EncryptedDataWithKeykp:(NSData *)key withDataKey:(NSData *)keyData
{
    return [self AES128OperationWithEncriptionMode:kCCEncrypt key:key iv:key];
}

- (NSData *)AES128OperationWithEncriptionMode:(CCOperation)operation key:(NSData *)key iv:(NSData *)iv
{
    
    
    CCCryptorRef cryptor = NULL;
    // 1. Create a cryptographic context.
    CCCryptorStatus status = CCCryptorCreateWithMode(operation, kCCModeCFB, kCCAlgorithmAES, ccNoPadding, [iv bytes], [key bytes], [key length], NULL, 0, 0, kCCModeOptionCTR_BE, &cryptor);
    
    NSAssert(status == kCCSuccess, @"Failed to create a cryptographic context.");
    
    NSMutableData *retData = [NSMutableData new];
    
    // 2. Encrypt or decrypt data.
    NSMutableData *buffer = [NSMutableData data];
    [buffer setLength:CCCryptorGetOutputLength(cryptor, [self length], true)]; // We'll reuse the buffer in -finish
    
    size_t dataOutMoved;
    status = CCCryptorUpdate(cryptor, self.bytes, self.length, buffer.mutableBytes, buffer.length, &dataOutMoved);
    NSAssert(status == kCCSuccess, @"Failed to encrypt or decrypt data");
    [retData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
    
    // 3. Finish the encrypt or decrypt operation.
    status = CCCryptorFinal(cryptor, buffer.mutableBytes, buffer.length, &dataOutMoved);
    NSAssert(status == kCCSuccess, @"Failed to finish the encrypt or decrypt operation");
    [retData appendData:[buffer subdataWithRange:NSMakeRange(0, dataOutMoved)]];
    CCCryptorRelease(cryptor);
    
    return [retData copy];
}


- (NSData *)aesCBCEncrypt:(NSData *)data
                      key:(NSData *)key
                    error:(NSError **)error
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    int             ivLength   = kCCBlockSizeAES128;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:ivLength + data.length + kCCBlockSizeAES128];
    
    SecRandomCopyBytes(kSecRandomDefault, ivLength, dataOut.mutableBytes);
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       key.bytes, key.length,
                       dataOut.bytes,
                       data.bytes, data.length,
                       dataOut.mutableBytes + ivLength, dataOut.length,
                       &cryptBytes);
    
//    CCCryptorStatus cryptStatus = CCCrypt(operation,
//                                          kCCAlgorithmAES128,
//                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//                                          keyPtr,
//                                          kCCBlockSizeAES128,
//                                          ivPtr,
//                                          [self bytes],
//                                          dataLength,
//                                          buffer,
//                                          bufferSize,
//                                          &numBytesEncrypted);
    
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes + ivLength;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError" code:ccStatus userInfo:nil];
        }
        dataOut = nil;
    }
    
    return dataOut;
}

- (NSData *) EncryptAES: (NSString *) key
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCOptionECBMode;
    void *buffer = malloc(bufferSize);
//    const unsigned char iv[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    
    CCCryptorStatus result = CCCrypt( kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     keyPtr,
                                     kCCKeySizeAES128,
                                     ivPtr,
                                     [self bytes], [self length],
                                     buffer, bufferSize,
                                     &numBytesEncrypted );
    
//    if(result==kCCSuccess )
    {
    }
    return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];

}

- (NSMutableData*) EncryptAES123:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero( keyPtr, sizeof(keyPtr) );
    
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF16StringEncoding];
    size_t numBytesEncrypted = 0;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    NSMutableData *output = [[NSData alloc] init];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCKeySizeAES256, NULL, [self bytes], [self length], buffer, bufferSize, &numBytesEncrypted);
    
    output = [NSMutableData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    if(result == kCCSuccess)
    {
        return output;
    }
            return NULL;
}

- (NSData *)doCipher:(NSData *)dataIn
                  iv:(NSData *)iv
                 key:(NSData *)symmetricKey
             context:(NSData *)encryptOrDecrypt
               error:(NSError **)error
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;    // Number of bytes moved to buffer.
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
    
    ccStatus = CCCrypt( kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       symmetricKey.bytes,
                       kCCKeySizeAES128,
                       iv.bytes,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError"
                                         code:ccStatus
                                     userInfo:nil];
        }
        dataOut = nil;
    }
    
    return dataOut;
}
@end
