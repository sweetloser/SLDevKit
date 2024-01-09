//
//  SLAssemblerBase.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLAssemblerBase_hpp
#define SLAssemblerBase_hpp

#include <stdio.h>
#ifdef __cplusplus
#include <vector>
#include "SLAssemblerPseudoLabel.hpp"
#include "SLCodeBuffer.hpp"

class SLAssemblerBase {
public:
    explicit SLAssemblerBase(void *address);
    
    ~SLAssemblerBase();
    
    size_t ip_offset() const;
    size_t pc_offset() const;
    
    SLCodeBuffer *getCodeBuffer();
    
    void pseudoBind(SLAssemblerPseudoLabel *label);
    void relocBind();
    
    void appendRelocLabel(SLRelocLabel *label);
    
protected:
    std::vector<SLRelocLabel *> data_labels_;
    
public:
    virtual void *getRealizedAddress();
    virtual void setRealizedAddress(void *address);
    static void flushICache(sl_addr_t start, int size);
    static void flushICache(sl_addr_t start, sl_addr_t end);
    
protected:
    SLCodeBuffer *buffer_;
    
    void *realized_addr_;
};


#endif
#endif /* SLAssemblerBase_hpp */
