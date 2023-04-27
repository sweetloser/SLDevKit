//
//  UITextView+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "UIView+SLChainable.h"

#define SLTextView ([UITextView new])

#define SL_TEXTVIEW_PROP(D)   SL_PROP(UITextView, D)

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (SLChainable)

/// 设置文本
SL_TEXTVIEW_PROP(Object)str;

/// 设置字体
SL_TEXTVIEW_PROP(Object)fnt;

/// 设置文字颜色
SL_TEXTVIEW_PROP(Object)tColor;

/// 设置文字对齐方式
SL_TEXTVIEW_PROP(Int)textAlign;

/// 设置文字内边距
SL_TEXTVIEW_PROP(Insets)insets;

/// 设置是否可编辑
SL_TEXTVIEW_PROP(Int)editable_sl;

/// 设置是否可以滑动
SL_TEXTVIEW_PROP(Int)scrollable_sl;

/// 设置代理
SL_TEXTVIEW_PROP(Object)delegate_sl;

/// 设置横向滑条是否显示
SL_TEXTVIEW_PROP(Int)showHIndicator;

/// 设置纵向滑条是否显示
SL_TEXTVIEW_PROP(Int)showVIndicator;

@end

NS_ASSUME_NONNULL_END
