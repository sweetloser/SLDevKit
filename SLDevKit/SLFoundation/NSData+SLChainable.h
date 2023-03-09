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

/**
 * sm4 ecb加密
 * 注意：返回的NSData 并不等于 `self`。
 * 用法：.sm4EcbEncrypt(keyData)
 */
SL_DATA_PROP(Object)sm4EcbEncrypt;

/**
 * sm4 ecb解密
 * 注意：返回的NSData 并不等于 `self`。
 */
SL_DATA_PROP(Object)sm4EcbDecrypt;

/**
 * sm4 cbc加密
 * 注意：返回的NSData 并不等于 `self`。
 * 用法：.sm4CbcEncrypt(keyData, ivData)
 */
SL_DATA_PROP(TwoObject)sm4CbcEncrypt;

/**
 * sm4 cbc解密
 * 注意：返回的NSData 并不等于 `self`。
 * 用法：.sm4CbcDecrypt(keyData, ivData)
 */
SL_DATA_PROP(TwoObject)sm4CbcDecrypt;

@end

NS_ASSUME_NONNULL_END
