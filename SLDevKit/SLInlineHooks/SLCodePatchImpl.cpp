//
//  SLCodePatchImpl.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/2.
//

#include <stdio.h>
#include "SLTypeAlias.hpp"
#include "SLUtilityMacro.hpp"
#include <mach/vm_statistics.h>
#include <dlfcn.h>
#include <mach/vm_map.h>
#include <mach/mach.h>
#include "SLLogger.h"
#include "mach_vm.hpp"
#include "SLSymbolResolver.hpp"
#include "pac_kit.h"
#include <libkern/OSCacheControl.h>

#ifdef __cplusplus
extern "C" {
#endif

PUBLIC int sl_codePatch(void *address, uint8_t *buffer, uint32_t buffer_size) {
    if (address == nullptr || buffer == nullptr || buffer_size == 0) {
        return -1;
    }
    
    // memory page size.
    size_t page_size = PAGE_SIZE;
    // the memory page where the address is located.
    sl_addr_t patch_page = ALIGN_FLOOR(address, page_size);
    
    // cross over page.
    if ((sl_addr_t)address + buffer_size > patch_page + page_size) {
        void *address_a = address;
        uint8_t *buffer_a = buffer;
        uint32_t buffer_size_a = (uint32_t)(patch_page + page_size - (sl_addr_t)address);
        auto ret = sl_codePatch(address_a, buffer_a, buffer_size_a);
        if (ret == -1) {
            return ret;
        }
        
        void *address_b = (void *)((sl_addr_t)address + buffer_size_a);
        uint8_t *buffer_b = buffer + buffer_size_a;
        uint32_t buffer_size_b = buffer_size - buffer_size_a;
        ret = sl_codePatch(address_b, buffer_b, buffer_size_b);
        return ret;
    }
    
    sl_addr_t remap_dest_page = patch_page;

    auto self_task = mach_task_self();
    kern_return_t kr;
    
    int orig_prot = 0;
    int orig_max_prot = 0;
    int share_mode = 0;
    int is_enable_remap = -1;
    if (is_enable_remap == -1) {
        auto get_region_info = [&](sl_addr_t region_start) -> void {
            vm_region_submap_info_64 region_submap_info;
            mach_msg_type_number_t count = VM_REGION_SUBMAP_INFO_COUNT_64;
            mach_vm_address_t addr = region_start;
            mach_vm_size_t size = 0;
            natural_t depth = 0;
            while (1) {
                kr = mach_vm_region_recurse(mach_task_self(), (mach_vm_address_t *)&addr, (mach_vm_size_t *)&size, &depth, (vm_region_recurse_info_t)&region_submap_info, &count);
                if (region_submap_info.is_submap) {
                    depth++;
                } else {
                    orig_prot = region_submap_info.protection;
                    orig_max_prot = region_submap_info.max_protection;
                    share_mode = region_submap_info.share_mode;
                    return;
                }
            }
        };
        
        get_region_info(remap_dest_page);
        
        if (orig_max_prot != 5 && share_mode != 2) {
            is_enable_remap = 1;
        } else {
            is_enable_remap = 0;
            SLDEBUG_LOG("code patch %p won't use remap.", address);
        }
    }
    
    if (is_enable_remap == 1) {
        sl_addr_t remap_dummy_page = 0;
        kr = mach_vm_allocate((vm_map_t)self_task, (mach_vm_address_t *)&remap_dummy_page, page_size, VM_FLAGS_ANYWHERE);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("mach_vm_allocate failure.");
            return kr;
        }
        
        memcpy((void *)remap_dummy_page, (void *)patch_page, page_size);
        
        int offset = (int)((sl_addr_t)address - patch_page);
        memcpy((void *)(remap_dummy_page + offset), buffer, buffer_size);
        
        kr = mach_vm_protect(self_task, remap_dummy_page, page_size, false, VM_PROT_READ | VM_PROT_EXECUTE);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("mach_vm_protect failure.");
            return kr;
        }
        
        vm_prot_t prot, max_prot;
        kr = mach_vm_remap(self_task, (mach_vm_address_t *)&remap_dest_page, page_size, 0, VM_FLAGS_OVERWRITE | VM_FLAGS_FIXED, self_task, remap_dummy_page, true, &prot, &max_prot, VM_INHERIT_COPY);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("mach_vm_remap failure.");
            return kr;
        }
        
        kr = mach_vm_deallocate(self_task, remap_dummy_page, page_size);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("mach_vm_deallocate failure.");
            return kr;
        }
    } else {
        static __typeof(vm_protect) *vm_protect_impl = nullptr;
        if (vm_protect_impl == nullptr) {
            vm_protect_impl = (__typeof(vm_protect) *)sl_symbolResolver("dyld", "vm_protect");
            
            if (vm_protect_impl == nullptr) {
                vm_protect_impl = (__typeof(vm_protect) *)sl_symbolResolver("libsystem_kernel.dylib", "_vm_protect");
            }
            vm_protect_impl = (__typeof(vm_protect) *)pac_sign((void *)vm_protect_impl);
        }
        
        kr = vm_protect_impl(self_task, remap_dest_page, page_size, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("vm_protect failure.");
            return kr;
        }
        
        memcpy((void *)(patch_page + ((uint64_t)address - remap_dest_page)), buffer, buffer_size);
        
        kr = vm_protect_impl(self_task, remap_dest_page, page_size, false, orig_prot);
        if (kr != KERN_SUCCESS) {
            SLERROR_LOG("vm_protect failure.");
            return kr;
        }
    }
    
    sys_icache_invalidate(address, buffer_size);
    return 0;
}

#ifdef __cplusplus
} // extern "C"
#endif

