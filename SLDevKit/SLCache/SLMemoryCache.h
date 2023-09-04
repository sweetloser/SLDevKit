//
//  SLMemoryCache.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLMemoryCache : NSObject

/**
 * 当前缓存数
 */
@property(nonatomic,assign,readonly)NSUInteger totalCount;

/**
 * 总成本
 */
@property(nonatomic,assign,readonly)NSUInteger totalCost;

/**
 * 设置释放对象的时机
 * releaseAsynchronously_sl - 是否异步释放 默认YES
 * releaseOnMainThread_sl - 是否在主线程释放 默认NO
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^releaseAsynchronously_sl)(BOOL);
@property(nonatomic,copy,readonly)SLMemoryCache *(^releaseOnMainThread_sl)(BOOL);


/**
 * 配置缓存的最大容量
 * 默认值为`NSUIntegerMax`;
 * 注：这并不是一个严格的限制，当缓存数超过限制时，程序会在后台线程中逐渐清除；
 *
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^countLimit_sl)(NSUInteger);

/**
 * 配置缓存的最长时长，单位为秒
 * 默认值为`DBL_MAX`
 * 注：这并不是一个严格的限制，当缓存时长超过限制时，程序会在后台线程中逐渐清楚缓存；
 *
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^timeLimit_sl)(NSTimeInterval);

/**
 * 自动清除缓存的间隔时间，单位为秒
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^autoTrimInterval_sl)(NSTimeInterval);

/**
 * 是否在程序收到内存警告时释放所有缓存
 * 默认值为YES
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^shouldRemoveAllObjectsOnMemoryWarning_sl)(BOOL);

/**
 * 是否在程序进入后台时释放所有缓存
 * 默认值为YES
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^shouldRemoveAllObjectsWhenEnteringBackground_sl)(BOOL);

/**
 * 缓存对象
 * 参数类型：
 *      1) 待缓存对象
 *      2) 缓存key
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^cacheObjectWithKey_sl)(id obj, id key);

/**
 * 缓存对象
 * 参数类型：
 *      1) 待缓存对象
 *      2) 缓存key
 *      3) 缓存对象的消耗量（成本）
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^cacheObjectWithKeyAndCost_sl)(id obj, id key, NSUInteger cost);

/**
 * 缓存中是否包含指定key
 */
@property(nonatomic,copy,readonly)BOOL(^containObjectForKey_sl)(NSString *key);

/**
 * 获取key对应的缓存对象
 */
@property(nonatomic,copy,readonly)id(^objectForKey_sl)(id key);

/**
 * 移除key对应的缓存对象
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^removeObjectWithKey_sl)(id);

/**
 * 移除缓存中的所有对象
 */
@property(nonatomic,copy)SLMemoryCache *(^removeAllObjects_sl)(void);

/**
 * 清除缓存到指定数量以下
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^trimCacheToCount_sl)(NSUInteger);

/**
 * 清除缓存到指定时间内
 */
@property(nonatomic,copy,readonly)SLMemoryCache *(^trimCacheToTime_sl)(NSTimeInterval);


@end

NS_ASSUME_NONNULL_END
