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
#import "SLHookUnit.h"
#import "SLHookInfo.h"

@protocol SLHookInfo;

static NSString *const SLHookMessagePrefix = @"slhook_";

#pragma mark - C函数定义
static NSMutableDictionary *sl_getSwizzledClassesDict(void);
static void sl_performLocked(dispatch_block_t block);
static BOOL sl_isSelectorAllowedAndTrack(NSObject *self, SEL selector, SLHookOptions options, __strong NSError **error);
static id sl_addHook(id self, SEL selector, SLHookOptions options, id block, __strong NSError **error);
static SLHookContainer *sl_getContainerForObject(NSObject *self, SEL selector);
static SEL sl_aliasForSelector(SEL selector);
static Class sl_hookClass(NSObject *self, NSError **error);
static void _sl_modifySwizzledClasses(void(^block)(NSMutableSet *swizzledClasses));
static Class sl_swizzleClassInPlace(Class klass);
static void sl_swizzleForwardInvocation(Class klass);
static void _sl_forwardInvocation_imp(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation);
static SLHookContainer *sl_getContainerForClass(Class klass, SEL aliasSelector);
static NSArray *_sl_hookInvoke(NSArray *hookUnits, id<SLHookInfo> info);
static void sl_prepareClassAndHookSelector(NSObject *self, SEL selector, __strong NSError **error);

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
            SLHookUnit *hookUnit = [SLHookUnit hookUnitWithSelector:selector object:self options:options block:block error:error];
            [hookContainer addHookUnit:hookUnit withOptions:options];
            sl_prepareClassAndHookSelector(self, selector, error);
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

/**
 * hook class
 *
 * - Parameters:
 *  - self: 待hook对象（可能为实例对象，也可能为类）
 *  - error: 错误码
 */
static Class sl_hookClass(NSObject *self, NSError **error) {
    // 当 self 为实例对象时，[self class] 和 object_getClass(self) 都指向类对象
    // 当 self 为类对象时，[self class] 指向的是类对象本身，object_getClass(self) 指向的是类对象的元类对象
    // 当 self 为元类对象时，[self class] 指向的是元类对象本身，object_getClass(self) 指向的是根元类
    Class statedClass = [self class];
    Class basedClass = object_getClass(self);
    NSString *className = NSStringFromClass(basedClass);
    
    if ([className hasSuffix:(NSString *)kSLHookSubclassSuffix]) {
        return basedClass;
    } else if (class_isMetaClass(basedClass)) {
        // 判断是否为元类
        return sl_swizzleClassInPlace((Class)self);
    } else if (statedClass != basedClass) {
        return sl_swizzleClassInPlace(basedClass);
    }
    const char *subClassName = "";
    Class subClass = objc_getClass(subClassName);
    return subClass;
}

static Class sl_swizzleClassInPlace(Class klass) {
    NSString *className = NSStringFromClass(klass);
    _sl_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        
        if (![swizzledClasses containsObject:className]) {
            // 未hook过
            sl_swizzleForwardInvocation(klass);
            [swizzledClasses addObject:className];
        }
    });
    return klass;
}
static void _sl_modifySwizzledClasses(void(^block)(NSMutableSet *swizzledClasses)) {
    static NSMutableSet *swizzledClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableSet new];
    });
    @synchronized (swizzledClasses) {
        block(swizzledClasses);
    }
}
/**
 * hook 类的forwardInvocation方法
 * - Parameter klass: 待hook的类
 */
static void sl_swizzleForwardInvocation(Class klass) {
    IMP originalImp = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)_sl_forwardInvocation_imp, "v@:@");
    if (originalImp) {
        class_addMethod(klass, NSSelectorFromString((NSString *)kSLHookForwardInvocationSelectorName), (IMP)_sl_forwardInvocation_imp, "v@:@");
    }
}

static SLHookContainer *sl_getContainerForClass(Class klass, SEL aliasSelector) {
    SLHookContainer *container = nil;
    do {
        container = objc_getAssociatedObject(klass, aliasSelector);
        if (container.hasHooks) break;
    } while ((klass = class_getSuperclass(klass)));
    return container;
}
static NSArray *_sl_hookInvoke(NSArray *hookUnits, id<SLHookInfo> info) {
    for (SLHookUnit *hookUnit in hookUnits) {
        [hookUnit invokeWithInfo:info];
    }
    return @[];
}

static void sl_prepareClassAndHookSelector(NSObject *self, SEL selector, __strong NSError **error) {
    
}

#pragma mark - hook forwardInvocation
static void _sl_forwardInvocation_imp(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    NSLog(@"被hook");
    SEL originalSelector = invocation.selector;
    SEL aliasSelector = sl_aliasForSelector(originalSelector);
    invocation.selector = aliasSelector;
    
    SLHookContainer *hookContainer = objc_getAssociatedObject(self, aliasSelector);
    SLHookContainer *classHookContainer = sl_getContainerForClass(object_getClass(self), aliasSelector);
    
    SLHookInfo *hookInfo = [[SLHookInfo alloc] initWithInstance:self invocation:invocation];
    
    // 原方法前调用
    _sl_hookInvoke(hookContainer.beforeHooks, hookInfo);
    _sl_hookInvoke(classHookContainer.beforeHooks, hookInfo);
    
    // 替换原方法的调用
    if (hookContainer.insteadHooks.count || classHookContainer.insteadHooks.count) {
        _sl_hookInvoke(hookContainer.insteadHooks, hookInfo);
        _sl_hookInvoke(classHookContainer.insteadHooks, hookInfo);
    } else {
        // 没有替换原方法的调用，需调用原方法
        Class klass = object_getClass(invocation.target);
        do {
            if ([klass instancesRespondToSelector:selector]) {
                [invocation invoke];
                break;
            }
        } while ((klass = class_getSuperclass(klass)));
    }
}



