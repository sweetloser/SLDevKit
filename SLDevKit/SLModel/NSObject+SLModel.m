//
//  NSObject+SLModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import "NSObject+SLModel.h"
#import "_SLModelMeta.h"

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
    return NO;
}

@end
