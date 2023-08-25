//
//  SLCustomFieldItemCell.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/5/30.
//

#import "SLCustomFieldItemCell.h"
#import "SLUIKit.h"
#import "SLAutoLayout.h"
#import "SLFoundation.h"

 NSString * const _kCursorAnimationKey = @"SLCursorAnimationKey";

@interface SLCustomFieldItemCell ()

@property(nonatomic,strong)UILabel *valueLabel;

/// 光标
@property(nonatomic,strong)UIView *cursorView;
/// 闪烁的光标动画
@property(nonatomic,strong)CABasicAnimation *cursorAnimation;

@end

@implementation SLCustomFieldItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}

- (void)_setupSubviews {
    self.valueLabel.addTo(self.contentView).slLayout().spaceToSuperview_sl(0);
    self.cursorView.addTo(self.contentView).slLayout().centerXEqualToView_sl(self.contentView).centerYEqualToView_sl(self.contentView).wIs_sl(1.5).heightRatioToView_sl(0.5, self.contentView);
}
#pragma mark - model -> view
- (void)setItemModel:(SLCustomFieldItemModel *)itemModel {
    _itemModel = itemModel;
    // 设置边框宽度
    self.layer.borderWidth = itemModel.borderWidth;
    self.layer.cornerRadius = itemModel.borderRadius;
    
    // 先将动画移除
    [self.cursorView.layer removeAnimationForKey:_kCursorAnimationKey];
    self.cursorView.hidden = YES;
    self.cursorView.backgroundColor = itemModel.cursorColor;

    if (itemModel.value && itemModel.value.length != 0) {
        // 设置值
        self.valueLabel.text = itemModel.value;
        self.layer.borderColor = itemModel.enteredBorderColor.CGColor;
    } else {
        self.valueLabel.text = @"";
        if (itemModel.focus) {
            self.layer.borderColor = itemModel.focusBorderColor.CGColor;
            if (itemModel.cursor) {
                // 显示闪烁光标
                self.cursorView.hidden = NO;
                [self.cursorView.layer addAnimation:self.cursorAnimation forKey:_kCursorAnimationKey];
            }
        } else {
            self.layer.borderColor = itemModel.emptyBorderColor.CGColor;
        }
    }
}
#pragma mark - 懒加载
- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = SLLabel.bgColor(UIColor.clearColor).fnt(@"15").tColor(@"#282828").textAlign(NSTextAlignmentCenter);
    }
    return _valueLabel;
}
- (UIView *)cursorView {
    if (!_cursorView) {
        _cursorView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _cursorView;
}
- (CABasicAnimation *)cursorAnimation {
    if (!_cursorAnimation) {
        _cursorAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _cursorAnimation.fromValue = @(1.0);
        _cursorAnimation.toValue = @(0.0);
        _cursorAnimation.duration = 0.8;
        _cursorAnimation.repeatCount = HUGE_VALF;
        _cursorAnimation.removedOnCompletion = YES;
        _cursorAnimation.fillMode = kCAFillModeForwards;
        _cursorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    }
    
    return _cursorAnimation;
}

@end
