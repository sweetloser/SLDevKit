//
//  SLAutoLayoutPrivate.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "SLAutoLayoutPrivate.h"
#import <objc/runtime.h>

@implementation UIView (SLAutoLayoutPrivate)

- (void)setOwnLayoutModel:(SLAutoLayoutModel *)ownLayoutModel {
    objc_setAssociatedObject(self, @selector(ownLayoutModel), ownLayoutModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SLAutoLayoutModel *)ownLayoutModel {
    return objc_getAssociatedObject(self, @selector(ownLayoutModel));
}

@end
