//
//  SLRegisterBase.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLRegisterBase_hpp
#define SLRegisterBase_hpp

#include <stdio.h>
#ifdef __cplusplus
class SLRegisterBase {
public:
    static constexpr SLRegisterBase from_code(int code);
    
    static constexpr SLRegisterBase no_reg();
    
    virtual bool is(const SLRegisterBase &reg) const {
        return (reg.reg_code_ == this->reg_code_);
    }
    
protected:
    explicit constexpr SLRegisterBase(int code) : reg_code_(code) {}
    
    int reg_code_;
    
    
};
#endif
#endif /* SLRegisterBase_hpp */
