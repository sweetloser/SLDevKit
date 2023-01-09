//
//  SLBlockInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/9.
//

#import "SLBlockInfo.h"
#import "SLDefs.h"

/// 以下类型定义来自`https://opensource.apple.com/source/libclosure/libclosure-79/Block_private.h`
///
typedef void(*BlockCopyFunction)(void *, const void *);
typedef void(*BlockDisposeFunction)(const void *);
typedef void(*BlockInvokeFunction)(void *, ...);

#if __has_feature(ptrauth_signed_block_descriptors) || !__has_feature(ptrauth_calls)
#define BLOCK_SMALL_DESCRIPTOR_SUPPORTED 1
#endif
enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_INLINE_LAYOUT_STRING = (1 << 21), // compiler

#if BLOCK_SMALL_DESCRIPTOR_SUPPORTED
    BLOCK_SMALL_DESCRIPTOR =  (1 << 22), // compiler
#endif

    BLOCK_IS_NOESCAPE =       (1 << 23), // compiler
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

struct Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    BlockCopyFunction copy;
    BlockDisposeFunction dispose;
};

struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};
struct Block_layout {
    void * __ptrauth_objc_isa_pointer isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    BlockInvokeFunction invoke;
    struct Block_descriptor_1 *descriptor;
    // imported variables
};

@interface SLBlockInfo ()

@property(nonatomic,strong,readwrite)id block;
@property (nonatomic,strong,readwrite)NSMethodSignature *signature;

@end

@implementation SLBlockInfo

#pragma mark - 初始化
-(instancetype)initWithBlock:(id)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (const char *)argumentTypeAtIndex:(NSInteger)index {
    return [self.signature getArgumentTypeAtIndex:index + 1];
}
- (BOOL)isAcceptingIntAtIndex:(NSInteger)index {
    if (index < self.argumentCount) {
        return SL_CHECK_IS_INT([self argumentTypeAtIndex:index][0]);
    }
    return NO;
}
- (BOOL)isAcceptingFloatAtIndex:(NSInteger)index {
    if (index < self.argumentCount) {
        return SL_CHECK_IS_FLOAT([self argumentTypeAtIndex:index][0]);
    }
    return NO;
}
- (BOOL)isAcceptingObjectAtIndex:(NSInteger)index {
    if (index < self.argumentCount) {
        return SL_CHECK_IS_OBJECT([self argumentTypeAtIndex:index][0]);
    }
    return NO;
}

#pragma mark - private
-(NSMethodSignature *)_getSignatureWithBlock:(id)block {
    struct Block_layout *blockLayout = (__bridge struct Block_layout *)block;
    unsigned char *desc3 = NULL;
    if (!(blockLayout->flags & BLOCK_HAS_SIGNATURE)) {
        return nil;
    }
    // block有签名
    desc3 = (unsigned char *)blockLayout->descriptor;
    desc3 += sizeof(struct Block_descriptor_1);
    
    if (blockLayout->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc3 += sizeof(struct Block_descriptor_2);
    }
    return [NSMethodSignature signatureWithObjCTypes:((struct Block_descriptor_3 *)desc3)->signature];
}

#pragma mark - 懒加载
-(NSMethodSignature *)signature {
    if (!_signature) {
        _signature = [self _getSignatureWithBlock:self.block];
    }
    return _signature;
}
- (const char *)returnType {
    return [self.signature methodReturnType];
}
- (NSInteger)argumentCount {
    return [self.signature numberOfArguments]-1;
}
- (BOOL)isReturningInt {
    return SL_CHECK_IS_INT(self.returnType[0]);
}
- (BOOL)isReturningFloat {
    return SL_CHECK_IS_FLOAT(self.returnType[0]);
}
- (BOOL)isReturningObject {
    return SL_CHECK_IS_OBJECT(self.returnType[0]);
}



@end
