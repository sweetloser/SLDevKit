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

@interface SLCustomFieldItemCell ()

@property(nonatomic,strong)UILabel *valueLabel;

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
}
#pragma mark - model -> view
- (void)setItemModel:(SLCustomFieldItemModel *)itemModel {
    _itemModel = itemModel;
    // 设置边框宽度
    self.layer.borderWidth = itemModel.borderWidth;
    self.layer.cornerRadius = itemModel.borderRadius;
    
    if (itemModel.value && itemModel.value.length != 0) {
        // 设置值
        self.valueLabel.text = itemModel.value;
        self.layer.borderColor = itemModel.enteredBorderColor.CGColor;
    } else {
        self.valueLabel.text = @"";
        if (itemModel.focus) {
            self.layer.borderColor = itemModel.focusBorderColor.CGColor;
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

@end
