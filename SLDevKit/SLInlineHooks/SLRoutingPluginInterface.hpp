//
//  SLRoutingPluginInterface.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#ifndef SLRoutingPluginInterface_hpp
#define SLRoutingPluginInterface_hpp
#include <stdio.h>
#include "SLInterceptRouting.hpp"
#include <vector>

class SLRoutingPluginInterface {
public:
    virtual bool prepare(SLInterceptRouting *routing) = 0;
    virtual bool active(SLInterceptRouting *routing) = 0;
    virtual bool generateTrampolineBuffer(SLInterceptRouting *routing, sl_addr_t src, sl_addr_t dst) = 0;
    
private:
    char name_[256];
};

class SLRoutingPluginManager {
public:
    static void registerPlugin(const char *name, SLRoutingPluginInterface *plugin);
    
public:
    static std::vector<SLRoutingPluginInterface *> plugins;
    static SLRoutingPluginInterface *near_branch_trampoline;
};

#endif /* SLRoutingPluginInterface_hpp */
