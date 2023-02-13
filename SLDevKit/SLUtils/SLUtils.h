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

@end


NS_ASSUME_NONNULL_END
