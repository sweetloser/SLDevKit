//
//  mach_o.hpp
//  Pods
//
//  Created by 曾祥翔 on 2023/12/28.
//

#ifndef mach_o_h
#define mach_o_h
#include <mach-o/nlist.h>
#include <mach-o/loader.h>

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

#ifdef __cplusplus
}
#endif
#endif /* mach_o_h */
