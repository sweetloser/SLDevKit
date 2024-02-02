//
//  mach_vm_h.hpp
//  Pods
//
//  Created by 曾祥翔 on 2023/12/25.
//

#ifndef mach_vm_h
#define mach_vm_h

#include <mach/mach.h>
#include <sys/mman.h>
#include <mach/boolean.h>
#include <mach/kern_return.h>
#include <mach/mach_types.h>
#include <mach/message.h>
#include <mach/mig_errors.h>
#include <mach/ndr.h>
#include <mach/notify.h>
#include <mach/port.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

extern kern_return_t mach_vm_region_recurse(vm_map_t target_task, mach_vm_address_t *address, mach_vm_size_t *size, natural_t *nesting_depth, vm_region_recurse_info_t info, mach_msg_type_number_t *infoCnt);

extern kern_return_t mach_vm_allocate(vm_map_t target, mach_vm_address_t *address, mach_vm_size_t size, int flags);

extern kern_return_t mach_vm_deallocate(vm_map_t target, mach_vm_address_t address, mach_vm_size_t size);

extern kern_return_t mach_vm_protect(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, boolean_t set_maximum, vm_prot_t new_protection);

extern kern_return_t mach_vm_remap(vm_map_t target_task, mach_vm_address_t *target_address, mach_vm_size_t size, mach_vm_offset_t mask, int flags, vm_map_t src_task, mach_vm_address_t src_address, boolean_t copy, vm_prot_t *curr_protection, vm_prot_t *max_protection, vm_inherit_t inheritance);

extern kern_return_t mach_vm_region_recurse(vm_map_t target_task, mach_vm_address_t *address, mach_vm_size_t *size, natural_t *nesting_depth, vm_region_recurse_info_t info, mach_msg_type_number_t *infoCnt);


#ifdef __cplusplus
} // extern "C"
#endif

#endif /* mach_vm_h */
