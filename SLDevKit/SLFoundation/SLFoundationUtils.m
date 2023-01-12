//
//  SLFoundationUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/11.
//

#import "SLFoundationUtils.h"

@implementation SLFoundationUtils

id _sl_ObjectFromVariadicFunction(NSString *placeholder, ...) {
    va_list argList;
    va_start(argList, placeholder);
    id result = va_arg(argList, id);
    va_end(argList);
    return result;
}

@end
