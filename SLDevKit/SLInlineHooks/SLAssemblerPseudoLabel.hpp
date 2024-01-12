//
//  SLAssemblerPseudoLabel.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLAssemblerPseudoLabel_hpp
#define SLAssemblerPseudoLabel_hpp

#ifdef __cplusplus
#include <stdio.h>
#include "SLCodeBufferBase.hpp"
#include "SLTypeAlias.hpp"

class SLLabel {
public:
    SLLabel(sl_addr_t addr) : pos_(addr) {}
    sl_addr_t pos() {
        return pos_;
    }
protected:
    sl_addr_t pos_;
};

class SLAssemblerPseudoLabel : public SLLabel {
public:
    typedef struct {
        int link_type;
        size_t pc_offset;
        sl_addr_t vmaddr_;
    } ref_label_insn_t;
    
public:
    SLAssemblerPseudoLabel(sl_addr_t addr) : SLLabel(addr) {
        ref_label_insns_.reserve(4);
        bind_to(addr);
    }
    
    bool has_confused_instructions() {
        return ref_label_insns_.size();
    }
    
    void link_confused_instructions();
    void link_confused_instructions(SLCodeBufferBase *buffer);
    void link_to(int link_type, uint32_t pc_offset) {
        ref_label_insn_t insn;
        insn.link_type = link_type;
        insn.pc_offset = pc_offset;
        ref_label_insns_.push_back(insn);
    }
    
public:
    sl_addr_t pos() {
        return pos_;
    }
    
    void bind_to(sl_addr_t addr) {
        pos_ = addr;
    }
    
protected:
    std::vector<ref_label_insn_t> ref_label_insns_;
};

struct SLRelocLabel : public SLAssemblerPseudoLabel {
public:
    SLRelocLabel() : SLAssemblerPseudoLabel(0) {
        memset(data_, 0, sizeof(data_));
        data_size_ = 0;
    }
    
    template <typename T> static SLRelocLabel *withData(T value) {
        auto label = new SLRelocLabel();
        label->setData(value);
        return label;
    }
    
    template <typename T> T data() {
        return *(T *)data_;
    }
    
    template <typename T> void setData(T value) {
        data_size_ = sizeof(T);
        memcpy(data_, &value, data_size_);
    }
    
    template <typename T> void fixupData(T value) {
        *(T *)data_ = value;
    }
    
    uint8_t data_[8];
    int data_size_;
};

#endif
#endif /* SLAssemblerPseudoLabel_hpp */
