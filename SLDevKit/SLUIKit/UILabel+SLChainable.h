//
//  UILabel+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/11.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "UIView+SLChainable.h"

NS_ASSUME_NONNULL_BEGIN

#define SL_LABEL_PROP(D)   SL_PROP(UILabel, D)

@interface UILabel (SLChainable)

/// 设置UILabel的text或者attributedText
/// str 属性内部使用的是 Str 宏，因此，可以接受所有 Str 宏能接受的参数；同时，str 也接受一个NSAttributedString对象的参数。
/// 用法：.str(3.14)
///      .str(@"%d+%d=%d",1,2,1+2)
///      .str(AttStr(@"hello").fnt(16))
SL_LABEL_PROP(Object)str;

/// 设置UILabel的font；
/// fnt 属性内部使用的是Fnt宏，因此，它可以接受所有 Fnt 宏能接受的参数；
/// 用法：.fnt(16)
///      .fnt(@16)
///      .fnt(@"headline")
///      .fnt(@"PingFang SC,15")
SL_LABEL_PROP(Object)fnt;

/// 设置UILabel的textColor
/// tColor 属性内部使用的是 Color 宏，因此它可以接受所有 Color 宏能接受的参数；
/// 用法：.tColor(@"0xFFF")
///      .tColor(UIColor对象)
///      .tColor(@"red")
///      .tColor(@"255,40,40,0.5")
SL_LABEL_PROP(Object)tColor;

/// 设置UILabel的numberOfLines；
/// 用法：.lines(2)
///      .lines(0)
SL_LABEL_PROP(Int)lines;

/// 设置UILabel的textAlignment；
/// 参数为`NSTextAlignment`枚举
/// 用法：.textAlign
SL_LABEL_PROP(Int)textAlign;

@end

NS_ASSUME_NONNULL_END
