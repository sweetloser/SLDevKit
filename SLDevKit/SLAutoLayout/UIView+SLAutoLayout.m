//
//  UIView+SLAutoLayout.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "UIView+SLAutoLayout.h"
#import "SLAutoLayoutPrivate.h"
#import "SLFoundationPrivate.h"
#import "SLAutoLayoutModelItem.h"

@interface SLAutoLayoutModel ()

@property(nonatomic,strong)SLAutoLayoutModelItem *height;
@property(nonatomic,strong)SLAutoLayoutModelItem *width;
@property(nonatomic,strong)SLAutoLayoutModelItem *left;
@property(nonatomic,strong)SLAutoLayoutModelItem *right;
@property(nonatomic,strong)SLAutoLayoutModelItem *top;
@property(nonatomic,strong)SLAutoLayoutModelItem *bottom;

@property(nonatomic,strong) NSNumber *centerX;
@property(nonatomic,strong) NSNumber *centerY;

@property(nonatomic,strong)SLAutoLayoutModelItem *equalLeft;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalTop;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalRight;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalBottom;

@property(nonatomic,strong)SLAutoLayoutModelItem *equalCenterX;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalCenterY;

@property(nonatomic,strong)SLAutoLayoutModelItem *widthEqualHeight;
@property(nonatomic,strong)SLAutoLayoutModelItem *heightEqualWidth;

@property (nonatomic, strong) SLAutoLayoutModelItem *ratio_width;
@property (nonatomic, strong) SLAutoLayoutModelItem *ratio_height;

// 用来记录offset作用于哪个item；
@property(nonatomic,strong)SLAutoLayoutModelItem *lastModelItem;

/// 需要布局的view
@property(nonatomic,weak)UIView *needsAutoResizeView;

@end

@implementation UIView (SLAutoLayout)
+ (void)load {
    if (self == [UIView class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self _sl_exchengeMethods:@[@"layoutSubviews"] prefix:@"sl_"];
        });
    }
}

- (SLChainableSLAutoLayoutModelEmptyBlock)slLayout {
    return ^{
        SLAutoLayoutModel *layoutModel = [self sl_ownLayoutModel];
        if (!layoutModel) {
            layoutModel = [[SLAutoLayoutModel alloc] init];
            layoutModel.needsAutoResizeView = self;
            [self setSl_ownLayoutModel:layoutModel];
            [self.superview.sl_autoLayoutModelsArray addObject:layoutModel];
        }
        return layoutModel;
    };
}

/// hook UIView的`layoutSubviews`方法
- (void)sl_layoutSubviews {
    [self sl_layoutSubviews];
    
    [self _sl_layoutSubviewsHandle];
}

#pragma mark - private
- (void)_sl_layoutSubviewsHandle {
    if (self.sl_autoLayoutModelsArray.count) {
        [self.sl_autoLayoutModelsArray enumerateObjectsUsingBlock:^(SLAutoLayoutModel * _Nonnull layoutModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [self _sl_resizeWithLayoutModel:layoutModel];
        }];
    }
}
- (void)_sl_resizeWithLayoutModel:(SLAutoLayoutModel *)layoutModel {
    UIView *view = layoutModel.needsAutoResizeView;
    
    if (!view) {
        // 目标视图不存在
        return;
    }
    // 宽度
    [self _sl_layoutWidthWithView:view layoutModel:layoutModel];
    // 高度
    [self _sl_layoutHeightWithView:view layoutModel:layoutModel];
    // 左布局
    [self _sl_layoutLeftWithView:view layoutModel:layoutModel];
    // 右布局
    [self _sl_layoutRightWithView:view layoutModel:layoutModel];
    // 上布局
    [self _sl_layoutTopWithView:view layoutModel:layoutModel];
    // 下布局
    [self _sl_layoutBottomWithView:view layoutModel:layoutModel];
    
    // 中心布局
    [self _sl_layoutCenterWithView:view layoutModel:layoutModel];
}

- (void)_sl_layoutWidthWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.width) {
        view.width_sl(layoutModel.width.value.floatValue);
        view.fixedWidth = @(view.widthValue);
    } else if (layoutModel.ratio_width) {
        view.width_sl(layoutModel.ratio_width.refView.widthValue*layoutModel.ratio_width.value.floatValue);
        view.fixedWidth = @(view.widthValue);
    }
}

- (void)_sl_layoutHeightWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.height) {
        view.height_sl(layoutModel.height.value.floatValue);
        view.fixedHeight = @(view.heightValue);
    }else if (layoutModel.ratio_height) {
        view.height_sl(layoutModel.ratio_height.refView.heightValue*layoutModel.ratio_height.value.floatValue);
    }
}

- (void)_sl_layoutLeftWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.left) {
        SLAutoLayoutModelItem *leftItem = layoutModel.left;
        if (view.superview == leftItem.refView) {
            // 根据父视图进行左布局
            view.left_sl([leftItem.value floatValue]);
        } else {
            if (leftItem.refViewsArray.count) {
                CGFloat rightMax = INTMAX_MIN;
                // 寻找左边视图的最右值
                for (UIView *refView in leftItem.refViewsArray) {
                    if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.rightValue > rightMax) {
                        leftItem.refView = refView;
                        rightMax = refView.rightValue;
                    }
                }
            }
            view.left_sl(leftItem.refView.rightValue+[leftItem.value floatValue]);
        }
    } else if (layoutModel.equalLeft) {
        if (!view.fixedWidth) {
            if (layoutModel.needsAutoResizeView == view.superview) {
                view.width_sl(view.rightValue - (0+layoutModel.equalLeft.offset));
            } else {
                view.width_sl(view.rightValue - (layoutModel.equalLeft.refView.leftValue + layoutModel.equalLeft.offset));
            }
        }
        
        if (view.superview == layoutModel.equalLeft.refView) {
            view.left_sl(0+layoutModel.equalLeft.offset);
        } else {
            view.left_sl(layoutModel.equalLeft.refView.leftValue + layoutModel.equalLeft.offset);
        }
    }
}
- (void)_sl_layoutRightWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.right) {
        SLAutoLayoutModelItem *rightItem = layoutModel.right;
        if (rightItem.refView == view.superview) {
            // 根据父视图进行右布局
            if (view.fixedWidth == nil) {
                // 没有设置固定宽度，根据左右布局计算宽度
                view.width_sl(rightItem.refView.widthValue-rightItem.value.floatValue-view.leftValue);
            }
            view.right_sl(rightItem.refView.widthValue - [rightItem.value floatValue]);
        } else {
            if (rightItem.refViewsArray.count) {
                // 寻找右视图的最左边
                CGFloat leftMin = INT_MAX;
                for (UIView *refView in rightItem.refViewsArray) {
                    if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.leftValue < leftMin) {
                        rightItem.refView = refView;
                        leftMin = refView.leftValue;
                    }
                }
            }
            
            if (!view.fixedWidth) {
                // 没有设置宽度（根据左右布局，计算宽度）
                view.width_sl(rightItem.refView.leftValue-rightItem.value.floatValue-view.leftValue);
            }
            // 设置右布局（实际上设置origin.x）
            view.right_sl(rightItem.refView.leftValue-rightItem.value.floatValue);
        }
    } else if (layoutModel.equalRight) {
        if (!view.fixedWidth) {
            if (layoutModel.equalRight.refView == view.superview) {
                view.width_sl(layoutModel.equalRight.refView.widthValue - view.leftValue + layoutModel.equalRight.offset);
            } else {
                view.width_sl(layoutModel.equalRight.refView.rightValue - view.leftValue + layoutModel.equalRight.offset);
            }
        }
        
        view.right_sl(layoutModel.equalRight.refView.rightValue + layoutModel.equalRight.offset);
        if (view.superview == layoutModel.equalRight.refView) {
            view.right_sl(layoutModel.equalRight.refView.widthValue + layoutModel.equalRight.offset);
        }
    }
}
- (void)_sl_layoutTopWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.top) {
        SLAutoLayoutModelItem *topItem = layoutModel.top;
        if (topItem.refView == view.superview) {
            // 根据父视图布局
            view.top_sl(topItem.value.floatValue);
        } else {
            if (topItem.refViewsArray.count) {
                // 寻找上视图的最下边
                CGFloat topMin = INT_MIN;
                for (UIView *refView in topItem.refViewsArray) {
                    if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.bottomValue > topMin) {
                        topItem.refView = refView;
                        topMin = refView.bottomValue;
                    }
                }
            }
            
            view.top_sl(topItem.refView.bottomValue+topItem.value.floatValue);
            
        }
    } else if (layoutModel.equalTop) {
        if (view.superview == layoutModel.equalTop.refView) {
            if (!view.fixedHeight) {
                view.height_sl(view.bottomValue - layoutModel.equalTop.offset);
            }
            view.top_sl(0 + layoutModel.equalTop.offset);
        } else {
            if (!view.fixedHeight) {
                view.height_sl(view.bottomValue - (layoutModel.equalTop.refView.topValue + layoutModel.equalTop.offset));
            }
            view.top_sl(layoutModel.equalTop.refView.topValue + layoutModel.equalTop.offset);
        }
    }
}

- (void)_sl_layoutBottomWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.bottom) {
        SLAutoLayoutModelItem *bottomItem = layoutModel.bottom;
        if (bottomItem.refView == view.superview) {
            // 根据父视图布局
            if (view.fixedHeight == nil) {
                view.height_sl(bottomItem.refView.heightValue-bottomItem.value.floatValue-view.topValue);
            }
            view.bottom_sl(bottomItem.refView.heightValue-bottomItem.value.floatValue);
            
        } else {
            // 寻找下视图的最上边
            CGFloat bottomMax = INT_MAX;
            for (UIView *refView in bottomItem.refViewsArray) {
                if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.topValue < bottomMax) {
                    bottomItem.refView = refView;
                    bottomMax = refView.topValue;
                }
            }
            view.bottom_sl(bottomItem.refView.topValue - bottomItem.value.floatValue);
        }
    }else if (layoutModel.equalBottom) {
        if (view.superview == layoutModel.equalBottom.refView) {
            if (!view.fixedHeight) {
                view.height_sl(view.superview.heightValue - view.topValue + layoutModel.equalBottom.offset);
            }
            view.bottom_sl(layoutModel.equalBottom.refView.heightValue + layoutModel.equalBottom.offset);
        } else {
            if (!view.fixedHeight) {
                view.height_sl(layoutModel.equalBottom.refView.bottomValue - view.topValue + layoutModel.equalBottom.offset);
            }
            view.bottom_sl(layoutModel.equalBottom.refView.bottomValue + layoutModel.equalBottom.offset);
        }
    }
    
    if (layoutModel.widthEqualHeight && !view.fixedHeight) {
        [self _sl_layoutRightWithView:view layoutModel:layoutModel];
    }
    
}

- (void)_sl_layoutCenterWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    
    // 计算宽度【如果没有指定的话】
    NSNumber *_tempLeft = nil;
    if ((!view.fixedWidth) && (layoutModel.equalCenterX || layoutModel.centerX)) { // 根据 左|右 + centerx 确定宽度
        _tempLeft = @(view.leftValue);
    }
    
    // center x
    CGFloat centerXValue;
    if (layoutModel.equalCenterX) {
        if (view.superview == layoutModel.equalCenterX.refView) {
            centerXValue = layoutModel.equalCenterX.refView.widthValue*0.5 + layoutModel.equalCenterX.offset;
        } else {
            centerXValue = layoutModel.equalCenterX.refView.centerXValue + layoutModel.equalCenterX.offset;
        }
        if (_tempLeft) {
            view.width_sl(fabs(centerXValue-_tempLeft.floatValue)*2);
        }
        view.centerX_sl(centerXValue);
    } else if (layoutModel.centerX) {
        centerXValue = layoutModel.centerX.floatValue;
        if (_tempLeft) {
            view.width_sl(fabs(centerXValue-_tempLeft.floatValue)*2);
        }
        view.centerX_sl(centerXValue);
    }
    
    
    // 计算高度【如果没有指定的话】
    NSNumber *_tempTop = nil;
    if ((!view.fixedHeight) && (layoutModel.equalCenterY || layoutModel.centerY)) { // 根据 上|下 + centery 确定高度
        _tempTop = @(view.topValue);
    }
    // center y
    CGFloat centerYValue;
    if (layoutModel.equalCenterY) {
        if (view.superview == layoutModel.equalCenterY.refView) {
            centerYValue = layoutModel.equalCenterY.refView.heightValue * 0.5 + layoutModel.equalCenterY.offset;
        } else {
            centerYValue = layoutModel.equalCenterY.refView.centerYValue + layoutModel.equalCenterY.offset;
        }
        if (_tempTop) {
            view.height_sl(fabs(centerYValue-_tempTop.floatValue)*2);
        }
        view.centerY_sl(centerYValue);
    } else if (layoutModel.centerY) {
        centerYValue = [layoutModel.centerY floatValue];
        if (_tempTop) {
            view.height_sl(fabs(centerYValue-_tempTop.floatValue)*2);
        }
        view.centerY_sl(centerYValue);
    }
    
}

#pragma mark - setter&getter
- (void)setSl_ownLayoutModel:(SLAutoLayoutModel *)sl_ownLayoutModel {
    objc_setAssociatedObject(self, @selector(sl_ownLayoutModel), sl_ownLayoutModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SLAutoLayoutModel *)sl_ownLayoutModel {
    return objc_getAssociatedObject(self, @selector(sl_ownLayoutModel));
}
- (NSMutableArray *)sl_autoLayoutModelsArray {
    NSMutableArray *_sl_autoLayoutModelsArray = objc_getAssociatedObject(self, _cmd);
    if (!_sl_autoLayoutModelsArray) {
        _sl_autoLayoutModelsArray = [NSMutableArray new];
        objc_setAssociatedObject(self, _cmd, _sl_autoLayoutModelsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _sl_autoLayoutModelsArray;
}

- (NSNumber *)fixedWidth {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFixedWidth:(NSNumber *)fixedWidth {
    objc_setAssociatedObject(self, @selector(fixedWidth), fixedWidth, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)fixedHeight {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFixedHeight:(NSNumber *)fixedHeight {
    objc_setAssociatedObject(self, @selector(fixedHeight), fixedHeight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
