//
//  SLUIKitMacros.h
//  Pods
//
//  Created by zengxiangxiang on 2022/11/25.
//

#ifndef SLUIKitMacros_h
#define SLUIKitMacros_h

/// 类型相关
#define SL_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define SL_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SL_IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

/// 屏幕尺寸相关
#define SL_SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SL_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SL_SCREEN_BOUNDS ([[UIScreen mainScreen] bounds])
#define SL_SCREEN_MAX_LENGTH (MAX(SL_SCREEN_WIDTH, SL_SCREEN_HEIGHT))
#define SL_SCREEN_MIN_LENGTH (MIN(SL_SCREEN_WIDTH, SL_SCREEN_HEIGHT))

/// 手机类型相关
#define SL_IS_IPHONE_4_OR_LESS  (SL_IS_IPHONE && SL_SCREEN_MAX_LENGTH  < 568.0)
#define SL_IS_IPHONE_5          (SL_IS_IPHONE && SL_SCREEN_MAX_LENGTH == 568.0)
#define SL_IS_IPHONE_6          (SL_IS_IPHONE && SL_SCREEN_MAX_LENGTH == 667.0)
#define SL_IS_IPHONE_6P         (SL_IS_IPHONE && SL_SCREEN_MAX_LENGTH == 736.0)
#define SL_IS_IPHONE_X          (SL_IS_IPHONE && SL_SCREEN_MAX_LENGTH == 812.0)


/// 导航条高度
#define SL_APPLICATION_TOP_BAR_HEIGHT (_navigationFullHeight())
/// tabBar高度
#define SL_APPLICATION_TAB_BAR_HEIGHT (_tabBarFullHeight())
/// 工具条高度 (常见的高度)
#define SL_APPLICATION_TOOL_BAR_HEIGHT_44  44.0f
#define SL_APPLICATION_TOOL_BAR_HEIGHT_49  49.0f
/// 状态栏高度
#define SL_APPLICATION_STATUS_BAR_HEIGHT (_statusBarHeight())
/// 底部安全距离
#define SL_APPLICATION_BOTTOM_SAFE_HEIGHT (_safeDistanceBottom())

#endif /* SLUIKitMacros_h */
