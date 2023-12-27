//
//  SLHookUnit.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import "SLHookUnit.h"
#import <objc/message.h>
#import "SLHookHeader.h"
#import "SLHookInfo.h"

static NSMethodSignature *sl_blockMethodSignature(id block, __strong NSError ** error);
static BOOL sl_isBlockSignatureCompatibleWithSelector(NSMethodSignature *blockSignature, id object, SEL selector, __strong NSError **error);
FOUNDATION_EXTERN BOOL sl_removeHook(SLHookUnit *hookUnit, NSError **error);
@implementation SLHookUnit

- (BOOL)remove {
    return sl_removeHook(self, NULL);
}

+ (instancetype)hookUnitWithSelector:(SEL)selector object:(id)object options:(SLHookOptions)options block:(id)block error:(NSError *__strong  _Nullable *)errror {
    NSMethodSignature *blockSignature = sl_blockMethodSignature(block, errror);
    if (!sl_isBlockSignatureCompatibleWithSelector(blockSignature, object, selector, errror)) {
        return nil;
    }
    
    SLHookUnit *hookUnit = nil;
    if (blockSignature) {
        hookUnit = [SLHookUnit new];
        hookUnit.selector = selector;
        hookUnit.block = block;
        hookUnit.blockSignature = blockSignature;
        hookUnit.object = object;
        hookUnit.options = options;
    }
    
    return hookUnit;
}

- (BOOL)invokeWithInfo:(id<SLHookInfo>)info {
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    NSInvocation *originalInvocation = [info originalInvocation];
    
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;
    
    // 将hookinfo对象设置为block的第二个参数
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&info atIndex:1];
    }
    
    // 依次将原方法调用的参数赋值给block
    void *argBuff = NULL;
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        if (!(argBuff = reallocf(argBuff, argSize))) {
            return NO;
        }
        [originalInvocation getArgument:argBuff atIndex:idx];
        [blockInvocation setArgument:argBuff atIndex:idx];
    }
    
    [blockInvocation invokeWithTarget:self.block];
    
    if (argBuff) free(argBuff);
    return YES;
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
    __SLHook_BlockLayout_t layout = (__SLHook_BlockLayout_t)(__bridge void *)block;
    if ((layout->flags & __SLHook_BLOCK_HAS_SIGNATURE) == 0) {
        // block没有签名信息
        NSString *errorDescription = [NSString stringWithFormat:@"block【%@】没有方法签名信息", block];
        *error = [NSError errorWithDomain:(NSErrorDomain)kSLHookErrorDomain code:SLHookErrorMissingBlockSignature userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        return nil;
    }
    void *descriptor = layout->descriptor;
    // 跳过 descriptor_1 的地址
    descriptor = (void *)((uintptr_t)descriptor + (uintptr_t)(sizeof(uintptr_t) * 2));
    
    // 跳过 descriptor_2 地址 （如果存在）
    if ((layout->flags & __SLHook_BLOCK_HAS_COPY_DISPOSE) != 0) {
        // 如果存在 copy dispose，则将指针往后移 16 字节（两个指针所占用的内存）
        descriptor = (void *)((uintptr_t)descriptor + (uintptr_t)(2 * sizeof(void *)));
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

/**
 * 判断block的方法签名和原方法的签名参数是否符合
 * - Parameters:
 *   - blockSignature: block的方法签名
 *   - object: 待hook对象
 *   - selector: 待hook方法
 *   - error: 错误码
 */
static BOOL sl_isBlockSignatureCompatibleWithSelector(NSMethodSignature *blockSignature, id object, SEL selector, __strong NSError **error) {
    BOOL signatureMatch = YES;
    NSMethodSignature *methodSignature = [[object class] instanceMethodSignatureForSelector:selector];
    if (blockSignature.numberOfArguments > methodSignature.numberOfArguments) {
        signatureMatch = NO;
    } else {
        if (blockSignature.numberOfArguments > 1) {
            const char *blockType = [blockSignature getArgumentTypeAtIndex:1];
            if (blockType[0] != '@') {
                signatureMatch = NO;
            }
        }
        
        if (signatureMatch == YES) {
            for (int idx = 2; idx < blockSignature.numberOfArguments; idx++) {
                const char *methodType = [methodSignature getArgumentTypeAtIndex:idx];
                const char *blockType = [blockSignature getArgumentTypeAtIndex:idx];
                if (!methodType || !blockType || blockType[0] != methodType[0]) {
                    signatureMatch = NO;
                    break;
                }
            }
        }
    }
    return signatureMatch;
}
