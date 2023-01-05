//
//  SLUIKitUtils.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

/// 顶部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceTop(void);

/// 底部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceBottom(void);

/// 顶部状态栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _statusBarHeight(void);

/// 导航栏高度
__attribute__((always_inline)) CGFloat _navigationBarHeight(void);

/// 状态栏+导航栏的高度
__attribute__((always_inline)) CGFloat _navigationFullHeight(void);

/// 底部导航栏高度
__attribute__((always_inline)) CGFloat _tabBarHeight(void);

/// 底部导航栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _tabBarFullHeight(void);

/// 将inset标准化
/// eg.{1}=>{1,1,1,1}
///    {1,2}=>{1,2,1,2}
///    {1,2,3}=>{1,2,2,3}
///    {1,2,3,4}=>{1,2,3,4}
/// - Parameters:
///   - insets:
///   - number:
UIEdgeInsets SLConvertSLEdgeInsetsToUIEdgeInsets(SLEdgeInsets insets, NSInteger number);

@interface SLUIKitUtils : NSObject

/// 从一个obj中创建UIColor对象
/// - Parameter object:参数可以是:@"#FFFFFF"
///                              @"FFF"
///                              @"200,100,100"
///                              @"#FFF,0.5"
///                              UIColor对象
///                              UIImage对象
+(UIColor *)_colorWithColorObject:(id)object;

/// 从一个obj中创建一个UIFont对象
/// - Parameter object: 参数可以是：@"body"   固定的系统字体
///                               @15       指定字号的加粗字体
///                               @"15"     指定字号的系统字体
///                               @"PingFang SC, 16"    指定字体名+字号
///                               UIFont对象 返回参数本身
+(UIFont *)_fontWithFontObject:(id)object;

@end


NS_ASSUME_NONNULL_END
