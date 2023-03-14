//
//  UIButton+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "UIButton+SLChainable.h"
#import "SLUIKitUtils.h"
#import "UIFont+SLChainable.h"
#import "UIColor+SLChainable.h"
#import "UIImage+SLChainable.h"
#import "UIView+SLChainable.h"
#import "SLFoundationPrivate.h"

@implementation UIButton (SLChainable)

- (SLChainableUIButtonObjectBlock)str {
    SL_CHAINABLE_OBJECT_BLOCK([SLUIKitUtils _setTextWithStringObject:value forView:self]);
}

- (SLChainableUIButtonObjectBlock)fnt {
    SL_CHAINABLE_OBJECT_BLOCK(self.titleLabel.font = Fnt(value));
}

- (SLChainableUIButtonObjectBlock)tColor {
    SL_CHAINABLE_OBJECT_BLOCK([self setTitleColor:Color(value) forState:UIControlStateNormal]);
}

- (SLChainableUIButtonObjectBlock)selectedColor {
    SL_CHAINABLE_OBJECT_BLOCK([self setTitleColor:Color(value) forState:UIControlStateSelected]);
}

- (SLChainableUIButtonObjectBlock)highColor {
    SL_CHAINABLE_OBJECT_BLOCK([self setTitleColor:Color(value) forState:UIControlStateHighlighted]);
}

- (SLChainableUIButtonObjectBlock)img {
    SL_CHAINABLE_OBJECT_BLOCK([self setImage:Img(value) forState:UIControlStateNormal]);
}

- (SLChainableUIButtonObjectBlock)selectedImg {
    SL_CHAINABLE_OBJECT_BLOCK([self setImage:Img(value) forState:UIControlStateSelected]);
}

- (SLChainableUIButtonObjectBlock)highImg {
    SL_CHAINABLE_OBJECT_BLOCK([self setImage:Img(value) forState:UIControlStateHighlighted]);
}

- (SLChainableUIButtonObjectBlock)bgImg {
    SL_CHAINABLE_OBJECT_BLOCK([self setBackgroundImage:Img(value) forState:UIControlStateNormal]);
}

- (SLChainableUIButtonObjectBlock)selectedBgImg {
    SL_CHAINABLE_OBJECT_BLOCK([self setBackgroundImage:Img(value) forState:UIControlStateSelected]);
}

- (SLChainableUIButtonObjectBlock)highBgImg {
    SL_CHAINABLE_OBJECT_BLOCK([self setBackgroundImage:Img(value) forState:UIControlStateHighlighted]);
}

- (SLChainableUIButtonCallBackBlock)onClick {
    SL_CHAINABLE_2OBJECT_BLOCK(if (SL_IS_BLOCK(object)) {
        SEL _action = @selector(_sl_button_onClickHandler);
        objc_setAssociatedObject(self, _action, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addTarget:self action:_action forControlEvents:UIControlEventTouchUpInside];
    }else if (SL_IS_STRING(object)) {
        SEL _action = NSSelectorFromString(object);
        [self addTarget:target action:_action forControlEvents:UIControlEventTouchUpInside];
    });
}

-(void)_sl_button_onClickHandler {
    id block = objc_getAssociatedObject(self, _cmd);
    if (block) ((SLObjectBlock)block)(self);
}

@end
