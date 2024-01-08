//
//  SLInstrumentImpl.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#include <stdio.h>
#include "SLLogger.h"
#include "SLTypeAlias.hpp"
#include "pac_kit.h"
#include "SLInterceptor.hpp"

int sl_instrument(void *address, sl_instrument_callback_t pre_handler) {
    if (!address) {
        SLDEBUG_LOG("address is 0x0.");
        return -1;
    }
    
#if defined(__APPLE__) && defined(__arm64__)
    address = pac_strip(address);
#endif
    
    SLDEBUG_LOG("\n\n----- [SLInstrument:%p] -----", address);
    
    auto entry = SLInterceptor::sharedInterceptor()->find((sl_addr_t)address);
    if (entry) {
        SLDEBUG_LOG("0x%x already been instrumented.", (sl_addr_t)address);
        return -1;
    }
    
    entry = new SLInterceptEntry(SLInterceptEntryTypeInstructionInstrument, (sl_addr_t)address);
    
    
    
    SLInterceptor::sharedInterceptor()->add(entry);
    
    return 0;
}
