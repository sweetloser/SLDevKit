//
//  SLHookTracker.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/12.
//

#import "SLHookTracker.h"

@implementation SLHookTracker

- (instancetype)initWithTrackedClass:(Class)trackedClass parentTracker:(SLHookTracker *)parentTracker {
    self = [super init];
    if (self) {
        self.trackedClass = trackedClass;
        self.parentTracker = parentTracker;
        self.selectorNames = [NSMutableSet new];
    }
    return self;
}

@end
