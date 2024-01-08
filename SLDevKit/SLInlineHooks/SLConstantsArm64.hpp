//
//  SLConstantsArm64.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLConstantsArm64_hpp
#define SLConstantsArm64_hpp

#include <stdio.h>

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

#endif /* SLConstantsArm64_hpp */
