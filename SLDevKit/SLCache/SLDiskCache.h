//
//  SLDiskCache.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLDiskCache : NSObject

#pragma mark - 初始化方法
/**
 * 根据缓存地址初始化一个磁盘缓存对象
 *
 * - Parameter path: 缓存地址（全路径）
 */
- (instancetype)initWithPath:(NSString *)path;
/**
 * 根据缓存地址和数据大小限定值初始化一个磁盘缓存对象
 *
 * - Parameters:
 *   - path: 缓存地址（全路径）
 *   - threshold: 缓存大小限定值。当缓存数据的大小超过这个值时，数据将被缓存为文件；否则数据将被存储在数据库中
 *                默认值：20kb
 */
- (instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)threshold;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

#pragma mark - 配置方法
@property(nonatomic,copy,readonly)SLDiskCache *(^countLimit_sl)(NSUInteger countLimit);
@property(nonatomic,copy,readonly)SLDiskCache *(^timeLimit_sl)(NSTimeInterval time);

#pragma mark - 业务方法
/**
 * 缓存中是否包含指定key
 */
@property(nonatomic,copy,readonly)BOOL(^containObjectForKey_sl)(NSString *key);

/**
 * 缓存对象
 * 参数类型：
 *      1) 待缓存对象
 *      2) 缓存key
 */
@property(nonatomic,copy,readonly)SLDiskCache *(^cacheObjectWithKey_sl)(id<NSCoding> obj, NSString *key);

/**
 * 移除key对应的缓存对象
 */
@property(nonatomic,copy,readonly)SLDiskCache *(^removeObjectWithKey_sl)(NSString *key);

/**
 * 移除所有缓存对象
 */
@property(nonatomic,copy,readonly)SLDiskCache *(^removeAllObjects)(void);

/**
 * 获取指定key对应的缓存对象
 */
@property(nonatomic,copy,readonly)id<NSCoding> _Nullable (^objectForKeyAndUnchivedClasses_sl)(NSString *key, NSSet <Class>*unarchiveClasses);

@end

NS_ASSUME_NONNULL_END
