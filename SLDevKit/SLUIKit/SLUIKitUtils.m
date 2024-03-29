//
//  SLUIKitUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUIKitUtils.h"
#import "SLUIKitPrivate.h"

@implementation SLUIKitUtils

+ (UIColor *)_colorWithColorObject:(id)object {
    if ([object isKindOfClass:UIColor.class]) {
        // 参数是一个 UIColor对象，则直接返回该对象。
        return object;
    }else if ([object isKindOfClass:NSString.class]) {
        CGFloat alpha_ = 1.f;
        NSArray *args_ = [(NSString*)object componentsSeparatedByString:@","];
        
        // 判断object是否包含aplha值
        if (args_.count == 2 || args_.count == 4) {
            // 从字符串末尾开始查找第一个`,`
            NSRange range_ = [object rangeOfString:@"," options:NSBackwardsSearch];
            // 获取`,`之后的字符串 并将其转化为透明值
            alpha_ = [[object substringFromIndex:range_.location+range_.length] floatValue];
            // 透明值不能大于1
            alpha_ = MIN(alpha_, 1.f);
            // 获取去除透明值和`,`的值(表示颜色的值) eg. object = @"random, o,5" ===> object = @"random"
            object = [object substringToIndex:range_.location];
        }
        
        // 判断是否是 system color. eg:@"red"
        SEL sel_ = NSSelectorFromString([NSString stringWithFormat:@"%@Color",object]);
        if ([UIColor respondsToSelector:sel_]) {
            UIColor *color_ = [UIColor performSelector:sel_ withObject:nil];
            return [color_ colorWithAlphaComponent:alpha_];
        }
        
        int r_=0, g_=0, b_=0;
        BOOL isRGBColor_ = NO;
        
        // 判断是否是 random
        if ([object isEqualToString:@"random"]) {
            r_ = arc4random_uniform(256);
            g_ = arc4random_uniform(256);
            b_ = arc4random_uniform(256);
            isRGBColor_ = YES;
        } else {
            BOOL isHex_ = NO;
            // 判断是否是 @"#FFFFFF" 之类的颜色值
            if ([object hasPrefix:@"#"]) {
                object = [object substringFromIndex:1];
                isHex_ = YES;
            }
            if ([object hasPrefix:@"0x"] || [object hasPrefix:@"0X"]) {
                object = [object substringFromIndex:2];
                isHex_ = YES;
            }
            
            if (isHex_) {
                // 格式化(六位色值) FFFFFF
                int hexCount_ = sscanf([(NSString *)object UTF8String], "%02x%02x%02x",&r_,&g_,&b_);
                if (hexCount_ != 3) {
                    // 格式化(3位色值) FFF
                    hexCount_ = sscanf([(NSString *)object UTF8String], "%01x%01x%01x",&r_,&g_,&b_);
                    // 将三位色值转化为六位色值(FFF -> FFFFFF)
                    if (hexCount_ == 3) {
                        r_ *= 0x11;
                        g_ *= 0x11;
                        b_ *= 0x11;
                    }
                }
                isRGBColor_ = (hexCount_ == 3);
            } else {
                // rgb色值 eg:255,0,0
                int hexCount_ = sscanf([(NSString *)object UTF8String], "%d,%d,%d",&r_,&g_,&b_);
                isRGBColor_ = (hexCount_ == 3);
            }
        }
        
        if (isRGBColor_) {
            return [UIColor colorWithRed:r_/255.f green:g_/255.f blue:b_/255.f alpha:alpha_];
        }
    } else if ([object isKindOfClass:[UIImage class]]) {
        return [UIColor colorWithPatternImage:object];
    }
    return nil;
}

+ (BOOL)_colorHasAlphaChannel:(UIColor *)color {
    return CGColorGetAlpha(color.CGColor) < 1;
}

+ (UIFont *)_fontWithFontObject:(id)object {
    if ([object isKindOfClass:[UIFont class]]) {
        // 参数是 UIFont 类型，直接返回 object
        return object;
    } else if ([object isKindOfClass:[NSNumber class]]){
        // 参数是 NSNumber 类型，则默认为系统bold字体+字号
        return [UIFont boldSystemFontOfSize:[object floatValue]];
    } else if ([object isKindOfClass:[NSString class]]) {
        // 参数是 NSString 类型
        // 1.判断是否为固定字体。eg.@"body",@"title1"等。
        static NSMutableDictionary *fontStyles = nil;
        if (fontStyles == nil) {
            fontStyles = [@{@"headline":    UIFontTextStyleHeadline,
                            @"subheadline": UIFontTextStyleSubheadline,
                            @"caption1":    UIFontTextStyleCaption1,
                            @"caption2":    UIFontTextStyleCaption2,
                            @"body":        UIFontTextStyleBody,
                            @"footnote":    UIFontTextStyleFootnote} mutableCopy];
            
            if (SL_SYSTEM_VERSION_HIGHER_EQUAL(9)) {// iOS9新增系统字体
                // 消除警告
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored"-Wunguarded-availability"
                [fontStyles setObject:UIFontTextStyleCallout forKey:@"callout"];
                [fontStyles setObject:UIFontTextStyleTitle1 forKey:@"title1"];
                [fontStyles setObject:UIFontTextStyleTitle2 forKey:@"title2"];
                [fontStyles setObject:UIFontTextStyleTitle3 forKey:@"title3"];
    #pragma clang diagnostic pop
            }
        }
        // 将字符串转化为小写
        NSString *fontString_ = [object lowercaseString];
        NSString *fontStyle_ = [fontStyles objectForKey:fontString_];
        
        if (fontStyle_ != nil) {
            // 返回对应的字体
            return [UIFont preferredFontForTextStyle:fontStyle_];
        }
        
        NSArray *fontElements_ = [object componentsSeparatedByString:@","];
        if (fontElements_.count == 2) {
            // 包含字体名和字号
            NSString *fontName_ = fontElements_[0];
            CGFloat fontSize_ = [fontElements_[1] floatValue];
            return [UIFont fontWithName:fontName_ size:fontSize_];
        }
        CGFloat fontSize_ = [fontString_ floatValue];
        if (fontSize_ > 0) {
            return [UIFont systemFontOfSize:fontSize_];
        }
    }
    return nil;
}

+ (UIImage *)_imageWithImageObject:(id)object {
    return [self _imageWithImageObject:object allowColorImage:YES];
}

+ (UIImage *)_imageWithImageObject:(id)object allowColorImage:(BOOL)allowColorImage {
    if ([object isKindOfClass:[UIImage class]]) {
        // object是一个`UIImage对象`，直接返回
        return object;
    } else if ([object isKindOfClass:[NSString class]]) {
        // object是一个字符串
        
        // 判断是否有`#`标识
        BOOL stretchImage = [object hasPrefix:@"#"];
        
        NSString *imageName = stretchImage? [object substringFromIndex:1]: object;
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (stretchImage) {
            if (!image) {
                // #并非为拉伸图片标识，而是图片名的一部分
                image = [UIImage imageNamed:object];
                
            } else {
                return [image _stretchableImage];
            }
        }
        
        if (allowColorImage && !image) {
            image = [self _onePointImageWithColor:[self _colorWithColorObject:object]];
        }

        return image;
    }
    
    return nil;
}

+ (UIImage *)_onePointImageWithColor:(UIColor *)color {
    if (!color) return nil;
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    BOOL hasAlpha = [self _colorHasAlphaChannel:color];
    UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)_setTextWithStringObject:(id)stringObject forView:(UIView *)view {
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        
        if ([stringObject isKindOfClass:[NSAttributedString class]]) {
            [button setAttributedTitle:stringObject forState:UIControlStateNormal];
        } else {
            [button setTitle:[stringObject description] forState:UIControlStateNormal];
        }
        
    } else {
        if ([stringObject isKindOfClass:[NSAttributedString class]]) {
            if ([view respondsToSelector:@selector(setAttributedText:)]) {
                [view performSelector:@selector(setAttributedText:) withObject:stringObject];
            }
        } else {
            if ([view respondsToSelector:@selector(setText:)]) {
                [view performSelector:@selector(setText:) withObject:[stringObject description]];
            }
        }
    }
}

@end

/// 顶部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceTop(void) {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.top;
    }
    return 0;
}

/// 底部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceBottom(void) {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}


/// 顶部状态栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _statusBarHeight(void) {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        return statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

/// 导航栏高度
__attribute__((always_inline)) CGFloat _navigationBarHeight(void) {
    return 44.0f;
}

/// 状态栏+导航栏的高度
__attribute__((always_inline)) CGFloat _navigationFullHeight(void) {
    return _statusBarHeight() + _navigationBarHeight();
}

/// 底部导航栏高度
__attribute__((always_inline)) CGFloat _tabBarHeight(void) {
    return 49.0f;
}

/// 底部导航栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _tabBarFullHeight(void) {
    return _tabBarHeight() + _safeDistanceBottom();
}

__attribute__((always_inline)) UIEdgeInsets SLConvertSLEdgeInsetsToUIEdgeInsets(SLEdgeInsets insets, NSInteger number) {
    UIEdgeInsets newInsets;
    CGFloat a = insets.value.top;
    CGFloat b = insets.value.left;
    CGFloat c = insets.value.bottom;
    CGFloat d = insets.value.right;
    
    if (number == 1) {
        newInsets = UIEdgeInsetsMake(a, a, a, a);
    } else if (number == 2) {
        newInsets = UIEdgeInsetsMake(a, b, a, b);
    } else if (number == 3) {
        newInsets = UIEdgeInsetsMake(a, b, c, b);
    } else {
        newInsets = UIEdgeInsetsMake(a, b, c, d);
    }
    return newInsets;
}
