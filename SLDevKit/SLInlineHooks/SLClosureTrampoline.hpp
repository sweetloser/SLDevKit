//
//  SLClosureTrampoline.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLClosureTrampoline_hpp
#define SLClosureTrampoline_hpp

#include <stdio.h>
#include <vector>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    void *address;
    int size;
    void *carry_handler;
    void *carry_data;
}SLClosureTrampolineEntry;

#ifdef __cplusplus
}
#endif

class SLClosureTrampoline {
private:
    static std::vector<SLClosureTrampolineEntry> *trampolines_;
    
public:
    static SLClosureTrampolineEntry *createClosureTrampoline(void *carry_data, void *carry_handler);
};

#endif /* SLClosureTrampoline_hpp */
