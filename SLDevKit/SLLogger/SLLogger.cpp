//
//  SLLogger.cpp
//  Aspects
//
//  Created by 曾祥翔 on 2023/12/22.
//

#include "SLLogger.h"
#include <string.h>
#include <time.h>
#include <dlfcn.h>
#include <syslog.h>
#include <sys/socket.h>
#include <sys/fcntl.h>
#include <sys/un.h>
#include <unistd.h>
#include <errno.h>

SLLogger *SLLogger::g_logger = nullptr;

void SLLogger::logv(SLLOGLevel level, const char *fmt, va_list ap) {
    if (level < log_level) {
        return;
    }
    
    char fmt_buffer[4096] = {0};
    
    // log for tag.
    if (log_tag != nullptr) {
        snprintf(fmt_buffer + strlen(fmt_buffer), sizeof(fmt_buffer) - strlen(fmt_buffer), "%s ", log_tag);
    }
    
    if (enable_time_tag) {
        time_t now = time(NULL);
        struct tm *tm = localtime(&now);
        snprintf(fmt_buffer + strlen(fmt_buffer), sizeof(fmt_buffer) - strlen(fmt_buffer), "%04d-%02d-%02d %02d:%02d:%02d ", tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec);
    }
    
    snprintf(fmt_buffer + strlen(fmt_buffer), sizeof(fmt_buffer) - strlen(fmt_buffer), "%s\n", fmt);
    
    // sys log.
    if (enable_syslog) {
        // console log.
        vsyslog(LOG_ALERT, fmt_buffer, ap);
        
        // syslog.
        static int _logDescriptor = 0;
        if (_logDescriptor == 0) {
            _logDescriptor = socket(AF_UNIX, SOCK_DGRAM, 0);
            if (_logDescriptor != -1) {
                fcntl(_logDescriptor, F_SETFD, FD_CLOEXEC);
                struct sockaddr_un addr;
                addr.sun_family = AF_UNIX;
                strncpy(addr.sun_path, _PATH_LOG, sizeof(addr.sun_path));
                if (connect(_logDescriptor, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
                    close(_logDescriptor);
                    _logDescriptor = -1;
                    SLERROR_LOG("failed to connect to syslogd: %s", strerror(errno));
                }
            }
        }
        if (_logDescriptor > 0) {
            vdprintf(_logDescriptor, fmt_buffer, ap);
        }
    }
    
    // file log.
    if (log_file != nullptr) {
        char buffer[0x4000] = {0};
        vsnprintf(buffer, sizeof(buffer)-1, fmt_buffer, ap);
        fwrite(buffer, strlen(buffer), 1, log_file_stream);
        fflush(log_file_stream);
    }
    vprintf(fmt_buffer, ap);
}

void *sl_logger_create(const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog) {
    SLLogger *logger = new SLLogger(tag, file, level, enable_time_tag, enable_syslog);
    return logger;
}
void sl_logger_set_options(void *logger, const char *tag, const char *file, SLLOGLevel level, bool enable_time_tag, bool enable_syslog) {
    if (logger == nullptr) {
        logger = SLLogger::shared_logger();
    }
    ((SLLogger *)logger)->set_options(tag, file, level, enable_time_tag, enable_syslog);
}
void sl_logger_log_impl(void *logger, SLLOGLevel level, const char *fmt, ...) {
    if (logger == nullptr) {
        logger = SLLogger::shared_logger();
    }
    va_list ap;
    va_start(ap, fmt);
    ((SLLogger *)logger)->logv(level, fmt, ap);
    va_end(ap);
}
