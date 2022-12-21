//
//  UIView+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/12/20.
//

#import "UIView+SLChainable.h"
#import "UIColor+SLChainable.h"
#import "SLUIKitPrivate.h"
#import "SLFoundationPrivate.h"

@implementation UIView (SLChainable)

- (SLChainableUIViewIntBlock)tg {
    SL_CHAINABLE_INT_BLOCK(self.tag = value);
}

- (SLChainableUIViewFloatBlock)opacity {
    SL_CHAINABLE_FLOAT_BLOCK(self.alpha = value);
}

- (SLChainableUIViewObjectBlock)tint {
    SL_CHAINABLE_OBJECT_BLOCK(self.tintColor = Color(value));
}

- (SLChainableUIViewObjectBlock)bgColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.backgroundColor = Color(value));
}

- (SLChainableUIViewFloatBlock)borderRadius {
    SL_CHAINABLE_FLOAT_BLOCK(self.layer.cornerRadius = value;
                             if (self.layer.shadowOpacity == 0) {self.layer.masksToBounds = YES;});
}

- (SLChainableUIViewFloatObjectListBlock)border {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(self.layer.borderWidth = value;
                                         if (arguments.count > 0) {self.layer.borderColor = Color(arguments[0]).CGColor;});
}

- (SLChainableUIViewFloatListBlock)shadow {
    SL_CHAINABLE_FLOAT_LIST_BLOCK(self.layer.masksToBounds = NO;
                                  self.layer.shadowOpacity = value.f1;
                                  self.layer.shadowRadius = 3.f;
                                  if (CGSizeEqualToSize(self.layer.shadowOffset, CGSizeMake(0, -3))) {self.layer.shadowOffset = CGSizeMake(0, 3);}
                                  CGSize _offset = self.layer.shadowOffset;
                                  if (value.validCount >=2){self.layer.shadowRadius = value.f2;}
                                  if (value.validCount >= 3) {_offset.width = value.f3;}
                                  if (value.validCount >= 4) {_offset.height = value.f4;}
                                  self.layer.shadowOffset = _offset);
}

- (SLChainableUIViewInsetsBlock)touchInsets {
    SL_CHAINABLE_INSETS_BLOCK(self.slTouchInsets = value);
}

- (SLChainableUIViewCallBackBlock)onClick {
    SL_CHAINABLE_CALLBACK_BLOCK(if (SL_IS_BLOCK(object)) {
        SEL _action = @selector(_sl_view_onClickHandler);
        objc_setAssociatedObject(self, _action, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self _sl_view_addClickHandler:self action:_action];
    }else if (SL_IS_STRING(object)) {
        SEL _action = NSSelectorFromString(object);
        [self _sl_view_addClickHandler:target action:_action];
    });
}
- (void)_sl_view_addClickHandler:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        id reg = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:reg];
    }
}
-(void)_sl_view_onClickHandler {
    id _block = objc_getAssociatedObject(self, _cmd);
    if (_block) ((SLObjectBlock)_block)(self);
}
@end
