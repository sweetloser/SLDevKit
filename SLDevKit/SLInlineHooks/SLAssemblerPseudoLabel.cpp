//
//  SLAssemblerPseudoLabel.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLAssemblerPseudoLabel.hpp"
#include "SLCodeBuffer.hpp"
#include "SLInstDecodeEncodeKit.hpp"

void SLAssemblerPseudoLabel::link_confused_instructions(SLCodeBufferBase *buffer_) {
    auto buffer = (SLCodeBuffer *)buffer_;
    
    for (auto &ref_label_insn : ref_label_insns_) {
        int64_t fixup_offset = pos() - ref_label_insn.pc_offset;
        sl_arm64_inst_t inst = buffer->loadInst((uint32_t)ref_label_insn.pc_offset);
        sl_arm64_inst_t new_inst = 0;
        
        if (ref_label_insn.link_type == kLabelImm19) {
            new_inst = sl_encode_imm19_offset(inst, fixup_offset);
        }
        buffer->rewriteInst((uint32_t)ref_label_insn.pc_offset, new_inst);
    }
}
