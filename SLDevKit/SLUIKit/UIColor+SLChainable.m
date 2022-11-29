//
//  UIColor+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "UIColor+SLChainable.h"
#import "SLUIKitPrivate.h"

@implementation UIColor (SLChainable)

- (SLChainableUIColorFloatBlock)opacity {
    SL_CHAINABLE_FLOAT_BLOCK(return [self colorWithAlphaComponent:value]);
}

- (SLChainableUIColorFloatBlock)hueOffset {
    SL_CHAINABLE_FLOAT_BLOCK(return [self _colorWithHueOffset:value saturationOffset:0 brightnessOffset:0]);
}

- (SLChainableUIColorFloatBlock)saturate {
    SL_CHAINABLE_FLOAT_BLOCK(return [self _colorWithHueOffset:0 saturationOffset:value brightnessOffset:0]);
}

- (SLChainableUIColorFloatBlock)desaturate {
    SL_CHAINABLE_FLOAT_BLOCK(return [self _colorWithHueOffset:0 saturationOffset:-value brightnessOffset:0]);
}

- (SLChainableUIColorFloatBlock)brighten {
    SL_CHAINABLE_FLOAT_BLOCK(return [self _colorWithHueOffset:0 saturationOffset:0 brightnessOffset:value]);
}

- (SLChainableUIColorFloatBlock)darken {
    SL_CHAINABLE_FLOAT_BLOCK(return [self _colorWithHueOffset:0 saturationOffset:0  brightnessOffset:-value]);
}

@end
