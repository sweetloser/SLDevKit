//
//  UISwitch+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/9.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

#define SL_SWITCH_PROP(D)   SL_PROP(UISwitch, D)

SL_DEFINE_CHAINABLE_BLOCKS(UISwitch)

@interface UISwitch (SLChainable)

SL_SWITCH_PROP(Object)onColor;

SL_SWITCH_PROP(Object)thumbColor;

SL_SWITCH_PROP(Object)outlineColor;

@end

NS_ASSUME_NONNULL_END
