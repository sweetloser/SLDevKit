//
//  SLMemoryAllocator.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#include "SLMemoryAllocator.hpp"
#include "SLUtilityMacro.hpp"
#include "SLCheckLogging.hpp"
#include "SLOSMemory.hpp"


SLMemBlock *SLMemoryArena::allocMemBlock(size_t size) {
    if (this->end - this->cursor_addr < size) {
        return nullptr;
    }
    auto result = new SLMemBlock(cursor_addr, size);
    cursor_addr += size;
    return result;
}

SLMemoryAllocator *SLMemoryAllocator::shared_allocator = nullptr;
SLMemoryAllocator *SLMemoryAllocator::sharedAllocator() {
    if (SLMemoryAllocator::shared_allocator == nullptr) {
        SLMemoryAllocator::shared_allocator = new SLMemoryAllocator();
    }
    return SLMemoryAllocator::shared_allocator;
}

SLCodeMemoryArena *SLMemoryAllocator::allocateCodeMemoryArena(uint32_t size) {
    CHECK_EQ(size % SLOSMemory::pageSize(), 0);
    uint32_t arena_size = size;
    auto arena_addr = SLOSMemory::allocate(arena_size, kNoAccess);
    SLOSMemory::setPermission(arena_addr, arena_size, kReadExecute);
    
    auto result = new SLCodeMemoryArena((sl_addr_t)arena_addr, (size_t)arena_size);
    code_arenas.push_back(result);
    return result;
}
SLCodeMemBlock *SLMemoryAllocator::allocteExecBlock(uint32_t size) {
    SLCodeMemBlock *block = nullptr;
    for (auto iter = code_arenas.begin(); iter != code_arenas.end(); iter++) {
        auto arena = static_cast<SLCodeMemoryArena *>(*iter);
        block = arena->allocMemBlock(size);
        if (block) {
            break;
        }
    }
    if (!block) {
        auto arena_size = ALIGN_CEIL(size, SLOSMemory::pageSize());
        auto arena = allocateCodeMemoryArena((uint32_t)arena_size);
        CHECK_NOT_NULL(block);
    }
    return block;
}

uint8_t *SLMemoryAllocator::allocateExecMemory(uint32_t size) {
    auto block = allocteExecBlock(size);
    return (uint8_t *)block->addr;
}

uint8_t *SLMemoryAllocator::allocateExecMemory(uint8_t *buffer, uint32_t buffer_size) {
    auto mem = allocateExecMemory(buffer_size);
    auto ret = sl_codePatch(mem, buffer, buffer_size);
    CHECK_EQ(ret, 0);
    return mem;
}

SLDataMemoryArena *SLMemoryAllocator::allocateDataMemoryArena(uint32_t size) {
    SLDataMemoryArena *result = nullptr;
    uint32_t buffer_size = (uint32_t)ALIGN_CEIL(size, SLOSMemory::pageSize());
    void *buffer = SLOSMemory::allocate(buffer_size, kNoAccess);
    SLOSMemory::setPermission(buffer, buffer_size, kReadWrite);
    
    result = new SLDataMemoryArena((sl_addr_t)buffer, (size_t)buffer_size);
    data_arenas.push_back(result);
    return result;
}

SLDataMemBlock *SLMemoryAllocator::allocateDataBlock(uint32_t size) {
    SLCodeMemBlock *block = nullptr;
    for (auto iter = data_arenas.begin(); iter != data_arenas.end(); iter++) {
        auto arena = static_cast<SLDataMemoryArena *>(*iter);
        block = arena->allocMemBlock(size);
        if (block) {
            break;
        }
    }
    if (!block) {
        auto arena = allocateCodeMemoryArena(size);
        block = arena->allocMemBlock(size);
        CHECK_NOT_NULL(block);
    }
    return block;
}
uint8_t *SLMemoryAllocator::allocateDataMemory(uint32_t size) {
    auto block = allocateDataBlock(size);
    return (uint8_t *)block->addr;
}

uint8_t *SLMemoryAllocator::allocateDataMemory(uint8_t *buffer, uint32_t buffer_size) {
    auto mem = allocateDataMemory(buffer_size);
    memcpy(mem, buffer, buffer_size);
    return mem;
}

