//
//  SLOSMemory.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLOSMemory_hpp
#define SLOSMemory_hpp

#include <stdio.h>
#include "SLTypeAlias.hpp"

class SLOSMemory {
public:
    static int pageSize();
    static void *allocate(size_t size, SLMemoryPermission access);
    static void *allocate(size_t size, SLMemoryPermission access, void *fixed_address);
    
    static bool free(void *address, size_t size);
    static bool release(void *address, size_t size);
    static bool setPermission(void *address, size_t size, SLMemoryPermission access);
};

#endif /* SLOSMemory_hpp */
