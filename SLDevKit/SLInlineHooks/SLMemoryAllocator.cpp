//
//  SLMemoryAllocator.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/25.
//

#include "SLMemoryAllocator.hpp"

SLMemRange::SLMemRange(sl_addr_t start, size_t size) : start(start), end(0), size(size) {
    end = start + size;
}

void SLMemRange::reset(sl_addr_t start, size_t size) {
    this->start = start;
    this->size = size;
    this->end = start + size;
}
