//
//  SLProcessRuntimeUtility.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#include "SLProcessRuntimeUtility.hpp"
#include <mach/mach.h>
#include <sys/mman.h>
#include <mach-o/dyld_images.h>
#include <algorithm>
#include <vector>
#include "mach_vm.h"


std::vector<SLMemRegion> regions;

const std::vector<SLMemRegion> &SLProcessRuntimeUtility::GetProcessMemoryLayout() {
    regions.clear();
    
    vm_region_submap_info_64 region_submap_info;
    mach_msg_type_number_t count = VM_REGION_SUBMAP_INFO_COUNT_64;
    mach_vm_address_t addr = 0;
    mach_vm_size_t size = 0;
    natural_t depth = 0;
    
    while (true) {
        count = VM_REGION_SUBMAP_INFO_COUNT_64;
        kern_return_t kr = mach_vm_region_recurse(mach_task_self(), (mach_vm_address_t *)&addr, (mach_vm_size_t *)&size, (natural_t *)&depth, (vm_region_recurse_info_t)&region_submap_info, &count);
        if (kr != KERN_SUCCESS) {
            break;
        }
        
        if (region_submap_info.is_submap) {
            depth++;
        } else {
            SLMemoryPermission perission;
            if ((region_submap_info.protection & PROT_READ) && (region_submap_info.protection & PROT_WRITE)) {
                // read & write
                perission = SLMemoryPermission::kReadWrite;
            } else if ((region_submap_info.protection & PROT_READ) == region_submap_info.protection) {
                // read only
                perission = SLMemoryPermission::kRead;
            } else if ((region_submap_info.protection & PROT_READ) && (region_submap_info.protection & PROT_EXEC)) {
                // read & execute
                perission = SLMemoryPermission::kReadExecute;
            } else {
                // no access.
                perission = SLMemoryPermission::kNoAccess;
            }
            
            SLMemRegion region = SLMemRegion(addr, size, perission);
            regions.push_back(region);
            addr += size;
        }
    }
    return regions;
}


static std::vector<SLRuntimeModule> *modules;
const std::vector<SLRuntimeModule> &SLProcessRuntimeUtility::GetProcessModuleMap() {
    if (modules == nullptr) {
        modules = new std::vector<SLRuntimeModule>();
    }
    modules->clear();
    
    kern_return_t kr;
    task_dyld_info_data_t task_dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;
    kr = task_info(mach_task_self_, TASK_DYLD_INFO, (task_info_t)&task_dyld_info, &count);
    if (kr != KERN_SUCCESS) {
        return *modules;
    }
    
    struct dyld_all_image_infos *infos = (struct dyld_all_image_infos *)task_dyld_info.all_image_info_addr;
    const struct dyld_image_info *infoArray = infos->infoArray;
    uint32_t infoArrayCount = infos->infoArrayCount;
    
    SLRuntimeModule one = {0};
    
    strncpy(one.path, "dummy-placeholder-module", sizeof(one.path) - 1);
    one.load_address = 0;
    modules->push_back(one);
    
    strncpy(one.path, infos->dyldPath, sizeof(one.path) - 1);
    one.load_address = (void *)infos->dyldImageLoadAddress;
    modules->push_back(one);
    
    for (int i = 0; i < infoArrayCount; i++) {
        const struct dyld_image_info *info = &infoArray[i];
        
        strncpy(one.path, info->imageFilePath, sizeof(one.path) - 1);
        one.load_address = (void *)info->imageLoadAddress;
        modules->push_back(one);
    }
    auto comp = [](const SLRuntimeModule &a, const SLRuntimeModule &b)->bool {
        return a.load_address < b.load_address;
    };
    std::sort(modules->begin(), modules->end(), comp);
    
    return *modules;
}

