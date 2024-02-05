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
#include <vector>

struct SLMemRange {
    sl_addr_t start;
    sl_addr_t end;
    size_t size;
    
    SLMemRange(sl_addr_t start, size_t size) : start(start), end(0), size(size) {
        end = start + size;
    }
    
    void reset(sl_addr_t start, size_t size) {
        this->start = start;
        this->size = size;
        this->end = start + size;
    }
};

struct SLMemBlock : SLMemRange {
    sl_addr_t addr;
    
    SLMemBlock() : SLMemRange(0, 0), addr(0) {}
    
    SLMemBlock(sl_addr_t addr, size_t size) : SLMemRange(addr, size), addr(addr) {}
    
    void reset(sl_addr_t addr, size_t size) {
        SLMemRange::reset(addr, size);
        this->addr = addr;
    }
};

struct SLMemoryArena : SLMemRange {
    sl_addr_t addr;
    sl_addr_t cursor_addr;
    
    std::vector<SLMemBlock *> memory_blocks;
    
    SLMemoryArena(sl_addr_t addr, size_t size) : SLMemRange(addr, size), addr(addr), cursor_addr(addr) {}
    
    virtual SLMemBlock *allocMemBlock(size_t size);
};

using SLCodeMemBlock = SLMemBlock;
using SLCodeMemoryArena = SLMemoryArena;
using SLDataMemoryArena = SLMemoryArena;
using SLDataMemBlock = SLMemBlock;

class SLNearMemoryAllocator;
class SLMemoryAllocator {
    friend class SLNearMemoryAllocator;
    
private:
    std::vector<SLCodeMemoryArena *> code_arenas;
    std::vector<SLDataMemoryArena *> data_arenas;
    
private:
    static SLMemoryAllocator *shared_allocator;
    
public:
    static SLMemoryAllocator *sharedAllocator();
    
public:
    SLCodeMemoryArena *allocateCodeMemoryArena(uint32_t size);
    SLCodeMemBlock *allocteExecBlock(uint32_t size);
    uint8_t *allocateExecMemory(uint32_t size);
    uint8_t *allocateExecMemory(uint8_t *buffer, uint32_t buffer_size);
    
    SLDataMemoryArena *allocateDataMemoryArena(uint32_t size);
    SLDataMemBlock *allocateDataBlock(uint32_t size);
    uint8_t *allocateDataMemory(uint32_t size);
    uint8_t *allocateDataMemory(uint8_t *buffer, uint32_t buffer_size);
};



#endif  // endif __cplusplus
#endif /* SLMemoryAllocator_hpp */
