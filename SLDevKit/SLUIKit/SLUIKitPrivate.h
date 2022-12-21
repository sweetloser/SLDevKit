//
//  SLUIKitPrivate.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor(SLUIKitPrivate)

-(UIColor *)_colorWithHueOffset:(CGFloat)ho saturationOffset:(CGFloat)so brightnessOffset:(CGFloat)bo;

@end

@interface UIView (SLUIKitPrivate)

@property(nonatomic,assign)UIEdgeInsets slTouchInsets;

@end

NS_ASSUME_NONNULL_END
