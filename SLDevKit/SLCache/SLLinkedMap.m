//
//  SLLinkedMap.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/8/23.
//

#import "SLLinkedMap.h"
#import "SLLinkedMapNode.h"
#import <pthread.h>

@interface SLLinkedMap () {
    
    pthread_mutex_t _threadLock;

    /**
     * 缓存存储容器
     */
    CFMutableDictionaryRef _dict;
    
    /**
     * 链表头
     */
    SLLinkedMapNode *_headNode;
    
    /**
     * 链表尾
     */
    SLLinkedMapNode *_tailNode;
    
    NSInteger _totalCount;
}
@end

@implementation SLLinkedMap

#pragma mark - 生命周期
- (instancetype)init {
    self = [super init];
    if (self) {

        pthread_mutex_init(&_threadLock, NULL);

        _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _releaseAsynchronously = YES;
        _releaseOnMainThread = NO;
        _totalCount = 0;
        
    }
    return self;
}
- (void)dealloc {
    pthread_mutex_destroy(&_threadLock);
    CFRelease(_dict);
}


-(void)insertNodeAtHead:(SLLinkedMapNode *)node {
    pthread_mutex_lock(&_threadLock);
    CFDictionarySetValue(_dict, (__bridge const void *)node.key, (__bridge const void *)node);
    _totalCount++;
    if (_headNode) {
        _headNode.preNode = node;
        node.nextNode = _headNode;
        _headNode = node;
    } else {
        _headNode = node;
    }
    pthread_mutex_unlock(&_threadLock);
}

- (void)bringNodeToHead:(SLLinkedMapNode *)node {
    if (_headNode == node) {
        // 当前元素已经处于链表头
        return;
    }
    if (_tailNode == node) {
        pthread_mutex_lock(&_threadLock);
        // 当前元素处于链表尾
        node.preNode.nextNode = nil;
        // 重置链表尾指针
        _tailNode = node.preNode;
        
        node.preNode = nil;
        node.nextNode = _headNode;
        _headNode.preNode = node;
        
        _headNode = node;
        pthread_mutex_unlock(&_threadLock);
        return;
    }
    
    pthread_mutex_lock(&_threadLock);
    // 当前元素处于链表中
    node.preNode.nextNode = node.nextNode;
    node.nextNode.preNode = node.preNode;
    
    node.nextNode = _headNode;
    _headNode.preNode = node;
    node.preNode = nil;
    
    _headNode = node;
    pthread_mutex_unlock(&_threadLock);
}

- (void)removeNode:(SLLinkedMapNode *)node {
    
    pthread_mutex_lock(&_threadLock);

    CFDictionaryRemoveValue(_dict, (__bridge const void *)node.key);
    if (node.nextNode) {
        node.nextNode.preNode = node.preNode;
    }
    if (node.preNode) {
        node.preNode.nextNode = node.nextNode;
    }
    
    if (node == _headNode) {
        _headNode = node.nextNode;
    }
    if (node == _tailNode) {
        _tailNode = node.preNode;
    }
    pthread_mutex_unlock(&_threadLock);
}

- (SLLinkedMapNode *)removeTailNode {
    if (!_tailNode) {
        return nil;
    }
    pthread_mutex_lock(&_threadLock);
    _totalCount--;
    SLLinkedMapNode *tailNode = _tailNode;
    CFDictionaryRemoveValue(_dict, (__bridge const void *)_tailNode.key);
    
    if (_tailNode == _headNode) {
        _tailNode = nil;
        _headNode = nil;
    } else {
        _tailNode = _tailNode.preNode;
        _tailNode.nextNode = nil;
    }
    pthread_mutex_unlock(&_threadLock);
    return tailNode;
}

- (void)removeAllNodes {
    pthread_mutex_lock(&_threadLock);
    _headNode = nil;
    _tailNode = nil;
    _totalCount = 0;
    CFMutableDictionaryRef dict = _dict;
    _dict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    pthread_mutex_unlock(&_threadLock);
    
    // 释放内存
    if (_releaseAsynchronously) {
        dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(queue, ^{
            CFRelease(dict);
        });
    } else if (_releaseOnMainThread && !pthread_main_np()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRelease(dict);
        });
    } else {
        CFRelease(dict);
    }
}

- (BOOL)containsObjectForKey:(id)key {
    if (!key) {
        return NO;
    }
    pthread_mutex_lock(&_threadLock);
    BOOL contains = CFDictionaryContainsKey(_dict, (__bridge const void *)key);
    pthread_mutex_unlock(&_threadLock);
    return contains;
}

- (SLLinkedMapNode *)nodeForKey:(id)key {
    if (!key) {
        return nil;
    }
    pthread_mutex_lock(&_threadLock);
    SLLinkedMapNode *node = CFDictionaryGetValue(_dict, (__bridge const void *)key);
    pthread_mutex_unlock(&_threadLock);
    return node;
    
}

#pragma mark - getter
- (SLLinkedMapNode *)headNode {
    return _headNode;
}
- (SLLinkedMapNode *)tailNode {
    return _tailNode;
}

@end
