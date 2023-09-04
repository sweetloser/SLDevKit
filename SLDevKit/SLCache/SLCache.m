//
//  SLCache.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import "SLCache.h"
#import "SLDiskCache.h"
#import "SLMemoryCache.h"

@interface SLCache ()

@property(nonatomic,strong)SLDiskCache *diskCache;
@property(nonatomic,strong)SLMemoryCache *memoryCache;

@end

@implementation SLCache

#pragma mark - 生命周期
- (instancetype)initWithName:(NSString *)name {
    if (name.length == 0) return nil;
    
    NSString *cacheFolder = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    
    return [self initWithPath:path];
}
- (instancetype)initWithPath:(NSString *)path {
    if (path.length == 0) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    NSString *name = [path lastPathComponent];
    _diskCache = [[SLDiskCache alloc] initWithPath:path];
    
    _memoryCache = [[SLMemoryCache alloc] init];
    _name = name;
    _path = path;
    
    return self;
}

#pragma mark - 业务代码
- (BOOL (^)(NSString * _Nonnull))containsObjectForKey_sl {
    return ^(NSString *key) {
        BOOL contains = (self->_memoryCache.containObjectForKey_sl(key) || self->_diskCache.containObjectForKey_sl(key));
        return contains;
    };
}
- (SLCache * _Nonnull (^)(id<NSCoding> _Nonnull, NSString * _Nonnull))cacheObjectWithKey_sl {
    return ^(id<NSCoding>obj, NSString *key) {
        self->_memoryCache.cacheObjectWithKey_sl(obj, key);
        self->_diskCache.cacheObjectWithKey_sl(obj, key);
        return self;
    };
}


@end
