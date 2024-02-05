//
//  SLAssemblyCodeBuilder.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#include "SLAssemblyCodeBuilder.hpp"

SLAssemblyCode * SLAssemblyCodeBuilder::finalizeFromTurboAssembler(SLAssemblerBase *assembler) {
    auto buffer = (SLCodeBufferBase *)assembler->getCodeBuffer();
    auto realized_addr = (sl_addr_t)assembler->getRealizedAddress();
    
    if (!realized_addr) {
        size_t buffer_size = 0;
        buffer_size = buffer->getBufferSize();
    }
    auto block = SLMemoryAllocator();
}
