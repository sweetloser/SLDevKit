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
    
//    inline explicit SLMemOperand(SLRegister)
private:
    SLRegister base_;
    SLRegister regoffset_;
    
    int64_t offset_;
    SLShift shift_;
    SLExtend extend_;
    uint32_t shift_extend_imm_;
    
    SLAddrMode addrmode_;
};


#endif
#endif /* SLOperand_hpp */
