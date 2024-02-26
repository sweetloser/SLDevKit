//
//  SLCodeGenBase.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#ifndef SLCodeGenBase_hpp
#define SLCodeGenBase_hpp

#include <stdio.h>
#include "SLAssemblerBase.hpp"

class SLCodeGenBase {
public:
    SLCodeGenBase(SLAssemblerBase *assembler) : assembler_(assembler){
        
    }
protected:
    SLAssemblerBase *assembler_;
};

#endif /* SLCodeGenBase_hpp */
