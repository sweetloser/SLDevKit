//
//  UIColor+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "SLUIKitUtils.h"

NS_ASSUME_NONNULL_BEGIN

/// Usages: Color([UIColor redColor]),
///         Color(@"red"),
///         Color(@"red,0.5"),
///         Color(@"255,0,0,1"),
///         Color(@"#F00,0.5"),
///         Color(@"random,0.5")
#define Color(x)    [SLUIKitUtils _colorWithColorObject:x]

#define SL_COLOR_PROP(D) SL_PROP(UIColor, D)

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UIColor)

@interface UIColor (SLChainable)

/// 设置透明度
/// eg: .opacity(0.1)
SL_COLOR_PROP(Float)opacity;

/// color的HSB色彩模式(即色度、饱和度、亮度模式)中的色度调整
/// eg: .hueOffset(0.4)  hueOffset(-0.8)
SL_COLOR_PROP(Float)hueOffset;

/// color的HSB色彩模式(即色度、饱和度、亮度模式)中的饱和度增加
/// 取值范围:[0,1]
/// eg: .saturate(0.3)
SL_COLOR_PROP(Float)saturate;

/// color的HSB色彩模式(即色度、饱和度、亮度模式)中的饱和度降低
/// 取值范围:[0,1]
/// eg: .desaturate(0.3)
SL_COLOR_PROP(Float)desaturate;

/// color的HSB色彩模式(即色度、饱和度、亮度模式)中的亮度增加(变亮)
/// 取值范围:[0,1]
/// eg: .brighten(0.3)
SL_COLOR_PROP(Float)brighten;

/// color的HSB色彩模式(即色度、饱和度、亮度模式)中的亮度降低(变暗)
/// 取值范围:[0,1]
/// eg: .darken(0.3)
SL_COLOR_PROP(Float)darken;
@end

NS_ASSUME_NONNULL_END
