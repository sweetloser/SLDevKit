//
//  SLInterceptor.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/5.
//

#include "SLInterceptor.hpp"
SLInterceptor *SLInterceptor::instance = nullptr;

SLInterceptor *SLInterceptor::sharedInterceptor() {
    if (SLInterceptor::instance == nullptr) {
        SLInterceptor::instance = new SLInterceptor();
    }
    return SLInterceptor::instance;
}

SLInterceptEntry *SLInterceptor::find(sl_addr_t addr) {
    for (auto *entry : entries) {
        if (entry->patched_addr == addr) {
            return entry;
        }
    }
    return nullptr;
}

void SLInterceptor::add(SLInterceptEntry *entry) {
    entries.push_back(entry);
}

void SLInterceptor::remove(sl_addr_t addr) {
    for (auto iter = entries.begin(); iter != entries.end(); iter++) {
        if ((*iter)->patched_addr == addr) {
            entries.erase(iter);
            break;
        }
    }
}

const SLInterceptEntry *SLInterceptor::getEntry(int i) {
    return entries[i];
}

int SLInterceptor::count() {
    return (int)entries.size();
}
