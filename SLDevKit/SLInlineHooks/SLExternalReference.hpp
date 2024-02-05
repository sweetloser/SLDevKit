//
//  SLExternalReference.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/4.
//

#ifndef SLExternalReference_hpp
#define SLExternalReference_hpp

#include <stdio.h>
#ifdef __cplusplus
#include "pac_kit.h"


class SLExternalReference {
public:
    explicit SLExternalReference(void *address) : address_(address) {
#if defined(__APPLE__) && __arm64e__
        address_ = pac_strip((void *)address_);
#endif
    }
    const void *address();
private:
    const void *address_;
};

#endif
#endif /* SLExternalReference_hpp */
