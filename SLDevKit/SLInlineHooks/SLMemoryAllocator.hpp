//
//  SLMemoryAllocator.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#ifndef SLMemoryAllocator_hpp
#define SLMemoryAllocator_hpp

# ifdef __cplusplus

#include <stdio.h>
#include "SLInlineHooks.hpp"

enum SLMemoryPermission {
    kNoAccess,
    kRead,
    kReadWrite,
    kReadWriteExecute,
    kReadExecute,
};

struct SLMemRange {
    sl_addr_t start;
    sl_addr_t end;
    size_t size;
    
    SLMemRange(sl_addr_t start, size_t size);
    
    void reset(sl_addr_t start, size_t size);
};

class SLMemoryAllocator {
public:
    
};

#endif  // endif __cplusplus
#endif /* SLMemoryAllocator_hpp */
