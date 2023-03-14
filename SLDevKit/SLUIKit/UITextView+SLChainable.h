//
//  UITextView+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "UIView+SLChainable.h"

#define SLTextView [UITextView new]

#define SL_TEXTVIEW_PROP(D)   SL_PROP(UITextView, D)

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (SLChainable)

SL_TEXTVIEW_PROP(Object)str;

SL_TEXTVIEW_PROP(Object)fnt;

SL_TEXTVIEW_PROP(Object)tColor;

SL_TEXTVIEW_PROP(Int)textAlign;

SL_TEXTVIEW_PROP(Insets)insets;

SL_TEXTVIEW_PROP(Int)editable_sl;

SL_TEXTVIEW_PROP(Int)scrollable_sl;

SL_TEXTVIEW_PROP(Object)delegate_sl;

SL_TEXTVIEW_PROP(Int)showHIndicator;

SL_TEXTVIEW_PROP(Int)showVIndicator;

@end

NS_ASSUME_NONNULL_END
