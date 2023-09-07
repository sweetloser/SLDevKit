//
//  SLDiskCache.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import "SLDiskCache.h"
#import "SLKVStorage.h"
#import "SLKVStorageItem.h"
#import <CommonCrypto/CommonCrypto.h>

#pragma mark - 全局静态变量 & C函数定义
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
static void _SLDiskCacheInitGlobal(void);

/**
 * 从全局Map中获取`diskcache`对象
 * - Parameter path: map中`diskcache`对象的key
 */
static SLDiskCache *_SLDiskCacheGetGlobal(NSString *path);
/**
 * 将 `diskcache`对象存入map中
 * - Parameter cache: `diskcache`对象
 */
static void _SLDiskCacheSetGlobal(SLDiskCache *cache);

/**
 * 获取字符串对应的MD5值（大写）
 * - Parameter string: 字符串
 */
static __unused NSString *_SLDiskCacheMD5(NSString *string);

/**
 * 获取字符串对应的MD5值（小写）
 * - Parameter string: 字符串
 */
static NSString *_SLDiskCachemd5(NSString *string);

@interface SLDiskCache ()
@property(nonatomic,copy,readonly)NSString *path;
@property(nonatomic,assign,readonly)NSUInteger inlineThreshold;
@end
@implementation SLDiskCache {
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
    
    SLKVStorage *_kv;
    
    NSUInteger _countLimit;
    NSUInteger _costLimit;
    NSUInteger _timeLimit;
    NSTimeInterval _autoTrimInterval;
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
    if (!self) {
        return nil;
    }
    
    SLKVStorageType type;
    if (threshold == 0) {
        type = SLKVStorageTypeFile;
    } else if (threshold == NSUIntegerMax) {
        type = SLKVStorageTypeSQLite;
    } else {
        type = SLKVStorageTypeMixed;
    }
    _kv = [[SLKVStorage alloc] initWithPath:path type:type];
    if (!_kv) return nil;
    
    _path = path;
    _inlineThreshold = threshold;
    _lock = dispatch_semaphore_create(1);
    _queue = dispatch_queue_create("com.sweetloser.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    
    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _timeLimit = DBL_MAX;
    _autoTrimInterval = 60;
    
    [self _trimRecursively];
    // 存入map
    _SLDiskCacheSetGlobal(self);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
    
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

#pragma mark - 配置代码
- (SLDiskCache * _Nonnull (^)(NSUInteger))countLimit_sl {
    return ^(NSUInteger countLimit) {
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        self->_countLimit = countLimit;
        dispatch_semaphore_signal(self->_lock);
        return self;
    };
}
- (SLDiskCache * _Nonnull (^)(NSTimeInterval))timeLimit_sl {
    return ^(NSTimeInterval time) {
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        self->_timeLimit = time;
        dispatch_semaphore_signal(self->_lock);
        return self;
    };
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
- (SLDiskCache * _Nonnull (^)(void))removeAllObjects {
    return ^{
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [self->_kv removeAllItems];
        dispatch_semaphore_signal(self->_lock);
        return self;
    };
}
- (SLDiskCache * _Nonnull (^)(id<NSCoding> _Nonnull, NSString * _Nonnull))cacheObjectWithKey_sl {
    return ^(id<NSCoding> obj, NSString *key) {
        // 如果key为空，则不做任何操作
        if (!key) return self;
        
        // 如果缓存对象为空，则删除key对应的缓存
        if (!obj) {
            self.removeObjectWithKey_sl(key);
        }
        NSError *error;
        NSData *value = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:&error];
        if (error || value == nil) {
            NSLog(@"object archive error");
            return self;
        }
        
        NSString *fileName = nil;
        if (self->_kv.type != SLKVStorageTypeSQLite) {
            // 当缓存策略不为仅数据库缓存时，需考虑是否使用文件缓存
            if (value.length > self.inlineThreshold) {
                fileName = [self _fileNameForKey:key];
            }
        }
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [self->_kv saveItemWithKey:key value:value fileName:fileName extendedData:nil];
        dispatch_semaphore_signal(self->_lock);
        
        return self;
    };
}
- (id<NSCoding>  _Nullable (^)(NSString * _Nonnull, NSSet<Class> * _Nonnull))objectForKeyAndUnchivedClasses_sl {
    return ^(NSString *key, NSSet <Class>*unarchiveClasses) {
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        SLKVStorageItem *item = [self->_kv getItemForKey:key];
        dispatch_semaphore_signal(self->_lock);
        if (!item.value) return (id)nil;
        
        id object = nil;
        NSError *error = nil;
        object = [NSKeyedUnarchiver unarchivedObjectOfClasses:unarchiveClasses fromData:item.value error:&error];
        if (error != nil || object == nil) {
            NSLog(@"object unarchive error; %@", error);
            return (id)nil;
        };
        return object;
    };
}

#pragma mark - 通知
- (void)_appWillBeTerminated {
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
    self->_kv = nil;
    dispatch_semaphore_signal(self->_lock);
}

#pragma mark - 清理缓存
- (void)_trimRecursively {
    __weak typeof(self) _weak = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), queue, ^{
        __strong typeof(_weak) self = _weak;
        if (!self) return;
        
        [self _trimInBackground];
        [self _trimRecursively];
    });
}
- (void)_trimInBackground {
    __weak typeof(self) _weak = self;
    dispatch_async(_queue, ^{
        __strong typeof(_weak) self = _weak;
        if (!self) return;
        dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
        [self _trimToCount:self->_countLimit];
        [self _trimToCost:self->_costLimit];
        [self _trimToTime:self->_timeLimit];
        dispatch_semaphore_signal(self->_lock);
    });
}
- (void)_trimToCount:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX) return;
    [self->_kv removeItemsToFitCount:(int)countLimit];
}
- (void)_trimToCost:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX) return;
    [self->_kv removeItemsToFitSize:(int)costLimit];
}
- (void)_trimToTime:(NSTimeInterval)timeLimit {
    if (timeLimit <= 0) {
        [self removeAllObjects];
        return;
    }
    
    long timestamp = time(NULL);
    if (timestamp <= timeLimit) {
        return;
    }
    
    long timeLine = timestamp - timeLimit;
    if (timeLine >= INT_MAX) return;
    
    [self->_kv removeItemsEarlierThanTime:(int)timeLine];
}

#pragma mark - tools
- (NSString *)_fileNameForKey:(NSString *)key {
    NSString *fileName = _SLDiskCachemd5(key);
    return fileName;
}

@end

#pragma mark - C函数实现
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
static __unused NSString *_SLDiskCacheMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
                @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0],  result[1],  result[2],  result[3],
                result[4],  result[5],  result[6],  result[7],
                result[8],  result[9],  result[10], result[11],
                result[12], result[13], result[14], result[15]
            ];
}
static NSString *_SLDiskCachemd5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0],  result[1],  result[2],  result[3],
                result[4],  result[5],  result[6],  result[7],
                result[8],  result[9],  result[10], result[11],
                result[12], result[13], result[14], result[15]
            ];
}
