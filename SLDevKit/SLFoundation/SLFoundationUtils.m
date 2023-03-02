//
//  SLFoundationUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/11.
//

#import "SLFoundationUtils.h"

id _sl_ObjectFromVariadicFunction(NSString *placeholder, ...) {
    va_list argList;
    va_start(argList, placeholder);
    id result = va_arg(argList, id);
    va_end(argList);
    return result;
}

@implementation SLFoundationUtils

+ (NSString *)jsonStringWithObject:(id)object {
    if (!object) {
        return @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (id)jsonObjectFromJsonString:(NSString *)jsonString {
    if (!jsonString) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return jsonObject;
}

@end
