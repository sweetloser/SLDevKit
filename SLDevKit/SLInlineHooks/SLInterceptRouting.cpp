//
//  SLInterceptRouting.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#include "SLInterceptRouting.hpp"
#include "SLInstructionRelocationARM64.hpp"
#include "SLLogger.h"

void SLInterceptRouting::prepare() {
}

bool SLInterceptRouting::generateRelocateCode() {
    uint32_t tramp_size = (uint32_t)getTrampolineBuffer()->getBufferSize();
    origin_ = new SLCodeMemBlock(entry_->patched_addr, tramp_size);
    relocated_ = new SLCodeMemBlock();
    
    auto buffer = (void *)entry_->patched_addr;
#if defined(TARGET_ARCH_ARM)
    if (entry_->thumb_mode) {
        buffer = (void *)((sl_addr_t)buffer) + 1);
    }
#endif
    genRelocateCodeAndBranch(buffer, origin_, relocated_);
    if (relocated_->size == 0) {
        SLERROR_LOG("[insn relocate] failed");
        return false;
    }
    
    entry_->relocated_addr = relocated_->addr;
    
    memcpy((void *)entry_->origin_insns, (void *)origin_->addr, origin_->size);
    
    SLDEBUG_LOG("[insn relocate] origin %p - %d", origin_->addr, origin_->size);
    
    return true;
}
void SLInterceptRouting::active() {
    auto ret = sl_codePatch((void *)entry_->patched_addr, trampoline_buffer_->getBuffer(), (uint32_t)trampoline_buffer_->getBufferSize());
    if (ret == -1) {
        return;
    }
}
void SLInterceptRouting::commit() {
    this->active();
}

