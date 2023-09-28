//
//  SLFoundationPrivate.h
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SLPasswordLevelOptions) {
    SLPasswordLevelOptionsLength = 0,                               // 用前5bit存储密码的长度【最长31】
    SLPasswordLevelOptionsNUM = 1 << 5,                             // 是否包含数字
    SLPasswordLevelOptionsLowercase = 1 << 6,                       // 是否包含小写字母
    SLPasswordLevelOptionsUppercase = 1 << 7,                       // 是否包含大小字母
    SLPasswordLevelOptionsSpecificSymbol = 1 << 8,                  // 是否包含特殊字符
    SLPasswordLevelOptionsConsecutiveIdenticalCharacters = 1 << 9,  // 是否连续包含相同的字符【默认超过4个即记录】eg:aaaaaaaaabbb.
};

BOOL SLObjectIsKindOfClass(NSString *className, id obj);

@interface NSObject (SLFoundationPrivate)

+(void)_sl_exchengeMethods:(NSArray<NSString *> *)selectorStingArr prefix:(NSString *)prefix;

@end

@interface NSString (SLFoundationPrivate)

/// 获取字符串的full range
/// eg:12345   => {0, 5}
-(NSRange)sl_fullRange;


/// 检测密码等级
-(SLPasswordLevelOptions)sl_passwordLevel;

@end

@interface NSArray(SLFoundationPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface NSData (SLFoundationPrivate)

- (NSData *)_base64Encode;

- (NSData *)_base64Decode;

- (NSData *)_hexEncode;

@end

NS_ASSUME_NONNULL_END
