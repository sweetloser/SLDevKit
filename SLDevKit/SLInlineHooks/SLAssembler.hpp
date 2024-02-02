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

class SLAssembler : public SLAssemblerBase{
public:
    SLAssembler(void *address) : SLAssemblerBase(address) {
        buffer_ = new SLCodeBuffer();
    }
    
    ~SLAssembler() {
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
    
    void str(const SLCPURegister &rt, const SLMemOperand &src) {
        loadStore(OP_X(STR), rt, src);
    }
    
    void ldp(const SLRegister &rt1, const SLRegister &rt2, const SLMemOperand &src) {
        if (rt1.type() == SLRegister::kSIMD_FP_Register_128) {
            loadStorePair(OP_Q(LDP), rt1, rt2, src);
        } else if (rt1.type() == SLRegister::kRegister_X) {
            loadStorePair(OP_X(LDP), rt1, rt2, src);
        } else {
            // 未定义
        }
    }
    
    void stp(const SLRegister &rt1, const SLRegister &rt2, const SLMemOperand &dst) {
        if (rt1.type() == SLRegister::kSIMD_FP_Register_128) {
            loadStorePair(OP_Q(STP), rt1, rt2, dst);
        } else if (rt1.type() == SLRegister::kRegister_X) {
            loadStorePair(OP_X(STP), rt1, rt2, dst);
        } else {
            // 未定义
        }
    }
    
    void mov(const SLRegister &rd, const SLRegister &rn) {
        if (rd.is(SP) || rn.is(SP)) {
            add(rd, rn, 0);
        } else {
            if (rd.is64Bits()) {
                orr(rd, xzr, SLOperand(rn));
            } else {
                orr(rd, wzr, SLOperand(rn));
            }
        }
    }
    
    void movk(const SLRegister &rd, uint64_t imm, int shift = -1) {
        moveWide(rd, imm, shift, MOVK);
    }
    void movn(const SLRegister &rd, uint64_t imm, int shift = -1) {
        moveWide(rd, imm, shift, MOVN);
    }
    void movz(const SLRegister &rd, uint64_t imm, int shift = -1) {
        moveWide(rd, imm, shift, MOVZ);
    }
    void orr(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand) {
        logical(rd, rn, operand, ORR);
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
            // 未定义
        } else {
            // 未定义
        }
    }
    
    void loadStorePair(SLLoadStorePairOP op, SLCPURegister rt1, SLCPURegister rt2, const SLMemOperand &addr) {
        int32_t combine_fields_op = SLOPEncode::loadStorePair(op, rt1, rt2, addr) | Rt2(rt2) | Rn(addr.base()) | Rt(rt1);
        int32_t addrmodeop;
        
        if (addr.isImmediateOffset()) {
            addrmodeop = SLLoadStorePairOffsetOPFixed;
        } else {
            if (addr.isPreIndex()) {
                addrmodeop = SLLoadStorePairPreIndexOPFixed;
            } else {
                addrmodeop = SLLoadStorePairPostIndexOPFixed;
            }
        }
        emit(op | addrmodeop | combine_fields_op);
    }
    
    void moveWide(SLRegister rd, uint64_t imm, int shift, SLMoveWideImmediateOP op) {
        if (shift > 0) {
            shift /= 16;
        } else {
            shift = 0;
        }
        
        int32_t imm16 = (int32_t)LeftShift(imm, 16, 5);
        emit(SLMoveWideImmediateOPFixed | op | SLOPEncode::sf(rd) | LeftShift(shift, 2, 21) | imm16 | Rd(rd));
    }
    
    void logical(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand, SLLogicalOP op) {
        if (operand.isImmediate()) {
            
        }
    }
    void logicalImmediate(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand, SLLogicalOP op) {
        int32_t combine_fields_op = SLOPEncode::encodeLogicalImmediate(rd, rn, operand);
        emit(op | combine_fields_op);
    }
    
};

#endif
#endif /* SLAssemblerArm64_hpp */
