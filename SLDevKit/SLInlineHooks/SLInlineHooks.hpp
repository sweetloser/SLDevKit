//
//  SLInlineHooks.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#ifndef SLInlineHooks_hpp
#define SLInlineHooks_hpp

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include "SLTypeAlias.hpp"

/**
 * memory code patch.
 * 
 * @param address address description
 * @param buffer buffer description
 * @param buffer_size buffer_size description
 */
int sl_codePatch(void *address, uint8_t *buffer, uint32_t buffer_size);


int sl_instrument(void *address, sl_instrument_callback_t pre_handler);

/**
 * resolves the address of the symbol in the given module.module can be null, if null, resolves in all modules, including dyld.
 *
 * @param image_name the module name used to search for symbols. null-able, if null, it is found in all modules.
 * @param symbol_name name of the symbol to be resolver.
 *
 * @return returns the symbol address if success, otherwise 0 and prints error message in debug mode.
 */
void *sl_symbolResolver(const char *image_name, const char *symbol_name);

/**
 * replace the given import symbol, as fishhook did.
 * 
 * @param image_name the module name used to search for symbols. null-able, if null, it is found in all modules.
 * @param symbol_name name of the symbol to be replaced.
 * @param fake_func function to replace.
 * @param orig_func_ptr a pointer to save the original function.
 * 
 * @return returns 0 if success, otherwise -1 and prints error message in debug mode.
 */
int sl_importTableReplace(char *image_name, char *symbol_name, sl_dummy_func_t fake_func, sl_dummy_func_t *orig_func_ptr);

#ifdef __cplusplus
}
#endif
#endif /* SLInlineHooks_hpp */
