//
//  SLHookContainer.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"

@class SLHookUnit;

NS_ASSUME_NONNULL_BEGIN

@interface SLHookContainer : NSObject

@property(nonatomic,copy)NSArray *beforeHooks;
@property(nonatomic,copy)NSArray *insteadHooks;
@property(nonatomic,copy)NSArray *afterHooks;

- (BOOL)hasHooks;

- (void)addHookUnit:(SLHookUnit *)hookUnit withOptions:(SLHookOptions)hookOptions;

@end

NS_ASSUME_NONNULL_END
