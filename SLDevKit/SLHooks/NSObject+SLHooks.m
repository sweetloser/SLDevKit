//
//  NSObject+SLHooks.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import "NSObject+SLHooks.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "SLHookContainer.h"
#import "SLHookHeader.h"

static NSString *const SLHookMessagePrefix = @"slhook_";

#pragma mark - C函数定义
static NSMutableDictionary *sl_getSwizzledClassesDict(void);
static void sl_performLocked(dispatch_block_t block);
static BOOL sl_isSelectorAllowedAndTrack(NSObject *self, SEL selector, SLHookOptions options, __strong NSError **error);
static id sl_addHook(id self, SEL selector, SLHookOptions options, id block, __strong NSError **error);
static SLHookContainer *sl_getContainerForObject(NSObject *self, SEL selector);
static SEL sl_aliasForSelector(SEL selector);


@implementation NSObject (SLHooks)

+ (BOOL)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error {
    sl_addHook((id)self, selector, options, block, error);
    return YES;
}

- (BOOL)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error {
    sl_addHook((id)self, selector, options, block, error);
    return YES;
}


@end


static void sl_performLocked(dispatch_block_t block) {
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t _dsema;
    dispatch_once(&onceToken, ^{
        _dsema = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(_dsema, DISPATCH_TIME_FOREVER);
    block();
    dispatch_semaphore_signal(_dsema);
}

static id sl_addHook(id self, SEL selector, SLHookOptions options, id block, __strong NSError **error) {
    sl_performLocked(^{
        if (sl_isSelectorAllowedAndTrack(self, selector, options, error)) {
            SLHookContainer *hookContainer = sl_getContainerForObject(self, selector);
        }
    });
    
    return nil;
}

/**
 * 判断方法是否可以被hook
 *
 * - Parameters:
 *   - self: 待hook对象
 *   - selector: 待hook方法
 *   - options: hook选项
 *   - error: 错误信息（出错时才会被赋值）
 */
static BOOL sl_isSelectorAllowedAndTrack(NSObject *self, SEL selector, SLHookOptions options, __strong NSError **error) {
    
    // 初始化hook黑名单
    static dispatch_once_t onceToken;
    static NSSet *disAllowedSelectorList;
    dispatch_once(&onceToken, ^{
        disAllowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });
    
    // 黑名单列表检测
    NSString *selectorName = NSStringFromSelector(selector);
    if ([disAllowedSelectorList containsObject:selectorName]) {
        NSString *errorDescription = [NSString stringWithFormat:@"方法`%@`为在黑名单中", selectorName];
        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorSelectorBlacklisted userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        return NO;
    }
    
    // 方法实现检测
    if (![self respondsToSelector:selector] && ![self.class instancesRespondToSelector:selector]) {
        NSString *errorDescription = [NSString stringWithFormat:@"未发现方法`-[%@ %@]`", NSStringFromClass(self.class), selectorName];
        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorDoesNotRespondToSelector userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        return NO;
    }
    
    if (class_isMetaClass(object_getClass(self))) {
        // self 为类对象
        Class klass = [self class];
        __unused NSMutableDictionary *swizzledClassesDict = sl_getSwizzledClassesDict();
        Class currentClass = klass;
        do {
            
        } while ((currentClass = class_getSuperclass(currentClass)));
    }
    
    return YES;
}

static NSMutableDictionary *sl_getSwizzledClassesDict(void) {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *swizzledClassesDict;
    dispatch_once(&onceToken, ^{
        swizzledClassesDict = [NSMutableDictionary new];
    });
    return swizzledClassesDict;
}

/**
 * 懒加载待hook方法的container
 *
 * - Parameters:
 *  - self: 待hook对象
 *  - selector: 待hook方法
 */
static SLHookContainer *sl_getContainerForObject(NSObject *self, SEL selector) {
    SEL aliasSelector = sl_aliasForSelector(selector);
    SLHookContainer *hookContainer = objc_getAssociatedObject(self, aliasSelector);
    if (!hookContainer) {
        hookContainer = [SLHookContainer new];
        objc_setAssociatedObject(self, aliasSelector, hookContainer, OBJC_ASSOCIATION_RETAIN);
    }
    return hookContainer;
}

/**
 * 原方法名对应的hook别名
 * eg.`viewDidLoad`   ====>   `slhook__viewDidLoad`
 *
 * - Parameter selector: 原方法名(SEL)
 */
static SEL sl_aliasForSelector(SEL selector) {
    NSString *aliasSelectorName = [NSString stringWithFormat:@"%@_%@", SLHookMessagePrefix, NSStringFromSelector(selector)];
    return NSSelectorFromString(aliasSelectorName);
}
