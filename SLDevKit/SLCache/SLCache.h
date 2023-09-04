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

@end

NS_ASSUME_NONNULL_END
