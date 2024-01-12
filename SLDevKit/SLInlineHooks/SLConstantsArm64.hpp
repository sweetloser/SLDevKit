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

/**
 unconditional branch.

 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
 op 0  0  1  0  1  |--------------------------imm26----------------------------------|
 
 op==0 b instruction, op==1 bl instruction.
 
 is the program label to be unconditionally branched to. its offset from the address of this instruction, in the range +/-128MB, is encoded as "imm26" times 4.
 offset = imm26 * 4
 imm26 = offset / 4
 offset four-byte alignment
 
 */
enum SLUnconditionalBranchOP {
    SLUnconditionalBranchOPFixed        = 0x14000000,
    SLUnconditionalBranchOPFixedMask    = 0x7C000000,
    SLUnconditionalBranchOPMask         = 0xFC000000,
    
    B   = SLUnconditionalBranchOPFixed | 0x00000000,
    BL  = SLUnconditionalBranchOPFixed | 0x80000000,
};

/**
 unconditional branch to register.
 
 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
 1  1  0  1  0  1  1  Z  0 |-op-|  1  1  1  1  1  0  0  0  0  A  M |---Rn--| |--Rm---|
 op == 00, br instruction.
 op == 01, blr instruction.
 op == 10, ret instruction.
 
 Z always 0,
 A always 0,
 M always 0,
 Rm always 0000,
 */
enum SLUnconditionalBranchToRegisterOP {
    SLUnconditionalBranchToRegisterOPFixed      = 0xD6000000,
    SLUnconditionalBranchToRegisterOPFixedMask  = 0xFE000000,
    SLUnconditionalBranchToRegisterOPMask       = 0xFFFFFC1F,
    
    BR  = SLUnconditionalBranchToRegisterOPFixed | 0x001F0000,
    BLR = SLUnconditionalBranchToRegisterOPFixed | 0x003F0000,
    RET = SLUnconditionalBranchToRegisterOPFixed | 0x005F0000,
};

// PC relative addressing.
enum SLPCRelAddressingOP {
    SLPCRelAddressingOPFixed        = 0x10000000,
    SLPCRelAddressingOPFixedMask    = 0x1F000000,
    SLPCRelAddressingOPMask         = 0x9F000000,
    ADR     = SLPCRelAddressingOPFixed | 0x00000000,
    ADRP    = SLPCRelAddressingOPFixed | 0x80000000,
};

enum SLLoadRegLiteralOP {
    SLLoadRegLiteralOPFixed         = 0x18000000,
    SLLoadRegLiteralOPFixedMask     = 0x3B000000,
    SLLoadRegLiteralOPMask          = 0xFF000000,
    
#define SLLoadRegLiteralSub(opc, V)    SLLoadRegLiteralOPFixed | LeftShift(opc, 2, 30) | LeftShift(V, 1, 26)
    OPT_W(LDR, literal) = SLLoadRegLiteralSub(0b00, 0),
    OPT_X(LDR, literal) = SLLoadRegLiteralSub(0b01, 0),
    OPT(LDRSW, literal) = SLLoadRegLiteralSub(0b10, 0),
    OPT(PRFM, literal)  = SLLoadRegLiteralSub(0b11, 0),
    
    OPT_S(LDR, literal) = SLLoadRegLiteralSub(0b00, 1),
    OPT_D(LDR, literal) = SLLoadRegLiteralSub(0b01, 1),
    OPT_Q(LDR, literal) = SLLoadRegLiteralSub(0b10, 1),
};

#define SL_LOAD_STORE_OP_LIST(V)   \
  V(OP_W(STRB),   0b00, 0, 0b00),   \
  V(OP_W(LDRB),   0b00, 0, 0b01),   \
  V(OP_X(LDRSB),  0b00, 0, 0b10),   \
  V(OP_W(LDRSB),  0b00, 0, 0b11),   \
  V(OP_B(STR),    0b00, 1, 0b00),   \
  V(OP_B(LDR),    0b00, 1, 0b01),   \
  V(OP_Q(STR),    0b00, 1, 0b10),   \
  V(OP_Q(LDR),    0b00, 1, 0b11),   \
  V(OP_W(STRH),   0b01, 0, 0b00),   \
  V(OP_W(LDRH),   0b01, 0, 0b01),   \
  V(OP_X(LDRSH),  0b01, 0, 0b10),   \
  V(OP_W(LDRSH),  0b01, 0, 0b11),   \
  V(OP_H(STR),    0b01, 1, 0b00),   \
  V(OP_H(LDR),    0b01, 1, 0b01),   \
  V(OP_W(STR),    0b10, 0, 0b00),   \
  V(OP_W(LDR),    0b10, 0, 0b01),   \
  V(OP(LDRSW),    0b10, 0, 0b10),   \
  V(OP_S(STR),    0b10, 1, 0b00),   \
  V(OP_S(LDR),    0b10, 1, 0b01),   \
  V(OP_X(STR),    0b11, 0, 0b00),   \
  V(OP_X(LDR),    0b11, 0, 0b01),   \
  V(OP(PRFM),     0b11, 0, 0b10),   \
  V(OP_D(STR),    0b11, 1, 0b00),   \
  V(OP_D(LDR),    0b11, 1, 0b01),

enum SLLoadStoreOP {
#define SLLoadStoreOPSub(size, V, opc)  LeftShift(size, 2, 30) | LeftShift(V, 1, 26) | LeftShift(opc, 2, 22)
#define SL_LOAD_STORE(opname, size, V, opc) OP(opname) = SLLoadStoreOPSub(size, V, opc)
    
    SL_LOAD_STORE_OP_LIST(SL_LOAD_STORE)

#undef SL_LOAD_STORE
};

// clang-format off
#define SL_LOAD_STORE_PAIR_OP_LIST(V) \
  V(OP_W(STP),    0b00, 0, 0),   \
  V(OP_W(LDP),    0b00, 0, 1),   \
  V(OP_S(STP),    0b00, 1, 0),   \
  V(OP_S(LDP),    0b00, 1, 1),   \
  V(OP(LDPSW),    0b01, 0, 1),   \
  V(OP_D(STP),    0b01, 1, 0),   \
  V(OP_D(LDP),    0b01, 1, 1),   \
  V(OP_X(STP),    0b10, 0, 0),   \
  V(OP_X(LDP),    0b10, 0, 1),   \
  V(OP_Q(STP),    0b10, 1, 0),   \
  V(OP_Q(LDP),    0b10, 1, 1)
// clang-format on
enum SLLoadStorePairOP {
#define SLLoadStorePairOpSub(opc, V, L) LeftShift(opc, 2, 30) | LeftShift(V, 1, 26) | LeftShift(L, 1, 22)
#define SL_LOAD_STORE_PAIR(opname, opc, V, L) OP(opname) = SLLoadStorePairOpSub(opc, V, L)
  SL_LOAD_STORE_PAIR_OP_LIST(SL_LOAD_STORE_PAIR)
#undef LOAD_STORE_PAIR
};

// Load/store unsigned offset.
enum SLLoadStoreUnsignedOffset {
  SLLoadStoreUnsignedOffsetFixed = 0x39000000,
  SLLoadStoreUnsignedOffsetFixedMask = 0x3B000000,
  SLLoadStoreUnsignedOffsetMask = 0xFFC00000,

#define SLLoadStoreUnsignedOffsetSub(size, V, opc)                                                                       \
  SLLoadStoreUnsignedOffsetFixed | LeftShift(size, 2, 30) | LeftShift(V, 1, 26) | LeftShift(opc, 2, 22)
#define SL_LOAD_STORE_UNSIGNED_OFFSET(opname, size, V, opc)                                                               \
  OPT(opname, unsigned) = SLLoadStoreUnsignedOffsetSub(size, V, opc)
  SL_LOAD_STORE_OP_LIST(SL_LOAD_STORE_UNSIGNED_OFFSET)
#undef SL_LOAD_STORE_UNSIGNED_OFFSET
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
