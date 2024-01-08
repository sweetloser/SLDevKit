//
//  SLCPURegister.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLCPURegister_hpp
#define SLCPURegister_hpp

#include <stdio.h>
#ifdef __cplusplus
#include "SLRegisterBase.hpp"
#include <stdint.h>

class SLCPURegister : public SLRegisterBase {
public:
    enum SLRegisterType {
        kRegister_32,
        kRegister_W = kRegister_32,
        kRegister_64,
        kRegister_X = kRegister_64,
        kRegister,
        
        kVRegister,
        kSIMD_FP_Register_8,
        kSIMD_FP_Register_B = kSIMD_FP_Register_8,
        kSIMD_FP_Register_16,
        kSIMD_FP_Register_H = kSIMD_FP_Register_16,
        kSIMD_FP_Register_32,
        kSIMD_FP_Register_S = kSIMD_FP_Register_32,
        kSIMD_FP_Register_64,
        kSIMD_FP_Register_D = kSIMD_FP_Register_64,
        kSIMD_FP_Register_128,
        kSIMD_FP_Register_Q = kSIMD_FP_Register_128,
        
        kInvalid
    };
    
    constexpr SLCPURegister(int code, int size, SLRegisterType type) : SLRegisterBase(code), reg_size_(size), reg_type_(type) {}
    
    static constexpr SLCPURegister create(int code, int size, SLRegisterType type) {
        return SLCPURegister(code, size, type);
    }
    
    static constexpr SLCPURegister X(int code) {
        return SLCPURegister(code, 64, kRegister_64);
    }
    
    static constexpr SLCPURegister W(int code) {
        return SLCPURegister(code, 32, kRegister_32);
    }
    
    static constexpr SLCPURegister Q(int code) {
        return SLCPURegister(code, 128, kSIMD_FP_Register_128);
    }
    
    static constexpr SLCPURegister invalidRegister() {
        return SLCPURegister(0, 0, kInvalid);
    }
    
    bool is(const SLCPURegister &reg) const {
        return (reg.reg_code_ == this->reg_code_);
    }
    
    bool is64Bits() const {
        return (reg_size_ == 64);
    }
    
    bool isRegister() const {
        return reg_type_ < kRegister;
    }
    
    bool isVRegister() const {
        return reg_type_ > kVRegister;
    }
    
    SLRegisterType type() const {
        return reg_type_;
    }
    int32_t code() const {
        return reg_code_;
    }
    
private:
    SLRegisterType reg_type_;
    int reg_size_;
};


typedef SLCPURegister SLRegister;
typedef SLCPURegister SLVRegister;

#define GENERAL_REGISTER_CODE_LIST(R)                                   \
    R(0)    R(1)    R(2)    R(3)    R(4)    R(5)    R(6)    R(7)        \
    R(8)    R(9)    R(10)   R(11)   R(12)   R(13)   R(14)   R(15)       \
    R(16)   R(17)   R(18)   R(19)   R(20)   R(21)   R(22)   R(23)       \
    R(24)   R(25)   R(26)   R(27)   R(28)   R(29)   R(30)   R(31)       \

#define DEFINE_REGISTER(register_class, name, ...)  constexpr register_class name = register_class::create(__VA_ARGS__)

#define DEFINE_REGISTERS(N)      \
DEFINE_REGISTER(SLRegister, w##N, N, 32, SLCPURegister::kRegister_32);  \
DEFINE_REGISTER(SLRegister, x##N, N, 64, SLCPURegister::kRegister_64);  \

GENERAL_REGISTER_CODE_LIST(DEFINE_REGISTERS)

#undef DEFINE_REGISTERS

#define DEFINE_VREGISTERS(N)    \
DEFINE_REGISTER(SLVRegister, b##N, N, 8, SLCPURegister::kSIMD_FP_Register_8);       \
DEFINE_REGISTER(SLVRegister, h##N, N, 16, SLCPURegister::kSIMD_FP_Register_16);     \
DEFINE_REGISTER(SLVRegister, s##N, N, 32, SLCPURegister::kSIMD_FP_Register_32);     \
DEFINE_REGISTER(SLVRegister, d##N, N, 64, SLCPURegister::kSIMD_FP_Register_64);     \
DEFINE_REGISTER(SLVRegister, q##N, N, 128, SLCPURegister::kSIMD_FP_Register_128);   \

#undef DEFINE_VREGISTERS


constexpr SLRegister wzr    = w31;
constexpr SLRegister xzr    = x31;

constexpr SLRegister SP     = x31;
constexpr SLRegister wSP    = w31;
constexpr SLRegister FP     = x29;
constexpr SLRegister wFP    = w29;
constexpr SLRegister LR     = x30;
constexpr SLRegister wLR    = w30;



#define W(code) SLCPURegister::W(code)
#define X(code) SLCPURegister::X(code)
#define Q(code) SLCPURegister::Q(code)

#define InvalidRegister SLCPURegister::invalidRegister()

#endif
#endif /* SLCPURegister_hpp */
