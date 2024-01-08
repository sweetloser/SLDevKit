//
//  SLRegisterBase.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLRegisterBase.hpp"

constexpr SLRegisterBase SLRegisterBase::from_code(int code) {
    return SLRegisterBase{code};
}

constexpr SLRegisterBase SLRegisterBase::no_reg() {
    return SLRegisterBase{0};
}
