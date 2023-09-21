//
//  NSArray+SLModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import "NSArray+SLModel.h"
#import "NSObject+SLModel.h"

@implementation NSArray (SLModel)

+ (NSArray *)sl_modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *array = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        array = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            array = nil;
        }
    }
    
    return [self sl_modelArrayWithClass:cls array:array];
}

+ (NSArray *)sl_modelArrayWithClass:(Class)cls array:(NSArray *)array {
    if (!array) return nil;
    NSMutableArray *retArray = [NSMutableArray new];
    for (NSDictionary *dict in array) {
        if (![dict isKindOfClass:[NSDictionary class]]) continue;
        
        NSObject *oneObj = [cls sl_modelWithDictionary:dict];
        if (oneObj) [retArray addObject:oneObj];
    }
    return retArray;
}

@end
