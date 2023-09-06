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
#pragma mark - 缓存配置
- (SLCache * _Nonnull (^)(NSUInteger))countLimit_sl {
    return ^(NSUInteger countLimit) {
        self->_memoryCache.countLimit_sl(countLimit);
        return self;
    };
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
- (id<NSCoding>  _Nonnull (^)(NSString * _Nonnull))objectForKey_sl {
    return ^(NSString *key) {
        id<NSCoding> object = self->_memoryCache.objectForKey_sl(key);
        return object;
    };
}
- (id<NSCoding>  _Nonnull (^)(NSString * _Nonnull, NSSet<Class> * _Nonnull))objectForKeyAndUnchivedClasses_sl {
    return ^(NSString *key, NSSet <Class>*classes) {
        id<NSCoding> object = self.objectForKey_sl(key);
        if (!object) {
            object = self->_diskCache.objectForKeyAndUnchivedClasses_sl(key, classes);
            if (object) {
                self.memoryCache.cacheObjectWithKey_sl(key, object);
            }
        }
        return object;
    };
}
- (SLCache * _Nonnull (^)(NSString * _Nonnull))removeObjectWithKey {
    return ^(NSString *key) {
        if (key.length == 0) return self;
        
        self.memoryCache.removeObjectWithKey_sl(key);
        self.diskCache.removeObjectWithKey_sl(key);
        
        return self;
    };
}
- (SLCache * _Nonnull (^)(void))removeAllObjects {
    return ^{
        self.memoryCache.removeAllObjects_sl();
        self.diskCache.removeAllObjects();
        return self;
    };
}

@end
