//
//  SLIntructionInstrumentRouting.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLIntructionInstrumentRouting.hpp"
#include "SLInstrumentRoutingHandler.hpp"
#include "pac_kit.h"
#include "SLClosureTrampoline.hpp"

void SLIntructionInstrumentRouting::buildRouting() {
    void *handler = (void *)sl_instrument_routing_dispatch;
#if defined(__APPLE__) && defined(__arm64__)
    handler = pac_strip(handler);
#endif
    auto closure_trampoline = SLClosureTrampoline::createClosureTrampoline(entry_, handler);
    this->setTrampolineTarget((sl_addr_t)closure_trampoline->address);
    
    sl_addr_t from = entry_->patched_addr;
    
    sl_addr_t to = getTrampolineTraget();
    
    generateTrampolineBuffer(from, to);
    
}

void SLIntructionInstrumentRouting::dispatchRouting() {
    buildRouting();
    generateRelocateCode();
}
