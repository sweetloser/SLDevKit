//
//  NSObject+SLModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import "NSObject+SLModel.h"
#import "_SLModelMeta.h"
#import "_SLModelClassPropertyMeta.h"
#import <objc/runtime.h>
#import <objc/message.h>

static void sl_modelSetWithDictionaryFunction(const void *_key, const void *_value, void *context);
static NSNumber *sl_numberCreateFromID(__unsafe_unretained id _id);
static void sl_modelSetNumberToProperty(__unsafe_unretained id model, __unsafe_unretained NSNumber *number, __unsafe_unretained _SLModelClassPropertyMeta *meta);
static void sl_modelSetValueForProperty(__unsafe_unretained id model, __unsafe_unretained id value, __unsafe_unretained _SLModelClassPropertyMeta *meta);

@implementation NSObject (SLModel)

/**
 * json数据转model
 *
 * - Parameter json: 待转换的json数据
 * 
 * - Returns: 转换成功：model对象；转换失败：nil
 */
+ (instancetype)sl_modelWithJson:(id)json {
    NSDictionary *dict = [self _sl_dictionaryWithJson:json];
    return [self sl_modelWithDictionary:dict];
}

/**
 * 字典转model
 *
 * - Parameter dictionary: 待转换的字典
 *
 * - Returns: 转换成功：model对象；转换失败：nil
 */
+ (instancetype)sl_modelWithDictionary:(NSDictionary *)dictionary {
    // 判断是否为空
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    // 判断是否为NSDictionary对象
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    _SLModelMeta *modelMeta = [_SLModelMeta metaWithClass:cls];
    if (modelMeta.hasCustomClassFromDictionary) {
        cls = [(Class<SLModel>)cls sl_modelCustomClassForDictionary:dictionary] ?: cls;
    }
    
    NSObject *one = [cls new];
    if ([one sl_modelSetWithDictionary:dictionary]) return one;
    return nil;
}

/**
 * json对象转化为字典
 *
 * - Parameter json: json对象(NSString、NSData、NSDictionary)
 */
+ (NSDictionary *)_sl_dictionaryWithJson:(id)json {
    /// 如果 `json` 为空或者为NSNull对象，则返回nil
    if (!json || json == (id)kCFNull) return nil;
    
    NSDictionary *dict = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = (NSDictionary *)json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = (NSData *)json;
    }
    
    if (jsonData != nil) {
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dict isKindOfClass:[NSDictionary class]]) {
            dict = nil;
        }
    }
    
    return dict;
}

- (BOOL)sl_modelSetWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || (dictionary == (id)kCFNull)) return NO;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    
    _SLModelMeta *modelMeta = [_SLModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta.keyMappedCount == 0) return NO;
    
    if (modelMeta.hasCustomWillTransformFromDictionary) {
        dictionary = [(id<SLModel>)self sl_modelCustomWillTransformFromDictionary:dictionary];
        if (![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    SLModelSetContext context = {NULL,NULL,NULL};
    context.modelMeta = (__bridge void *)modelMeta;
    context.model = (__bridge void *)self;
    context.dictionary = (__bridge void *)dictionary;
    
    if (modelMeta.keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dictionary)) {
        // 属性数 > 键值对数
        CFDictionaryApplyFunction((CFDictionaryRef)dictionary, (CFDictionaryApplierFunction)sl_modelSetWithDictionaryFunction, &context);
        
        if (modelMeta.keyPathPropertyMetas) {
            
        }
    } else {
        
    }
    
    return NO;
}


@end


static void sl_modelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    SLModelSetContext *context = (SLModelSetContext *)_context;
    __unsafe_unretained _SLModelMeta *modelMeta = (__bridge _SLModelMeta *)context->modelMeta;
    __unsafe_unretained _SLModelClassPropertyMeta *propertyMeta = [modelMeta.mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)context->model;
    while (propertyMeta) {
        if (propertyMeta.setter) {
            sl_modelSetValueForProperty(model, (__bridge id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta.next;
    }
}

static void sl_modelSetValueForProperty(__unsafe_unretained id model, __unsafe_unretained id value, __unsafe_unretained _SLModelClassPropertyMeta *meta) {
    if (meta.isCNumber) {
        NSNumber *number = sl_numberCreateFromID(value);
        sl_modelSetNumberToProperty(model, number, meta);
        if (number) [number class];
    } else if (meta.nsType) {
        if (value == (id)kCFNull) {
            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, nil);
        } else {
            switch (meta.nsType) {
                case SLModelEncodingNSTypeNSString:
                case SLModelEncodingNSTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta.nsType == SLModelEncodingNSTypeNSString) {
                            ((void(*)(id,SEL,NSString *))objc_msgSend)(model, meta.setter, value);
                        } else {
                            ((void(*)(id,SEL,NSMutableString *))objc_msgSend)(model, meta.setter, [(NSString *)value mutableCopy]);
                        }
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        id setValue = (meta.nsType == SLModelEncodingNSTypeNSString) ? [(NSNumber *)value stringValue] : [(NSNumber *)value stringValue].mutableCopy;
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, setValue);
                    } else if ([value isKindOfClass:[NSData class]]) {
                        id setValue = [[NSString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding];
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableString) {
                            setValue = [(NSString *)setValue mutableCopy];
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model,meta.setter,setValue);
                    } else if ([value isKindOfClass:[NSURL class]]) {
                        id setValue = [(NSURL *)value absoluteString];
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableString) {
                            setValue = [(NSString *)setValue mutableCopy];
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model,meta.setter,setValue);
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        id setValue = [(NSAttributedString *)value string];
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableString) {
                            setValue = [(NSString *)setValue mutableCopy];
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model,meta.setter,setValue);
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSValue: {
                    if ([value isKindOfClass:[NSValue class]]) {
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSNumber: {
                    NSNumber *number = sl_numberCreateFromID(value);
                    ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, number);
                }
                    break;
                case SLModelEncodingNSTypeNSDecimalNumber: {
                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta.setter, value);
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta.setter, decNum);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                        NSDecimal dec = decNum.decimalValue;
                        if (dec._length == 0 && dec._isNegative) {
                            decNum = nil; // NaN
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta.setter, decNum);
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSData:
                case SLModelEncodingNSTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        NSData *setValue = (NSData *)value;
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableData) {
                            setValue = setValue.mutableCopy;
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, setValue);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData *setValue = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableData) {
                            setValue = setValue.mutableCopy;
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, setValue);
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSDate: {
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
}
static NSNumber *sl_numberCreateFromID(__unsafe_unretained id _id) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE": @(YES),
                @"True": @(YES),
                @"true": @(YES),
                @"FALSE": @(NO),
                @"False": @(NO),
                @"false": @(NO),
                @"YES": @(YES),
                @"Yes": @(YES),
                @"yes": @(YES),
                @"NO": @(NO),
                @"No": @(NO),
                @"no": @(NO),
                @"NIL": (id)kCFNull,
                @"Nil": (id)kCFNull,
                @"nil": (id)kCFNull,
                @"NULL": (id)kCFNull,
                @"Null": (id)kCFNull,
                @"null": (id)kCFNull,
                @"(NULL)": (id)kCFNull,
                @"(Null)": (id)kCFNull,
                @"(null)": (id)kCFNull,
                @"<NULL>": (id)kCFNull,
                @"<Null>": (id)kCFNull,
                @"<null>": (id)kCFNull};
    });
    
    if (!_id || _id == (id)kCFNull) return nil;
    if ([_id isKindOfClass:[NSNumber class]]) return _id;
    
    if ([_id isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[_id];
        
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        
        if ([(NSString *)_id rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cString = [(NSString *)_id UTF8String];
            if (!cString) return nil;
            
            double num = atof(cString);
            // 判断是否为无效数和无限数
            if (isnan(num) || isinf(num)) return nil;
            
            return @(num);
        } else {
            const char *cString = [(NSString *)_id UTF8String];
            if (!cString) return nil;
            return @(atoll(cString));
        }
    }
    
    return nil;
}

static void sl_modelSetNumberToProperty(__unsafe_unretained id model, __unsafe_unretained NSNumber *number, __unsafe_unretained _SLModelClassPropertyMeta *meta) {
    switch (meta.type & SLModelEncodingTypeMask) {
        case SLModelEncodingTypeBool: {
            ((void(*)(id,SEL,bool))objc_msgSend)(model, meta.setter, number.boolValue);
        }
            break;
        case SLModelEncodingTypeInt8: {
            ((void(*)(id,SEL,int8_t))objc_msgSend)(model, meta.setter, (int8_t)(number.charValue));
        }
            break;
        case SLModelEncodingTypeUInt8: {
            ((void(*)(id,SEL,uint8_t))objc_msgSend)(model, meta.setter, (uint8_t)number.unsignedCharValue);
        }
            break;
        case SLModelEncodingTypeInt16: {
            ((void(*)(id,SEL,int16_t))objc_msgSend)(model, meta.setter, (int16_t)number.shortValue);
        }
            break;
        case SLModelEncodingTypeUInt16: {
            ((void(*)(id,SEL,uint16_t))objc_msgSend)(model, meta.setter, (uint16_t)number.unsignedShortValue);
        }
            break;
        case SLModelEncodingTypeInt32: {
            ((void(*)(id,SEL,int32_t))objc_msgSend)(model, meta.setter, (int32_t)number.intValue);
        }
            break;
        case SLModelEncodingTypeUInt32: {
            ((void(*)(id,SEL,uint32_t))objc_msgSend)(model, meta.setter, (uint32_t)number.unsignedIntValue);
        }
            break;
        case SLModelEncodingTypeInt64: {
            ((void(*)(id,SEL,int64_t))objc_msgSend)(model, meta.setter, (int64_t)number.longLongValue);
        }
            break;
        case SLModelEncodingTypeUInt64: {
            ((void(*)(id,SEL,uint64_t))objc_msgSend)(model, meta.setter, (uint64_t)number.unsignedLongLongValue);
        }
            break;
        case SLModelEncodingTypeFloat: {
            ((void(*)(id,SEL,float))objc_msgSend)(model, meta.setter, (float)number.floatValue);
        }
            break;
        case SLModelEncodingTypeDouble: {
            ((void(*)(id,SEL,double))objc_msgSend)(model, meta.setter, (double)number.doubleValue);
        }
        case SLModelEncodingTypeLongDouble: {
            ((void(*)(id,SEL,long double))objc_msgSend)(model, meta.setter, (long double)number.doubleValue);
        }
        default:
            break;
    }
}
