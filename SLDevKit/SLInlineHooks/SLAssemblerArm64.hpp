//
//  SLAssemblerArm64.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLAssemblerArm64_hpp
#define SLAssemblerArm64_hpp

#include <stdio.h>
#ifdef __cplusplus
#include "SLAssemblerBase.hpp"
#include "SLCheckLogging.hpp"
#include "SLConstantsArm64.hpp"
#include "SLUtilityMacro.hpp"
#include "SLCPURegister.hpp"
#include "SLOperand.hpp"

#define Rd(rd)  (rd.code() << kRdShift)
#define Rt(rt)  (rt.code() << kRtShift)
#define Rn(rn)  (rn.code() << kRnShift)

class SLAssemblerArm64 : public SLAssemblerBase{
public:
    SLAssemblerArm64(void *address) : SLAssemblerBase(address) {
        buffer_ = new SLCodeBuffer();
    }
    
    ~SLAssemblerArm64() {
        if (buffer_) {
            delete buffer_;
        }
        buffer_ = NULL;
    }
    
public:
    void setRealizedAddress(void *address) {
        CHECK_EQ(0, reinterpret_cast<uint64_t>(address) % 4);
        SLAssemblerBase::setRealizedAddress(address);
    }
    
    void emit(uint32_t value) {
        buffer_->emit32(value);
    }
    
    void emitInt64(int64_t value) {
        buffer_->emit64(value);
    }
    
    void bind(SLLabel *label);
    
    void nop() {
        emit(0xD503201F);
    }
    // the imme of brk(breakpoint instruction) is stored in bits 5 to 20.
    void brk(int code) {
        emit(BRK | LeftShift(code, 16, 5));
    }
    
    void ret() {
        emit(0xD65F03C0);
    }
    
    void adrp(const SLRegister &rd, int64_t imm) {
        CHECK(rd.is64Bits());
        CHECK((abs(imm) >> 12) < (1 << 21));
        
        uint32_t immlo = (uint32_t)LeftShift(bits(imm >> 12, 0, 1), 2, 29);
        uint32_t immhi = (uint32_t)LeftShift(bits(imm >> 12, 2, 20), 19, 5);
        emit(ADRP | Rd(rd) | immlo | immhi);
    }
    
    void add(const SLRegister &rd, const SLRegister &rn, int64_t imm) {
        if (rd.is64Bits() && rn.is64Bits()) {
            // 64-bit register.
            addSubImmediate(rd, rn, SLOperand(imm), OPT_X(ADD, imm));
        } else {
            // 32-bit register.
            addSubImmediate(rd, rn, SLOperand(imm), OPT_W(ADD, imm));
        }
    }
    
    void sub(const SLRegister &rd, const SLRegister &rn, int64_t imm) {
        if (rd.is64Bits() && rn.is64Bits()) {
            // 64-bit register.
            addSubImmediate(rd, rn, SLOperand(imm), OPT_X(SUB, imm));
        } else {
            // 32-bit register.
            addSubImmediate(rd, rn, SLOperand(imm), OPT_W(SUB, imm));
        }
    }
    
private:
    void addSubImmediate(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand, SLAddSubImmediateOP op) {
        if (operand.isImmediate()) {
            int64_t imediate = operand.immediate();
            int32_t imm12 = (int32_t)LeftShift(imediate, 12, 10);
            emit((uint32_t)op | (uint32_t)Rd(rd) | (uint32_t)Rn(rn) | (uint32_t)imm12);
        } else {
            SLFATAL_LOG("unreachable code!!!");
        }
    }
};

#endif
#endif /* SLAssemblerArm64_hpp */
