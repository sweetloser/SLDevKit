//
//  SLUIKitPrivate.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUIKitPrivate.h"
#import <objc/runtime.h>
#import "SLDefs.h"

@implementation NSObject (SLUIKitPrivate)

+(BOOL)_sl_swizzleMethod:(SEL)selector1 withMethod:(SEL)selector2 {
    Method m1 = class_getInstanceMethod(self, selector1);
    Method m2 = class_getInstanceMethod(self, selector2);
    if (m1 == NULL || m2 == NULL) {
        return NO;
    }
    class_addMethod(self, selector1, method_getImplementation(m1), method_getTypeEncoding(m1));
    class_addMethod(self, selector2, method_getImplementation(m2), method_getTypeEncoding(m2));
    
    m1 = class_getInstanceMethod(self, selector1);
    m2 = class_getInstanceMethod(self, selector2);
    method_exchangeImplementations(m1, m2);
    
    return YES;
}

+(BOOL)_sl_swizzleClassMethod:(SEL)selector1 withMethod:(SEL)selector2 {
    return [object_getClass(self) _sl_swizzleMethod:selector1 withMethod:selector2];
}

@end

@implementation NSMutableAttributedString (SLUIKitPrivate)

SL_SYNTHESIZE_BOOL(slAddAttributeIfNotExists,setSlAddAttributeIfNotExists);
SL_SYNTHESIZE_BOOL(slIsJustSettingEffectedRanges, setSlIsJustSettingEffectedRanges);
SL_SYNTHESIZE_OBJECT(slEffectedRanges, setSlEffectedRanges);

@end

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

@implementation UIView (SLUIKitPrivate)

SL_SYNTHESIZE_STRUCT(slTouchInsets, setSlTouchInsets, UIEdgeInsets)

+ (void)load {
    [self _sl_swizzleMethod:@selector(pointInside:withEvent:) withMethod:@selector(_sl_pointInside:withEvent:)];
}

- (BOOL)_sl_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets touchInsets = self.slTouchInsets;
    CGRect rect = UIEdgeInsetsInsetRect(self.bounds, touchInsets);
    return CGRectContainsPoint(rect, point);
}

- (void)_sl_addChild:(id)value {
    UIView *parent = self;
    if ([parent isKindOfClass:UIVisualEffectView.class]) {
        parent = ((UIVisualEffectView *)parent).contentView;
    }
    
    if ([value isKindOfClass:[UIView class]]) {
        [parent addSubview:value];
        
    } else if ([value isKindOfClass:[NSArray class]]) {
        for (id view in value) {
            [parent addSubview:view];
        }
        
    } else {
        @throw @"Invalid child";
    }
}

@end

@implementation NSMutableAttributedString (SLPrivate)

- (void)sl_applyAttribute:(NSString *)name withValue:(id)value {
    if (self.slEffectedRanges) {
        
    }
    [self addAttribute:name value:value range:NSMakeRange(0, self.length)];
}

@end
