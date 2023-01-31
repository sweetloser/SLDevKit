//
//  NSData+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/29.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

#define SL_DATA_PROP(D)   SL_PROP(NSData, D)

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(NSData)

@interface NSData (SLChainable)

/// base64编码
SL_DATA_PROP(Empty)base64Encode;

/// base64解码
SL_DATA_PROP(Empty)base64Decode;

@end

NS_ASSUME_NONNULL_END
