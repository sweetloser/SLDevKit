//
//  SLOperand.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLOperand_hpp
#define SLOperand_hpp

#include <stdio.h>
#ifdef __cplusplus
#include <stdint.h>
#include "SLCPURegister.hpp"
#include "SLConstantsArm64.hpp"
#include "SLCheckLogging.hpp"

class SLOperand {
public:
    inline explicit SLOperand(int64_t imm) : immediate_(imm), reg_(InvalidRegister), shift_(NO_SHIFT), extend_(NO_EXTEND), shift_extent_imm_(0) {}
    inline SLOperand(SLRegister reg, SLShift shift = LSL, int32_t shift_imm = 0) : immediate_(0), reg_(reg), shift_(shift), extend_(NO_EXTEND), shift_extent_imm_(shift_imm) {}
    
    inline SLOperand(SLRegister reg, SLExtend extend, int32_t shift_imm = 0) : immediate_(0), reg_(reg), shift_(NO_SHIFT), extend_(extend), shift_extent_imm_(shift_imm) {}
    bool isImmediate() const {
        return reg_.is(InvalidRegister);
    }
    
    bool isShiftedRegister() const {
        return (shift_ != NO_SHIFT);
    }
    
    bool isExtendedRegister() const {
        return (extend_ != NO_EXTEND);
    }
    
    SLRegister reg() const {
        CHECK((isShiftedRegister() || isExtendedRegister()));
        return reg_;
    }
    int64_t immediate() const {
        return immediate_;
    }
    SLShift shift() const {
        CHECK(isShiftedRegister());
        return shift_;
    }
    SLExtend extend() const {
        CHECK(isExtendedRegister());
        return extend_;
    }
    
    int32_t shift_extend_imm() const {
        return shift_extent_imm_;
    }
    
private:
    int64_t immediate_;
    
    SLRegister reg_;
    
    SLShift shift_;
    SLExtend extend_;
    int32_t shift_extent_imm_;
};

class SLMemOperand {
public:
    inline explicit SLMemOperand(SLRegister base, int64_t offset = 0, SLAddrMode addrmode = Offset) : base_(base), regoffset_(InvalidRegister), offset_(offset), addrmode_(addrmode), shift_(NO_SHIFT), extend_(NO_EXTEND), shift_extend_imm_(0) {}
    
    inline explicit SLMemOperand(SLRegister base, SLRegister regoffset, SLExtend extend, unsigned extend_imm) : base_(base), regoffset_(regoffset), offset_(0), addrmode_(Offset), shift_(NO_SHIFT), extend_(extend), shift_extend_imm_(extend_imm) {}
    
    inline explicit SLMemOperand(SLRegister base, SLRegister regoffset, SLShift shift = LSL, unsigned shift_imm = 0) : base_(base), regoffset_(regoffset), offset_(0), addrmode_(Offset), shift_(shift), extend_(NO_EXTEND), shift_extend_imm_(shift_imm) {}
    
    inline explicit SLMemOperand(SLRegister base, const SLOperand &offset, SLAddrMode addrmode = Offset) : base_(base), regoffset_(InvalidRegister), addrmode_(addrmode) {
        if (offset.isShiftedRegister()) {
            regoffset_ = offset.reg();
            shift_ = offset.shift();
            shift_extend_imm_ = offset.shift_extend_imm();
            
            extend_ = NO_EXTEND;
            offset_ = 0;
        } else if (offset.isExtendedRegister()) {
            regoffset_ = offset.reg();
            extend_ = offset.extend();
            shift_extend_imm_ = offset.shift_extend_imm();
            
            shift_ = NO_SHIFT;
            offset_ = 0;
        }
    }
    
    const SLRegister &base() const {
        return base_;
    }
    const SLRegister &regoffset() const {
        return regoffset_;
    }
    int64_t offset() const {
        return offset_;
    }
    SLAddrMode addrmode() const {
        return addrmode_;
    }
    SLShift shift() const {
        return shift_;
    }
    SLExtend extend() const {
        return extend_;
    }
    unsigned shift_extend_imm() const {
        return shift_extend_imm_;
    }
    
    bool isImmediateOffset() const {
        return (addrmode_ == Offset);
    }
    bool isRegisterOffset() const {
        return (addrmode_ == Offset);
    }
    bool isPreIndex() const {
        return (addrmode_ == PreIndex);
    }
    bool isPostIndex() const {
        return addrmode_ == PostIndex;
    }
    
private:
    SLRegister base_;
    SLRegister regoffset_;
    
    int64_t offset_;
    SLShift shift_;
    SLExtend extend_;
    uint32_t shift_extend_imm_;
    
    SLAddrMode addrmode_;
};

class SLOPEncode {
public:
    static int32_t sf(const SLRegister &reg, int32_t op) {
        return (op | sf(reg));
    }
    static int32_t sf(const SLRegister &reg) {
        if (reg.is64Bits()) {
            return LeftShift(1, 1, 31);
        }
        return 0;
    }
    
    static int32_t v(const SLRegister &reg, int32_t op) {
        return (op | sf(reg));
    }
    static int32_t v(const SLRegister &reg) {
        if (reg.isVRegister()) {
            return LeftShift(1, 1, 26);
        }
        return 0;
    }
    
    static int32_t l(bool load_or_store) {
        if (load_or_store) {
            return LeftShift(1, 1, 22);
        }
        return 0;
    }
    
    static int32_t shift(SLShift shift) {
        return LeftShift(shift, 2, 22);
    }
    
    static int encodeLogicalImmediate(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand) {
        int64_t imm = operand.immediate();
        int32_t n, imms, immr;
        immr = bits(imm, 0, 5);
        imms = bits(imm, 6, 11);
        n = bit(imm, 12);
        
        return (sf(rd) | LeftShift(immr, 6, 16) | LeftShift(imms, 6, 10) | Rd(rd) | Rn(rn));
    }
    
    static int32_t encodeLogicalShift(const SLRegister &rd, const SLRegister &rn, const SLOperand &operand) {
        return (sf(rd) | shift(operand.shift()) | Rm(operand.reg()) | LeftShift(operand.shift_extend_imm(), 6, 10) | Rn(rn) | Rd(rd));
    }
    
    static int32_t loadStorePair(SLLoadStorePairOP op, SLRegister rt, SLRegister rt2, const SLMemOperand &addr) {
        int32_t scale = 2;
        int32_t opc = 0;
        int imm7;
        opc = bits(op, 30, 31);
        if (rt.isRegister()) {
            scale += bit(opc, 1);
        } else if (rt.isVRegister()) {
            scale += opc;
        }
        imm7 = (int)(addr.offset() >> scale);
        return LeftShift(imm7, 7, 15);
    }
    
    static int32_t scale(int32_t op) {
        int scale = 0;
        if ((op & SLLoadStoreUnsignedOffsetFixed) == SLLoadStoreUnsignedOffsetFixed) {
            scale = bits(op, 30, 31);
        }
        return scale;
    }
public:
    
};

#endif
#endif /* SLOperand_hpp */
