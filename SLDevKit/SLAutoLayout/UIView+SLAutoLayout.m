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
        SLAutoLayoutModel *layoutModel = [self ownLayoutModel];
        if (!layoutModel) {
            layoutModel = [[SLAutoLayoutModel alloc] init];
            layoutModel.needsAutoResizeView = self;
            [self setOwnLayoutModel:layoutModel];
            [self.superview.autoLayoutModelsArray addObject:layoutModel];
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
    if (self.autoLayoutModelsArray.count) {
        [self.autoLayoutModelsArray enumerateObjectsUsingBlock:^(SLAutoLayoutModel * _Nonnull layoutModel, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
}

- (void)_sl_layoutWidthWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.width) {
        view.width_sl(layoutModel.width.value.floatValue);
        view.fixedWidth = @(view.widthValue);
    }
}

- (void)_sl_layoutHeightWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.height) {
        view.height_sl(layoutModel.height.value.floatValue);
        view.fixedHeight = @(view.heightValue);
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
    } else if (layoutModel.equalCenterX) {
        if (view.superview == layoutModel.equalCenterX.refView) {
            view.centerX_sl(layoutModel.equalCenterX.refView.widthValue*0.5 + layoutModel.equalCenterX.offset);
        } else {
            view.centerX_sl(layoutModel.equalCenterX.refView.centerXValue + layoutModel.equalCenterX.offset);
        }
    } else if (layoutModel.centerX) {
        view.centerX_sl(layoutModel.centerX.floatValue);
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
    } else if (layoutModel.equalCenterY) {
        if (view.superview == layoutModel.equalCenterY.refView) {
            view.centerY_sl(layoutModel.equalCenterY.refView.heightValue * 0.5 + layoutModel.equalCenterY.offset);
        } else {
            view.centerY_sl(layoutModel.equalCenterY.refView.centerYValue + layoutModel.equalCenterY.offset);
        }
    } else if (layoutModel.centerY) {
        view.centerY_sl([layoutModel.centerY floatValue]);
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
        }
        view.bottom_sl(bottomItem.refView.topValue - bottomItem.value.floatValue);
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

#pragma mark - setter&getter
- (void)setOwnLayoutModel:(SLAutoLayoutModel *)ownLayoutModel {
    objc_setAssociatedObject(self, @selector(ownLayoutModel), ownLayoutModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SLAutoLayoutModel *)ownLayoutModel {
    return objc_getAssociatedObject(self, @selector(ownLayoutModel));
}
- (NSMutableArray *)autoLayoutModelsArray {
    NSMutableArray *_autoLayoutModelsArray = objc_getAssociatedObject(self, _cmd);
    if (!_autoLayoutModelsArray) {
        _autoLayoutModelsArray = [NSMutableArray new];
        objc_setAssociatedObject(self, _cmd, _autoLayoutModelsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _autoLayoutModelsArray;
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
