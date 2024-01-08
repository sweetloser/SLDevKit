//
//  SLClosureTrampoline.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLClosureTrampoline_hpp
#define SLClosureTrampoline_hpp

#include <stdio.h>
#ifdef __cplusplus
#include <vector>

typedef struct {
    void *adress;
    int size;
    void *carry_handler;
    void *carry_data;
}SLClosureTrampolineEntry;

class SLClosureTrampoline {
private:
    static std::vector<SLClosureTrampolineEntry> *trampolines_;
    
public:
    static SLClosureTrampolineEntry *createClosureTrampoline(void *carry_data, void *carry_handler);
};

#endif

#endif /* SLClosureTrampoline_hpp */
