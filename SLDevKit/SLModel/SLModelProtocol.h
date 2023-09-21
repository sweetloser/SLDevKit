//
//  SLModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SLModel <NSObject>

/**
 * 当属性为容器（NSArray、NSDictionary、NSSet）时，需通过重写该方法，返回容器对应的数据类型
 * 映射关系为：{"属性名":数据类}
 * key为属性值，value为类对象或者字符串
 *
 *eg. 在类`Person`中有如下容器属性：
 *      @property NSArray <Dog *>*dogs;
 *
 *    则需要实现`sl_modelContainerPropertyGenericClass`方法，并返回`Dog`类:
 *      + (NSDictionary <NSString *, id>*)sl_modelContainerPropertyGenericClass {
 *          return @{@"dogs": [Dog class]};
 *      }
 *
 *    或者:
 *      + (NSDictionary <NSString *, id>*)sl_modelContainerPropertyGenericClass {
 *          return @{@"dogs": @"Dog"};
 *      }
 */
+ (NSDictionary <NSString *, id>*_Nullable)sl_modelContainerPropertyGenericClass;

/**
 * map
 */
+ (nullable NSDictionary <NSString *, id> *)sl_modelCustomPropertyMapper;

- (NSDictionary *_Nullable)sl_modelCustomWillTransformFromDictionary:(NSDictionary *_Nullable)dic;
- (BOOL)sl_modelCustomTransformFromDictionary:(NSDictionary *_Nullable)dic;
- (BOOL)sl_modelCustomTransformToDictionary:(NSMutableDictionary *_Nullable)dic;
+ (nullable Class)sl_modelCustomClassForDictionary:(NSDictionary *_Nullable)dictionary;

@end

NS_ASSUME_NONNULL_END
