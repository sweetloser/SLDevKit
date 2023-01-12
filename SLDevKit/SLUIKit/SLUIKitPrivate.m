//
//  SLUIKitPrivate.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUIKitPrivate.h"
#import <objc/runtime.h>
#import "SLDefs.h"
#import "SLFoundationPrivate.h"

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

// 重写setter、getter方法
- (void)setSlEffectedRanges:(NSMutableIndexSet *)slEffectedRanges {
    objc_setAssociatedObject(self, @selector(slEffectedRanges), slEffectedRanges, OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableIndexSet *)slEffectedRanges {
    NSMutableIndexSet *_ranges = objc_getAssociatedObject(self, @selector(slEffectedRanges));
    if (!_ranges) {
        _ranges = [[NSMutableIndexSet alloc] init];
        [self setSlEffectedRanges:_ranges];
    }
    return _ranges;
}

+ (instancetype)sl_attributedStringWithSubstrings:(NSArray *)substrings {
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] init];
    
    for (id sub in substrings) {
        id subAtt = nil;
        
        if ([sub isKindOfClass:NSAttributedString.class]) {
            subAtt = sub;
            
        } else if ([sub isKindOfClass:NSString.class]) {
            subAtt = [[NSAttributedString alloc] initWithString:sub];
            
        } else if ([sub isKindOfClass:UIImage.class]) {
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.image = sub;
            subAtt = [NSAttributedString attributedStringWithAttachment:attachment];
            
        } else if ([sub isKindOfClass:NSData.class]) {
            id options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                           NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
            subAtt = [[NSAttributedString alloc] initWithData:sub options:options documentAttributes:nil error:nil];
        }
        
        if (subAtt) {
            [att appendAttributedString:subAtt];
        }
    }
    return att;
}

- (void)sl_applyAttribute:(NSString *)name withValue:(id)value {
    if (self.slEffectedRanges.count) {
        [self.slEffectedRanges enumerateRangesUsingBlock:^(NSRange range, BOOL * _Nonnull stop) {
            [self addAttribute:name value:value range:range];
        }];
    }else {
        [self addAttribute:name value:value range:[self.string sl_fullRange]];
    }
}

- (void)sl_setParagraphStyleValue:(id)value forKey:(NSString *)key {
    [self sl_setParagraphStyleValue:value forKey:key range:[self.string sl_fullRange]];
}
- (void)sl_setParagraphStyleValue:(id)value forKey:(NSString *)key range:(NSRange)range {
    NSParagraphStyle *style = nil;
    
    if (NSEqualRanges(range, [self.string sl_fullRange])) {
        style = [self attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
    } else {
        style = [self attribute:NSParagraphStyleAttributeName atIndex:range.location longestEffectiveRange:NULL inRange:range];
    }
    
    NSMutableParagraphStyle *mutableStyle = nil;
    if (style) {
        mutableStyle = [style mutableCopy];
    } else {
        mutableStyle = [NSMutableParagraphStyle new];
        mutableStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    [mutableStyle setValue:value forKey:key];
    [self addAttribute:NSParagraphStyleAttributeName value:mutableStyle range:range];
}

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

@implementation UIImage (SLUIKitPrivate)

-(UIImage *)_stretchableImage {
    CGFloat right = floorf(self.size.width / 2);
    CGFloat left = right - 1;
    CGFloat bottom = floorf(self.size.height / 2);
    CGFloat top = bottom - 1;
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    return [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
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
