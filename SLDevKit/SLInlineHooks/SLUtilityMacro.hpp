//
//  SLUtilityMacro.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLUtilityMacro_hpp
#define SLUtilityMacro_hpp

// left/right shift
#define LeftShift(a, b, c)  ((a & ((1 << b) - 1)) << c)

// align
#ifndef ALIGN
#define ALIGN ALIGN_FLOOR
#endif

// partition the memory according to the specified size.
// the memory page where the given address is located.
#define ALIGN_FLOOR(address, range) ((uintptr_t)address & ~((uintptr_t)range - 1))
// the next page of the memory page where the address is located.
#define ALIGN_CEIL(address, range) (((uintptr_t)address + (uintptr_t)range - 1) & ~((uintptr_t)range - 1))

// The mask of a given bit.
// eg. submask(4) ===> 0b11111 = 0x1f = 31
#define submask(x) ((1L << ((x) + 1)) - 1)

// value from st to fn bits.
// eg. bits(0b101110001011, 5, 10) = 0b11100 = 0x1c
#define bits(obj, st, fn)   (((obj) >> (st)) & submask((fn) - (st)))

// value at st bit.
// eg.bit(0b101110001011, 5) = 0
#define bit(obj, st) (((obj) >> (st)) & 1)

#define sbits(obj, st, fn) ((long)(bits(obj, st, fn) | ((long)bit(obj, fn) * ~submask((fn) - (st)))))

// set value at st bit.
#define set_bit(obj, st, bit) obj = (((~(1 << st)) & obj) | (bit << st))

// set values from st to fn bits.
#define set_bits(obj, st, fn, bits) obj = (((~(submask(fn - st) << st)) & obj) | (bits << st))

#define PUBLIC __attribute__((visibility("default")))
#define INTERNAL __attribute__((visibility("internal")))

#endif /* SLUtilityMacro_hpp */
