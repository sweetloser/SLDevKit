//
//  SLCheckLogging.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2024/1/8.
//

#ifndef SLCheckLogging_hpp
#define SLCheckLogging_hpp

#include "SLLogger.h"

#define CHECK_WITH_MSG(condition, message)          \
do {                                                \
    if (!(condition)) {                             \
        SLFALAL_LOG("check failed: %s.", message);  \
    }                                               \
} while(0)

#define CHECK(condition)    CHECK_WITH_MSG(condition, #condition)


#define CHECK_OP(name, op, lhs, rhs)                    \
do {                                                    \
    bool _cond = lhs op rhs;                            \
    CHECK_WITH_MSG(_cond, #lhs " " #op " " #rhs "\n");  \
} while (0)

#define CHECK_EQ(lhs, rhs) CHECK_OP(EQ, ==, lhs, rhs)
#define CHECK_NE(lhs, rhs) CHECK_OP(NE, !=, lhs, rhs)
#define CHECK_LE(lhs, rhs) CHECK_OP(LE, <=, lhs, rhs)
#define CHECK_LT(lhs, rhs) CHECK_OP(LT, <, lhs, rhs)
#define CHECK_GE(lhs, rhs) CHECK_OP(GE, >=, lhs, rhs)
#define CHECK_GT(lhs, rhs) CHECK_OP(GT, >, lhs, rhs)
#define CHECK_NULL(val) CHECK((val) == NULL)
#define CHECK_NOT_NULL(val) CHECK((val) != NULL)

#endif /* SLCheckLogging_hpp */
