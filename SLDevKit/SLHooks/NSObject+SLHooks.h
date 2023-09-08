//
//  NSObject+SLHooks.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SLHooks)

+ (BOOL)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;
- (BOOL)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;

@end


NS_ASSUME_NONNULL_END
