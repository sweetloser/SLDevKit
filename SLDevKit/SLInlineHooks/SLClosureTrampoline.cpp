//
//  SLClosureTrampoline.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLClosureTrampoline.hpp"
#include "SLTurboAssembler.hpp"

SLClosureTrampolineEntry *SLClosureTrampoline::createClosureTrampoline(void *carry_data, void *carry_handler) {
    SLClosureTrampolineEntry *tramp_entry = nullptr;
    tramp_entry = new SLClosureTrampolineEntry;
    
    SLTurboAssembler turbo_assembler_(0);
    
    SLAssemblerPseudoLabel entry_label(0);
    SLAssemblerPseudoLabel forward_bridge_label(0);
#define _ turbo_assembler_.
    
    _ sub(SP, SP, 2 * 8);
    _ str(x30, SLMemOperand(SP, 8));
    
    _ Ldr(SL_TMP_REG_0, &entry_label);
    _ str(SL_TMP_REG_0, SLMemOperand(SP, 0));
    
    _ Ldr(SL_TMP_REG_0, &forward_bridge_label);
    _ blr(SL_TMP_REG_0);
    
    _ ldr(x30, SLMemOperand(SP, 8));
    _ add(SP, SP, 2 * 8);
    
    _ br(SL_TMP_REG_0);
    
    _ pseudoBind(&entry_label);
    _ emitInt64((uint64_t)tramp_entry);
    _ pseudoBind(&forward_bridge_label);
    
    return tramp_entry;
}
