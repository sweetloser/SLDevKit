//
//  SLHookInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/11.
//

#import "SLHookInfo.h"

@implementation SLHookInfo

- (instancetype)initWithInstance:(id)instance invocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        _instance = instance;
        _originalInvocation = invocation;
    }
    return self;
}

@end
