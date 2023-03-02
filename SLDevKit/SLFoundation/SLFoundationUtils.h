//
//  SLFoundationUtils.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 从可变参数中获取x【第一个参数；类型为id】
#define SL_RETURN_OBJECT(x, ...)       _sl_ObjectFromVariadicFunction(@"placeholder", x)

/// 从可变参数中获取第一个参数【类型为id】
/// - Parameter placeholder:
id _sl_ObjectFromVariadicFunction(NSString *placeholder, ...);

@interface SLFoundationUtils : NSObject

/// json数据转字符串
/// - Parameter object: json数据【数组或者字典】
+ (NSString *)jsonStringWithObject:(id)object;

/// json字符串转数组或字典
/// - Parameter jsonString: json字符串
+ (id)jsonObjectFromJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
