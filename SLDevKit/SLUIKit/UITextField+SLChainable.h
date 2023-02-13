//
//  UITextField+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/2/10.
//

#import <UIKit/UIKit.h>
#import "UIView+SLChainable.h"

#define SL_TEXTFIELD_PROP(D)   SL_PROP(UITextField, D)
NS_ASSUME_NONNULL_BEGIN

@interface UITextField (SLChainable)

/// 设置UITextField的text属性或者attributedText属性
/// str 属性内部使用的是 Str 宏，因此，可以接受所有 Str 宏能接受的参数；同时，str 也接受一个NSAttributedString对象的参数。
/// 用法：.str(3.14)
///      .str(@"%d+%d=%d",1,2,1+2)
///      .str(AttStr(@"hello").fnt(16))
SL_TEXTFIELD_PROP(Object)str;

/// 设置UITextField的font；
/// fnt 属性内部使用的是Fnt宏，因此，它可以接受所有 Fnt 宏能接受的参数；
/// 用法：.fnt(16)
///      .fnt(@16)
///      .fnt(@"headline")
///      .fnt(@"PingFang SC,15")
SL_TEXTFIELD_PROP(Object)fnt;

/// 设置 UITextField 的 placeholder 属性或 attributedPlaceholder 属性
SL_TEXTFIELD_PROP(Object)hint;

/// 设置UITextField的textColor
/// tColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.tColor(@"0xFFF")
///      .tColor(UIColor对象)
///      .tColor(@"red")
///      .tColor(@"255,40,40,0.5")
SL_TEXTFIELD_PROP(Object)tColor;

/// 设置UITextField的textAlignment；
/// 参数为`NSTextAlignment`枚举
/// 用法：.textAlign(NSTextAlignmentCenter)
SL_TEXTFIELD_PROP(Int)textAlign;

/// 设置UITextField的secureTextEntry属性
/// 参数为BOOL类型
/// 用法：.secure(YES)
///      .secure(NO)
SL_TEXTFIELD_PROP(Int)secure;

/// 设置UITextField的clearButtonMode属性；
/// 参数为 UITextFieldViewMode枚举值
/// 用法：.clearMode(UITextFieldViewModeAlways)
///      .clearMode(UITextFieldViewModeWhileEditing)
SL_TEXTFIELD_PROP(Int)clearMode;

@end

NS_ASSUME_NONNULL_END
