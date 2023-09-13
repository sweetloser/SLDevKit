//
//  NSObject+SLHooks.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"
#import "SLHookInfo.h"
#import "SLHookUnit.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * hook的实现原理：
 *      一、针对类对象进行实例方法的hook
 *          1、hook类的`forwardInvocation:`方法，并将原实现保存在新方法内；
 *          2、hook类的`selector`，将原实现保存在新方法内，将`selector`的实现指向`_objc_msgForward`函数；
 *
 *      二、针对实例对象进行实例方法的hook
 *          1、动态创建一个类，继承被hook的类，并将被hook的实例对象的isa指向动态类。
 *          2、hook动态类的`class`，返回被hook的类；
 *          3、hook动态类的`forwardInvocation:`方法，并将原实现保存在新方法内；
 *          4、hook动态类的`selector`，将原实现保存在新方法内，将`selector`的实现指向`_objc_msgForward`函数；
 */
@interface NSObject (SLHooks)

/**
 * hook类的实例方法
 *
 * - Parameters:
 *   - selector: 待hook的方法
 *   - options: hook的位置以及是否需要在调用后清除
 *   - block: 用来hook的block；参数：(id<SLHookInfo> info, ...[原方法的参数列表])
 *   - error: 错误码
 */
+ (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;

/**
 * hook特定实例的实例方法
 *
 * - Parameters:
 *   - selector: 待hook的方法
 *   - options: hook的位置以及是否需要在调用后清除
 *   - block: 用来hook的block；参数：(id<SLHookInfo> info, ...[原方法的参数列表])
 *   - error: 错误码
 */
- (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;

@end


NS_ASSUME_NONNULL_END
