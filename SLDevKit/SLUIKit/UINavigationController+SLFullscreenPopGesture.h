//
//  UINavigationController+SLFullscreenPopGesture.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2024/03/01.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (SLFullscreenPopGesture)

@property(nonatomic,strong,readonly)UIPanGestureRecognizer *sl_fullscreenPopGestureRecognizer;

@property(nonatomic,assign)BOOL sl_viewControllerBasedNavigationBarAppearanceEnabled;

@end

@interface UIViewController (SLFullscreenPopGesture)

@property(nonatomic,assign)BOOL sl_interactivePopDisabled;

@property(nonatomic,assign)BOOL sl_prefersNavigationBarHidden;

@end

NS_ASSUME_NONNULL_END
