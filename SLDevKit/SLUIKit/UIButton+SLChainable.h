//
//  UIButton+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "UIView+SLChainable.h"
#import "SLUIKitPrivate.h"

NS_ASSUME_NONNULL_BEGIN

#define SLButton ([UIButton _sl_littleHigherHuggingAndResistanceButton])

#define SL_BUTTON_PROP(D)   SL_PROP(UIButton, D)

@interface UIButton (SLChainable)

/// 设置UIButton的 title 或者 attributedTitle
/// 参数类型：1）str内部使用Str 宏，因此，str属性可以接受Str宏能接受的参数
///         2）str还可以接受NSAttributedString对象作为参数
/// 用法：.str(100)
///      .str(@3.14)
///      .str(@"hello")
///      .str(@"%d+%d=%d",1,2,1+2)
///      .str(NSAttributedString对象)
SL_BUTTON_PROP(Object)str;

/// 设置titleLabel的font；
/// fnt 属性内部使用的是Fnt宏，因此，它可以接受所有 Fnt 宏能接受的参数；
/// 用法：.fnt(16)
///      .fnt(@16)
///      .fnt(@"headline")
///      .fnt(@"PingFang SC,15")
SL_BUTTON_PROP(Object)fnt;

/// 设置UIButton的textColor【UIControlStateNormal】
/// color 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.color(@"0xFFF")
///      .color(UIColor对象)
///      .color(@"red")
///      .color(@"255,40,40,0.5")
SL_BUTTON_PROP(Object)tColor;

/// 设置UIButton的textColor【UIControlStateSelected】
/// selectedColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.selectedColor(@"0xFFF")
///      .selectedColor(UIColor对象)
///      .selectedColor(@"red")
///      .selectedColor(@"255,40,40,0.5")
SL_BUTTON_PROP(Object)selectedColor;

/// 设置UIButton的textColor【UIControlStateHighlighted】
/// highColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.highColor(@"0xFFF")
///      .highColor(UIColor对象)
///      .highColor(@"red")
///      .highColor(@"255,40,40,0.5")
SL_BUTTON_PROP(Object)highColor;

/// 设置UIButton的image【UIControlStateNormal】
/// img 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.img(@"icon")    // 图片名
///      .img(UIImage对象)
///      .img(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)img;

/// 设置UIButton的selectedImage【UIControlStateSelected】
/// selectedImg 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.selectedImg(@"icon")    // 图片名
///      .selectedImg(UIImage对象)
///      .selectedImg(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)selectedImg;

/// 设置UIButton的highlightedImage【UIControlStateHighlighted】
/// highImg 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.highImg(@"icon")    // 图片名
///      .highImg(UIImage对象)
///      .highImg(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)highImg;

/// 设置UIButton的backgroundImage【UIControlStateNormal】
/// backgroundImage 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.backgroundImage(@"icon")    // 图片名
///      .backgroundImage(UIImage对象)
///      .backgroundImage(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)bgImg;

/// 设置UIButton的selectedBackgroundImage【UIControlStateSelected】
/// selectedBgImg 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.selectedBgImg(@"icon")    // 图片名
///      .selectedBgImg(UIImage对象)
///      .selectedBgImg(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)selectedBgImg;

/// 设置UIButton的highlightedBackgroundImage【UIControlStateHighlighted】
/// highBgImg 属性内部使用的是 Img 宏，因此它可以接受所有 Img 宏能接受的参数；
/// 用法：.highBgImg(@"icon")    // 图片名
///      .highBgImg(UIImage对象)
///      .highBgImg(@"#icon")   // 拉伸图
SL_BUTTON_PROP(Object)highBgImg;

SL_BUTTON_PROP(CallBack)onClick;

@end

NS_ASSUME_NONNULL_END
