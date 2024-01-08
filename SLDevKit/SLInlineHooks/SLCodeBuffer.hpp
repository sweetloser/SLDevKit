//
//  SLCodeBuffer.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLCodeBuffer_hpp
#define SLCodeBuffer_hpp

#ifdef __cplusplus
#include <stdio.h>
#include "SLCodeBufferBase.hpp"

typedef int32_t sl_arm64_inst_t;

class SLCodeBuffer : public SLCodeBufferBase {
public:
    SLCodeBuffer() : SLCodeBufferBase() {}
    
public:
    sl_arm64_inst_t loadInst(uint32_t offset) {
        return *reinterpret_cast<int32_t *>(getBuffer() + offset);
    }
    void rewriteInst(uint32_t offset, sl_arm64_inst_t instr) {
        *reinterpret_cast<sl_arm64_inst_t *>(getBuffer() + offset) = instr;
    }
};

#endif
#endif /* SLCodeBuffer_hpp */
