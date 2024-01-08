//
//  SLInterceptEntry.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#ifndef SLInterceptEntry_hpp
#define SLInterceptEntry_hpp

#include <stdio.h>
#include <stdint.h>
#include "SLTypeAlias.hpp"

#ifdef __cplusplus

typedef enum {
    SLInterceptEntryTypeFunctionInlineHook,
    SLInterceptEntryTypeInstructionInstrument,
}SLInterceptEntryType;

class SLInterceptRouting;

typedef struct SLInterceptEntry {
    uint32_t id;
    SLInterceptEntryType type;
    SLInterceptRouting *routing;
    
    union {
        sl_addr_t addr;
        sl_addr_t patched_addr;
    };
    uint32_t patched_size;
    
    sl_addr_t relocated_addr;
    uint32_t relocated_size;
    
    uint8_t origin_insns[256];
    uint32_t origin_insn_size;
    
    bool thumb_mode;
    
    SLInterceptEntry(SLInterceptEntryType type, sl_addr_t address);
}SLInterceptEntry;

#endif

#endif /* SLInterceptEntry_hpp */
