//
//  SLNormalTrampoline.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#include "SLNormalTrampoline.hpp"
#include "SLTurboAssembler.hpp"
#include "SLCodeGen.hpp"

SLCodeBufferBase *generateNormalTrampolineBuffer(sl_addr_t from, sl_addr_t to) {
    SLTurboAssembler turbo_assembler_((void *)from);
#define _ turbo_assembler_.
    
    uint64_t distance = llabs((int64_t)(from - to));
    uint64_t adrp_range = ((uint64_t)1 << (2 + 19 + 12 -1));
    
    if (distance < adrp_range) {
        _ adrpAdd(SL_TMP_REG_0, from, to);
        _ br(SL_TMP_REG_0);
        SLDEBUG_LOG("[trampoline] use [adrp, add, br]");
    } else {
        SLCodeGen codegen(&turbo_assembler_);
        codegen.literalLdrBranch((uint64_t)to);
        SLDEBUG_LOG("[trampoline] use [ldr, br, #label]");
    }
#undef _
    
    turbo_assembler_.relocBind();
    
    auto result = turbo_assembler_.getCodeBuffer()->copy();
    return result;
    
}
