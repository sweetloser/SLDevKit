//
//  SLInstrumentRoutingHandler.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLInstrumentRoutingHandler.hpp"
#include "SLIntructionInstrumentRouting.hpp"

void sl_instrument_forward_handler(SLInterceptEntry *entry, SLRegisterContext *ctx) {
    auto routing = static_cast<SLIntructionInstrumentRouting *>(entry->routing);
    if (routing->pre_handler) {
        auto handler = (sl_instrument_callback_t)routing->pre_handler;
        (*handler)((void *)entry->patched_addr, ctx);
    }
}

void sl_instrument_routing_dispatch(SLInterceptEntry *entry, SLRegisterContext *ctx) {
    sl_instrument_forward_handler(entry, ctx);
}
