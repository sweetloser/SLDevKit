//
//  _SLModelMeta.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import "_SLModelMeta.h"
#import "SLMemoryCache.h"

@implementation _SLModelMeta

+ (instancetype)metaWithClass:(Class)cls {
    static SLMemoryCache *memoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memoryCache = [[SLMemoryCache alloc] init];
    });
    _SLModelMeta *modelMeta = memoryCache.objectForKey_sl(cls);
    if (!modelMeta) {
        modelMeta = [[_SLModelMeta alloc] initWithClass:cls];
        memoryCache.cacheObjectWithKey_sl(modelMeta, cls);
    }
    return modelMeta;
}

- (instancetype)initWithClass:(Class)cls {
    _classInfo = [_SLModelClassInfo classInfoWithClass:cls];
    if (!_classInfo) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    return self;
}



@end
