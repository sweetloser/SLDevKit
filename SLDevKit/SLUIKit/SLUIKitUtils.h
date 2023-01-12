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

/// 创建一个UIImage对象
/// - Parameter object: 支持的参数类型：1）UIImage对象
///                                  2）@"图片名"
///                                  3）@"#图片名"  【以#为标识，创建可拉伸的图片】
///                                  4）Color宏支持的类型  【从指定颜色中创建一个UIImage对象】
+(UIImage *)_imageWithImageObject:(id)object;

/// 从一个UIColor对象中创建一个大小为1像素的UIImage对象
/// - Parameter color: color对象
+ (UIImage *)_onePointImageWithColor:(UIColor *)color;

/// 为控件设置text
/// - Parameters:
///   - stringObject: text对象【如果是NSString/NSAttributedString，则直接设置，否则将调用【NSObject description】将对象转化为NSString对象】
///   - view: 控件
+ (void)_setTextWithStringObject:(id)stringObject forView:(UIView *)view;

@end


NS_ASSUME_NONNULL_END
