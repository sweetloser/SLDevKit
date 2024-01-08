//
//  SLInstDecodeEncodeKit.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLInstDecodeEncodeKit_hpp
#define SLInstDecodeEncodeKit_hpp

#include <stdio.h>
#include <stdint.h>
#include "SLUtilityMacro.hpp"

static inline uint32_t sl_encode_imm19_offset(uint32_t instr, int64_t offset) {
    uint32_t imm19 = bits((offset >> 2), 0, 18);
    set_bits(instr, 5, 23, imm19);
    return instr;
}
#endif /* SLInstDecodeEncodeKit_hpp */
