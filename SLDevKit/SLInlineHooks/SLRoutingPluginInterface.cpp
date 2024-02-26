//
//  SLRoutingPluginInterface.cpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/2/26.
//

#include "SLRoutingPluginInterface.hpp"

std::vector<SLRoutingPluginInterface *> SLRoutingPluginManager::plugins;

SLRoutingPluginInterface * SLRoutingPluginManager::near_branch_trampoline = NULL;

void SLRoutingPluginManager::registerPlugin(const char *name, SLRoutingPluginInterface *plugin) {
    SLRoutingPluginManager::plugins.push_back(plugin);
}
