//
//  sl_mach_vm.hpp
//  Pods
//
//  Created by 曾祥翔 on 2023/12/25.
//

#ifndef sl_mach_vm_h
#define sl_mach_vm_h

#ifdef __cplusplus
extern "C" {
#endif

#include <mach/mach.h>
#include <sys/mman.h>
#include <mach-o/dyld_images.h>

extern kern_return_t mach_vm_region_recurse(vm_map_t target_task, mach_vm_address_t *address, mach_vm_size_t *size, natural_t *nesting_depth, vm_region_recurse_info_t info, mach_msg_type_number_t *infoCnt);

#ifdef __cplusplus
} // extern "C"

#endif
#endif /* sl_mach_vm_h */
