//
//  UIView+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

#define SL_VIEW_PROP(D)     SL_PROP(UIView, D)

SL_DEFINE_CHAINABLE_BLOCKS(UIView);

@interface UIView (SLChainable)

/// 设置tag（tag）
/// 用法：.tg(100)
SL_VIEW_PROP(Int)tg;

/// 设置透明度（alpha）
/// 用法：.opacity(0.5)
SL_VIEW_PROP(Float)opacity;


@end

NS_ASSUME_NONNULL_END
