//
//  SLLogger.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/22.
//

#ifndef SLLogger_hpp
#define SLLogger_hpp
#include <stdio.h>
#include <stdarg.h>

#define SL_LOG_TAG NULL

// log level enum.
typedef enum {
    SL_LOG_LEVEL_DEBUG  = 0,        ///< debug
    SL_LOG_LEVEL_INFO   = 1,        ///< info
    SL_LOG_LEVEL_WARN   = 2,        ///< warn
    SL_LOG_LEVEL_ERROR  = 3,        ///< error
    SL_LOG_LEVEL_FATAL  = 4,        ///< fatal
}SLLOGLevel;

#ifdef __cplusplus
class SLLogger {
    
public:
    const char *log_tag;
    const char *log_file;
    FILE *log_file_stream;
    
    SLLOGLevel log_level;
    
    // whether log time.
    bool enable_time_tag;
    
    // whether sys log.
    bool enable_syslog;
    
    // global logger object.
    static SLLogger *g_logger;
    
    // get global logger object.
    static SLLogger *shared_logger() {
        if (g_logger == nullptr) {
            g_logger = new SLLogger();
        }
        return g_logger;
    }
    
    SLLogger() {
        log_tag = nullptr;
        log_file = nullptr;
        log_level = SL_LOG_LEVEL_DEBUG;
        enable_time_tag = false;
        enable_syslog = false;
    }
    
    SLLogger(const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog){
        set_tag(tag);
        set_file(file);
        set_level(level);
        set_enable_syslog(enable_time_tag);
        set_enable_syslog(enable_syslog);
    }
    
    void set_options(const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog) {
        if (tag) {
            set_tag(tag);
        }
        if (file) {
            set_file(file);
        }
        set_level(level);
        set_enable_time_log(enable_time_tag);
        set_enable_syslog(enable_syslog);
    }
    
    void set_tag(const char *tag) {
        log_tag = tag;
    }
    void set_file(const char *file) {
        log_file = file;
        // open the log file.
        log_file_stream = fopen(log_file, "a");
    }
    void set_level(SLLOGLevel level) {
        log_level = level;
    }
    void set_enable_time_log(bool enable_or_not) {
        enable_time_tag = enable_or_not;
    }
    void set_enable_syslog(bool enable_or_nor) {
        enable_syslog = enable_or_nor;
    }
    
    void logv(SLLOGLevel level, const char *fmt, va_list ap);
    
    void log(SLLOGLevel level, const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(level, fmt, ap);
        va_end(ap);
    }
    
    
    void debug(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(SL_LOG_LEVEL_DEBUG, fmt, ap);
        va_end(ap);
    }
    void info(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(SL_LOG_LEVEL_INFO, fmt, ap);
        va_end(ap);
    }
    void warn(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(SL_LOG_LEVEL_WARN, fmt, ap);
        va_end(ap);
    }
    void error(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(SL_LOG_LEVEL_ERROR, fmt, ap);
        va_end(ap);
    }
    void fatal(const char *fmt, ...) {
        va_list ap;
        va_start(ap, fmt);
        logv(SL_LOG_LEVEL_FATAL, fmt, ap);
        va_end(ap);
    }
};

#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef SL_LOG_FUNCTION_IMPL
#define SL_LOG_FUNCTION_IMPL sl_logger_log_impl
#endif

void *sl_logger_create(const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog);
void sl_logger_set_options(void *logger, const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog);
void sl_logger_log_impl(void *logger, SLLOGLevel level, const char *fmt, ...);

#ifdef __cplusplus
}
#endif

#define SLLOG(level, fmt, ...)                                                              \
    do {                                                                                    \
        if (SL_LOG_TAG) {                                                                   \
            SL_LOG_FUNCTION_IMPL(NULL, level, "[%s] " fmt, SL_LOG_TAG, ##__VA_ARGS__);      \
        } else {                                                                            \
            SL_LOG_FUNCTION_IMPL(NULL, level, fmt, ##__VA_ARGS__);                          \
        }                                                                                   \
    }while(0)

#define SLDEBUG_LOG(fmt, ...)                                                               \
    do {                                                                                    \
        SLLOG(SL_LOG_LEVEL_DEBUG, fmt, ##__VA_ARGS__);                                      \
    }while(0)

#define SLINFO_LOG(fmt, ...)                                                                \
    do {                                                                                    \
        SLLOG(SL_LOG_LEVEL_INFO, fmt, ##__VA_ARGS__);                                       \
    }while(0)

#define SLIWARN_LOG(fmt, ...)                                                               \
    do {                                                                                    \
        SLLOG(SL_LOG_LEVEL_WARN, fmt, ##__VA_ARGS__);                                       \
    }while(0)

#define SLERROR_LOG(fmt, ...)                                                               \
    do {                                                                                    \
        SLLOG(SL_LOG_LEVEL_ERROR, fmt, ##__VA_ARGS__);                                      \
    }while(0)

#define SLFALAT_LOG(fmt, ...)                                                               \
    do {                                                                                    \
        SLLOG(SL_LOG_LEVEL_FALAT, fmt, ##__VA_ARGS__);                                      \
    }while(0)

#endif /* SLLogger_hpp */
