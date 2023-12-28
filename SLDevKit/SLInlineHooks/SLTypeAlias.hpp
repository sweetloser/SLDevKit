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

#ifdef __cplusplus
}
#endif

#endif /* SLTypeAlias_h */
