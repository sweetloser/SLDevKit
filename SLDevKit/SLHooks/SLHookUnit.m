//
//  SLHookUnit.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import "SLHookUnit.h"
#import <objc/message.h>
#import "SLHookHeader.h"

static NSMethodSignature *sl_blockMethodSignature(id block, __strong NSError ** error);
static BOOL sl_isBlockSignatureCompatibleWithSelector(NSMethodSignature *blockSignature, id object, SEL selector, __strong NSError **error);
@implementation SLHookUnit

+ (instancetype)hookUnitWithSelector:(SEL)selector object:(id)object options:(SLHookOptions)options block:(id)block error:(NSError *__strong  _Nullable *)errror {
    NSMethodSignature *signature = sl_blockMethodSignature(block, errror);
    
    return [self new];
}

@end

/**
 * 获取block的签名信息
 * - Parameters:
 *   - block: 待获取签名信息的block
 *   - error: 错误信息（报错时才赋值）
 *
 * - Returns: block的签名信息（NSMethodSignature对象）
 */
static NSMethodSignature *sl_blockMethodSignature(id block, __strong NSError ** error) {
    // 解析 block
    __SLHook_BlockLayout layout = (__bridge void *)block;
    if ((layout->flags & __SLHook_BLOCK_HAS_SIGNATURE) == 0) {
        // block没有签名信息
        NSString *errorDescription = [NSString stringWithFormat:@"block【%@】没有方法签名信息", block];
        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorMissingBlockSignature userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        return nil;
    }
    void *descriptor = layout->descriptor;
    if ((layout->flags & __SLHook_BLOCK_HAS_COPY_DISPOSE) != 0) {
        // 如果存在 copy dispose，则将指针往后移 16 字节（两个指针所占用的内存）
        descriptor = descriptor + 2 * sizeof(void *);
    }
    
    if (!descriptor) {
        NSString *errorDescription = [NSString stringWithFormat:@"block【%@】没有方法签名信息", block];
        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorMissingBlockSignature userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        return nil;
    }
    
    struct __SLHook_Block_descriptor_3 descriptor_3 = *((struct __SLHook_Block_descriptor_3 *)descriptor);
    const char *signature = descriptor_3.signature;
    
    return [NSMethodSignature signatureWithObjCTypes:signature];
}

static BOOL sl_isBlockSignatureCompatibleWithSelector(NSMethodSignature *blockSignature, id object, SEL selector, __strong NSError **error) {
    return YES;
}
