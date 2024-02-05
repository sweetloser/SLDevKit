//
//  SLNearMemoryAllocator.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLNearMemoryAllocator_hpp
#define SLNearMemoryAllocator_hpp

#include <stdio.h>
#include "SLMemoryAllocator.hpp"

class SLNearMemoryAllocator {
public:
    SLMemoryAllocator *default_allocator;
    SLNearMemoryAllocator() {
        default_allocator = SLMemoryAllocator::sharedAllocator();
    }
    
private:
    static SLNearMemoryAllocator *shared_allocator;
    
public:
    static SLNearMemoryAllocator *sharedAllocator();
    
public:
    SLMemBlock *allocateNearBlock(uint32_t size, sl_addr_t pos, size_t search_range, bool executable);
    SLMemBlock *allocateNearBlockFromDefaultAllocator(uint32_t size, sl_addr_t pos, size_t search_range, bool executable);
    SLMemBlock *allocateNearBlockFromUnusedRegion(uint32_t size, sl_addr_t pos, size_t search_range, bool executable);
    
    uint8_t *allocateNearExecMemory(uint32_t size, sl_addr_t pos, size_t search_range);
    uint8_t *allocateNearExecMemory(uint8_t *buffer, uint32_t buffer_size, sl_addr_t pos, size_t search_range);
    
    uint8_t *allocateNearDataMemory(uint32_t size, sl_addr_t pos, size_t search_range);
    uint8_t *allocateNearDataMemory(uint8_t *buffer, uint32_t buffer_size, sl_addr_t pos, size_t search_range);
};

#endif /* SLNearMemoryAllocator_hpp */
