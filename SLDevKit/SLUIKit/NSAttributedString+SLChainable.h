//
//  NSAttributedString+SLChainable.h
//  SLDevKit
//
//  Created by sweetloser on 2022/11/11.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (SLChainable)

@end

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(NSMutableAttributedString)

#define SL_ATTRISTR_PROP(D)   SL_PROP(NSMutableAttributedString, D)

@interface NSMutableAttributedString (SLChainable)

/// 设置字体。(NSFontAttributeName)
/// 参数为一个
SL_ATTRISTR_PROP(Object)font;

@end

NS_ASSUME_NONNULL_END
