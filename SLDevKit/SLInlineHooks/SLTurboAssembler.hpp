//
//  SLTurboAssembler.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/30.
//

#ifndef SLTurboAssembler_hpp
#define SLTurboAssembler_hpp
#ifdef __cplusplus
#include "SLAssembler.hpp"
#include "SLExternalReference.hpp"

constexpr SLRegister SL_TMP_REG_0 = X(SL_ARM64_TMP_REG_NDX_0);

static inline uint16_t Low16Bits(uint32_t value) {
    return static_cast<uint16_t>(value & 0xFFFF);
}
static inline uint16_t High16Bits(uint32_t value) {
    return static_cast<uint16_t>(value >> 16);
}
static inline uint32_t Low32Bits(uint64_t value) {
    return static_cast<uint32_t>(value & 0xFFFFFFFF);
}
static inline uint32_t High32Bits(uint64_t value) {
    return static_cast<uint32_t>(value >> 32);
}

class SLTurboAssembler : public SLAssembler {
public:
    SLTurboAssembler(void *address) : SLAssembler(address) {
    }
    ~SLTurboAssembler() {}
    
    void callFunction(SLExternalReference function) {
        Mov(SL_TMP_REG_0, (uint64_t)function.address());
        blr(SL_TMP_REG_0);
    }
    
    void Mov(SLRegister rd, uint64_t imm) {
        const uint32_t w0 = Low32Bits(imm);
        const uint32_t w1 = High32Bits(imm);
        const uint16_t h0 = Low16Bits(w0);
        const uint16_t h1 = High16Bits(w0);
        const uint16_t h2 = Low16Bits(w1);
        const uint16_t h3 = High16Bits(w1);
        movz(rd, h0, 0);
        movk(rd, h1, 16);
        movk(rd, h2, 32);
        movk(rd, h3, 48);
    }
    
    void Ldr(SLRegister rt, SLAssemblerPseudoLabel *label) {
        if (label->pos()) {
            int offset = (int)(label->pos() - buffer_->getBufferSize());
            ldr(rt, offset);
        } else {
            label->link_to(kLabelImm19, (uint32_t)buffer_->getBufferSize());
            ldr(rt, 0);
        }
    }
    
    void adrpAdd(SLRegister rd, uint64_t from, uint64_t to) {
        uint64_t from_page = ALIGN(from, 0x1000);
        uint64_t to_page = ALIGN(to, 0x1000);
        uint64_t to_page_off = (uint64_t)to % 0x1000;
        
        adrp(rd, to_page - from_page);
        add(rd, rd, to_page_off);
    }
};


#endif
#endif /* SLTurboAssembler_hpp */
