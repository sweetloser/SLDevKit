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
#import "SLHookTracker.h"

@protocol SLHookInfo;

static NSString *const SLHookMessagePrefix = @"slhook_";

#pragma mark - C函数定义
static NSMutableDictionary *sl_getSwizzledClassesDict(void);
static void sl_performLocked(dispatch_block_t block);
static BOOL sl_isSelectorAllowedAndTrack(NSObject *self, SEL selector, SLHookOptions options, __strong NSError **error);
static id sl_addHook(id self, SEL selector, SLHookOptions options, id block, __strong NSError **error);
static SLHookContainer *sl_getContainerForObject(NSObject *self, SEL selector);
static void sl_destroyContainerForObject(id<NSObject> self, SEL selector);
static SEL sl_aliasForSelector(SEL selector);
static Class sl_hookClass(NSObject *self, __strong NSError **error);
static void _sl_modifySwizzledClasses(void(^block)(NSMutableSet *swizzledClasses));
static Class sl_swizzleClassInPlace(Class klass);
static void sl_swizzleForwardInvocation(Class klass);
static void sl_undoSwizzleForwardInvocation(Class class);

static void _sl_forwardInvocation_imp(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation);
static SLHookContainer *sl_getContainerForClass(Class klass, SEL aliasSelector);
static NSArray *_sl_hookInvoke(NSArray *hookUnits, id<SLHookInfo> info);
static void sl_prepareClassAndHookSelector(NSObject *self, SEL selector, __strong NSError **error);
static void sl_hookedGetClass(Class class, Class statedClass);
static void sl_cleanupSelector(NSObject *self, SEL selector);
static void sl_cleanupClass(NSObject *self, SEL selector);


@implementation NSObject (SLHooks)

+ (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error {
    
    return sl_addHook((id)self, selector, options, block, error);
}

- (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error {
    
    return sl_addHook((id)self, selector, options, block, error);
}

@end

#pragma mark - 对执行的代码进行加锁
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
    __block SLHookUnit *hookUnit = nil;
    sl_performLocked(^{
        if (sl_isSelectorAllowedAndTrack(self, selector, options, error)) {
            // 获取hook容器
            SLHookContainer *hookContainer = sl_getContainerForObject(self, selector);
            // 初始化hook单元
            hookUnit = [SLHookUnit hookUnitWithSelector:selector object:self options:options block:block error:error];
            // 将hook单元添加到容器中
            [hookContainer addHookUnit:hookUnit];
            
            sl_prepareClassAndHookSelector(self, selector, error);
        }
    });
    
    return hookUnit;
}
BOOL sl_removeHook(SLHookUnit *hookUnit, NSError **error) {
    __block BOOL success = NO;
    sl_performLocked(^{
        id self = hookUnit.object;
        if (self) {
            SLHookContainer *hookContainer = sl_getContainerForObject(self, hookUnit.selector);
            success = [hookContainer removeHookUnit:hookUnit];
            
            // 还原方法的实现
            sl_cleanupSelector(self, hookUnit.selector);
            
            if (!hookContainer.hasHooks) {
                // 容器中没有hook单元时，需要对类进行还原
                sl_cleanupClass(self, hookUnit.selector);
                // 取消容器和对象的关联
                sl_destroyContainerForObject(self, hookUnit.selector);
            }
            
            hookUnit.object = nil;
            hookUnit.block = nil;
            hookUnit.selector = NULL;
            hookUnit.blockSignature = nil;
        }
    });
    return success;
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
        if (error) {
            NSString *errorDescription = [NSString stringWithFormat:@"未发现方法`-[%@ %@]`", NSStringFromClass(self.class), selectorName];
            *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorDoesNotRespondToSelector userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        }
        return NO;
    }
    
    if (class_isMetaClass(object_getClass(self))) {
        // self 为类对象
        Class klass = [self class];
        __unused NSMutableDictionary *swizzledClassesDict = sl_getSwizzledClassesDict();
        Class currentClass = klass;
        do {
            // 查找当前类以及子类是否hook过selector
            SLHookTracker *hookTracker = swizzledClassesDict[currentClass];
            if ([hookTracker.selectorNames containsObject:selectorName]) {
                // 当前类以及hook了该方法
                if (hookTracker.parentTracker) {
                    SLHookTracker *topTracker = hookTracker.parentTracker;
                    while (topTracker.parentTracker) {
                        topTracker = topTracker.parentTracker;
                    }
                    if (error) {
                        NSString *errorDescription = [NSString stringWithFormat:@"错误: %@ 方法已经在 %@ 中被hook了.", selectorName, NSStringFromClass(topTracker.trackedClass)];
                        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorSelectorAlreadyHookedInClassHierarchy userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
                    }
                    return NO;
                } else if (currentClass == klass) {
                    return YES;
                }
            }
        } while ((currentClass = class_getSuperclass(currentClass)));
        
        /// 向上遍历父类，向下存储`parentTracker`，反向链表；
        /// 即：父类的tracker对象的`parentTracker`指向子类的tracker对象；
        currentClass = klass;
        SLHookTracker *parentTracker = nil;
        do {
            SLHookTracker *hookTracker = swizzledClassesDict[currentClass];
            if (!hookTracker) {
                hookTracker = [[SLHookTracker alloc] initWithTrackedClass:currentClass parentTracker:parentTracker];
                swizzledClassesDict[(id<NSCopying>)currentClass] = hookTracker;
            }
            [hookTracker.selectorNames addObject:selectorName];
            parentTracker = hookTracker;
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

static void sl_destroyContainerForObject(id<NSObject> self, SEL selector) {
    SEL aliasSelector = sl_aliasForSelector(selector);
    objc_setAssociatedObject(self, aliasSelector, nil, OBJC_ASSOCIATION_RETAIN);
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
 *  1、当self为实例对象时（该实现方式，和kvo的实现原理类似）
 *      ① 动态创建一个类，继承`object_getClass(self)`；
 *      ② hook动态类的`forwardInvocation:`方法，使其指向`_sl_forwardInvocation_imp`函数；
 *      ③ hook动态类以及动态类元类的class方法，使其返回`[self class]`；
 *      ④ 将self的isa指针指向动态类对象；
 *  2、当self为类对象时
 *      hook类对象的`forwardInvocation:`方法，使其指向`_sl_forwardInvocation_imp`函数；
 *  3、当self为添加了KVO的实例对象时
 *      hook KVO动态创建的类对象的`forwardInvocation:`方法，使其指向`_sl_forwardInvocation_imp`函数；
 *
 * - Parameters:
 *  - self: 待hook对象（可能为实例对象，也可能为类）
 *  - error: 错误码
 */
static Class sl_hookClass(NSObject *self, __strong NSError **error) {
    // 当 self 为实例对象时，[self class] 和 object_getClass(self) 都指向类对象
    // 当 self 为类对象时，[self class] 指向的是类对象本身，object_getClass(self) 指向的是类对象的元类对象
    // 当 self 为元类对象时，[self class] 指向的是元类对象本身，object_getClass(self) 指向的是根元类
    Class statedClass = [self class];
    Class baseClass = object_getClass(self);
    NSString *className = NSStringFromClass(baseClass);
    
    if ([className hasSuffix:(NSString *)kSLHookSubclassSuffix]) {
        // self为实例对象，且当前实例对象的isa指向动态类对象，则复用此动态对象
        return baseClass;
    } else if (class_isMetaClass(baseClass)) {
        // self为类对象，则hook类对象的 forwardInvocation: 方法
        return sl_swizzleClassInPlace((Class)self);
    } else if (statedClass != baseClass) {
        // self 为实例对象，且当前对象 KVO 了，baseClass 为 KVO 动态创建的类，则对 KVO 动态创建的类的 forwardInvocation: 进行hook。
        return sl_swizzleClassInPlace(baseClass);
    }
    
    // self 为实例对象，且没有被hook过。
    const char *subClassName = [className stringByAppendingString:(NSString *)kSLHookSubclassSuffix].UTF8String;
    Class subClass = objc_getClass(subClassName);
    if (subClass == nil) {
        subClass = objc_allocateClassPair(baseClass, subClassName, 0);
        if (subClass == nil) {
            NSString *errorDescription = [NSString stringWithFormat:@"objc_allocateClassPair fail to allocate class %s.", subClassName];
            *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorSelectorBlacklisted userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
            return nil;
        }
        
        sl_swizzleForwardInvocation(subClass);
        sl_hookedGetClass(subClass, statedClass);
        sl_hookedGetClass(object_getClass(subClass), statedClass);
        objc_registerClassPair(subClass);
    }
    
    // 将实例对象的 isa 指向 subClass
    object_setClass(self, subClass);
    
    return subClass;
}

/**
 * hook类的`class`方法，返回指定的类
 * - Parameters:
 *   - class: 待hook的类
 *   - statedClass: `class`方法的返回值
 */
static void sl_hookedGetClass(Class class, Class statedClass) {
    Method classMethod = class_getInstanceMethod(class, @selector(class));
    IMP newImp = imp_implementationWithBlock(^(id self){
        return statedClass;
    });
    class_replaceMethod(class, @selector(class), newImp, method_getTypeEncoding(classMethod));
}

/**
 * hook类对象的`forwardInvocation:`方法，使其指向`_sl_forwardInvocation_imp`函数；
 */
static Class sl_swizzleClassInPlace(Class class) {
    NSString *className = NSStringFromClass(class);
    _sl_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        
        if (![swizzledClasses containsObject:className]) {
            // 未hook过
            sl_swizzleForwardInvocation(class);
            [swizzledClasses addObject:className];
        }
    });
    return class;
}
/**
 * hook 类的forwardInvocation方法
 * 并将原方法的实现指向`__slhook_forwardInvocation:`方法
 *
 * - Parameter klass: 待hook的类
 */
static void sl_swizzleForwardInvocation(Class class) {
    IMP originalImp = class_replaceMethod(class, @selector(forwardInvocation:), (IMP)_sl_forwardInvocation_imp, "v@:@");
    if (originalImp) {
        class_addMethod(class, NSSelectorFromString((NSString *)kSLHookForwardInvocationSelectorName), (IMP)originalImp, "v@:@");
    }
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

static Class sl_undoSwizzleClassInPlace(Class class) {
    NSString *className = NSStringFromClass(class);
    _sl_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        
        if ([swizzledClasses containsObject:className]) {
            sl_undoSwizzleForwardInvocation(class);
            [swizzledClasses removeObject:className];
        }
        
    });
    return class;
}
static void sl_undoSwizzleForwardInvocation(Class class) {
    SEL hookedForwardInvocationSelector = NSSelectorFromString((NSString *)kSLHookForwardInvocationSelectorName);
    Method hookedForwardInvocationMethod = class_getInstanceMethod(class, hookedForwardInvocationSelector);
    Method forwardInvocationMethod = class_getInstanceMethod(class, @selector(forwardInvocation:));
    
    IMP originalImp = method_getImplementation(hookedForwardInvocationMethod?:forwardInvocationMethod);
    
    if (originalImp) {
        class_replaceMethod(class, @selector(forwardInvocation:), originalImp, "v@:@");
    }
}


/**
 * 获取类对象指定方法的hook单元容器
 *  hook单元容器使用关联对象和类对象进行绑定
 */
static SLHookContainer *sl_getContainerForClass(Class klass, SEL aliasSelector) {
    SLHookContainer *container = nil;
    do {
        container = objc_getAssociatedObject(klass, aliasSelector);
        if (container.hasHooks) break;
    } while ((klass = class_getSuperclass(klass)));
    return container;
}
static NSArray *_sl_hookInvoke(NSArray *hookUnits, id<SLHookInfo> info) {
    NSMutableArray *removeHookUnits = [NSMutableArray new];
    for (SLHookUnit *hookUnit in hookUnits) {
        [hookUnit invokeWithInfo:info];
        if (hookUnit.options & SLHookOptionRemoveAfterCalled) {
            [removeHookUnits addObject:hookUnit];
        }
    }
    return [removeHookUnits copy];
}

static void sl_cleanupSelector(NSObject *self, SEL selector) {
    
    Class klass = object_getClass(self);
    BOOL isMetaClass = class_isMetaClass(klass);
    if (isMetaClass) {
        klass = (Class)self;
    }
    
    Method originalMethod = class_getInstanceMethod(klass, selector);
    IMP hookedIMP = method_getImplementation(originalMethod);
    if (hookedIMP == _objc_msgForward) {
        // 获取原方法的类型编码
        const char *typeEncoding = method_getTypeEncoding(originalMethod);
        
        // 获取动态增加的方法
        SEL aliasSelector = sl_aliasForSelector(selector);
        Method aliasMethod = class_getInstanceMethod(klass, aliasSelector);
        
        // 在动态方法中获取原方法的IMP
        IMP originalIMP = method_getImplementation(aliasMethod);
        
        // 将原方法的IMP还原
        class_replaceMethod(klass, selector, originalIMP, typeEncoding);
    }
}

static void sl_cleanupClass(NSObject *self, SEL selector) {
    Class klass = object_getClass(self);
    BOOL isMetaClass = class_isMetaClass(klass);
    if (isMetaClass) {
        klass = (Class)self;
    }
    NSString *className = NSStringFromClass(klass);
    if ([className hasSuffix:(NSString *)kSLHookSubclassSuffix]) {
        NSString *originalClassName = [className stringByReplacingOccurrencesOfString:(NSString *)kSLHookSubclassSuffix withString:@""];
        Class originalClass = NSClassFromString(originalClassName);
        object_setClass(self, originalClass);
    } else {
        if (isMetaClass) {
            sl_undoSwizzleClassInPlace((Class)self);
        }
    }
}


/**
 * hook方法
 * 1、hook`self`对应的`forwardInvocation:`方法
 * 2、为`self`增加一个和`selector`对应的方法,并将`selector`方法的IMP赋值给新方法
 * 3、将`selector`的IMP替换我`_objc_msgForward`
 *
 * - Parameters:
 *   - self: 待hook对象（实例对象或类对象）
 *   - selector: hook的方法
 *   - error: 错误码（发生错误时才会赋值）
 */
static void sl_prepareClassAndHookSelector(NSObject *self, SEL selector, __strong NSError **error) {
    Class klass = sl_hookClass(self, error);
    Method targerMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targerMethod);
    if (targetMethodIMP == _objc_msgForward) {
        return;
    }
    const char *typeEncoding = method_getTypeEncoding(targerMethod);
    SEL aliasSelector = sl_aliasForSelector(selector);
    if (![klass instancesRespondToSelector:aliasSelector]) {
        class_addMethod(klass, aliasSelector, targetMethodIMP, typeEncoding);
    }
    class_replaceMethod(klass, selector, _objc_msgForward, typeEncoding);
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
    
    NSMutableArray *removeHookUnits = [NSMutableArray new];
    
    // 原方法前的调用
    [removeHookUnits addObjectsFromArray: _sl_hookInvoke(hookContainer.beforeHooks, hookInfo)];
    [removeHookUnits addObjectsFromArray: _sl_hookInvoke(classHookContainer.beforeHooks, hookInfo)];
    
    // 替换原方法的调用
    BOOL respondsToAlias = YES;
    if (hookContainer.insteadHooks.count || classHookContainer.insteadHooks.count) {
        [removeHookUnits addObjectsFromArray: _sl_hookInvoke(hookContainer.insteadHooks, hookInfo)];
        [removeHookUnits addObjectsFromArray: _sl_hookInvoke(classHookContainer.insteadHooks, hookInfo)];
    } else {
        // 没有替换原方法的调用，需调用原方法
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:selector])) {
                [invocation invoke];
                break;
            }
        } while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }
    
    // 原方法后的调用
    [removeHookUnits addObjectsFromArray: _sl_hookInvoke(hookContainer.afterHooks, hookInfo)];
    [removeHookUnits addObjectsFromArray: _sl_hookInvoke(classHookContainer.afterHooks, hookInfo)];
    
    // 如果hook未生效，即hook失败，则需要执行原方法
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSelector = NSSelectorFromString((NSString *)kSLHookForwardInvocationSelectorName);
        if ([self respondsToSelector:originalForwardInvocationSelector]) {
            ((void(*)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSelector, invocation);
        } else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }
    
    // 调用完后，需要清理hook单元（针对执行一次就清除的hook单元）
    [removeHookUnits makeObjectsPerformSelector:@selector(remove)];
}



