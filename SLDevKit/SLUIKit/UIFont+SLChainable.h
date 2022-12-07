//
//  UIFont+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/12/2.
//

#import <UIKit/UIKit.h>
#import "SLUIKitUtils.h"
#import "SLUtils.h"

NS_ASSUME_NONNULL_BEGIN

#define Font(f)     [SLUIKitUtils _fontWithFontObject:SL_CONVERT_VALUE_TO_STRING(f)]

@interface UIFont (SLChainable)

@end

NS_ASSUME_NONNULL_END
