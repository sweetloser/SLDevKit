//
//  SLProcessRuntimeUtility.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#ifndef SLProcessRuntimeUtility_hpp
#define SLProcessRuntimeUtility_hpp

#include <stdio.h>
#include "SLMemoryAllocator.hpp"
#include <vector>

typedef struct _SLRuntimeModule {
    char path[1024];
    void *load_address;
}SLRuntimeModule;

struct SLMemRegion: SLMemRange {
    SLMemoryPermission permission;
    
    SLMemRegion(sl_addr_t start, size_t size, SLMemoryPermission permission): SLMemRange(start, size), permission(permission) {}
};

class SLProcessRuntimeUtility {
    
public:
    static const std::vector<SLMemRegion> &GetProcessMemoryLayout();
    
    static const std::vector<SLRuntimeModule> &GetProcessModuleMap();
    
};

#endif /* SLProcessRuntimeUtility_hpp */
