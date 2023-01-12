//
//  UIView+SLAutoLayout.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "UIView+SLAutoLayout.h"

@implementation UIView (SLAutoLayout)

- (SLChainableSLAutoLayoutModelEmptyBlock)slLayout {
    return ^{
        SLAutoLayoutModel *layoutModel = [[SLAutoLayoutModel alloc] init];
        layoutModel.needsAutoResizeView = self;
        return layoutModel;
    };
}

@end
