//
//  SLUIKitUtils.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 顶部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceTop(void);

/// 底部安全区高度
__attribute__((always_inline)) CGFloat _safeDistanceBottom(void);

/// 顶部状态栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _statusBarHeight(void);

/// 导航栏高度
__attribute__((always_inline)) CGFloat _navigationBarHeight(void);

/// 状态栏+导航栏的高度
__attribute__((always_inline)) CGFloat _navigationFullHeight(void);

/// 底部导航栏高度
__attribute__((always_inline)) CGFloat _tabBarHeight(void);

/// 底部导航栏高度（包括安全区）
__attribute__((always_inline)) CGFloat _tabBarFullHeight(void);

@interface SLUIKitUtils : NSObject

/// 从一个obj中创建UIColor对象
/// - Parameter object:参数可以是:@"#FFFFFF"
///                              @"FFF"
///                              @"200,100,100"
///                              @"#FFF,0.5"
///                              UIColor对象
///                              UIImage对象
+(UIColor *)_colorWithColorObject:(id)object;

@end


NS_ASSUME_NONNULL_END
