//
//  SLIntructionInstrumentRouting.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLIntructionInstrumentRouting_hpp
#define SLIntructionInstrumentRouting_hpp
#include <stdio.h>
#include "SLInterceptRouting.hpp"

#ifdef __cplusplus

class SLIntructionInstrumentRouting : public SLInterceptRouting {
public:
    SLIntructionInstrumentRouting(SLInterceptEntry *entry, sl_instrument_callback_t pre_handler, sl_instrument_callback_t post_hander) : SLInterceptRouting(entry) {
        this->prologue_dispatch_bridge = nullptr;
        this->pre_handler = pre_handler;
        this->post_handler = post_hander;
    }
    
    void dispatchRouting() override;
    
private:
    void buildRouting();
    
public:
    sl_instrument_callback_t pre_handler;
    sl_instrument_callback_t post_handler;
    
private:
    void *prologue_dispatch_bridge;
};

#endif
#endif /* SLIntructionInstrumentRouting_hpp */
