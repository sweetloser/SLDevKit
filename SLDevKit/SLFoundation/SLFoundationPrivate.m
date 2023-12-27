//
//  SLFoundationPrivate.m
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import "SLFoundationPrivate.h"
#import <objc/runtime.h>
#import "SLDefs.h"

BOOL SLObjectIsKindOfClass(NSString *className, id obj) {
    return [obj isKindOfClass:NSClassFromString(className)];
}

@implementation NSObject (SLFoundationPrivate)

+ (void)_sl_exchengeMethods:(NSArray<NSString *> *)selectorStingArr prefix:(NSString *)prefix {
    if (!prefix || [prefix isEqualToString:@""]) {
        prefix = @"sl_";
    }
    [selectorStingArr enumerateObjectsUsingBlock:^(NSString * _Nonnull origSelectorStr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newSelectorStr = [prefix stringByAppendingString:origSelectorStr];
        Method origMethod = class_getInstanceMethod(self, NSSelectorFromString(origSelectorStr));
        Method newMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorStr));
        
        const char *typeEncoding = method_getTypeEncoding(origMethod);
        
        BOOL canAddMethod = class_addMethod(self, NSSelectorFromString(newSelectorStr), method_getImplementation(newMethod), typeEncoding);
        if (canAddMethod) {
            class_replaceMethod(self, NSSelectorFromString(newSelectorStr), method_getImplementation(origMethod), typeEncoding);
        } else {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }];
}

@end

@implementation NSString (SLFoundationPrivate)

- (NSRange)sl_fullRange {
    return NSMakeRange(0, self.length);
}
SL_INLINE bool _isNum(const int c) {
    return isdigit(c);
}
SL_INLINE bool _islower(const int c) {
    return islower(c);
}
SL_INLINE bool _isupper(const int c) {
    return isupper(c);
}
SL_INLINE bool _isspecial(const int c) {
    return isspace(c);
}

- (SLPasswordLevelOptions)sl_passwordLevel {
    
    SLPasswordLevelOptions level = (self.length > 0b11111) ? 0b11111 : (self.length & 0b11111);
    
    // 判断有没有数字
    for (int n=0; n<self.length; n++) {
        int nChar = [self characterAtIndex:n];
        if (_isNum(nChar)) {
            level = level | SLPasswordLevelOptionsNUM;
            break;
        }
    }
    
    // 判断有没有小写字母
    for (int l=0; l<self.length; l++) {
        char lChar = (char)[self characterAtIndex:l];
        if (_islower(lChar)) {
            level = level | SLPasswordLevelOptionsLowercase;
            break;
        }
    }
    
    // 判断有没有大写字母
    for (int u=0; u<self.length; u++) {
        unichar uChar = [self characterAtIndex:u];
        if (_isupper(uChar)) {
            level = level | SLPasswordLevelOptionsUppercase;
            break;
        }
    }
    
    // 判断有没有特殊符号【英文】
    for (int s=0; s<self.length; s++) {
        unichar sChar = [self characterAtIndex:s];
        if (_isspecial(sChar)) {
            level = level | SLPasswordLevelOptionsSpecificSymbol;
            break;
        }
    }
    
    // 判断是否包含连续4个相同的字符
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.)\\1{3,}" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:[self sl_fullRange]];
    
    if (!match) {
        // 没有匹配到，即不存在，记录对应位
        level = level | SLPasswordLevelOptionsConsecutiveIdenticalCharacters;
    }
    
    // 判断是否有连续的数字或字母
    
    return level;
}

@end

@implementation NSArray (SLFoundationPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript:idx];
    }
    return nil;
}

@end

static const char *_kBase64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const char _kBase64DecodeChars[] = {
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      62/*+*/, 99,      99,      99,      63/*/ */,
    52/*0*/, 53/*1*/, 54/*2*/, 55/*3*/, 56/*4*/, 57/*5*/, 58/*6*/, 59/*7*/,
    60/*8*/, 61/*9*/, 99,      99,      99,      99,      99,      99,
    99,       0/*A*/,  1/*B*/,  2/*C*/,  3/*D*/,  4/*E*/,  5/*F*/,  6/*G*/,
    7/*H*/,  8/*I*/,  9/*J*/, 10/*K*/, 11/*L*/, 12/*M*/, 13/*N*/, 14/*O*/,
    15/*P*/, 16/*Q*/, 17/*R*/, 18/*S*/, 19/*T*/, 20/*U*/, 21/*V*/, 22/*W*/,
    23/*X*/, 24/*Y*/, 25/*Z*/, 99,      99,      99,      99,      99,
    99,      26/*a*/, 27/*b*/, 28/*c*/, 29/*d*/, 30/*e*/, 31/*f*/, 32/*g*/,
    33/*h*/, 34/*i*/, 35/*j*/, 36/*k*/, 37/*l*/, 38/*m*/, 39/*n*/, 40/*o*/,
    41/*p*/, 42/*q*/, 43/*r*/, 44/*s*/, 45/*t*/, 46/*u*/, 47/*v*/, 48/*w*/,
    49/*x*/, 50/*y*/, 51/*z*/, 99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99
};

static const char _kBase64PaddingChar = '=';

SL_INLINE NSUInteger _calcEncodedLength(NSUInteger srcLen) {
    // 原数据的bit位
    NSUInteger srcBitLen = srcLen * 8;
    // 编码后需要的bit位(填充后)
    NSUInteger encodedBitLen = ((srcBitLen + 23) / 24) * 24;
    // 每6bit转换为一个长
    return encodedBitLen / 6;
}

SL_INLINE NSUInteger _maxDecodeLength(NSUInteger encodeLen) {
    return ((encodeLen +3) / 4) * 3;
}

@implementation NSData (SLFoundationPrivate)

- (NSData *)_base64Encode {
    NSMutableData *_result = [NSMutableData new];
    NSUInteger _resultLen = _calcEncodedLength(self.length);
    [_result setLength:_resultLen];
    NSUInteger unEncodedLen = self.length;
    BytePtr _resultBytes = (BytePtr)[_result mutableBytes];
    BytePtr _selfBytes = (BytePtr)[self bytes];
    while (unEncodedLen > 2) {
        // 取第一Byte的高6bit作为索引
        _resultBytes[0] = _kBase64EncodeChars[(_selfBytes[0]>>2) & 0b00111111];
        // 取第一Byte的低2bit和第二Byte的高4bit作为索引
        _resultBytes[1] = _kBase64EncodeChars[((_selfBytes[0]<<4) & 0b00110000) | ((_selfBytes[1]>>4) & 0b00001111)];
        // 取第二Byte的低4bit和第三Byte的高2bit作为索引
        _resultBytes[2] = _kBase64EncodeChars[((_selfBytes[1]<<2) & 0b00111100) | ((_selfBytes[2]>>6) & 0b00000011)];
        // 取第三Byte的低6bit
        _resultBytes[3] = _kBase64EncodeChars[_selfBytes[2] & 0b00111111];
        
        _resultBytes += 4;
        _selfBytes += 3;
        unEncodedLen -= 3;
    }
    if (unEncodedLen == 1) {
        // 剩余1Byte未编码
        _resultBytes[0] = _kBase64EncodeChars[(_selfBytes[0]>>2) & 0b00111111];
        _resultBytes[1] = _kBase64EncodeChars[(_selfBytes[0]<<4) & 0b00110000];
        _resultBytes[2] = _kBase64PaddingChar;
        _resultBytes[3] = _kBase64PaddingChar;
    } else if (unEncodedLen == 2) {
        // 剩余2Byte未编码
        _resultBytes[0] = _kBase64EncodeChars[(_selfBytes[0]>>2) & 0b00111111];
        _resultBytes[1] = _kBase64EncodeChars[((_selfBytes[0]<<4) & 0b00110000) | ((_selfBytes[1]>>4) & 0b00001111)];
        _resultBytes[2] = _kBase64EncodeChars[((_selfBytes[1]<<2) & 0b00111100)];
        _resultBytes[3] = _kBase64PaddingChar;
    }
    return _result;
}

- (NSData *)_base64Decode {
    NSMutableData *_result = [NSMutableData new];
    NSUInteger _maxResultLen = _maxDecodeLength(self.length);
    [_result setLength:_maxResultLen];
    
    NSUInteger _unDecodeLen = self.length;
    BytePtr _selfBytes = (BytePtr)[self bytes];
    BytePtr _resultBytes = (BytePtr)[_result mutableBytes];
    
    // 将'='的长度忽略
    while (*(_selfBytes+_unDecodeLen-1) == '=') {
        _unDecodeLen--;
    }
    
    while (_unDecodeLen > 3) {
        // 第一Byte：取第1个字符下标的低6bit和第2个字符下标的高2bit
        _resultBytes[0] = ((_kBase64DecodeChars[_selfBytes[0]] << 2) & 0b11111100) | ((_kBase64DecodeChars[_selfBytes[1]] >> 4) & 0b00000011);
        // 第二Byte：取第2个字符下标的低4bit和第3个字符下标的高4bit
        _resultBytes[1] = ((_kBase64DecodeChars[_selfBytes[1]] << 4) & 0b11110000) | ((_kBase64DecodeChars[_selfBytes[2]] >> 2) & 0b00001111);
        // 第三Byte：取第3个字符下标的低2bit和第4个字符下标的低6bit
        _resultBytes[2] = ((_kBase64DecodeChars[_selfBytes[2]] << 6) & 0b11000000) | ((_kBase64DecodeChars[_selfBytes[3]]) & 0b00111111);
        
        _resultBytes += 3;
        _selfBytes += 4;
        _unDecodeLen -= 4;
    }
    
    if (_unDecodeLen == 1) {
        // 不会出现这种情况
    } else if (_unDecodeLen == 2) {
        // 还有1Byte
        _resultBytes[0] = ((_kBase64DecodeChars[_selfBytes[0]] << 2) & 0b11111100) | ((_kBase64DecodeChars[_selfBytes[1]] >> 4) & 0b00000011);
        // 预估的长度多了2Byte
        [_result setLength:_maxResultLen-2];
    } else if (_unDecodeLen == 3) {
        // 还有2Byte
        _resultBytes[0] = ((_kBase64DecodeChars[_selfBytes[0]] << 2) & 0b11111100) | ((_kBase64DecodeChars[_selfBytes[1]] >> 4) & 0b00000011);
        _resultBytes[1] = ((_kBase64DecodeChars[_selfBytes[1]] << 4) & 0b11110000) | ((_kBase64DecodeChars[_selfBytes[2]] >> 2) & 0b00001111);
        // 预估的长度多了1Byte
        [_result setLength:_maxResultLen-1];
    }
    
    return _result;
}

- (NSData *)_hexEncode {
    static char *hex = (char *)"0123456789abcdef";
    Byte *hexEncode = (Byte *)malloc(self.length * 2);
    memset(hexEncode, 0, self.length * 2);
    Byte *bytes = (Byte *)self.bytes;
    for (int i = 0; i < self.length; i++) {
        hexEncode[2*i] = hex[(bytes[i] >> 4) & 0xF];
        hexEncode[2*i+1] = hex[bytes[i] & 0xF];
    }
    
    NSData *data = [[NSData alloc] initWithBytes:hexEncode length:self.length * 2];
    free(hexEncode);
    
    return data;
}


@end
