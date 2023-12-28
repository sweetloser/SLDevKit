//
//  SLSharedCacheContext.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/28.
//

#include "SLSharedCacheContext.hpp"
#include <string.h>
#include <SLLogger.h>
#include <mach/task.h>
#include <mach/mach.h>
#include <mach-o/dyld_images.h>
#include "SLMmapFileManager.hpp"


extern "C" {
extern const char *dyld_shared_cache_file_path(void);
extern int __shared_region_check_np(uint64_t *startaddress);
}

const char *share_cache_get_file_path(void) {
    return dyld_shared_cache_file_path();
}

struct dyld_cache_header *shared_cache_get_load_addr(void) {
    // check whether the cache has been mapped to the shared area.
    sl_addr_t shared_cache_base = 0;
    if (__shared_region_check_np((uint64_t *)&shared_cache_base) != 0) {
        SLWARN_LOG("__shared_region_check_np failed");
    }
    
    if (shared_cache_base) {
        return (struct dyld_cache_header *)shared_cache_base;
    }
    
    // task info
    task_dyld_info_data_t task_info_data;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
    kern_return_t kr = task_info(mach_task_self(), TASK_DYLD_INFO, (task_info_t)&task_info_data, &count);
    if (kr != KERN_SUCCESS) {
        SLERROR_LOG("task_info failed, ret: %d", kr);
        return nullptr;
    }
    
    auto *infos = (struct dyld_all_image_infos *)((uintptr_t)(task_info_data.all_image_info_addr));
    auto *shated_cache = (struct dyld_cache_header *)infos->sharedCacheBaseAddress;
    return shated_cache;
}

int sl_shared_cache_ctx_init(sl_shared_cache_ctx_t *ctx) {
    memset(ctx, 0, sizeof(sl_shared_cache_ctx_t));
    
    auto runtime_shared_cache = shared_cache_get_load_addr();
    if (!runtime_shared_cache) {
        return -1;
    }
    
    ctx->runtime_shared_cache = runtime_shared_cache;
    
    auto mappings = (struct dyld_cache_mapping_info *)((char *)runtime_shared_cache + runtime_shared_cache->mappingOffset);
    uintptr_t slide = (uintptr_t)runtime_shared_cache - (uintptr_t)(mappings[0].address);
    ctx->runtime_slide = slide;
    
    return 0;
}

int sl_shared_cache_load_symbols(sl_shared_cache_ctx_t *ctx) {
    uint64_t localSymbolsOffset = 0;
    
    bool latest_shared_cache_format = true;
    
    const char *shared_cache_path = share_cache_get_file_path();
    char shared_cache_symbols_path[4096] = {0};
    strcat(shared_cache_symbols_path, shared_cache_path);
    strcat(shared_cache_symbols_path, ".symbols");
    
    auto mmapShareCacheSymbolManager = new SLMmapFileManager(shared_cache_symbols_path);
    auto mmap_buffer = mmapShareCacheSymbolManager->map();
    if (mmap_buffer) {
        // iphoneos >= 15.0, which has .symbols file.
        ctx->mmap_shared_cahce = (struct dyld_cache_header *)mmap_buffer;
        localSymbolsOffset = ctx->mmap_shared_cahce->localSymbolsOffset;
    } else {
        // iphoneos < 15.0, which has no .symbols file
        auto mmapShareCacheManager = new SLMmapFileManager(shared_cache_path);
        auto runtime_shared_chahe = ctx->runtime_shared_cache;
        uint64_t mmap_length = runtime_shared_chahe->localSymbolsSize;
        uint64_t mmap_offset = runtime_shared_chahe->localSymbolsOffset;
        
        if (mmap_length == 0) {
            return -1;
        }
        
        auto mmap_buffer = mmapShareCacheManager->map_options(mmap_length, mmap_offset);
        
        if (!mmap_buffer) {
            return -1;
        }
        
        auto mmap_shared_cache = (struct dyld_cache_header *)((sl_addr_t)mmap_buffer - runtime_shared_chahe->localSymbolsOffset);
        ctx->mmap_shared_cahce = mmap_shared_cache;
        
        localSymbolsOffset = runtime_shared_chahe->localSymbolsOffset;
        latest_shared_cache_format = false;
    }
    
    ctx->latest_shared_cache_format = latest_shared_cache_format;
    
    
    
    return 0;
}
