//
//  SLAssemblerBase.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#include "SLAssemblerBase.hpp"

//SLAssemblerBase::SLAssemblerBase(void *address) {
//    realized_addr_ = address;
//    buffer_ = nullptr;
//}
//
//SLAssemblerBase::~SLAssemblerBase() {
//    buffer_ = nullptr;
//}

size_t SLAssemblerBase::ip_offset() const {
    return reinterpret_cast<SLCodeBufferBase *>(buffer_)->getBufferSize();
}
size_t SLAssemblerBase::pc_offset() const {
    return reinterpret_cast<SLCodeBufferBase *>(buffer_)->getBufferSize();
}

SLCodeBuffer *SLAssemblerBase::getCodeBuffer() {
    return buffer_;
}

void SLAssemblerBase::pseudoBind(SLAssemblerPseudoLabel *label) {
    auto pc_offset = reinterpret_cast<SLCodeBufferBase *>(buffer_)->getBufferSize();
    label->bind_to(pc_offset);
    if (label->has_confused_instructions()) {
        label->link_confused_instructions(reinterpret_cast<SLCodeBufferBase *>(buffer_));
    }
}

void SLAssemblerBase::relocBind() {
    for (auto *data_label : data_labels_) {
        reinterpret_cast<SLCodeBufferBase *>(buffer_)->emitBuffer(data_label->data_, data_label->data_size_);
    }
}

void SLAssemblerBase::appendRelocLabel(SLRelocLabel *label) {
    data_labels_.push_back(label);
}

void SLAssemblerBase::setRealizedAddress(void *address) {
    realized_addr_ = address;
}
void *SLAssemblerBase::getRealizedAddress() {
    return realized_addr_;
}

void SLAssemblerBase::flushICache(sl_addr_t start, int size) {}
void SLAssemblerBase::flushICache(sl_addr_t start, sl_addr_t end) {}
