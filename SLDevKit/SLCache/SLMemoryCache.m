//
//  SLMemoryCache.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/8/23.
//

#import "SLMemoryCache.h"
#import "SLLinkedMap.h"
#import "SLLinkedMapNode.h"
#import <pthread/pthread.h>

@interface SLMemoryCache () {
    SLLinkedMap *_linkedMap;
    pthread_mutex_t _threadLock;
    dispatch_queue_t _queue;
    
    NSUInteger _countLimit;
    NSTimeInterval _timeLimit;
    
    NSTimeInterval _autoTrimInterval;
    
    BOOL _releaseAsynchronously;
    BOOL _releaseOnMainThread;
    
    BOOL _shouldRemoveAllObjectsOnMemoryWarning;
    BOOL _shouldRemoveAllObjectsWhenEnteringBackground;
    
}
@end

@implementation SLMemoryCache

#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_threadLock, NULL);
        _linkedMap = [[SLLinkedMap alloc] init];
        _queue = dispatch_queue_create("com.sweetloser.cache.memory", DISPATCH_QUEUE_SERIAL);
        
        _countLimit = NSIntegerMax;
        _timeLimit = DBL_MAX;
        
        _autoTrimInterval = 6;
        
        _releaseAsynchronously = YES;
        _releaseOnMainThread = NO;
        
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        _shouldRemoveAllObjectsWhenEnteringBackground = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self _trimRecursively];
    }
    return self;
}
- (void)dealloc {
    // 清空缓存
    [_linkedMap removeAllNodes];
    // 移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 释放锁
    pthread_mutex_destroy(&_threadLock);
}

#pragma mark - 业务配置
- (SLMemoryCache * _Nonnull (^)(NSUInteger))countLimit_sl {
    return ^(NSUInteger countLimit) {
        self->_countLimit = countLimit;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(NSTimeInterval))timeLimit_sl {
    return ^(NSTimeInterval timeLimit) {
        self->_timeLimit = timeLimit;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(NSTimeInterval))autoTrimInterval_sl {
    return ^(NSTimeInterval time) {
        self->_autoTrimInterval = time;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(BOOL))releaseAsynchronously_sl {
    return ^(BOOL flag) {
        self->_releaseAsynchronously = flag;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(BOOL))releaseOnMainThread_sl {
    return ^(BOOL flag) {
        self->_releaseOnMainThread = flag;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(BOOL))shouldRemoveAllObjectsOnMemoryWarning_sl {
    return ^(BOOL flag) {
        self->_shouldRemoveAllObjectsOnMemoryWarning = flag;
        return self;
    };
}
- (SLMemoryCache * _Nonnull (^)(BOOL))shouldRemoveAllObjectsWhenEnteringBackground_sl {
    return ^(BOOL flag) {
        self->_shouldRemoveAllObjectsWhenEnteringBackground = flag;
        return self;
    };
}

#pragma mark - 业务处理
- (SLMemoryCache * _Nonnull (^)(id _Nonnull, id _Nonnull))cacheObjectWithKey_sl {
    return ^(id obj, id key) {
        pthread_mutex_lock(&self->_threadLock);
        SLLinkedMapNode *node = [self->_linkedMap nodeForKey:key];
        NSTimeInterval nowTime = CACurrentMediaTime();
        if (node) {
            // key对应的对象已经缓存过，需要更新
            node.value = obj;
            node.time = nowTime;
            [self->_linkedMap bringNodeToHead:node];
        } else {
            // 第一次缓存该key
            node = [[SLLinkedMapNode alloc] init];
            node.key = key;
            node.value = obj;
            node.time = nowTime;
            [self->_linkedMap insertNodeAtHead:node];
        }
        
        // 检测添加缓存后，有没有超过限制
        if (self->_linkedMap.totalCount > self->_countLimit) {
            __unused SLLinkedMapNode *node = [self->_linkedMap removeTailNode];
            // 释放对象
            if (self->_releaseAsynchronously) {
                dispatch_queue_t queue = self->_releaseOnMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                dispatch_async(queue, ^{
                    [node class];   // 无意义，仅为持有node对象
                });
            } else if (self->_releaseOnMainThread && !pthread_main_np()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [node class];
                });
            }
        }
        pthread_mutex_unlock(&self->_threadLock);
        return self;
    };
}

- (id  _Nonnull (^)(id _Nonnull))objectForKey_sl {
    return ^(id key) {
        if (!key) {
            return (id)nil;
        }
        pthread_mutex_lock(&self->_threadLock);
        SLLinkedMapNode *node = [self->_linkedMap nodeForKey:key];
        if (node) {
            node.time = CACurrentMediaTime();
            [self->_linkedMap bringNodeToHead:node];
        }
        pthread_mutex_unlock(&self->_threadLock);
        return node?node.value:(id)nil;
    };
}

- (SLMemoryCache * _Nonnull (^)(id _Nonnull))removeObjectWithKey_sl {
    return ^(id key) {
        if (!key) {
            return self;
        }
        pthread_mutex_lock(&self->_threadLock);
        SLLinkedMapNode *node = [self->_linkedMap nodeForKey:key];
        if (node) {
            [self->_linkedMap removeNode:node];
            
            // 释放对象
            if (self->_releaseAsynchronously) {
                dispatch_queue_t queue = self->_releaseOnMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                dispatch_async(queue, ^{
                    [node class];   // 无意义，仅为持有node对象
                });
            } else if (self->_releaseOnMainThread && !pthread_main_np()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [node class];
                });
            }
        }
        pthread_mutex_unlock(&self->_threadLock);
        return self;
    };
}

- (SLMemoryCache * _Nonnull (^)(void))removeAllObjects_sl {
    return ^{
        pthread_mutex_lock(&self->_threadLock);
        [self->_linkedMap removeAllNodes];
        pthread_mutex_unlock(&self->_threadLock);
        return self;
    };
}

- (SLMemoryCache * _Nonnull (^)(NSUInteger))trimCacheToCount_sl {
    return ^(NSUInteger count) {
        
        BOOL finish = NO;
        pthread_mutex_lock(&self->_threadLock);
        // 当前缓存数没有超过`count`
        if (self->_totalCount < count) {
            finish = YES;
        }
        // 清空
        if (count == 0) {
            [self->_linkedMap removeAllNodes];
            finish = YES;
        }
        pthread_mutex_unlock(&self->_threadLock);
        
        if (finish) return self;
        
        NSMutableArray *strongRefNodes = [NSMutableArray new];
        
        while (!finish) {
            if (pthread_mutex_trylock(&self->_threadLock) == 0) {
                if (self->_linkedMap.totalCount > count) {
                    __unused SLLinkedMapNode *node = [self->_linkedMap removeTailNode];
                    [strongRefNodes addObject:node];
                } else {
                    finish = YES;
                }
                pthread_mutex_unlock(&self->_threadLock);
            } else {
                usleep(10 * 1000); //10 ms
            }
        }
        
        // 释放对象
        if (strongRefNodes.count) {
            dispatch_queue_t queue = self->_releaseOnMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(queue, ^{
                [strongRefNodes count]; // 无意义，仅为持有数组中的node对象
            });
        }
        
        return self;
    };
}

- (SLMemoryCache * _Nonnull (^)(NSTimeInterval))trimCacheToTime_sl {
    return ^(NSTimeInterval time) {
        BOOL finish = NO;
        NSTimeInterval nowTime = CACurrentMediaTime();
        pthread_mutex_lock(&self->_threadLock);
        if (time <= 0) {
            // 当限定时间小于等于0时，删除所有缓存
            [self->_linkedMap removeAllNodes];
            finish = YES;
        } else if (!self->_linkedMap.tailNode || (nowTime - self->_linkedMap.tailNode.time) <= time) {
            // 不存在尾元素 或者 尾元素缓存时间未超过限定时间
            finish = YES;
        }
        pthread_mutex_unlock(&self->_threadLock);
        if (finish) return self;
        
        NSMutableArray *strongRefNodes = [NSMutableArray new];
        
        while (!finish) {
            if (pthread_mutex_trylock(&self->_threadLock) == 0) {
                if (self->_linkedMap.tailNode && (nowTime - self->_linkedMap.tailNode.time) > time) {
                    // 尾元素缓存时间超过限定时间,删除尾元素
                    __unused SLLinkedMapNode *node = [self->_linkedMap removeTailNode];
                    [strongRefNodes addObject:node];
                } else {
                    finish = YES;
                }
                pthread_mutex_unlock(&self->_threadLock);
            } else {
                usleep(10 * 1000);
            }
        }
        
        // 释放对象
        if (strongRefNodes.count) {
            dispatch_queue_t queue = self->_releaseOnMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(queue, ^{
                [strongRefNodes count]; // 无意义，仅为持有数组中的node对象
            });
        }
        
        return self;
    };
}
- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}
- (void)_trimInBackground {
    dispatch_async(_queue, ^{
        self.trimCacheToTime_sl(self->_timeLimit).trimCacheToCount_sl(self->_countLimit);
    });
}

#pragma mark - 通知
- (void)_appDidReceiveMemoryWarningNotification {
    if (self->_shouldRemoveAllObjectsOnMemoryWarning) {
        self.removeAllObjects_sl();
    }
}
-(void) _appDidEnterBackgroundNotification {
    if (self->_shouldRemoveAllObjectsWhenEnteringBackground) {
        self.removeAllObjects_sl();
    }
}
@end

