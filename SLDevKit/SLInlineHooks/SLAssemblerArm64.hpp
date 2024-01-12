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
    
    void b(int64_t offset) {
        // encode offset:
        int32_t imm26 = bits(offset >> 2, 0, 25);
        emit(B | imm26);
    }
    void b(SLLabel *label) {
        int offset = linkAndGetByteOffsetTo(label);
        b(offset);
    }
    void br(SLRegister rn) {
        emit(BR | Rn(rn));
    }
    void blr(SLRegister rn) {
        emit(BLR | Rn(rn));
    }
    
    void ldr(SLRegister rt, int64_t imm) {
        SLLoadRegLiteralOP op;
        switch (rt.type()) {
            case SLCPURegister::kRegister_W:
                op = OPT_W(LDR, literal);
                break;
            case SLCPURegister::kRegister_X:
                op = OPT_X(LDR, literal);
                break;
            case SLCPURegister::kSIMD_FP_Register_S:
                op = OPT_S(LDR, literal);
                break;
            case SLCPURegister::kSIMD_FP_Register_D:
                op = OPT_D(LDR, literal);
                break;
            case SLCPURegister::kSIMD_FP_Register_Q:
                op = OPT_Q(LDR, literal);
                break;
            default:
                SLFATAL_LOG("%s\n", "unreachable code!!!");
                op = SLLoadRegLiteralOPMask;
                break;
        }
        emitLoadRegLiteral(op, rt, imm);
    }
    
    void ldr(const SLCPURegister &rt, const SLMemOperand &src) {
        loadStore(OP_X(LDR), rt, src);
    }
    
private:
    // label helpers.
    int linkAndGetByteOffsetTo(SLLabel *label) {
        int offset = (int)label->pos() - (int)pc_offset();
        return offset;
    }
    // load helpers.
    void emitLoadRegLiteral(SLLoadRegLiteralOP op, SLRegister rt, int64_t imm) {
        const int32_t encoding = (int32_t)(op | LeftShift(imm, 26, 5) | Rt(rt));
        emit(encoding);
    }
    
    void addSubImmediate(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand, SLAddSubImmediateOP op) {
        if (operand.isImmediate()) {
            int64_t imediate = operand.immediate();
            int32_t imm12 = (int32_t)LeftShift(imediate, 12, 10);
            emit((uint32_t)op | (uint32_t)Rd(rd) | (uint32_t)Rn(rn) | (uint32_t)imm12);
        } else {
            SLFATAL_LOG("unreachable code!!!");
        }
    }
    
    void loadStore(SLLoadStoreOP op, SLCPURegister rt, const SLMemOperand &addr) {
        int64_t imm12 = addr.offset();
        if (addr.isImmediateOffset()) {
            imm12 = addr.offset() >> SLOPEncode::scale(SLLoadStoreUnsignedOffsetFixed | op);
            emit((uint32_t)(SLLoadStoreUnsignedOffsetFixed | op | LeftShift(imm12, 12, 10) | Rn(addr.base()) | Rt(rt)));
        } else if (addr.isRegisterOffset()) {
            
        } else {
            
        }
    }
};

#endif
#endif /* SLAssemblerArm64_hpp */
