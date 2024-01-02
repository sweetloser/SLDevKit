//
//  SLSymbolResolver.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/27.
//

#include <stdio.h>
#include "SLProcessRuntimeUtility.hpp"
#include <mach-o/loader.h>
#include "mach_o.hpp"
#include "SLTypeAlias.hpp"
#include "SLSharedCacheContext.hpp"
#include "SLMachOContext.hpp"
#include <mach/task_info.h>
#include <mach/task.h>
#include <mach/mach_init.h>
#include <mach-o/dyld_images.h>
#include "SLLogger.h"


void *sl_symbolResolver(const char *image_name, const char *symbol_name) {
    uintptr_t result = 0;
    auto modules = SLProcessRuntimeUtility::GetProcessModuleMap();
    
    for (auto iter = modules.begin(); iter != modules.end(); iter++) {
        auto one = *iter;
        
        // image filter.
        if (image_name && !strstr(one.path, image_name)) {
            continue;
        }
        
        // ignore dyld for global lookup, as some functions as own implementation in dyld.
        if (!image_name && strstr(one.path, "dyld")) {
            continue;
        }
        
        auto header = (mach_header_t *)one.load_address;
        if (header == nullptr) {
            continue;
        }
        
        nlist_t *symtab = NULL;
        uint32_t symtab_count = 0;
        char *strtab = NULL;
#if !defined(BUILDING_KERNEL)
#if defined(__arm__) || defined(__aarch64__)
        static int shared_cache_ctx_init_once = 0;
        static sl_shared_cache_ctx_t shared_cache_ctx;
        if (shared_cache_ctx_init_once == 0) {
            shared_cache_ctx_init_once = 1;
            sl_shared_cache_ctx_init(&shared_cache_ctx);
            sl_shared_cache_load_symbols(&shared_cache_ctx);
        }
        
        if (shared_cache_ctx.mmap_shared_cahce) {
            // shared cache library
            if (sl_shared_cache_is_contain(&shared_cache_ctx, (sl_addr_t)header, 0)) {
                sl_shared_cache_get_symbol_table(&shared_cache_ctx, header, &symtab, &symtab_count, &strtab);
            }
        }
        
        if (symtab && strtab) {
            result = sl_macho_iterate_symbol_table((char *)symbol_name, symtab, symtab_count, strtab);
        }
        
        if (result) {
            result = result + shared_cache_ctx.runtime_slide;
            return (void *)result;
        }
        
#endif
#endif
        
        result = sl_macho_symbol_resolve(header, symbol_name);
        if (result) {
            return (void *)result;
        }
    }
    
#if !defined(BUILDIND_KERNEL)
    mach_header_t *dyld_header = NULL;
    if (image_name != NULL && strcmp(image_name, "dyld") == 0) {
        task_dyld_info_data_t task_dyld_info;
        mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
        if (task_info(mach_task_self(), TASK_DYLD_INFO, (task_info_t)&task_dyld_info, &count)) {
            return NULL;
        }
        
        const struct dyld_all_image_infos *infos = (struct dyld_all_image_infos *)task_dyld_info.all_image_info_addr;
        dyld_header = (mach_header_t *)infos->dyldImageLoadAddress;
        sl_macho_ctx_t ctx;
        sl_macho_ctx_init(&ctx, dyld_header, true);
        result = (uintptr_t)sl_macho_ctx_symbol_resolve(&ctx, symbol_name);
        
        bool is_dyld_in_cache = ((mach_header_t *)dyld_header)->flags & MH_DYLIB_IN_CACHE;
        if (!is_dyld_in_cache && result == 0) {
            result = sl_macho_file_symbol_resolve(dyld_header->cputype, dyld_header->cpusubtype, "/usr/lib/dyld", (char *)symbol_name);
            result += (uintptr_t)dyld_header;
        }
    }
#endif
    
    if (result == 0) {
        SLDEBUG_LOG("symbol resolver failed: %s", symbol_name);
    }
    
    return (void *)result;
}
