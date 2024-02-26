//
//  SLCodeGen.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#ifndef SLCodeGen_hpp
#define SLCodeGen_hpp

#include <stdio.h>
#include "SLCodeGenBase.hpp"
#include "SLTurboAssembler.hpp"

class SLCodeGen : public SLCodeGenBase {
public:
    SLCodeGen(SLTurboAssembler *turbo_assembler) : SLCodeGenBase(turbo_assembler) {
        
    }
    
    void literalLdrBranch(uint64_t address);
};

#endif /* SLCodeGen_hpp */
