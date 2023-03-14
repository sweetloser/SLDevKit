//
//  SLUtils.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"

#define SL_CONVERT_VALUE_TO_STRING(x) _slConvertValueToString(SL_TYPE(x), x)

NS_ASSUME_NONNULL_BEGIN

id _slConvertValueToString(const char *type, ...);

@interface SLUtils : NSObject

/// 判断待匹配字符串是否仅包含数字、字母和英文字符
/// - Parameter matchString: 待匹配字符串
+(BOOL)matchNumLetterAndEnglishSymbol:(NSString *)matchString;

/// 获取当前连接的wifi的名称
+ (NSString *)wiFiName;

/// 判断是否连接VPN
+ (BOOL)isVPNOn;

/// 判断网络是否设置了代理
+ (BOOL)isOpenTheProxy;

/// 判断设备是否越狱
+ (BOOL)isJailBroken;

@end


NS_ASSUME_NONNULL_END
