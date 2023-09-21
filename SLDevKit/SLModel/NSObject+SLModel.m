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
#import "_SLModelTools.h"
#import "SLModelProtocol.h"

typedef struct {
    void * _Nullable modelMeta;
    void * _Nullable model;
    void * _Nullable dictionary;
} SLModelSetContext;


static void sl_modelSetWithDictionaryFunction(const void *_key, const void *_value, void *context);
static void sl_modelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context);

static NSNumber *sl_numberCreateFromID(__unsafe_unretained id _id);
static void sl_modelSetNumberToProperty(__unsafe_unretained id model, __unsafe_unretained NSNumber *number, __unsafe_unretained _SLModelClassPropertyMeta *meta);
static void sl_modelSetValueForProperty(__unsafe_unretained id model, __unsafe_unretained id value, __unsafe_unretained _SLModelClassPropertyMeta *meta);
static NSDate *_sl_NSDateFromString(__unsafe_unretained NSString *string);
static Class _sl_NSBlockClass(void);

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
            CFIndex count = CFArrayGetCount((CFArrayRef)modelMeta.keyPathPropertyMetas);
            CFArrayApplyFunction((CFArrayRef)modelMeta.keyPathPropertyMetas, CFRangeMake(0, count), (CFArrayApplierFunction)sl_modelSetWithPropertyMetaArrayFunction, &context);
        }
        
        if (modelMeta.multiKeysPropertyMetas) {
            CFIndex count = CFArrayGetCount((CFArrayRef)modelMeta.multiKeysPropertyMetas.count);
            CFArrayApplyFunction((CFArrayRef)modelMeta.multiKeysPropertyMetas, CFRangeMake(0, count), (CFArrayApplierFunction)sl_modelSetWithPropertyMetaArrayFunction, &context);
        }
        
    } else {
        CFIndex count = CFArrayGetCount((CFArrayRef)modelMeta.allPropertyMetas);
        CFArrayApplyFunction((CFArrayRef)modelMeta.allPropertyMetas, CFRangeMake(0, count), (CFArrayApplierFunction)sl_modelSetWithPropertyMetaArrayFunction, &context);
    }
    
    if (modelMeta.hasCustomTransformFromDictionary) {
        return [(id<SLModel>)self sl_modelCustomTransformFromDictionary:dictionary];
    }
    return YES;
}


@end

static id _sl_valueForKeyPath(__unsafe_unretained NSDictionary *dictionary, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    NSUInteger count = keyPaths.count;
    for (NSUInteger idx = 0; idx < count; idx++) {
        value = dictionary[keyPaths[idx]];
        if (idx + 1 < count) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dictionary = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

static id _sl_valueForMultiKeys(__unsafe_unretained NSDictionary *dictionary, __unsafe_unretained NSArray *multiKeys) {
    id value = nil;
    for (NSString *key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dictionary[key];
            if (value) break;
        } else {
            value = _sl_valueForKeyPath(dictionary, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}

static void sl_modelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context) {
    SLModelSetContext *context = _context;
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)context->dictionary;
    __unsafe_unretained _SLModelClassPropertyMeta *propertyMeta = (__bridge _SLModelClassPropertyMeta *)_propertyMeta;
    if (!propertyMeta.setter) return;
    
    id value = nil;
    
    if (propertyMeta.mappedToKeyArray) {
        value = _sl_valueForMultiKeys(dictionary, propertyMeta.mappedToKeyArray);
    } else if (propertyMeta.mappedToKeyPath) {
        value = _sl_valueForKeyPath(dictionary, propertyMeta.mappedToKeyPath);
    } else {
        value = [dictionary objectForKey:propertyMeta.mappedToKey];
    }
    
    if (value) {
        __unsafe_unretained id model = (__bridge id)context->model;
        sl_modelSetValueForProperty(model, value, propertyMeta);
    }
}

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
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, _sl_NSDateFromString(value));
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *urlString = [(NSString *)value stringByTrimmingCharactersInSet:set];
                        if (urlString.length == 0) {
                            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, nil);
                        } else {
                            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, [NSURL URLWithString:urlString]);
                        }
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSArray:
                case SLModelEncodingNSTypeNSMutableArray: {
                    
                    NSArray *valueArr = nil;
                    if ([value isKindOfClass:[NSArray class]]) {
                        valueArr = value;
                    } else if ([value isKindOfClass:[NSSet class]]) {
                        valueArr = [(NSSet *)value allObjects];
                    }
                    
                    if (!valueArr) break;
                    
                    if (meta.genericCls) {
                        NSMutableArray *objArray = [NSMutableArray new];
                        for (id one in valueArr) {
                            if ([one isKindOfClass:meta.genericCls]) {
                                [objArray addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = meta.genericCls;
                                if (meta.hasCustomClassFromDictionary) {
                                    cls = [cls sl_modelCustomClassForDictionary:one];
                                    if (!cls) cls = meta.genericCls;
                                }
                                NSObject *newOne = [cls new];
                                [newOne sl_modelSetWithDictionary:one];
                                if (newOne) [objArray addObject:newOne];
                            }
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, objArray);
                    } else {
                        id setValue = valueArr;
                        if (meta.nsType == SLModelEncodingNSTypeNSMutableArray) {
                            setValue = valueArr.mutableCopy;
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, setValue);
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSDictionary:
                case SLModelEncodingNSTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta.genericCls) {
                            NSMutableDictionary *dict = [NSMutableDictionary new];
                            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                if ([obj isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta.genericCls;
                                    if (meta.hasCustomClassFromDictionary) {
                                        cls = [cls sl_modelCustomClassForDictionary:obj];
                                        if (!cls) cls = meta.genericCls;
                                    }
                                    NSObject *newObj = [cls new];
                                    [newObj sl_modelSetWithDictionary:obj];
                                    if (newObj) dict[key] = newObj;
                                }
                            }];
                            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, dict);
                        } else {
                            if (meta.nsType == SLModelEncodingNSTypeNSDictionary) {
                                ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                            } else {
                                ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, [(NSDictionary *)value mutableCopy]);
                            }
                        }
                    }
                }
                    break;
                case SLModelEncodingNSTypeNSSet:
                case SLModelEncodingNSTypeNSMutableSet: {
                    NSSet *setValue = nil;
                    if ([value isKindOfClass:[NSSet class]]) {
                        setValue = value;
                    } else if ([value isKindOfClass:[NSArray class]]) {
                        setValue = [NSMutableSet setWithArray:value];
                    }
                    
                    if (!setValue) break;
                    
                    if (meta.genericCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in setValue) {
                            if ([one isKindOfClass:meta.genericCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = meta.genericCls;
                                if (meta.hasCustomClassFromDictionary) {
                                    cls = [cls sl_modelCustomClassForDictionary:one];
                                    if (!cls) cls = meta.genericCls;
                                }
                                NSObject *newObj = [cls new];
                                [newObj sl_modelSetWithDictionary:one];
                                if (newObj) [set addObject:newObj];
                            }
                        }
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, set);
                    } else {
                        if (meta.nsType == SLModelEncodingNSTypeNSSet) {
                            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, setValue);
                        } else {
                            ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, [(NSSet *)setValue mutableCopy]);
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    } else {
        BOOL isNull = (value == (id)kCFNull);
        switch (meta.type & SLModelEncodingTypeMask) {
            case SLModelEncodingTypeObject: {
                if (isNull) {
                    ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, nil);
                } else if ([value isKindOfClass:meta.cls] || !meta.cls) {
                    ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    NSObject *one = nil;
                    if (meta.getter) {
                        one = ((id(*)(id,SEL))objc_msgSend)(model, meta.getter);
                    }
                    if (one) {
                        [one sl_modelSetWithDictionary:value];
                    } else {
                        Class cls = meta.cls;
                        if (meta.hasCustomClassFromDictionary) {
                            cls = [cls sl_modelCustomClassForDictionary:value];
                            if (!cls) cls = meta.genericCls;
                        }
                        one = [cls new];
                        [one sl_modelSetWithDictionary:value];
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, one);
                    }
                }
            }
                break;
            case SLModelEncodingTypeClass: {
                if (isNull) {
                    ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, nil);
                } else {
                    if ([value isKindOfClass:[NSString class]]) {
                        // 是否为NSString
                        Class setClass = NSClassFromString(value);
                        if (setClass) {
                            ((void(*)(id,SEL,Class))objc_msgSend)(model, meta.setter, (Class)setClass);
                        }
                    } else {
                        // 是否为Class对象
                        Class metaClass = object_getClass(value);
                        if (metaClass) {
                            if (class_isMetaClass(metaClass)) {
                                ((void(*)(id,SEL,Class))objc_msgSend)(model, meta.setter, (Class)value);
                            }
                        }
                    }
                }
            }
                break;
            case SLModelEncodingTypeSEL: {
                if (isNull) {
                    ((void(*)(id,SEL,SEL))objc_msgSend)(model, meta.setter, (SEL)NULL);
                } else {
                    if ([value isKindOfClass:[NSString class]]) {
                        SEL setSel = NSSelectorFromString(value);
                        if (setSel) {
                            ((void(*)(id,SEL,SEL))objc_msgSend)(model, meta.setter, setSel);
                        }
                    }
                }
            }
                break;
            case SLModelEncodingTypeBlock: {
                if (isNull) {
                    ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, nil);
                } else {
                    if ([value isKindOfClass:_sl_NSBlockClass()]) {
                        // 判断value是否为block
                        ((void(*)(id,SEL,id))objc_msgSend)(model, meta.setter, value);
                    }
                }
            }
                break;
            case SLModelEncodingTypeStruct:
            case SLModelEncodingTypeUnion:
            case SLModelEncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = [(NSValue *)value objCType];
                    const char *metaType = meta.info.typeEncoding.UTF8String;
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta.name];
                    }
                }
            }
                break;
            case SLModelEncodingTypePoint:
            case SLModelEncodingTypeCString: {
                if (isNull) {
                    ((void(*)(id, SEL, void *))objc_msgSend)(model, meta.setter, NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    NSValue *setValue = (NSValue *)value;
                    if (setValue.objCType && strcmp(setValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))objc_msgSend)(model, meta.setter, setValue.pointerValue);
                    }
                }
            }
                break;
            default:
                break;
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

static NSDate *_sl_NSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate *(^SLNSDateParseBlock)(NSString *);
    #define kParseNum 34
    static SLNSDateParseBlock blocks[kParseNum+1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string){return [formatter dateFromString:string];};
        }
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.ssZ";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) {
                return [formatter1 dateFromString:string];
            };
            blocks[24] = ^(NSString *string) {
                return [formatter1 dateFromString:string] ?: [formatter2 dateFromString:string];
            };
            blocks[25] = ^(NSString *string) {
                return [formatter1 dateFromString:string];
            };
            blocks[28] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
            blocks[29] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
        }
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) {
                return [formatter1 dateFromString:string];
            };
            blocks[34] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
        }
    });
    if (!string) return nil;
    if (string.length > kParseNum) return nil;
    SLNSDateParseBlock parseBlock = blocks[kParseNum];
    if (!parseBlock) {
        return nil;
    }
    return parseBlock(string);
    #undef kParseNum
}

/**
 * 获取block的根类
 */
static Class _sl_NSBlockClass(void) {
    static Class blockClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_block_t tmpBlock = ^{};
        blockClass = [((NSObject *)tmpBlock) class];
        while (class_getSuperclass(blockClass) != [NSObject class]) {
            blockClass = class_getSuperclass(blockClass);
        }
    });
    return blockClass;
}
