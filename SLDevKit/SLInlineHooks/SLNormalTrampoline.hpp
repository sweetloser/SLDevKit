//
//  SLNormalTrampoline.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#ifndef SLNormalTrampoline_hpp
#define SLNormalTrampoline_hpp

#include <stdio.h>
#include "SLAssemblyCodeBuilder.hpp"

SLCodeBufferBase *generateNormalTrampolineBuffer(sl_addr_t from, sl_addr_t to);


#endif /* SLNormalTrampoline_hpp */
