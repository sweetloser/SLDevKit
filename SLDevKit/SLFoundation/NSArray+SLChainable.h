//
//  NSArray+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/9.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SLChainable)

/// 为数组中的每个元素调用一次参数所指定的block或者方法
/// 参数可以是：1）block
///           2）方法名
/// block参数：1）value：元素值；如果元素为int或者double类型的NSNumber，则可以使用基本数据类型
///           2）index：下标值；
///           3）array：数组自身；
/// 用法：subviews.forEach(@"removeFromSuperview")
///      subviews.forEach(^(UIView *view){[view removeFromSuperview];})
@property(nonatomic,readonly)NSArray *(^forEach)(id);

@end

NS_ASSUME_NONNULL_END
