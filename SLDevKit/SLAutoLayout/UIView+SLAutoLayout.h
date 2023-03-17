//
//  UIView+SLAutoLayout.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <UIKit/UIKit.h>
#import "SLAutoLayoutModel.h"
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN


@interface UIView (SLAutoLayout)

/// 开始自动布局
SL_LAYOUT_MODEL_PROP(Empty)slLayout;

@end

NS_ASSUME_NONNULL_END
