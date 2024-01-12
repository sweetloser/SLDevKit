//
//  SLInstrumentRoutingHandler.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLInstrumentRoutingHandler_hpp
#define SLInstrumentRoutingHandler_hpp

#include <stdio.h>
#include "SLInterceptEntry.hpp"
#include "SLTypeAlias.hpp"

#ifdef __cplusplus

void sl_instrument_routing_dispatch(SLInterceptEntry *entry, SLRegisterContext *ctx);

#endif

#endif /* SLInstrumentRoutingHandler_hpp */
