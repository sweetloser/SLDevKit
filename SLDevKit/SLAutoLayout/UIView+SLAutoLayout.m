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
        SLAutoLayoutModel *layoutModel = [[SLAutoLayoutModel alloc] init];
        layoutModel.needsAutoResizeView = self;
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
}

- (void)_sl_layoutWidthWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.width) {
        
    }
}

- (void)_sl_layoutHeightWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    
}

- (void)_sl_layoutLeftWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.left) {
        SLAutoLayoutModelItem *leftItem = layoutModel.left;
        if (view.superview == leftItem.refView) {
            // 根据父视图进行左布局
            view.left_sl([leftItem.value floatValue]);
        } else {
            CGFloat rightMax = INTMAX_MIN;
            // 寻找左边视图的最右值
            for (UIView *refView in leftItem.refViewsArray) {
                if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.rightValue > rightMax) {
                    leftItem.refView = refView;
                    rightMax = refView.rightValue;
                }
            }
            view.left_sl(leftItem.refView.rightValue+[leftItem.value floatValue]);
        }
    }
}
- (void)_sl_layoutRightWithView:(UIView *)view layoutModel:(SLAutoLayoutModel *)layoutModel {
    if (layoutModel.right) {
        SLAutoLayoutModelItem *rightItem = layoutModel.right;
        if (rightItem.refView == view.superview) {
            // 根据父视图进行右布局
            if (view.fixedWidth == nil) {
                // 没有设置固定宽度
            }
            view.right_sl(rightItem.refView.widthValue - [rightItem.value floatValue]);
        } else {
            CGFloat leftMin = INT_MAX;
            // 寻找右视图的最左边
            for (UIView *refView in rightItem.refViewsArray) {
                if ([refView isKindOfClass:[UIView class]] && refView != view.superview && refView.leftValue < leftMin) {
                    rightItem.refView = refView;
                    leftMin = refView.leftValue;
                }
            }
        }
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
