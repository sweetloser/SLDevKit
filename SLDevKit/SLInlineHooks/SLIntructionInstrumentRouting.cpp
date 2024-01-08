//
//  SLIntructionInstrumentRouting.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLIntructionInstrumentRouting.hpp"
#include "SLInstrumentRoutingHandler.hpp"
#include "pac_kit.h"

void SLIntructionInstrumentRouting::buildRouting() {
    void *handler = (void *)sl_instrument_routing_dispatch;
#if defined(__APPLE__) && defined(__arm64__)
    handler = pac_strip(handler);
#endif
    
    
}
