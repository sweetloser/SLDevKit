//
//  UISwitch+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/9.
//

#import "UISwitch+SLChainable.h"
#import "UIColor+SLChainable.h"

@implementation UISwitch (SLChainable)

- (SLChainableUISwitchObjectBlock)onColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.onTintColor = Color(value));
}

- (SLChainableUISwitchObjectBlock)thumbColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.thumbTintColor = Color(value));
}

- (SLChainableUISwitchObjectBlock)outlineColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.tintColor = Color(value));
}

@end
