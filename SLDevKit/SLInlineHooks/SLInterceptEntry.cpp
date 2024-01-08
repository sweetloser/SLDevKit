//
//  SLInterceptEntry.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#include "SLInterceptEntry.hpp"
#include "SLInterceptor.hpp"

SLInterceptEntry::SLInterceptEntry(SLInterceptEntryType type, sl_addr_t address) {
    this->type = type;
    
#if defined(TARGET_ARCH_ARM)
    if (address % 2) {
        address -= 1;
        this->thumb_mode = true;
    }
#endif
    
    this->patched_addr = address;
    this->id = SLInterceptor::sharedInterceptor()->count();
}
