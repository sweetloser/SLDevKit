//
//  SLTypeAlias.h
//  Pods
//
//  Created by 曾祥翔 on 2023/12/28.
//

#ifndef SLTypeAlias_h
#define SLTypeAlias_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

typedef uintptr_t sl_addr_t;
typedef uint32_t sl_addr32_t;
typedef uint64_t sl_addr64_t;

typedef void *sl_dummy_func_t;
typedef void *sl_asm_func_t;

#if defined(__arm__)

// register context.
typedef struct {
    uint32_t dummy_0;
    uint32_t dummy_1;
    
    uint32_t dummy_2;
    uint32_t sp; // stack point register.
    
    union {
        uint32_t r[13];
        struct {
            uint32_t r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12,
        } regs;
    } general;  // general register.
    
    uint32_t lr; // link register
}SLRegisterContext;

#elif defined(__arm64__) || defined(__aarch64__)

#define ARM64_TMP_REG_NDX_0 17

// floating point register.
typedef union {
    __int128_t q;
    struct {
        double d1;
        double d2;
    }d;
    struct {
        float f1;
        float f2;
        float f3;
        float f4;
    }f;
}SLFloatingPointRegister;

typedef struct {
    uint64_t dummy_0;
    uint64_t sp; // stack point register.
    
    uint64_t dummy_1;
    union {
        uint64_t x[29];
        struct {
            uint64_t x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28;
        }regs;
    }general;   // general register.
    
    uint64_t fp;    // frame point register.
    uint64_t lr;    // link register.
    
    union {
        SLFloatingPointRegister q[32];
        struct {
            SLFloatingPointRegister q0, q1, q2, q3, q4, q5, q6, q7;
            
            SLFloatingPointRegister q8, q9, q10, q11, q12, q13, q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, q30, q31;
        }regs;
    }floating;  // floating point register.
    
}SLRegisterContext;

typedef void(*sl_instrument_callback_t)(void *address, SLRegisterContext *ctx);

#endif

enum sl_ref_label_type_t { kLabelImm19 };

#ifdef __cplusplus
}
#endif

#endif /* SLTypeAlias_h */
