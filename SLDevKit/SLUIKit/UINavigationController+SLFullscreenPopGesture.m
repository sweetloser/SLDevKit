//
//  UINavigationController+SLFullscreenPopGesture.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2024/03/01.
//

#import "UINavigationController+SLFullscreenPopGesture.h"
#import <objc/runtime.h>
#import <objc/runtime.h>

typedef void (^_SLViewControllerWillAppearHookBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (SLFullscreenPopGesturePrivate)

@property(nonatomic,copy)_SLViewControllerWillAppearHookBlock sl_willAppearHookBlock;

@end

@implementation UIViewController (SLFullscreenPopGesturePrivate)

+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(sl_viewWillAppear:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)sl_viewWillAppear:(BOOL)animated {
    [self sl_viewWillAppear:animated];
    
    if (self.sl_willAppearHookBlock) {
        self.sl_willAppearHookBlock(self, animated);
    }
}

#pragma mark - setter & getter
- (void)setSl_willAppearHookBlock:(_SLViewControllerWillAppearHookBlock)block {
    objc_setAssociatedObject(self, @selector(sl_willAppearHookBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (_SLViewControllerWillAppearHookBlock)sl_willAppearHookBlock {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation UIViewController (SLFullscreenPopGesture)

- (BOOL)sl_interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setSl_interactivePopDisabled:(BOOL)disabled {
    objc_setAssociatedObject(self, @selector(sl_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL)sl_prefersNavigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setSl_prefersNavigationBarHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(sl_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


#pragma mark - FullscreenPopGestureRecognizerDelegate
@interface _SLFullscreenPopGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property(nonatomic,weak)UINavigationController *navigationController;

@end

@implementation _SLFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    // ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // ignore when controller is disabled.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.sl_interactivePopDisabled) {
        return NO;
    }
    
    // ignore the navigation controller in transition
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // ignore pan gesture in the opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@implementation UINavigationController (SLFullscreenPopGesture)

+ (void)load {
    // hook "-pushViewController:animated:"
    Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(sl_pushViewController:animated:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)sl_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.sl_fullscreenPopGestureRecognizer]) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.sl_fullscreenPopGestureRecognizer];
        
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:"); 
        self.sl_fullscreenPopGestureRecognizer.delegate = self.sl_popGestureRecognizerDelegate;
        [self.sl_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self sl_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    [self sl_pushViewController:viewController animated:animated];
}

- (void)sl_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    if (!self.sl_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _SLViewControllerWillAppearHookBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) stronglySelf = weakSelf;
        if (stronglySelf) {
            [stronglySelf setNavigationBarHidden:viewController.sl_prefersNavigationBarHidden animated:animated];
        }
    };
    
    // setup will appear hook block to appearing view controller.
    appearingViewController.sl_willAppearHookBlock = block;
    
    // setup disappearing view controller as well, because not every view controller is added into stack by pushing, maybe by "-setViewControllers:".
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.sl_willAppearHookBlock) {
        disappearingViewController.sl_willAppearHookBlock = block;
    }
}

#pragma mark - setter & getter
- (_SLFullscreenPopGestureRecognizerDelegate *)sl_popGestureRecognizerDelegate {
    _SLFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[_SLFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}
- (UIPanGestureRecognizer *)sl_fullscreenPopGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}
- (BOOL)sl_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.sl_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setSl_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enable {
    SEL key = @selector(sl_viewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(enable), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

