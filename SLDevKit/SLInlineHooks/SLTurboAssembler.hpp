//
//  SLTurboAssembler.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/30.
//

#ifndef SLTurboAssembler_hpp
#define SLTurboAssembler_hpp
#ifdef __cplusplus
#include "SLAssembler.hpp"

class SLTurboAssembler : public SLAssembler {
public:
    SLTurboAssembler(void *address) : SLAssembler(address) {
    }
    ~SLTurboAssembler() {}
    
    void callFunction() {}
public:
    
};


#endif
#endif /* SLTurboAssembler_hpp */
