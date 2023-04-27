//
//  UIImageView+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/2/9.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "UIView+SLChainable.h"

NS_ASSUME_NONNULL_BEGIN

#define SLImageView ([UIImageView new])

#define SL_IMGVIEW_PROP(D)   SL_PROP(UIImageView, D)

@interface UIImageView (SLChainable)

/**
 * 设置 UIImageView 的 image 属性或者 animationImages 属性；
 * img 属性内部使用的是 Img 宏，因此它可以接受 Img 宏能接受的所有参数。
 * 用法：.img(@"imageName")
 *      .img(@"#imageName")
 *      .img(@"walk1",@"walk2",@"walk3")
 */
SL_IMGVIEW_PROP(Object)img;

/**
 * 设置 UIImageView 的 highlightedImage 属性或者 highlightedAnimationImages 属性；
 * highImg 属性内部使用的是 Img 宏，因此它可以接受 Img 宏能接受的所有参数。
 * 用法：.highImg(@"imageName")
 *      .highImg(@"#imageName")
 *      .highImg(@"walk1",@"walk2",@"walk3")
 */
SL_IMGVIEW_PROP(Object)highImg;

/**
 * 设置UIImageView 的 contentMode 属性
 * 用法：.cMode(UIViewContentModeScaleToFill)
 *      .cMode(UIViewContentModeScaleAspectFit)
 *
 */
SL_IMGVIEW_PROP(Int)cMode;
@end

NS_ASSUME_NONNULL_END
