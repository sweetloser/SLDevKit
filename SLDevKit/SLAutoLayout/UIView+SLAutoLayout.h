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

@property(nonatomic,strong)SLAutoLayoutModel *_Nullable ownLayoutModel;

@property(nonatomic,strong,readonly)NSMutableArray *autoLayoutModelsArray;


/// 设置固定宽度【设置了之后，宽度就不会在自动布局中被修改】
@property(nonatomic,copy)NSNumber *fixedWidth;

/// 设置固定高度【设置了之后，高度度就不会在自动布局中被修改】
@property(nonatomic,copy)NSNumber *fixedHeight;

/// 开始自动布局
SL_LAYOUT_MODEL_PROP(Empty)slLayout;

@end

NS_ASSUME_NONNULL_END
