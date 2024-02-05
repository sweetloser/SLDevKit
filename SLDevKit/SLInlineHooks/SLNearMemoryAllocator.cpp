//
//  SLNearMemoryAllocator.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#include "SLNearMemoryAllocator.hpp"
#include "SLProcessRuntimeUtility.hpp"
#include "SLUtilityMacro.hpp"
#include "SLOSMemory.hpp"
#include "SLLogger.h"
#include "SLMemoryAllocator.hpp"
#include "SLCheckLogging.hpp"

#define KB (1024uLL)
#define MB (1024uLL * KB)
#define GB (1024uLL * MB)

#define min(a, b) (((a) < (b)) ? (a) : (b))
#define max(a, b) (((a) > (b)) ? (a) : (b))

SLNearMemoryAllocator *SLNearMemoryAllocator::shared_allocator = nullptr;
SLNearMemoryAllocator *SLNearMemoryAllocator::sharedAllocator() {
    if (SLNearMemoryAllocator::shared_allocator == nullptr) {
        SLNearMemoryAllocator::shared_allocator = new SLNearMemoryAllocator();
    }
    return SLNearMemoryAllocator::shared_allocator;
}

SLMemBlock *SLNearMemoryAllocator::allocateNearBlockFromDefaultAllocator(uint32_t size, sl_addr_t pos, size_t search_range, bool executable) {
    sl_addr_t min_valid_addr, max_valid_addr;
    min_valid_addr = pos - search_range;
    max_valid_addr = pos + search_range;
    
    auto allocateFromDefaultArena = [&](SLMemoryArena *arena, uint32_t size) -> sl_addr_t {
        sl_addr_t unused_mem_start = arena->cursor_addr;
        sl_addr_t unused_mem_end = arena->addr + arena->size;
        
        if (unused_mem_end < min_valid_addr || unused_mem_start > max_valid_addr) {
            return 0;
        }
        
        unused_mem_start = max(unused_mem_start, min_valid_addr);
        unused_mem_end = min(unused_mem_end, max_valid_addr);
        
        if (unused_mem_start >= unused_mem_end) {
            return 0;
        }
        
        if (unused_mem_end - unused_mem_start < size) {
            return 0;
        }
        
        return unused_mem_start;
    };
    
    SLMemoryArena *arena = nullptr;
    sl_addr_t unused_mem = 0;
    
    if (executable) {
        for (auto iter = default_allocator->code_arenas.begin(); iter != default_allocator->code_arenas.end(); iter++) {
            arena = *iter;
            unused_mem = allocateFromDefaultArena(arena, size);
            if (unused_mem) {
                continue;
            }
        }
    }
    if (!unused_mem) {
        return nullptr;
    }
    
    auto placeholder_block_size = unused_mem - arena->cursor_addr;
    arena->allocMemBlock(placeholder_block_size);
    
    auto block = arena->allocMemBlock(size);
    return block;
}

SLMemBlock *SLNearMemoryAllocator::allocateNearBlockFromUnusedRegion(uint32_t size, sl_addr_t pos, size_t search_range, bool executable) {
    sl_addr_t min_valid_addr, max_valid_addr;
    min_valid_addr = pos - search_range;
    max_valid_addr = pos + search_range;
    
    auto check_has_sufficient_memory_between_region = [&](SLMemRegion region, SLMemRegion next_region, uint32_t size) -> sl_addr_t {
        sl_addr_t unused_mem_start = region.start + region.size;
        sl_addr_t unused_mem_end = next_region.start;
        
        if (unused_mem_end < min_valid_addr || unused_mem_start > max_valid_addr) {
            return 0;
        }
        
        unused_mem_start = ALIGN_FLOOR(unused_mem_start, 4);
        
        unused_mem_start = max(unused_mem_start, min_valid_addr);
        unused_mem_end = min(unused_mem_end, max_valid_addr);
        
        if (unused_mem_start >= unused_mem_end) {
            return 0;
        }
        
        if (unused_mem_end - unused_mem_start < size) {
            return 0;
        }
        return unused_mem_start;
    };
    
    sl_addr_t unused_mem = 0;
    auto regions = SLProcessRuntimeUtility::GetProcessMemoryLayout();
    for (size_t i = 0; i + 1 < regions.size(); i++) {
        unused_mem = check_has_sufficient_memory_between_region(regions[i], regions[i + 1], size);
        if (unused_mem == 0) {
            continue;
        }
        break;
    }
    
    if (!unused_mem) {
        return nullptr;
    }
    
    auto unused_arena_first_page_addr = (sl_addr_t)ALIGN_FLOOR(unused_mem, SLOSMemory::pageSize());
    auto unused_arena_end_page_addr = ALIGN_FLOOR(unused_mem + size, SLOSMemory::pageSize());
    auto unused_arena_size = unused_arena_end_page_addr - unused_arena_first_page_addr + SLOSMemory::pageSize();
    auto unused_arena_addr = unused_arena_first_page_addr;
    
    if (SLOSMemory::allocate(unused_arena_size, kNoAccess, (void *)unused_arena_addr)) {
        SLERROR_LOG("[near memory allocator] allocate fixed page fialed %p", unused_arena_addr);
        return nullptr;
    }
    
    auto register_near_arena = [&](sl_addr_t arena_addr, size_t arena_size) -> SLMemoryArena * {
        SLMemoryArena *arena = nullptr;
        if (executable) {
            arena = new SLCodeMemoryArena(arena_addr, arena_size);
            default_allocator->code_arenas.push_back(arena);
        } else {
            arena = new SLDataMemoryArena(arena_addr, arena_size);
            default_allocator->data_arenas.push_back(arena);
        }
        SLOSMemory::setPermission((void *)arena->addr, arena->size, executable ? kReadExecute : kReadWrite);
        return arena;
    };
    
    auto unused_arena = register_near_arena(unused_arena_addr, unused_arena_size);
    
    auto placeholder_block_size = unused_mem - unused_arena->cursor_addr;
    unused_arena->allocMemBlock(placeholder_block_size);
    
    auto block = unused_arena->allocMemBlock(size);
    return block;
}

SLMemBlock *SLNearMemoryAllocator::allocateNearBlock(uint32_t size, sl_addr_t pos, size_t search_range, bool executable) {
    SLMemBlock *result = nullptr;
    result = allocateNearBlockFromDefaultAllocator(size, pos, search_range, executable);
    if (!result) {
        result = allocateNearBlockFromUnusedRegion(size, pos, search_range, executable);
    }
    if (!result) {
        SLERROR_LOG("[near momory allocator] allocte near block failed (%p, %p, %p)", size, pos, search_range);
    }
    return result;
}
 uint8_t *SLNearMemoryAllocator::allocateNearExecMemory(uint32_t size, sl_addr_t pos, size_t search_range) {
     auto block = allocateNearBlock(size, pos, search_range, true);
     if (!block) {
         return nullptr;
     }
     
     SLDEBUG_LOG("[near memory allocator] allocate exec memory at: %p, size: %p", block->addr, block->size);
     return (uint8_t *)block->addr;
}

uint8_t *SLNearMemoryAllocator::allocateNearExecMemory(uint8_t *buffer, uint32_t buffer_size, sl_addr_t pos, size_t search_range) {
    auto mem = allocateNearExecMemory(buffer_size, pos, search_range);
    auto ret = sl_codePatch(mem, buffer, buffer_size);
    CHECK_EQ(ret, 0);
    return mem;
}

uint8_t *SLNearMemoryAllocator::allocateNearDataMemory(uint32_t size, sl_addr_t pos, size_t search_range) {
    auto block = allocateNearBlock(size, pos, search_range, false);
    if (!block) {
        return nullptr;
    }
    SLDEBUG_LOG("[near memory allocator] allocate data memory at: %p, size: %p", block->addr, block->size);
    return (uint8_t *)block->addr;
}

uint8_t *SLNearMemoryAllocator::allocateNearDataMemory(uint8_t *buffer, uint32_t buffer_size, sl_addr_t pos, size_t search_range) {
    auto mem = allocateNearExecMemory(buffer_size, pos, search_range);
    memcpy(mem, buffer, buffer_size);
    return mem;
}
