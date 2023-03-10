//
//  SLAutoLayoutPrivate.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SLDefs.h"

@class SLAutoLayoutModel;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SLAutoLayoutPrivate)

@property(nonatomic,assign)CGFloat leftValue;
@property(nonatomic,assign)CGFloat rightValue;
@property(nonatomic,assign)CGFloat topValue;
@property(nonatomic,assign)CGFloat bottomValue;

@property(nonatomic,assign)CGFloat centerXValue;
@property(nonatomic,assign)CGFloat centerYValue;

@property(nonatomic,assign)CGFloat widthValue;
@property(nonatomic,assign)CGFloat heightValue;

@property(nonatomic,assign)CGPoint originValue;
@property(nonatomic,assign)CGSize sizeValue;

@end

typedef UIView *_Nonnull(^SLAutoLayoutFloatBlock)(CGFloat);
typedef UIView *_Nonnull(^SLAutoLayoutPointBlock)(CGPoint);
typedef UIView *_Nonnull(^SLAutoLayoutSizeBlock)(CGSize);

@interface UIView (SLAutoLayoutChainable)
#pragma mark - 链式调用
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock left_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock right_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock top_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock bottom_sl;

@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock centerX_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock centerY_sl;

@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock width_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutFloatBlock height_sl;

@property(nonatomic,copy,readonly)SLAutoLayoutPointBlock origin_sl;
@property(nonatomic,copy,readonly)SLAutoLayoutSizeBlock size_sl;

@end

NS_ASSUME_NONNULL_END
