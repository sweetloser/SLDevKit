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
#include <ptrauth.h>

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
    
    if (is_data_const) {
        mprotect(indirect_symbol_bindings, section->size, PROT_READ | PROT_WRITE);
    }
    
    for (unsigned int i = 0; i < section->size / sizeof(void *); i++) {
        uint32_t symtab_index = indirect_symbol_indices[i];
        if (symtab_index == INDIRECT_SYMBOL_ABS || symtab_index == INDIRECT_SYMBOL_LOCAL || symtab_index == (INDIRECT_SYMBOL_ABS | INDIRECT_SYMBOL_LOCAL)) {
            continue;
        }
        uint32_t strtab_offset = symtab[symtab_index].n_un.n_strx;
        char *local_symbol_name = strtab + strtab_offset;
        if (strcmp(local_symbol_name, symbol_name) == 0) {
            return &indirect_symbol_bindings[i];
        }
        if (local_symbol_name[0] == '_') {
            if (strcmp(symbol_name, &local_symbol_name[1]) == 0) {
                return &indirect_symbol_bindings[i];
            }
        }
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
    // symbol table address.
    nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
    // string table address.
    char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);
    // indirect symbol table address.
    uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);
    
    cur = (uintptr_t)header + sizeof(mach_header_t);
    for (unsigned int i = 0; i < header->ncmds; i++,cur += curr_seg_cmd->cmdsize) {
        curr_seg_cmd = (segment_command_t *)cur;
        
        if (curr_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            if (strcmp(curr_seg_cmd->segname, "__DATA") != 0 && strcmp(curr_seg_cmd->segname, "__DATA_CONST") != 0) {
                continue;
            }
            
            for (unsigned int j = 0; j < curr_seg_cmd->nsects; j++) {
                section_t *sect = ((section_t *)(cur + sizeof(segment_command_t))) + j;
                if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
                    // lazy symbol table.
                    void *stub = iterate_indirect_symtab(symbol_name, sect, slide, symtab, strtab, indirect_symtab);
                    if (stub) {
                        return stub;
                    }
                }
                if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
                    // no-lazy symbol table.
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
    
    if (symbol_name == NULL || fake_func == NULL) {
        SLDEBUG_LOG("parameter error.");
        return -1;
    }
    
    std::vector<SLRuntimeModule> modules = SLProcessRuntimeUtility::GetProcessModuleMap();
    
    for (auto one : modules) {
        // filter module with image name (if image name exist).
        if (image_name != NULL && strstr(one.path, image_name) == NULL) {
            continue;
        }
        
        sl_addr_t header = (sl_addr_t)one.load_address;
        if (header == 0) {
            continue;
        }
        void *stub = get_global_offset_table_stub((mach_header_t *)header, symbol_name);
        if (!stub) {
            continue;
        }
        SLDEBUG_LOG("symbol address:0x%x", *(void **)stub);
        if (orig_func_ptr != NULL) {
            SLDEBUG_LOG("save original function pointer.");
            void *orig_func = *(void **)stub;
            // strip the signature from a value without authenticating it.
#if __has_feature(ptrauth_calls)
            orig_func = ptrauth_strip(orig_func, ptrauth_key_asia);
            orig_func = ptrauth_sign_unauthenticated(orig_func, ptrauth_key_asia, 0);
#endif
            *orig_func_ptr = orig_func;
        }
        // strip the signature from a value without authenticating it.
#if __has_feature(ptrauth_calls)
        fake_func = (void *)ptrauth_strip(fake_func, ptrauth_key_asia);
        fake_func = ptrauth_sign_unauthenticated(fake_func, ptrauth_key_asia, stub);
#endif
        *(void **)stub = fake_func;
        return 0;
    }

    return -1;
}

#ifdef __cplusplus
} // extern "C"
#endif
