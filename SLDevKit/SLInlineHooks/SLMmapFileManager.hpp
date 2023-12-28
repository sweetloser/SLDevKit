//
//  SLMmapFileManager.hpp
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/12/28.
//

#ifndef SLMmapFileManager_hpp
#define SLMmapFileManager_hpp
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif
class SLMmapFileManager {
    const char *file_;
    uint8_t *mmap_buffer_;
    size_t mmap_buffer_size_;
public:
    explicit SLMmapFileManager(const char *file) : file_(file), mmap_buffer_(nullptr) {
    }
    ~SLMmapFileManager() {
        if (mmap_buffer_) {
            munmap((void *)mmap_buffer_, mmap_buffer_size_);
        }
    }
    
    uint8_t *map() {
        size_t file_size = 0;
        struct stat _stat;
        int rt = stat(file_, &_stat);
        if (rt != 0) {
            return NULL;
        }
        file_size = _stat.st_size;
        
        return map_options(file_size, 0);
    }
    
    
    uint8_t *map_options(size_t _size, off_t _off) {
        if (!mmap_buffer_) {
            int fd = open(file_, O_RDONLY, 0);
            if (fd < 0) {
                return NULL;
            }
            auto mmap_buffer = (uint8_t *)mmap(0, _size, PROT_READ | PROT_WRITE, MAP_FILE | MAP_PRIVATE, fd, _off);
            
            if (mmap_buffer == MAP_FAILED) {
                return NULL;
            }
            
            close(fd);
            
            mmap_buffer_ = mmap_buffer;
            mmap_buffer_size_ = _size;
        }
        return mmap_buffer_;
    }
};

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* SLMmapFileManager_hpp */
