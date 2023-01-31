//
//  NSData+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/29.
//

#import "NSData+SLChainable.h"
#import "SLFoundationPrivate.h"

@implementation NSData (SLChainable)

- (SLChainableNSDataEmptyBlock)base64Encode {
    SL_CHAINABLE_EMPTY_BLOCK(return [self _base64Encode];);
}

- (SLChainableNSDataEmptyBlock)base64Decode {
    SL_CHAINABLE_EMPTY_BLOCK(return [self _base64Decode];);
}
@end
