//
//  UIView+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "SLFoundationUtils.h"

NS_ASSUME_NONNULL_BEGIN

#define SL_VIEW_PROP(D)     (UIView, D)

#define SL_VIEW_SUPER_PROPS(T)      \
                                    \
/**
 * 设置tag（tag)用法：
 * .tg(100)
 */                                 \
SL_PROP(T ,Int)tg;                  \
                                    \
/**
 * 设置透明度（alpha）
 * 用法：.opacity(0.5)
 */                                 \
SL_PROP(T ,Float)opacity;           \
                                    \
/**
 * 设置渲染色调（tintColor）
 * tint 内部使用的是 Color() 宏，因此能且仅能接受 Color() 宏可接受的参数
 * 用法：.tint(@"red")
 *      .tint(@"#F00")
 *      .tint(@"255,0,0")
 *      .tint([UIColor redColor])
 */                                 \
SL_PROP(T ,Object)tint;             \
                                    \
/**
 * 设置背景色（backgroundColor）
 * bgColor 内部使用的是 Color() 宏，因此能且仅能接受 Color() 宏可接受的参数
 * 用法：.bgColor(@"red")
 *      .bgColor(@"#F00")
 *      .bgColor(@"255,0,0")
 *      .bgColor([UIColor redColor])
 */                                 \
SL_PROP(T ,Object)bgColor;          \
                                    \
/**
 * 设置圆角（.layer.cornerRadius）
 * 设置borderRadius的同时，会将 .layer.masksToBounds 设置为 YES。
 * 用法：.borderRadius(10.f)
 */                                 \
SL_PROP(T ,Float)borderRadius;      \
/**
 * 设置边框（.layer.borderWidth 和 .layer.borderColor【第二个参数可选】）
 * 第二个参数内部使用的是 Color() 宏，因此能且仅能接受 Color() 宏可接受的参数
 * 用法：.border(1.5)
 *      .border(1.5, @"red")
 *      .border(1.5, @"#FF0000, 0.5")
 */                                  \
SL_PROP(T ,FloatObjectList)border;   \
                                     \
/**
 * 设置阴影（.layer.shadowOpacity 和 .layer.shadowRadius【默认值: 3】 和 layer.shadowOffset【默认值: 0, 3】）
 * 用法：.shadow(1) 【设置透明度，另外两个值使用默认值】
 *      .shadow(0.8, 1)【设置透明度和阴影圆角，阴影偏移使用默认值】
 *      .shadow(1, 2, 2, 2)【透明度为1，圆角为2，阴影偏移为 {2,2}】
 */                                 \
SL_PROP(T ,FloatList)shadow;        \
                                    \
/**
 * 在原有的响应范围内，扩展可交互范围【当数值为负数时，收缩可交互范围】
 * 用法：.touchInsets(10)                 top/left/bottom/right = 10
 *      .touchInsets(10, 20)             top/bottom = 10, left/right = 20
 *      .touchInsets(10, 20, 30)         top = 10, left/right = 20, bottom = 30
 *      .touchInsets(10, 20, 30, 40)     top = 10, left = 20, bottom = 30, right = 40
 */                                 \
SL_PROP(T ,Insets)touchInsets;      \
/**
 * 添加一个单点手势回调。如果self是UIButton，则添加一个touchUpInside事件。
 * 支持两种参数：1、回调block
 *            2、selector 字符串【用于：NSSelectorWithString()】
 */                                 \
SL_PROP(T ,CallBack)onClick;        \
                                    \
/**
 * 将self添加到父视图
 * 用法：.addTo(`父视图`)
 */                                 \
SL_PROP(T ,Object)addTo;            \
                                    \
/**
 * 添加子视图
 * 用法：.addChild(subView1,subView2,...)
 */                                 \
SL_PROP(T ,Object)addChild;

SL_DEFINE_CHAINABLE_BLOCKS(UIView);
@interface UIView (SLChainable)

SL_VIEW_SUPER_PROPS(UIView);

@end

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UILabel)

@interface UILabel (UIView_Chainable)
SL_VIEW_SUPER_PROPS(UILabel);
@end

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UIButton)
@interface UIButton (UIView_Chainable)
SL_VIEW_SUPER_PROPS(UIButton);
@end

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UIImageView)
@interface UIImageView (UIView_Chainable)
SL_VIEW_SUPER_PROPS(UIImageView);
@end

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UITextField)
@interface UITextField (UIView_Chainable)
SL_VIEW_SUPER_PROPS(UITextField);
@end


#define onClick(x)              onClick(self, ({ id __self = self; __weak typeof(self) self = __self; __self = self; x; }) )
#define border(...)             border(__VA_ARGS__, nil)
#define shadow(...)             shadow(SL_MAKE_FLOAT_LIST(__VA_ARGS__))
#define touchInsets(...)        touchInsets(SL_NORMALIZE_INSETS(__VA_ARGS__))
#define addChild(...)           addChild(@[__VA_ARGS__])

/// 判断参数是否为NSAttributedString对象；
/// 1）YES————获取NSAttributedString对象
/// 2） NO————格式化参数为NSString对象
#define str(...)                str(SL_IS_ATTSTRING_ARGS(__VA_ARGS__)? SL_RETURN_OBJECT(__VA_ARGS__): Str(__VA_ARGS__))

NS_ASSUME_NONNULL_END
