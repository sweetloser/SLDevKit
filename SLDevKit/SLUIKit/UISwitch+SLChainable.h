//
//  UISwitch+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/9.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

#define SLSwitch ([UISwitch new])

#define SL_SWITCH_PROP(D)   SL_PROP(UISwitch, D)

SL_DEFINE_CHAINABLE_BLOCKS(UISwitch)

@interface UISwitch (SLChainable)

/// 设置 UISwitch 的 onTintColor 属性
/// onColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.onColor(@"0xFFF")
///      .onColor(UIColor对象)
///      .onColor(@"red")
///      .onColor(@"255,40,40,0.5")
SL_SWITCH_PROP(Object)onColor;

/// 设置 UISwitch 的 thumbTintColor 属性
/// thumbTintColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.thumbColor(@"0xFFF")
///      .thumbColor(UIColor对象)
///      .thumbColor(@"red")
///      .thumbColor(@"255,40,40,0.5")
SL_SWITCH_PROP(Object)thumbColor;

/// 设置 UISwitch 的 tintColor 属性
/// tintColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.outlineColor(@"0xFFF")
///      .outlineColor(UIColor对象)
///      .outlineColor(@"red")
///      .outlineColor(@"255,40,40,0.5")
SL_SWITCH_PROP(Object)outlineColor;


@end

NS_ASSUME_NONNULL_END
