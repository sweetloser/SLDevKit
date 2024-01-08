//
//  SLCodeBufferBase.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#include "SLCodeBufferBase.hpp"

SLCodeBufferBase *SLCodeBufferBase::copy() {
    SLCodeBufferBase *result = new SLCodeBufferBase();
    result->emitBuffer(getBuffer(), (int)getBufferSize());
    return result;
}

void SLCodeBufferBase::emit8(uint8_t data) {
    emit(data);
}
void SLCodeBufferBase::emit16(uint16_t data) {
    emit(data);
}
void SLCodeBufferBase::emit32(uint32_t data) {
    emit(data);
}
void SLCodeBufferBase::emit64(uint64_t data) {
    emit(data);
}

void SLCodeBufferBase::emitBuffer(uint8_t *buffer, int buffer_size) {
    buffer_.insert(buffer_.end(), buffer, buffer + buffer_size);
}

uint8_t *SLCodeBufferBase::getBuffer() {
    return buffer_.data();
}
size_t SLCodeBufferBase::getBufferSize() {
    return buffer_.size();
}
