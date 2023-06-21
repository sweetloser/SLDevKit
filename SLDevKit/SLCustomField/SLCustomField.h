//
//  SLCustomField.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/5/30.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "SLUIKit.h"

@class SLCustomField;
NS_ASSUME_NONNULL_BEGIN

#define SL_CUSTOM_FIELD_PROP(D)   SL_PROP(SLCustomField, D)
SL_DEFINE_CHAINABLE_BLOCKS(SLCustomField)

@interface SLCustomField : UIView

/// 设置是否需要光标
/// 默认需要
SL_CUSTOM_FIELD_PROP(Bool)cursor_sl;

/// 设置验证码长度
SL_CUSTOM_FIELD_PROP(Int)coodLength_sl;

/// 显示【用于布局，或者改变了配置后的重新布局】
SL_CUSTOM_FIELD_PROP(Empty)show_sl;

/// 输入框的size
SL_CUSTOM_FIELD_PROP(TwoFloat)itemSize_sl;

/// 边框宽度
SL_CUSTOM_FIELD_PROP(Float)borderWidth_sl;

/// 边框圆角
SL_CUSTOM_FIELD_PROP(Float)borderRadius_sl;

/// 边框颜色【聚焦】
SL_CUSTOM_FIELD_PROP(Object)focusBorderColor_sl;

/// 边框颜色【已输入】
SL_CUSTOM_FIELD_PROP(Object)enteredBorderColor_sl;

/// 边框颜色【未输入】
SL_CUSTOM_FIELD_PROP(Object)emptyBorderColor_sl;

@end

NS_ASSUME_NONNULL_END
