//
//  SLDiskCache.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import "SLDiskCache.h"
#import "SLKVStorage.h"

/**
 * 磁盘对象集合
 */
static NSMapTable *_globalMapTables;
/**
 * 磁盘对象获取时使用的信号量
 */
static dispatch_semaphore_t _globalMapTableLock;

/**
 * 初始化全局变量 `_globalMapTables` 和 `_globalMapTableLock`
 *
 */
static void _SLDiskCacheInitGlobal(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalMapTables = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        _globalMapTableLock = dispatch_semaphore_create(1);
    });
}
static SLDiskCache *_SLDiskCacheGetGlobal(NSString *path) {
    if (path.length == 0) {
        return nil;
    }
    _SLDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalMapTableLock, DISPATCH_TIME_FOREVER);
    id cache = [_globalMapTables objectForKey:path];
    dispatch_semaphore_signal(_globalMapTableLock);
    return cache;
}
static void _SLDiskCacheSetGlobal(SLDiskCache *cache) {
    if (cache.path.length == 0) {
        return;
    }
    _SLDiskCacheInitGlobal();
    
    dispatch_semaphore_wait(_globalMapTableLock, DISPATCH_TIME_FOREVER);
    [_globalMapTables setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_globalMapTableLock);
}



@implementation SLDiskCache {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
    
    SLKVStorage *_kv;
}
#pragma mark - 生命周期
-(instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:20*1024];
}
- (instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)threshold {
    
    // 先从map中获取
    SLDiskCache *cache = _SLDiskCacheGetGlobal(path);
    if (cache) {
        return cache;
    }
    
    self = [super init];
    if (self) {
        _path = path;
        _inlineThreshold = threshold;
        
        _lock = dispatch_semaphore_create(1);
        _queue = dispatch_queue_create("com.sweetloser.cache.disk", DISPATCH_QUEUE_CONCURRENT);
        
        _kv = [[SLKVStorage alloc] initWithPath:path type:SLKVStorageTypeSQLite];
        
    }
    
    // 存入map
    _SLDiskCacheSetGlobal(self);
    
    return self;
}
- (void)dealloc {
    _inlineThreshold = 0;
    _path = nil;
}

#pragma mark - 业务代码
- (BOOL (^)(NSString * _Nonnull))containObjectForKey_sl {
    return ^(NSString *key) {
        return [self->_kv itemExistsForKey:key];
    };
}
- (SLDiskCache * _Nonnull (^)(NSString * _Nonnull))removeObjectWithKey_sl {
    return ^(NSString *key) {
        if (!key) return self;
        
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [self->_kv removeItemForKey:key];
        dispatch_semaphore_signal(self->_lock);
        
        return self;
    };
}
- (SLDiskCache * _Nonnull (^)(id<NSCoding> _Nonnull, NSString * _Nonnull))cacheObjectWithKey_sl {
    return ^(id<NSCoding> obj, NSString *key) {
        if (!key) return self;
        
        if (!obj) {
            self.removeObjectWithKey_sl(key);
        }
        
        
        return self;
    };
}


@end
