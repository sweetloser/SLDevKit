//
//  SLUIKitUtils.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import "SLUIKitUtils.h"

@implementation SLUIKitUtils

+ (UIColor *)_colorWithColorObject:(id)object {
    if ([object isKindOfClass:UIColor.class]) {
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
                [object substringFromIndex:1];
                isHex_ = YES;
            }
            if ([object hasPrefix:@"0x"] || [object hasPrefix:@"0X"]) {
                [object substringFromIndex:2];
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

@end

/// 顶部安全区高度
CGFloat _safeDistanceTop(void) {
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
CGFloat _safeDistanceBottom(void) {
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
CGFloat _statusBarHeight(void) {
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
CGFloat _navigationBarHeight(void) {
    return 44.0f;
}

/// 状态栏+导航栏的高度
CGFloat _navigationFullHeight(void) {
    return _statusBarHeight() + _navigationBarHeight();
}

/// 底部导航栏高度
CGFloat _tabBarHeight(void) {
    return 49.0f;
}

/// 底部导航栏高度（包括安全区）
CGFloat _tabBarFullHeight(void) {
    return _tabBarHeight() + _safeDistanceBottom();
}
