//
//  SLAutoLayoutPrivate.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "SLAutoLayoutPrivate.h"
#import <objc/runtime.h>
#import "SLAutoLayoutModel.h"

@implementation UIView (SLAutoLayoutPrivate)

- (CGFloat)leftValue {
    return self.frame.origin.x;
}
- (void)setLeftValue:(CGFloat)leftValue {
    CGRect frame = self.frame;
    frame.origin.x = leftValue;
    self.frame = frame;
}
- (CGFloat)rightValue {
    return self.widthValue + self.leftValue;
}
- (void)setRightValue:(CGFloat)rightValue {
    CGRect frame = self.frame;
    frame.origin.x = rightValue-frame.size.width;
    self.frame = frame;
}
- (CGFloat)topValue {
    return self.frame.origin.y;
}
- (void)setTopValue:(CGFloat)topValue {
    CGRect frame = self.frame;
    frame.origin.y = topValue;
    self.frame = frame;
}
- (CGFloat)bottomValue {
    return self.topValue + self.heightValue;
}
- (void)setBottomValue:(CGFloat)bottomValue {
    CGRect frame = self.frame;
    frame.origin.y = bottomValue - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerXValue {
    return self.leftValue + self.widthValue * 0.5;
}
- (void)setCenterXValue:(CGFloat)centerXValue {
    self.left_sl(centerXValue-self.widthValue * 0.5f);
}
- (CGFloat)centerYValue {
    return self.topValue + self.heightValue * 0.5;
}
- (void)setCenterYValue:(CGFloat)centerYValue {
    self.top_sl(centerYValue-self.heightValue*0.5);
}


- (CGFloat)widthValue {
    return self.frame.size.width;
}
- (void)setWidthValue:(CGFloat)widthValue {
    CGRect frame = self.frame;
    frame.size.width = widthValue;
    self.frame = frame;
}
- (CGFloat)heightValue {
    return self.frame.size.height;
}
- (void)setHeightValue:(CGFloat)heightValue {
    CGRect frame = self.frame;
    frame.size.height = heightValue;
    self.frame = frame;
}

- (CGPoint)originValue {
    return CGPointMake(self.leftValue, self.topValue);
}
- (void)setOriginValue:(CGPoint)originValue {
    CGRect frame = self.frame;
    frame.origin = originValue;
    self.frame = frame;
}
- (CGSize)sizeValue {
    return CGSizeMake(self.widthValue, self.heightValue);
}
- (void)setSizeValue:(CGSize)sizeValue {
    CGRect frame = self.frame;
    frame.size = sizeValue;
    self.frame = frame;
}
@end

@implementation UIView (SLAutoLayoutChainable)
- (SLAutoLayoutFloatBlock)left_sl {
    return ^(CGFloat left){
        self.leftValue = left;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)right_sl {
    return ^(CGFloat right){
        self.rightValue = right;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)top_sl {
    return ^(CGFloat top){
        self.topValue = top;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)bottom_sl {
    return ^(CGFloat bottom){
        self.bottomValue = bottom;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)centerX_sl {
    return ^(CGFloat centerX) {
        self.centerXValue = centerX;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)centerY_sl {
    return ^(CGFloat centerY) {
        self.centerYValue = centerY;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)width_sl {
    return ^(CGFloat width){
        self.widthValue = width;
        return self;
    };
}

- (SLAutoLayoutFloatBlock)height_sl {
    return ^(CGFloat height){
        self.heightValue = height;
        return self;
    };
}

- (SLAutoLayoutPointBlock)origin_sl {
    return ^(CGPoint origin){
        self.originValue = origin;
        return self;
    };
}

- (SLAutoLayoutSizeBlock)size_sl {
    return ^(CGSize size){
        self.sizeValue = size;
        return self;
    };
}
@end
