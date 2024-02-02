//
//  SLInstructionRelocationARM64.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/30.
//

#include "SLInstructionRelocationARM64.hpp"
#include "SLTypeAlias.hpp"
#include <unordered_map>
#include "SLAssemblerPseudoLabel.hpp"

typedef struct {
    sl_addr_t mapped_addr;
    uint8_t *buffer;
    uint8_t *buffer_cursor;
    size_t buffer_size;
    
    sl_addr_t src_vmaddr;
    sl_addr_t dst_vmaddr;
    
    SLCodeMemBlock *origin;
    SLCodeMemBlock *relocated;
    
    std::unordered_map<off_t, off_t> relocated_offset_map;
    std::unordered_map<sl_addr_t, SLAssemblerPseudoLabel *> label_map;
}sl_relo_ctx_t;

int relo_relocate(sl_relo_ctx_t *ctx, bool branch) {
    int relocated_insn_count = 0;
    return 0;
}

void genRelocateCode(void *buffer, SLCodeMemBlock *origin, SLCodeMemBlock *relocated, bool branch) {
    sl_relo_ctx_t ctx = {0};
    
    ctx.buffer = (uint8_t *)buffer;
    ctx.buffer_cursor = (uint8_t *)buffer;
    ctx.buffer_size = origin->size;
    
    ctx.src_vmaddr = (sl_addr_t)origin->addr;
    ctx.dst_vmaddr = (sl_addr_t)relocated->addr;
    
    ctx.origin = origin;
    
    
}

void genRelocateCodeAndBranch(void *buffer, SLCodeMemBlock *origin, SLCodeMemBlock *relocated) {
    genRelocateCode(buffer, origin, relocated, true);
}
