//
//  SLCodeGen.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#include "SLCodeGen.hpp"

void SLCodeGen::literalLdrBranch(uint64_t address) {
    auto turbo_assembler_ = reinterpret_cast<SLTurboAssembler *>(this->assembler_);
    
#define _ turbo_assembler_->
    auto label = SLRelocLabel::withData(address);
    turbo_assembler_->appendRelocLabel(label);
    
    _ Ldr(SL_TMP_REG_0, label);
    _ br(SL_TMP_REG_0);
#undef _
}
