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
        
        
        
    }
    return nullptr;
}
