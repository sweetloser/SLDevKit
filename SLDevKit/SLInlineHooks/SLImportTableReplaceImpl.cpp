//
//  SLImportTableReplaceImpl.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#include <stdio.h>
#include <sys/mman.h>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach-o/nlist.h>
#include <mach-o/loader.h>
#include "SLProcessRuntimeUtility.hpp"
#include "SLInlineHooks.hpp"
#include "SLLogger.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__LP64__)
typedef mach_header_64 mach_header_t;
typedef segment_command_64 segment_command_t;
typedef section_64 section_t;
typedef nlist_64 nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef mach_header mach_header_t;
typedef segment_command segment_command_t;
typedef section section_t;
typedef nlist nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

static void *iterate_indirect_symtab(char *symbol_name, section_t *section, intptr_t slide, nlist_t *symtab, char *strtab, uint32_t *indirect_symtab) {
    const bool is_data_const = (strcmp(section->segname, "__DATA_CONST") == 0);
    uint32_t *indirect_symbol_indices = indirect_symtab + section->reserved1;
    void **indirect_symbol_bindings = (void **)((uintptr_t)slide + section->addr);
    
    vm_prot_t old_protection = VM_PROT_READ;
    if (is_data_const) {
        mprotect(indirect_symbol_bindings, section->size, PROT_READ | PROT_WRITE);
    }
    
    
    return NULL;
}

static void *get_global_offset_table_stub(mach_header_t *header, char *symbol_name) {
    segment_command_t *curr_seg_cmd;
    
    segment_command_t *text_seg_cmd = NULL;
    segment_command_t *data_seg_cmd = NULL;
    segment_command_t *linkedit_seg_cmd = NULL;
    
    struct symtab_command *symtab_cmd = NULL;
    struct dysymtab_command *dysymtab_cmd = NULL;
    
    uintptr_t cur = (uintptr_t)header + sizeof(mach_header_t);
    for (int i = 0; i < header->ncmds; i++) {
        curr_seg_cmd = (segment_command_t *)cur;
        
        if (curr_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            if (strcmp(curr_seg_cmd->segname, "__LINKEDIT") == 0) {
                linkedit_seg_cmd = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__DATA") == 0) {
                data_seg_cmd = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__TEXT") == 0) {
                text_seg_cmd = curr_seg_cmd;
            }
        } else if (curr_seg_cmd->cmd == LC_SYMTAB) {
            symtab_cmd = (struct symtab_command *)curr_seg_cmd;
        } else if (curr_seg_cmd->cmd == LC_DYSYMTAB) {
            dysymtab_cmd = (struct dysymtab_command *)curr_seg_cmd;
        }
        
        cur += curr_seg_cmd->cmdsize;
    }
    
    if (!symtab_cmd || !linkedit_seg_cmd || !dysymtab_cmd) {
        return NULL;
    }
    
    uintptr_t slide = (uintptr_t)header - (uintptr_t)text_seg_cmd->vmaddr;
    uintptr_t linkedit_base = slide + linkedit_seg_cmd->vmaddr - linkedit_seg_cmd->fileoff;
    nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
    char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);
    
    uint32_t symtab_count = symtab_cmd->nsyms;
    
    uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);
    
    cur = (uintptr_t)header + sizeof(mach_header_t);
    for (unsigned int i = 0; i < header->ncmds; i++) {
        curr_seg_cmd = (segment_command_t *)cur;
        
        if (curr_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            if (strcmp(curr_seg_cmd->segname, "__DATA") != 0 && strcmp(curr_seg_cmd->segname, "__DATA_CONST") != 0) {
                continue;
            }
            
            for (unsigned int j = 0; j < curr_seg_cmd->nsects; j++) {
                section_t *sect = ((section_t *)(cur + sizeof(segment_command_t))) + j;
                if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
                    // lazy symbol table
                    void *stub = iterate_indirect_symtab(symbol_name, sect, slide, symtab, strtab, indirect_symtab);
                    if (stub) {
                        return stub;
                    }
                }
                if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
                    // no-lazy symbol table
                    void *stub = iterate_indirect_symtab(symbol_name, sect, slide, symtab, strtab, indirect_symtab);
                    if (stub) {
                        return stub;
                    }
                }
            }
        }
        
        cur += curr_seg_cmd->cmdsize;
    }
    return NULL;
}

int sl_importTableReplace(char *image_name, char *symbol_name, sl_dummy_func_t fake_func, sl_dummy_func_t *orig_func_ptr) {
    std::vector<SLRuntimeModule> modules = SLProcessRuntimeUtility::GetProcessModuleMap();
    
    for (auto one : modules) {
        // filter module with image name (if image name exist).
        if (image_name != NULL && strstr(one.path, image_name) == NULL) {
            continue;
        }
        
        sl_addr_t header = (sl_addr_t)one.load_address;
        size_t slide = 0;
        
        uint32_t nlist_count = 0;
        nlist_t *nlist_array = 0;
        char *string_pool = 0;
        
        void *stub = get_global_offset_table_stub((mach_header_t *)header, symbol_name);
        SLDEBUG_LOG("symbol address:0x%x", stub);
        if (stub != NULL) {
            *orig_func_ptr = stub;
        }
    }

    return -1;
}

#ifdef __cplusplus
} // extern "C"
#endif
