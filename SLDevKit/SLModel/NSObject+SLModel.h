//
//  NSObject+SLModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SLModel)

/**
 *
 */
+ (nullable instancetype)sl_modelWithXML:(id)xml;

/**
 * json数据转model
 *
 * - Parameter json: json数据【NSString、NSData、NSDictionary】
 */
+ (nullable instancetype)sl_modelWithJson:(id)json;

/**
 * 字典转model
 *
 * - Parameter dictionary: 字典对象
 */
+ (nullable instancetype)sl_modelWithDictionary:(NSDictionary *)dictionary;

/**
 * 根据字典更新对象的属性值
 *
 * - Parameter dictionary: 字典对象
 */
- (BOOL)sl_modelSetWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
