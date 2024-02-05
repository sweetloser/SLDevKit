//
//  SLClosureBridge.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLClosureBridge_hpp
#define SLClosureBridge_hpp

#include <stdio.h>
#include "SLTypeAlias.hpp"

#ifdef __cplusplus
extern "C" {
#endif

sl_asm_func_t get_closure_bridge(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* SLClosureBridge_hpp */
