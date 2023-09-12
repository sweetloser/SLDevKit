//
//  NSObject+SLHooks.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLHookUnit, SLHookInfo;

@interface NSObject (SLHooks)

+ (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;
- (id<SLHookUnit>)sl_hookSelector:(SEL)selector withHookOptions:(SLHookOptions)options replaceBlock:(id)block error:(__strong NSError **)error;

@end


NS_ASSUME_NONNULL_END
