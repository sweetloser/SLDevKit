//
//  SLHookHeader.h
//  Pods
//
//  Created by zengxiangxiang on 2023/9/8.
//

#ifndef SLHookHeader_h
#define SLHookHeader_h

FOUNDATION_EXTERN const NSString *kSLHookErrorDomain;
FOUNDATION_EXTERN const NSString *kSLHookSubclassSuffix;
FOUNDATION_EXTERN const NSString *kSLHookForwardInvocationSelectorName;

#pragma mark - block 解析

typedef void(*__SLHook_BlockInvokeFunction)(void *, ...);
typedef void(*__SLHook_BlockCopyFunction)(void *, const void *);
typedef void(*__SLHook_BlockDisposeFunction)(const void *);
// flags标志位的含义
enum {
    __SLHook_BLOCK_DEALLOCATING =      (0x0001),  // runtime
    __SLHook_BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    __SLHook_BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    __SLHook_BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    __SLHook_BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    __SLHook_BLOCK_IS_GC =             (1 << 27), // runtime
    __SLHook_BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    __SLHook_BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    __SLHook_BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    __SLHook_BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

struct __SLHook_Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};
struct __SLHook_Block_descriptor_2 {
    // 当 flags & BLOCK_HAS_COPY_DISPOSE 为真时，该结构体存在
    __SLHook_BlockCopyFunction copy;
    __SLHook_BlockDisposeFunction dispose;
};
struct __SLHook_Block_descriptor_3 {
    // 当 flags & BLOCK_HAS_SIGNATURE 为真时，该结构体存在
    const char *signature;
    const char *layout;
};

typedef struct __SLHook_BlockLayout {
    void *isa;
    volatile int32_t flags;                             // 标识码
    int32_t reserved;                                   // 保留位
    __SLHook_BlockInvokeFunction invoke;                  // block的imp
    struct __SLHook_Block_descriptor_1 *descriptor;
} *__SLHook_BlockLayout;


#define SLHookPositionOptionsFilter 0x7

typedef NS_OPTIONS(NSUInteger, SLHookOptions) {
    SLHookPositionOptionBefore = 0,
    SLHookPositionOptionInstead = 1,
    SLHookPositionOptionAfter = 2,
    
    SLHookOptionRemoveAfterCalled = 1<<3,
};

typedef NS_ENUM(NSUInteger, SLHookErrorCode) {
    SLHookErrorSelectorBlacklisted,         /// 函数被列入黑名单；黑名单如下：release, autorelease, retain, forwardInvocation:
    SLHookErrorDoesNotRespondToSelector,    /// 函数未被实现
    SLHookErrorMissingBlockSignature,       /// block缺少方法签名
};


#endif /* SLHookHeader_h */
