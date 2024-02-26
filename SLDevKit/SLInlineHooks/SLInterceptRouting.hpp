//
//  SLInterceptRouting.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#ifndef SLInterceptRouting_hpp
#define SLInterceptRouting_hpp

#include <stdio.h>
#include "SLInterceptEntry.hpp"
#include "SLMemoryAllocator.hpp"
#include "SLCodeBufferBase.hpp"

#ifdef __cplusplus

class SLInterceptRouting {
public:
    explicit SLInterceptRouting(SLInterceptEntry *entry) :entry_(entry) {
        entry->routing = this;
        
        origin_ = nullptr;
        relocated_ = nullptr;
        
        trampoline_ = nullptr;
        trampoline_buffer_ = nullptr;
        trampoline_target_ = 0;
    }
    
    // pure vitrual function
    virtual void dispatchRouting() = 0;
    
    virtual void prepare();
    virtual void active();
    void commit();
    
    SLInterceptEntry *getInterceptEntry();
    
    void setTrampolineBuffer(SLCodeBufferBase *buffer) {
        trampoline_buffer_ = buffer;
    }
    
    SLCodeBufferBase *getTrampolineBuffer() {
        return trampoline_buffer_;
    }
    
    void setTrampolineTarget(sl_addr_t address) {
        trampoline_target_ = address;
    }
    
    sl_addr_t getTrampolineTraget() {
        return trampoline_target_;
    }
    
    
public:
protected:
    bool generateRelocateCode();
    
    bool generateTrampolineBuffer(sl_addr_t src, sl_addr_t dst);
    
protected:
    SLInterceptEntry *entry_;
    
    SLCodeMemBlock *origin_;
    SLCodeMemBlock *relocated_;
    
    SLCodeMemBlock *trampoline_;
    
    SLCodeBufferBase *trampoline_buffer_;
    sl_addr_t trampoline_target_;
    
};




#endif

#endif /* SLInterceptRouting_hpp */
