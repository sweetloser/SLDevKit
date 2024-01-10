//
//  SLConstantsArm64.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLConstantsArm64_hpp
#define SLConstantsArm64_hpp

#include <stdio.h>
#include "SLUtilityMacro.hpp"

enum SLShift {
    NO_SHIFT    = -1,
    LSL         = 0x0,
    LSR         = 0x1,
    ASR         = 0x2,
    ROR         = 0x3,
    MSL         = 0x4,
};

enum SLExtend {
    NO_EXTEND       = -1,
    UXTB            = 0,
    UXTH            = 1,
    UXTW            = 2,
    UXTX            = 3,
    SXTB            = 4,
    SXTH            = 5,
    SXTW            = 6,
    SXTX            = 7
};

enum SLAddrMode {
    Offset,
    PreIndex,
    PostIndex,
};

enum SLInstructionFields {
    // registers.
    kRdShift    = 0,
    kRdBits     = 5,
    kRnShift    = 5,
    kRnBits     = 5,
    kRaShift    = 10,
    kRaBits     = 5,
    kRmShift    = 16,
    kRmBits     = 5,
    kRtShift    = 0,
    kRtBits     = 5,
    kRt2Shift   = 10,
    kRt2Bits    = 5,
    kRsShift    = 16,
    kRsBits     = 5,
};

#define OP(op) op
#define OP_W(op) op##_w
#define OP_X(op) op##_x
#define OP_B(op) op##_b
#define OP_H(op) op##_h
#define OP_S(op) op##_s
#define OP_D(op) op##_d
#define OP_Q(op) op##_q

#define OPT(op, attribute) op##_##attribute
#define OPT_W(op, attribute) op##_w_##attribute
#define OPT_X(op, attribute) op##_x_##attribute
#define OPT_B(op, attribute) op##_b_##attribute
#define OPT_H(op, attribute) op##_h_##attribute
#define OPT_S(op, attribute) op##_s_##attribute
#define OPT_D(op, attribute) op##_d_##attribute
#define OPT_Q(op, attribute) op##_q_##attribute

// exception.
enum SLExceptionOp {
    SLExceptionOpFixed  = 0xD4000000,
    SLExceptionOpFMask  = 0xFF000000,
    SLExceptionOpMask   = 0xFFE0001F,
    
    HLT = SLExceptionOpFixed | 0x00400000,
    BRK = SLExceptionOpFixed | 0x00200000,
    SVC = SLExceptionOpFixed | 0x00000001,
    HVC = SLExceptionOpFixed | 0x00000002,
    SMC = SLExceptionOpFixed | 0x00000003,
    DCPS1 = SLExceptionOpFixed | 0x00A00001,
    DCPS2 = SLExceptionOpFixed | 0x00A00002,
    DCPS3 = SLExceptionOpFixed | 0x00A00003,
};

// PC relative addressing.
enum SLPCRelAddressingOP {
    SLPCRelAddressingOPFixed        = 0x10000000,
    SLPCRelAddressingOPFixedMask    = 0x1F000000,
    SLPCRelAddressingOPMask         = 0x9F000000,
    ADR     = SLPCRelAddressingOPFixed | 0x00000000,
    ADRP    = SLPCRelAddressingOPFixed | 0x80000000,
};

/**
 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
 sf op S  1  0  0  0  1  0  sh |------------imm12----------------| |---Rn--| |--Rd---|
 
 sf==0 32-bit register, sf==1 64-bit register.
 op==0 add instruction, op==1 sub instruction.
 S==0 without setting flags, S==1 setting flags.  add | adds
 
 */
enum SLAddSubImmediateOP {
    SLAddSubImmediateOPFixed            = 0x11000000,
    SLAddSubImmediateOPFixedMask        = 0x1F000000,
    SLAddSubImmediateOPMask             = 0xFF000000,

#define SLAddSubImmediateOpSub(sf, op, S)           \
SLAddSubImmediateOPFixed | LeftShift(sf, 1, 31) | LeftShift(op, 1, 30) | LeftShift(S, 1, 29)
    OPT_W(ADD, imm)     = SLAddSubImmediateOpSub(0, 0, 0),
    OPT_W(ADDS, imm)    = SLAddSubImmediateOpSub(0, 0, 1),
    OPT_W(SUB, imm)     = SLAddSubImmediateOpSub(0, 1, 0),
    OPT_W(SUBS, imm)    = SLAddSubImmediateOpSub(0, 1, 1),
    OPT_X(ADD, imm)     = SLAddSubImmediateOpSub(1, 0, 0),
    OPT_X(ADDS, imm)    = SLAddSubImmediateOpSub(1, 0, 1),
    OPT_X(SUB, imm)     = SLAddSubImmediateOpSub(1, 1, 0),
    OPT_X(SUBS, imm)    = SLAddSubImmediateOpSub(1, 1, 1),
};

#endif /* SLConstantsArm64_hpp */
