//
//  SLMachOContext.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/29.
//

#ifndef SLMachOContext_hpp
#define SLMachOContext_hpp

#include <stdio.h>
#include "mach_o.hpp"
#include "SLTypeAlias.hpp"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct sl_macho_ctx {
    bool is_runtime_mode;
    
    mach_header_t *header;
    
    uintptr_t slide;
    uintptr_t linkedit_base;
    
    segment_command_t *segments[64];
    int segments_count;
    
    segment_command_t *texg_seg;
    segment_command_t *data_seg;
    segment_command_t *text_exec_seg;
    segment_command_t *data_const_seg;
    segment_command_t *linkedit_seg;
    
    struct symtab_command *symtab_cmd;
    struct dysymtab_command *dysymtab_cmd;
    struct dyld_info_command *dyld_info_cmd;
    struct linkedit_data_command *exports_trie_cmd;
    struct linkedit_data_command *chained_fixups_cmd;
    
    nlist_t *symtab;
    char *strtab;
    uint32_t *indirect_symtab;
}sl_macho_ctx_t;

typedef enum {
    SL_RESOLVE_SYMBOL_TYPE_SYMBOL_TABLE = 1 << 0,
    SL_RESOLVE_SYMBOL_TYPE_EXPORTED = 1 << 1,
    SL_RESOLVE_SYMBOL_TYPE_ALL = SL_RESOLVE_SYMBOL_TYPE_SYMBOL_TABLE | SL_RESOLVE_SYMBOL_TYPE_EXPORTED
}sl_resolve_symbol_type_t;


void sl_macho_ctx_init(sl_macho_ctx_t *ctx, mach_header_t *header, bool is_runtime_mode);

uintptr_t sl_macho_ctx_symbol_resolve(sl_macho_ctx_t *ctx, const char *symbol_name_pattern);

uintptr_t sl_macho_iterate_symbol_table(char *name_pattern, nlist_t *symtab, uint32_t symtab_count, char *strtab);

uintptr_t sl_macho_symbol_resolve(mach_header_t *header, const char *symbol_name_pattern);

uintptr_t sl_macho_file_memory_symbol_resolve(cpu_type_t in_cputype, cpu_subtype_t in_cpusubtype, const uint8_t *file_mem, char *symbol_name_pattern);

uintptr_t sl_macho_file_symbol_resolve(cpu_type_t cpu, cpu_subtype_t subtype, const char *file, char *symol_name_pattern);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* SLMachOContext_hpp */
