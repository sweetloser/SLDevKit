//
//  SLCommonBridgeHandler.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#include "SLCommonBridgeHandler.hpp"
#include "SLUtilityMacro.hpp"
#include "SLInterceptEntry.hpp"
PUBLIC void sl_common_closure_bridge_handler(SLRegisterContext *ctx, SLClosureTrampolineEntry *entry) {
    typedef void(*sl_routing_handler_t)(SLInterceptEntry *, SLRegisterContext *);
    auto routing_handler = (sl_routing_handler_t)entry->carry_handler;
    
    routing_handler((SLInterceptEntry *)entry->carry_data, ctx);
}
