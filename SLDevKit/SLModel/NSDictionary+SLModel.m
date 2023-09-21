//
//  NSDictionary+SLModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import "NSDictionary+SLModel.h"
#import "NSObject+SLModel.h"

@implementation NSDictionary (SLModel)

+ (NSDictionary *)sl_modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSDictionary *dict = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dict = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        if (![dict isKindOfClass:[NSDictionary class]]) dict = nil;
    }
    
    return [self sl_modelDictionaryWithClass:cls dictionary:dict];
}

+ (NSDictionary *)sl_modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dictionary {
    if (!dictionary) return nil;
    
    NSMutableDictionary *retDictionary = [NSMutableDictionary new];
    for (NSString *key in dictionary.allKeys) {
        if (![key isKindOfClass:[NSString class]]) continue;
        
        NSObject *newObj = [cls sl_modelWithDictionary:dictionary[key]];
        if (newObj) retDictionary[key] = newObj;
    }
    return retDictionary;
}

@end
