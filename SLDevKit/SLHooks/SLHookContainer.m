//
//  SLHookContainer.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import "SLHookContainer.h"
#import "SLHookUnit.h"

@implementation SLHookContainer

- (void)addHookUnit:(SLHookUnit *)hookUnit withOptions:(SLHookOptions)hookOptions {
    SLHookOptions positions = hookOptions & SLHookPositionOptionsFilter;
    if (positions == SLHookPositionOptionBefore) {
        self.beforeHooks = [self.beforeHooks arrayByAddingObject:hookUnit];
    } else if (positions == SLHookPositionOptionInstead) {
        self.insteadHooks = [self.insteadHooks arrayByAddingObject:hookUnit];
    } else if (positions == SLHookPositionOptionAfter) {
        self.afterHooks = [self.afterHooks arrayByAddingObject:hookUnit];
    }
}
- (NSArray *)beforeHooks {
    if (!_beforeHooks) return @[];
    return _beforeHooks;
}
- (NSArray *)insteadHooks {
    if (!_insteadHooks) return @[];
    return _insteadHooks;
}
- (NSArray *)afterHooks {
    if (!_afterHooks) return @[];
    return _afterHooks;
}

- (BOOL)hasHooks {
    return self.beforeHooks.count > 0 || self.insteadHooks.count > 0 || self.afterHooks.count > 0;
}

@end
