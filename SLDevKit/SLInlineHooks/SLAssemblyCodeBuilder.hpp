//
//  SLAssemblyCodeBuilder.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLAssemblyCodeBuilder_hpp
#define SLAssemblyCodeBuilder_hpp

#include <stdio.h>
#include "SLMemoryAllocator.hpp"
#include "SLAssemblerBase.hpp"

using SLAssemblyCode = SLCodeMemBlock;

class SLAssemblyCodeBuilder {
public:
    static SLAssemblyCode *finalizeFromTurboAssembler(SLAssemblerBase *assembler);
};

#endif /* SLAssemblyCodeBuilder_hpp */
