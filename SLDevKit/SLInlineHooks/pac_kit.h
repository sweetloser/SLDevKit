//
//  pac_kit.h
//  Pods
//
//  Created by 曾祥翔 on 2024/1/5.
//

#ifndef pac_kit_h
#define pac_kit_h

#include <stdint.h>

#if defined(__arm64e__) && __has_feature(ptrauth_calls)
#include <ptrauth.h>
#endif

static inline void *pac_strip(void *addr) {
  if (addr == NULL) {
    return NULL;
  }
#if __has_feature(ptrauth_calls)
  addr = ptrauth_strip(addr, ptrauth_key_asia);
#endif
  return addr;
}

static inline void *pac_sign(void *addr) {
  if (addr == NULL) {
    return NULL;
  }
#if __has_feature(ptrauth_calls)
  addr = ptrauth_sign_unauthenticated((void *)addr, ptrauth_key_asia, 0);
#endif
  return addr;
}

static inline void *pac_strip_and_sign(void *addr) {
  return pac_sign(pac_strip(addr));
}

#endif /* pac_kit_h */
