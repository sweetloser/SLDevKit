//
//  SLHookContainer.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import "SLHookContainer.h"
#import "SLHookUnit.h"

@implementation SLHookContainer

- (void)addHookUnit:(SLHookUnit *)hookUnit {
    SLHookOptions positions = hookUnit.options & SLHookPositionOptionsFilter;
    if (positions == SLHookPositionOptionBefore) {
        self.beforeHooks = [self.beforeHooks arrayByAddingObject:hookUnit];
    } else if (positions == SLHookPositionOptionInstead) {
        self.insteadHooks = [self.insteadHooks arrayByAddingObject:hookUnit];
    } else if (positions == SLHookPositionOptionAfter) {
        self.afterHooks = [self.afterHooks arrayByAddingObject:hookUnit];
    }
}

- (BOOL)removeHookUnit:(SLHookUnit *)hookUnit {
    SLHookOptions positions = hookUnit.options & SLHookPositionOptionsFilter;
    if (positions == SLHookPositionOptionBefore) {
        NSUInteger idx = [self.beforeHooks indexOfObjectIdenticalTo:hookUnit];
        if (idx != NSNotFound) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.beforeHooks];
            [newArray removeObjectAtIndex:idx];
            self.beforeHooks = newArray;
            return YES;
        }
    } else if (positions == SLHookPositionOptionInstead) {
        NSUInteger idx = [self.insteadHooks indexOfObjectIdenticalTo:hookUnit];
        if (idx != NSNotFound) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.insteadHooks];
            [newArray removeObjectAtIndex:idx];
            self.insteadHooks = newArray;
            return YES;
        }
    } else if (positions == SLHookPositionOptionAfter) {
        NSUInteger idx = [self.afterHooks indexOfObjectIdenticalTo:hookUnit];
        if (idx != NSNotFound) {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:self.afterHooks];
            [newArray removeObjectAtIndex:idx];
            self.afterHooks = newArray;
            return YES;
        }
    }
    return NO;
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
