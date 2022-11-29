//
//  SLUIKitPrivate.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUIKitPrivate.h"

@implementation UIColor(SLUIKitPrivate)

- (UIColor *)_colorWithHueOffset:(CGFloat)ho saturationOffset:(CGFloat)so brightnessOffset:(CGFloat)bo {
    CGFloat hue_, saturation_, brightness_, alpha_;
    [self getHue:&hue_ saturation:&saturation_ brightness:&brightness_ alpha:&alpha_];
    
    // 计算溢出情况下的hue值
    hue_ += ho;
    if (hue_>1 || hue_<0) hue_ = hue_-floorf(hue_);
    
    // 计算饱和度(饱和度不溢出,溢出情况就取边界值)
    saturation_ += so;
    saturation_ = MAX(MIN(saturation_, 1), 0);
    
    // 计算亮度(亮度不溢出,溢出情况就取边界值)
    brightness_ += bo;
    brightness_ = MAX(MIN(brightness_, 1), 0);
    
    return [UIColor colorWithHue:hue_ saturation:saturation_ brightness:brightness_ alpha:alpha_];
}

@end


