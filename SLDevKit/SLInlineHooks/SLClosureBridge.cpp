//
//  SLClosureBridge.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#include "SLClosureBridge.hpp"
#include "SLTurboAssembler.hpp"
#include "SLMemoryAllocator.hpp"
#include "SLCommonBridgeHandler.hpp"
#include "SLConstantsArm64.hpp"
#include "SLAssemblyCodeBuilder.hpp"

static sl_asm_func_t closure_bridge_ = nullptr;
sl_asm_func_t get_closure_bridge(void) {
    if (closure_bridge_) {
        return closure_bridge_;
    }
    
    SLTurboAssembler turbo_assembler_(0);
#define _ turbo_assembler_.
#define MEM(reg, offset)    SLMemOperand(reg, offset)
    _ sub(SP, SP, 8 * 16);
    _ stp(Q(6), Q(7), MEM(SP, 6 * 16));
    _ stp(Q(4), Q(5), MEM(SP, 4 * 16));
    _ stp(Q(2), Q(3), MEM(SP, 2 * 16));
    _ stp(Q(0), Q(1), MEM(SP, 0 * 16));
    
    _ sub(SP, SP, 30 * 8);
    _ stp(X(29), X(30), MEM(SP, 28 * 8));
    _ stp(X(27), X(28), MEM(SP, 26 * 8));
    _ stp(X(25), X(26), MEM(SP, 24 * 8));
    _ stp(X(23), X(24), MEM(SP, 22 * 8));
    _ stp(X(21), X(22), MEM(SP, 20 * 8));
    _ stp(X(19), X(20), MEM(SP, 18 * 8));
    _ stp(X(17), X(18), MEM(SP, 16 * 8));
    _ stp(X(15), X(16), MEM(SP, 14 * 8));
    _ stp(X(13), X(14), MEM(SP, 12 * 8));
    _ stp(X(11), X(12), MEM(SP, 10 * 8));
    _ stp(X(9), X(10), MEM(SP, 8 * 8));
    _ stp(X(7), X(8), MEM(SP, 6 * 8));
    _ stp(X(5), X(6), MEM(SP, 4 * 8));
    _ stp(X(3), X(4), MEM(SP, 2 * 8));
    _ stp(X(1), X(2), MEM(SP, 0 * 8));
    
    _ sub(SP, SP, 2 * 8);
    _ str(x0, MEM(SP, 8));
    
    _ add(SL_TMP_REG_0, SP, 2 * 8);
    _ add(SL_TMP_REG_0, SL_TMP_REG_0, 2 * 8 + 30 * 8 + 8 * 16);
    _ sub(SP, SP, 2 * 8);
    _ str(SL_TMP_REG_0, MEM(SP, 8));
    
    _ mov(x0, SP);
    _ ldr(x1, MEM(SP, sizeof(SLRegisterContext) - 24 * 16));
    
    _ callFunction(SLExternalReference((void *)sl_common_closure_bridge_handler));
    
    _ add(SP, SP, 2 * 8);
    
    _ ldr(X(0), MEM(SP, 8));
    _ add(SP, SP, 2 * 8);
    
#define MEM_EXT(reg, offset, addrmode) SLMemOperand(reg, offset, addrmode)
    _ ldp(X(1), X(2), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(3), X(4), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(5), X(6), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(7), X(8), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(9), X(10), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(11), X(12), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(13), X(14), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(15), X(16), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(17), X(18), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(19), X(20), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(21), X(22), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(23), X(24), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(25), X(26), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(27), X(28), MEM_EXT(SP, 16, PostIndex));
    _ ldp(X(29), X(30), MEM_EXT(SP, 16, PostIndex));
    
    _ ldp(Q(0), Q(1), MEM_EXT(SP, 32, PostIndex));
    _ ldp(Q(2), Q(3), MEM_EXT(SP, 32, PostIndex));
    _ ldp(Q(4), Q(5), MEM_EXT(SP, 32, PostIndex));
    _ ldp(Q(6), Q(7), MEM_EXT(SP, 32, PostIndex));
    
    _ ret();
    
    auto code = SLAssemblyCodeBuilder::finalizeFromTurboAssembler(&turbo_assembler_);
    closure_bridge_ = (sl_asm_func_t)code->addr;
    return closure_bridge_;
}
