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

@end


NS_ASSUME_NONNULL_END
