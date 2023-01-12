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

@interface SLFoundationUtils : NSObject

/// 从可变参数中获取第一个参数【类型为id】
/// - Parameter placeholder:
id _sl_ObjectFromVariadicFunction(NSString *placeholder, ...);

@end

NS_ASSUME_NONNULL_END
