//
//  SLOSMemory.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#include "SLOSMemory.hpp"
#include <unistd.h>
#include <sys/mman.h>
#if defined(__APPLE__)
#include <dlfcn.h>
#include <mach/mach.h>
#include <mach/vm_statistics.h>
#endif

#if defined(__APPLE__)
const int kMmapFd = VM_MAKE_TAG(255);
#else
const int kMmapFd = -1;
#endif

const int kMmapFdOffset = 0;

static int getProtectionFromMemoryPermission(SLMemoryPermission access) {
    switch (access) {
        case SLMemoryPermission::kNoAccess:
            return PROT_NONE;
        case SLMemoryPermission::kRead:
            return PROT_READ;
        case SLMemoryPermission::kReadWrite:
            return PROT_READ | PROT_WRITE;
        case SLMemoryPermission::kReadWriteExecute:
            return PROT_READ | PROT_WRITE | PROT_EXEC;
        case SLMemoryPermission::kReadExecute:
            return PROT_READ | PROT_EXEC;
    }
}

int SLOSMemory::pageSize() {
    return static_cast<int>(sysconf(_SC_PAGESIZE));
}
void *SLOSMemory::allocate(size_t size, SLMemoryPermission access) {
    return SLOSMemory::allocate(size, access, nullptr);
}
void *SLOSMemory::allocate(size_t size, SLMemoryPermission access, void *fixed_address) {
    int prot = getProtectionFromMemoryPermission(access);
    
    int flags = MAP_PRIVATE | MAP_ANONYMOUS;
    if (fixed_address != nullptr) {
        flags = flags | MAP_FIXED;
    }
    void *result = mmap(fixed_address, size, prot, flags, kMmapFd, kMmapFdOffset);
    if (result == MAP_FAILED) {
        return nullptr;
    }
    return result;
}
