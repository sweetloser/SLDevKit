//
//  SLUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUtils.h"
#import "SLDefs.h"

id _slConvertValueToString(const char *type, ...) {
    id result = nil;
    
    va_list argList;
    va_start(argList, type);
    
    if (SL_CHECK_IS_INT(type[0])) {
        // 判断参数是否为整型【所有整型：包含int、long、bool、short等】
        NSInteger n = va_arg(argList, NSInteger);
        return [@(n) description];
    } else if (SL_CHECK_IS_FLOAT(type[0])) {
        // 判断参数是否为浮点型【float、double】
        double d = va_arg(argList, double);
        return [@(d) description];
    } else {
        result = va_arg(argList, id);
    }
    va_end(argList);
    
    return result;
}

@implementation SLUtils

@end
