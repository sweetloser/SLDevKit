//
//  SLMachOContext.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/29.
//

#include "SLMachOContext.hpp"
#include <string.h>
#include "SLMmapFileManager.hpp"
#include <mach-o/fat.h>

#define ASSERT(x)

void sl_macho_ctx_init(sl_macho_ctx_t *ctx, mach_header_t *header, bool is_runtime_mode) {
    memset(ctx, 0, sizeof(sl_macho_ctx_t));
    
    ctx->is_runtime_mode = is_runtime_mode;
    
    ctx->header = header;
    segment_command_t *curr_seg_cmd;
    segment_command_t *text_segment = 0;
    segment_command_t *text_exec_segment = 0;
    segment_command_t *data_segment = 0;
    segment_command_t *data_const_segment = 0;
    segment_command_t *linkedit_segment = 0;
    
    struct symtab_command *symtab_cmd = 0;
    struct dysymtab_command *dysymtab_cmd = 0;
    struct dyld_info_command *dyld_info_cmd = 0;
    struct linkedit_data_command *exports_trie_cmd = 0;
    struct linkedit_data_command *chained_fixups_cmd = 0;
    
    curr_seg_cmd = (segment_command_t *)((uintptr_t)header + sizeof(mach_header_t));
    
    for (int i = 0; i < header->ncmds; i++) {
        if (curr_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            ctx->segments[ctx->segments_count++] = curr_seg_cmd;
            
            if (strcmp(curr_seg_cmd->segname, "__LINKEDIT") == 0) {
                linkedit_segment = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__DATA") == 0) {
                data_segment = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__DATA_CONST") == 0) {
                data_const_segment = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__TEXT") == 0) {
                text_segment = curr_seg_cmd;
            } else if (strcmp(curr_seg_cmd->segname, "__TEXT_EXEC") == 0) {
                text_exec_segment = curr_seg_cmd;
            }
        } else if (curr_seg_cmd->cmd == LC_SYMTAB) {
            symtab_cmd = (struct symtab_command *)curr_seg_cmd;
        } else if (curr_seg_cmd->cmd == LC_DYSYMTAB) {
            dysymtab_cmd = (struct dysymtab_command *)curr_seg_cmd;
        } else if (curr_seg_cmd->cmd == LC_DYLD_INFO || curr_seg_cmd->cmd == LC_DYLD_INFO_ONLY) {
            dyld_info_cmd = (struct dyld_info_command *)curr_seg_cmd;
        } else if (curr_seg_cmd->cmd == LC_DYLD_EXPORTS_TRIE) {
            exports_trie_cmd = (struct linkedit_data_command *)curr_seg_cmd;
        } else if (curr_seg_cmd->cmd == LC_DYLD_CHAINED_FIXUPS) {
            chained_fixups_cmd = (struct linkedit_data_command *)curr_seg_cmd;
        }
        
        curr_seg_cmd = (segment_command_t *)((uintptr_t)curr_seg_cmd + curr_seg_cmd->cmdsize);
    }
    
    uintptr_t slide = (uintptr_t)header - (uintptr_t)text_segment->vmaddr;
    uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
    
    if (is_runtime_mode == false) {
        uintptr_t linkedit_segment_vmaddr = linkedit_segment->fileoff;
        linkedit_base = (uintptr_t)slide + linkedit_segment_vmaddr - linkedit_segment->fileoff;
    }
    
    ctx->texg_seg = text_segment;
    ctx->text_exec_seg = text_exec_segment;
    ctx->data_seg = data_segment;
    ctx->data_const_seg = data_const_segment;
    ctx->linkedit_seg = linkedit_segment;
    
    ctx->symtab_cmd = symtab_cmd;
    ctx->dysymtab_cmd = dysymtab_cmd;
    ctx->dyld_info_cmd = dyld_info_cmd;
    ctx->exports_trie_cmd = exports_trie_cmd;
    ctx->chained_fixups_cmd = chained_fixups_cmd;
    
    ctx->slide = slide;
    ctx->linkedit_base = linkedit_base;
    
    ctx->symtab = (nlist_t *)(ctx->linkedit_base + ctx->symtab_cmd->symoff);
    ctx->strtab = (char *)(ctx->linkedit_base + ctx->symtab_cmd->stroff);
    ctx->indirect_symtab = (uint32_t *)(ctx->linkedit_base + ctx->dysymtab_cmd->indirectsymoff);
    
}

uintptr_t sl_macho_iterate_symbol_table(char *symbol_name_pattern, nlist_t *symtab, uint32_t symtab_count, char *strtab) {
    for (uint32_t i = 0; i < symtab_count; i++) {
        if (symtab[i].n_value) {
            uint32_t strtab_offset = symtab[i].n_un.n_strx;
            char *symbol_name = strtab + strtab_offset;
            if (strcmp(symbol_name_pattern, symbol_name) == 0) {
                return symtab[i].n_value;
            }
            if (symbol_name[0] == '_') {
                if (strcmp(symbol_name_pattern, &symbol_name[1]) == 0) {
                    return symtab[i].n_value;
                }
            }
        }
    }
    return 0;
}

uintptr_t sl_macho_ctx_iterate_symbol_table(sl_macho_ctx_t *ctx, const char *symbol_name_pattern) {
    nlist_t *symtab = ctx->symtab;
    uint32_t symtab_count = ctx->symtab_cmd->nsyms;
    char *strtab = ctx->strtab;
    
    for (uint32_t i = 0; i < symtab_count; i++) {
        if (symtab[i].n_value) {
            uint32_t strtab_offset = symtab[i].n_un.n_strx;
            char *symbol_name = strtab + strtab_offset;
            if (strcmp(symbol_name_pattern, symbol_name) == 0) {
                return symtab[i].n_value;
            }
            if (symbol_name[0] == '_') {
                if (strcmp(symbol_name_pattern, &symbol_name[1]) == 0) {
                    return symtab[i].n_value;
                }
            }
        }
    }
    return 0;
}

uintptr_t sl_read_uleb128(const uint8_t **pp, const uint8_t *end) {
    uint8_t *p = (uint8_t *)*pp;
    uint64_t result = 0;
    int bit = 0;
    do {
        if (p == end) {
            ASSERT(p==end);
        }
        
        uint64_t slice = *p & 0x7f;
        if (bit > 63) {
            ASSERT(bit > 63)
        } else {
            result = result | (slice << bit);
            bit += 7;
        }
    } while (*p++ & 0x80);
    return result;
}

uint8_t *sl_tail_walk(const uint8_t *start, const uint8_t *end, const char *symbol) {
    uint32_t visitedNodeOffsets[128];
    int visitedNodeOffsetCount = 0;
    visitedNodeOffsets[visitedNodeOffsetCount++] = 0;
    const uint8_t *p = start;
    while (p < end) {
        uint64_t terminalSize = *p++;
        if (terminalSize > 127) {
            --p;
            terminalSize = sl_read_uleb128(&p, end);
        }
        if ((*symbol == '\0') && (terminalSize != 0)) {
            return (uint8_t *)p;
        }
        const uint8_t *children = p + terminalSize;
        if (children > end) {
            return NULL;
        }
        uint8_t childrenRemaining = *children++;
        p = children;
        uint64_t nodeOffset = 0;
        
        for (; childrenRemaining > 0; --childrenRemaining) {
            const char *ss = symbol;
            bool wrongEdge = false;
            
            char c = *p;
            while (c != '\0') {
                if (!wrongEdge) {
                    if (c != *ss) {
                        wrongEdge = true;
                    }
                    ++ss;
                }
                ++p;
                c = *p;
            }
            if (wrongEdge) {
                ++p;
                while ((*p & 0x80) != 0) {
                    ++p;
                }
                ++p;
                if (p > end) {
                    return nullptr;
                }
            } else {
                ++p;
                nodeOffset = sl_read_uleb128(&p, end);
                if (nodeOffset == 0 || (&start[nodeOffset] > end)) {
                    return nullptr;
                }
                symbol = ss;
                break;
            }
        }
        
        if (nodeOffset != 0) {
            if (nodeOffset > (uint64_t)(end - start)) {
                return NULL;
            }
            
            for (int i = 0; i < visitedNodeOffsetCount; ++i) {
                if (visitedNodeOffsets[i] == nodeOffset) {
                    return NULL;
                }
            }
            visitedNodeOffsets[visitedNodeOffsetCount] = (uint32_t)nodeOffset;
            p = &start[nodeOffset];
        } else {
            p = end;
        }
    }
    return NULL;
}

uintptr_t sl_macho_ctx_iterate_exported_symbol(sl_macho_ctx_t *ctx, const char *symbol_name, uint64_t *out_flags) {
    if (ctx->texg_seg == NULL || ctx->linkedit_seg == NULL) {
        return 0;
    }
    
    struct dyld_info_command *dyld_info_cmd = ctx->dyld_info_cmd;
    struct linkedit_data_command *exports_trie_cmd = ctx->exports_trie_cmd;
    if (exports_trie_cmd == NULL && dyld_info_cmd == NULL) {
        return 0;
    }
    
    uint32_t trieFileOffset = dyld_info_cmd ? dyld_info_cmd->export_off : exports_trie_cmd->dataoff;
    uint32_t trieFileSize = dyld_info_cmd ? dyld_info_cmd->export_size : exports_trie_cmd->datasize;
    
    void *exports = (void *)(ctx->linkedit_base + trieFileOffset);
    if (exports == NULL) {
        return 0;
    }
    
    uint8_t *exports_start = (uint8_t *)exports;
    uint8_t *exports_end = (uint8_t *)exports_start + trieFileSize;
    
    uint8_t *node = (uint8_t *)sl_tail_walk(exports_start, exports_end, symbol_name);
    if (node == NULL) {
        return 0;
    }
    
    const uint8_t *p = node;
    const uintptr_t flags = sl_read_uleb128(&p, exports_end);
    if (out_flags) {
        *out_flags = flags;
    }
    if (flags & EXPORT_SYMBOL_FLAGS_REEXPORT) {
        const uint64_t ordinal = sl_read_uleb128(&p, exports_end);
        const char *importedName = (const char *)p;
        if (importedName[0] == '\0') {
            importedName = symbol_name;
            return 0;
        }
        return (uintptr_t)importedName;
    }
    
    uint64_t trieValue = sl_read_uleb128(&p, exports_end);
    return trieValue;
}

uintptr_t sl_macho_ctx_symbol_resolve_options(sl_macho_ctx *ctx, const char *symbol_name_pattern, sl_resolve_symbol_type_t type) {
    if (type & SL_RESOLVE_SYMBOL_TYPE_SYMBOL_TABLE) {
        uintptr_t result = sl_macho_ctx_iterate_symbol_table(ctx, symbol_name_pattern);
        if (result) {
            result = result + (ctx->is_runtime_mode ? ctx->slide : 0);
            return result;
        }
    }
    
    if (type & SL_RESOLVE_SYMBOL_TYPE_EXPORTED) {
        uint64_t flags;
        uintptr_t result = sl_macho_ctx_iterate_exported_symbol(ctx, symbol_name_pattern, &flags);
        if (result) {
            
        }
    }
    
    return 0;
}

uintptr_t sl_macho_ctx_symbol_resolve(sl_macho_ctx_t *ctx, const char *symbol_name_pattern) {
    return sl_macho_ctx_symbol_resolve_options(ctx, symbol_name_pattern, SL_RESOLVE_SYMBOL_TYPE_ALL);
}

uintptr_t sl_macho_symbol_resolve_options(mach_header_t *header, const char *symbol_name_pattern, sl_resolve_symbol_type_t type) {
    sl_macho_ctx_t ctx;
    sl_macho_ctx_init(&ctx, header, true);
    
    return sl_macho_ctx_symbol_resolve_options(&ctx, symbol_name_pattern, type);
}

uintptr_t sl_macho_symbol_resolve(mach_header_t *header, const char *symbol_name_pattern) {
    
    return sl_macho_symbol_resolve_options(header, symbol_name_pattern, SL_RESOLVE_SYMBOL_TYPE_ALL);
}

uintptr_t sl_macho_file_memory_symbol_resolve(cpu_type_t in_cputype, cpu_subtype_t in_cpusubtype, const uint8_t *file_mem, char *symbol_name_pattern) {
    mach_header_t *header = (mach_header_t *)file_mem;
    struct fat_header *fh = (struct fat_header *)file_mem;
    if (fh->magic == OSSwapBigToHostInt32(FAT_MAGIC)) {
        const struct fat_arch *archs = (struct fat_arch *)(((uintptr_t)fh) + sizeof(struct fat_header));
        mach_header_t *header_arm64 = NULL;
        mach_header_t *header_arm64e = NULL;
        mach_header_t *header_x64 = NULL;
        for (size_t i = 0; i < OSSwapBigToHostInt32(fh->nfat_arch); i++) {
            uint64_t offset;
            uint64_t len;
            cpu_type_t cputype = (cpu_type_t)OSSwapBigToHostInt32(archs[i].cputype);
            cpu_subtype_t cpusubtype = (cpu_subtype_t)OSSwapBigToHostInt32(archs[i].cpusubtype);
            offset = OSSwapBigToHostInt32(archs[i].offset);
            len = OSSwapBigToHostInt32(archs[i].size);
            if (cputype == CPU_TYPE_X86_64) {
                header_x64 = (mach_header_t *)&file_mem[offset];
            } else if (cputype == CPU_TYPE_ARM64 && (cpusubtype & ~CPU_SUBTYPE_MASK) == CPU_SUBTYPE_ARM64E) {
                header_arm64e = (mach_header_t *)&file_mem[offset];
            } else if (cputype == CPU_TYPE_ARM64) {
                header_arm64 = (mach_header_t *)&file_mem[offset];
            }
            
            if ((cputype == in_cputype) && ((cpusubtype & in_cpusubtype) == in_cpusubtype)) {
                header = (mach_header_t *)&file_mem[offset];
                break;
            }
        }
        if (header == (mach_header_t *)file_mem) {
            if (in_cputype == 0 && in_cpusubtype == 0) {
#if defined(__arm64__) || defined(__aarch64__)
                header = header_arm64e ? header_arm64e : header_arm64;
#endif
            }
        }
    }
    
    sl_macho_ctx_t ctx;
    sl_macho_ctx_init(&ctx, header, false);
    return sl_macho_ctx_symbol_resolve_options(&ctx, symbol_name_pattern, SL_RESOLVE_SYMBOL_TYPE_SYMBOL_TABLE);
}

uintptr_t sl_macho_file_symbol_resolve(cpu_type_t cpu, cpu_subtype_t subtype, const char *file, char *symol_name_pattern) {
    SLMmapFileManager mng(file);
    auto mmap_buffer = mng.map();
    if (!mmap_buffer) {
        return 0;
    }
    
    return sl_macho_file_memory_symbol_resolve(cpu, subtype, mmap_buffer, symol_name_pattern);
}
