//
//  SLInstructionRelocationARM64.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/30.
//

#ifndef SLInstructionRelocationARM64_hpp
#define SLInstructionRelocationARM64_hpp

#include <stdio.h>
#include "SLMemoryAllocator.hpp"

void genRelocateCode(void *buffer, SLCodeMemBlock *origin, SLCodeMemBlock *relocated, bool branch);

void genRelocateCodeAndBranch(void *buffer, SLCodeMemBlock *origin, SLCodeMemBlock *relocated);


#endif /* SLInstructionRelocationARM64_hpp */
