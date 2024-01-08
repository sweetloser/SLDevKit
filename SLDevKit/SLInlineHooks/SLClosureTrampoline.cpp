//
//  SLClosureTrampoline.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLClosureTrampoline.hpp"

SLClosureTrampolineEntry *SLClosureTrampoline::createClosureTrampoline(void *carry_data, void *carry_handler) {
    SLClosureTrampolineEntry *tramp_entry = nullptr;
    tramp_entry = new SLClosureTrampolineEntry;
    
    return tramp_entry;
}
