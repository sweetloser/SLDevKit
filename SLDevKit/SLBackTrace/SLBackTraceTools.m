//
//  SLBackTraceTools.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/20.
//

#import "SLBackTraceTools.h"
#import <mach/mach.h>
#import <pthread/pthread.h>
#include <sys/types.h>
#import <limits.h>
#import "NSString+SLChainable.h"
#import "SLFoundationPrivate.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

typedef struct nlist_64 nlist_t;

typedef struct SL_StackFrameEntry {
    const struct SL_StackFrameEntry *const preFp;
    const uintptr_t lr;
    
}SL_StackFrameEntry;

static mach_port_t _main_thread_id;

thread_t machThreadFromNSThread(NSThread *thread) {
    // 判断是否为主线程
    if ([thread isMainThread]) return _main_thread_id;
    
    NSString *_origName = [thread name];
    
    // 为线程设置一个线程名   ————    防止线程没有设置过name，无法准确获取
    [thread setName:Str(@"%f",[NSDate date].timeIntervalSince1970)];
    // 获取线程数
    mach_msg_type_number_t _tCount;
    thread_act_array_t _tList;
    mach_port_t mach_thread = mach_thread_self();
    
    task_threads(mach_task_self(), &_tList, &_tCount);
    
    char _pName[256] = {0};
    for (int t = 0; t < _tCount; t++) {
        pthread_t pt = pthread_from_mach_thread_np(_tList[t]);
        if (pt) {
            pthread_getname_np(pt, _pName, sizeof(_pName));
            
            if (strcmp(_pName, thread.name.UTF8String) == 0) {
                mach_thread = _tList[t];
                break;
            }
        }
    }
    
    // 还原原本的线程名
    [thread setName:_origName];
    
    return mach_thread;
}

static kern_return_t sl_mach_copyMemory(const void *const src, void *const dst, const size_t numBytes){
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied);
}

static uintptr_t firstCmdAfterHeader(const struct mach_header* const header) {
    switch(header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            // Header is corrupt
            return 0;
    }
}

static uint32_t imageIndexContainingAddress(const uintptr_t address) {
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++)
    {
        header = _dyld_get_image_header(iImg);
        if(header != NULL) {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = firstCmdAfterHeader(header);
            if(cmdPtr == 0) {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr && addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                } else if(loadCmd->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr && addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}


static uintptr_t segmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* header = _dyld_get_image_header(idx);
    
    // Look for a segment command and return the file image address.
    uintptr_t cmdPtr = firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT) {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        } else if(loadCmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return 0;
}

BOOL sl_dladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;

    const uint32_t idx = imageIndexContainingAddress(address);
    if(idx == UINT_MAX) {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0) {
        return false;
    }

    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;

    // Find symbol tables and get whichever symbol is closest to the address.
    const nlist_t* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB) {
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const nlist_t* symbolTable = (nlist_t*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;

            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                // Skip all debug N_STAB symbols
                if ((symbolTable[iSym].n_type & N_STAB) != 0) {
                    continue;
                }

                // If n_value is 0, the symbol refers to an external object.
                if(symbolTable[iSym].n_value != 0) {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) && (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL) {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                if(bestMatch->n_desc == 16) {
                    // This image has been stripped. The name is meaningless, and
                    // almost certainly resolves to "_mh_execute_header"
                    info->dli_sname = NULL;
                } else {
                    info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                    if(*info->dli_sname == '_') {
                        info->dli_sname++;
                    }
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    
    return true;
}

void sl_symbolLicate(const uintptr_t *const backTraceBuffer, Dl_info *const symbolsBuffer, const int backTraceLength) {
    int i = 0;
    if (i < backTraceLength) {
        sl_dladdr(backTraceBuffer[i], &symbolsBuffer[i]);
    }
    i++;
    for (; i<backTraceLength; i++) {
        sl_dladdr((backTraceBuffer[i] & ~(3UL)) - 1, &symbolsBuffer[i]);
        printf("方法名：%s\n", symbolsBuffer[i].dli_sname);
    }
}

@implementation SLBackTraceTools

+ (void)load {
    _main_thread_id = mach_thread_self();
}

+ (NSArray <SLSymbolModel *>*)sl_backTraceWithThread:(NSThread *)thread {
    
    uintptr_t backTraceBuffer[50];
    int i = 0;
    
    thread_t _t = machThreadFromNSThread(thread);
    
    // 或许线程的寄存器信息
    _STRUCT_MCONTEXT _machineC;
    mach_msg_type_number_t sCount = ARM_THREAD_STATE64_COUNT;
    kern_return_t kr = thread_get_state(_t, ARM_THREAD_STATE64, (thread_state_t)&_machineC.__ss, &sCount);
    if (kr != KERN_SUCCESS) {
        NSLog(@"获取线程信息失败");
        return @[];
    }
    
    // 获取PC寄存器的值
    uintptr_t pcAddr = _machineC.__ss.__pc;
    NSLog(@"pc寄存器的值：0x%lx", pcAddr);
    
    // 获取lr寄存器的值
    uintptr_t lrAddr = _machineC.__ss.__lr;
    NSLog(@"lr寄存器的值：0x%lx", lrAddr);
    if (lrAddr) {
        backTraceBuffer[i] = lrAddr & 0xffffffff8;
        i++;
    }
    
    // 获取fp寄存器的值
    SL_StackFrameEntry fps = {0};
    const uintptr_t fpAddr = _machineC.__ss.__fp;
    
    // 获取fp寄存器指向的地址的值      【相当于对fp寄存器解引用 *fp， *(fp+1)】
    if (fpAddr == 0 || sl_mach_copyMemory((const void *)fpAddr, &fps, sizeof(fps)) != KERN_SUCCESS) {
        NSLog(@"获取pf寄存器失败");
    }
    
    // 递归回溯
    for (; i<50; i++) {
        backTraceBuffer[i] = fps.lr & 0xffffffff8;  // 保存lr寄存器的值
        if (backTraceBuffer[i] == 0 || fps.preFp == 0 || sl_mach_copyMemory(fps.preFp, &fps, sizeof(fps)) != KERN_SUCCESS) {
            break;
        }
    }
    
    // 回溯的层数
    int backTraceLength = i;
    
    // 获取符号信息
    Dl_info symbols[backTraceLength];
    sl_symbolLicate(backTraceBuffer, symbols, backTraceLength);
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:backTraceLength];
    for(int s = 0; s < backTraceLength; s++) {
        printf("函数名：%s\n",symbols[s].dli_sname);
        [retArray addObject:[[SLSymbolModel alloc] initWithDLInfo:symbols+s]];
    }
    
    return retArray;
}



@end
