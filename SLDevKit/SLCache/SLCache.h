//
//  SLCache.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLCache : NSObject

@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,copy,readonly)NSString *path;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithPath:(NSString *)path;

/**
 * 缓存中是否包含指定key对应的对象
 */
@property(nonatomic,copy)BOOL(^containsObjectForKey_sl)(NSString *key);

/**
 * 缓存对象
 * 参数类型：
 *      1) 待缓存对象
 *      2) 缓存key
 */
@property(nonatomic,copy,readonly)SLCache *(^cacheObjectWithKey_sl)(id<NSCoding> obj, NSString *key);

/**
 * 获取指定key的缓存对象
 * 注：该方法仅从内存缓存中获取缓存对象
 *
 * 参数类型：
 *      1) 指定key
 */
@property(nonatomic,copy,readonly)id<NSCoding> (^objectForKey_sl)(NSString *key);

/**
 * 获取指定key的缓存对象
 * 注：该方法先从内存缓存中获取缓存对象，如果未获取到，则从磁盘缓存中获取缓存对象
 *
 * 参数类型：
 *      1) 指定key
 *      2) 从磁盘缓存中获取对象时，解档所需的类集合
 */
@property(nonatomic,copy,readonly)id<NSCoding> (^objectForKeyAndUnchivedClasses_sl)(NSString *key, NSSet <Class>*classes);

/**
 * 从缓存中删除缓存对象
 *
 * 参数类型：
 *      1) 指定key
 */
@property(nonatomic,copy,readonly)SLCache *(^removeObjectWithKey)(NSString *key);

/**
 * 清空缓存对象
 */
@property(nonatomic,copy,readonly)SLCache *(^removeAllObjects)(void);

@end

NS_ASSUME_NONNULL_END
