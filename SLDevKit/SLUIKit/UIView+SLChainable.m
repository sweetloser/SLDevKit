//
//  UIView+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/12/20.
//

#import "UIView+SLChainable.h"

@implementation UIView (SLChainable)

- (SLChainableUIViewIntBlock)tg {
    SL_CHAINABLE_INT_BLOCK(self.tag = value);
}

- (SLChainableUIViewFloatBlock)opacity {
    SL_CHAINABLE_FLOAT_BLOCK(self.alpha = value);
}

@end
