//
//  SLCodeBufferBase.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#ifndef SLCodeBufferBase_hpp
#define SLCodeBufferBase_hpp

#ifdef __cplusplus
#include <stdio.h>
#include <stdint.h>
#include <vector>

class SLCodeBufferBase {
public:
    SLCodeBufferBase(){}
    
public:
    virtual SLCodeBufferBase *copy();
    
    void emit8(uint8_t data);
    
    void emit16(uint16_t data);
    
    void emit32(uint32_t data);
    
    void emit64(uint64_t data);
    
    template <typename T> void store(int offset, T value) {
        *((T *)(buffer_.data() + offset)) = value;
    }
    
    template <typename T> void emit(T value) {
        emitBuffer((uint8_t *)&value, sizeof(value));
    }
    
    void emitBuffer(uint8_t *buffer, int len);
    
    uint8_t *getBuffer();
    size_t getBufferSize();
    
private:
    std::vector<uint8_t> buffer_;
};



#endif

#endif /* SLCodeBufferBase_hpp */
