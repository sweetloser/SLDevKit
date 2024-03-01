//
//  SLCommonBridgeHandler.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLCommonBridgeHandler_hpp
#define SLCommonBridgeHandler_hpp
#include "SLTypeAlias.hpp"
#include "SLClosureTrampoline.hpp"

extern "C" {
void sl_common_closure_bridge_handler(SLRegisterContext *ctx, SLClosureTrampolineEntry *entry);
}

void sl_get_routing_bridge_next_hop(SLRegisterContext *ctx, void *address);

void sl_set_routing_bridge_next_hop(SLRegisterContext *ctx, void *address);

#endif /* SLCommonBridgeHandler_hpp */
