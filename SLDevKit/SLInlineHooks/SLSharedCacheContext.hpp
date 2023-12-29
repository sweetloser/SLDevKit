//
//  SLSharedCacheContext.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/28.
//

#ifndef SLSharedCacheContext_hpp
#define SLSharedCacheContext_hpp

#include <stdio.h>
#include "mach_o.hpp"
#include "SLTypeAlias.hpp"
#include "dyld_cache_format.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct sl_shared_cache_ctx {
    struct dyld_cache_header *runtime_shared_cache;
    struct dyld_cache_header *mmap_shared_cahce;
    
    uintptr_t runtime_slide;
    
    bool latest_shared_cache_format;
    
    struct dyld_cache_local_symbols_info *local_symbols_info;
    struct dyld_cache_local_symbols_entry *local_symbols_entries;
    struct dyld_cache_local_symbols_entry_64 *local_symbols_entries_64;
    
    nlist_t *symtab;
    char *strtab;
}sl_shared_cache_ctx_t;

int sl_shared_cache_ctx_init(sl_shared_cache_ctx_t *ctx);

int sl_shared_cache_load_symbols(sl_shared_cache_ctx_t *ctx);

bool sl_shared_cache_is_contain(sl_shared_cache_ctx_t *ctx, sl_addr_t addr, size_t length);

int sl_shared_cache_get_symbol_table(sl_shared_cache_ctx_t *ctx, mach_header_t *image_header, nlist_t **out_symtab, uint32_t *out_symtab_count, char **out_strtab);

#ifdef __cplusplus
}
#endif
#endif /* SLSharedCacheContext_hpp */
