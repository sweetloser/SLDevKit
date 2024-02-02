//
//  SLSymbolResolver.hpp
//  Pods
//
//  Created by 曾祥翔 on 2024/2/2.
//

#ifndef SLSymbolResolver_h
#define SLSymbolResolver_h

#ifdef __cplusplus
extern "C" {
#endif

void *sl_symbolResolver(const char *image_name, const char *symbol_name);

#ifdef __cplusplus
}
#endif /* SLSymbolResolver_h */
#endif
