//
//  SLInterceptor.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#ifndef SLInterceptor_hpp
#define SLInterceptor_hpp

#ifdef __cplusplus

#include <stdio.h>
#include "SLTypeAlias.hpp"
#include "SLInterceptEntry.hpp"
#include <vector>

class SLInterceptor {
public:
    static SLInterceptor *sharedInterceptor();
    
public:
    SLInterceptEntry *find(sl_addr_t addr);
    void remove(sl_addr_t addr);
    void add(SLInterceptEntry *entry);
    
    const SLInterceptEntry *getEntry(int i);
    
    int count();
    
    
private:
    static SLInterceptor *instance;
    std::vector<SLInterceptEntry *> entries;
    
};

#endif

#endif /* SLInterceptor_hpp */
