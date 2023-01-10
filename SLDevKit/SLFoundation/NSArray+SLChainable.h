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
///           2）index：下标值；【可选参数】
///           3）array：数组本身；【可选参数】
/// 用法：subviews.forEach(@"removeFromSuperview")
///      subviews.forEach(^(UIView *view){[view removeFromSuperview];})
@property(nonatomic,readonly)NSArray *(^forEach)(id);

/// 数组中的每个元素替换为block的返回值
/// 注：此方法会创建一个新数组
/// block参数：1）value：元素值；如果元素为int或者double类型的NSNumber，则可以使用基本数据类型
///           2）index：下标值；【可选参数】
///           3）array：数组本身；【可选参数】
/// 用法：@[@"a", @"b", @"c"].map(^(NSString *text) {return [text uppercaseString];});
///      @[@"a", @"b", @"c"].map(^(NSString *text) {return @(text.UTF8String[0]);});
@property(nonatomic,readonly)NSArray *(^map)(id);

/// 提供一个测试元素的block，通过block的测试结果筛选元素
/// 注：此方法会创建一个新数组
/// block参数：1）value：元素值；如果元素为int或者double类型的NSNumber，则可以使用基本数据类型
///           2）index：下标值；【可选参数】
///           3）array：数组本身；【可选参数】
/// 用法：@[@10,@20,@30].filter(^(int value){return value>15;})
@property(nonatomic,readonly)NSArray *(^filter)(id);

/// 累加器；对数组中每个元素调用block块，将其累加为单个值
/// 参数列表：1）initialValue 作为累加器的初始值； 【可选参数】
///         2）block 累加器
/// block参数列表：1）accumulator 累加值；
///              2）value：元素值；如果元素为int或者double类型的NSNumber，则可以使用基本数据类型
///              3）index：下标值；【可选参数】
///              4）array：数组本身；【可选参数】
/// 注意：accumulator参数要和value参数同类型
@property(nonatomic,readonly)id(^reduce)(id,...);

@end

NS_ASSUME_NONNULL_END
