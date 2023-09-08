//
//  SLHookUnit.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 一个hook单元
 *
 */
@interface SLHookUnit : NSObject

+ (instancetype)hookUnitWithSelector:(SEL)selector object:(id)object options:(SLHookOptions)options block:(id)block error:(__strong NSError **)errror;

@end

NS_ASSUME_NONNULL_END
