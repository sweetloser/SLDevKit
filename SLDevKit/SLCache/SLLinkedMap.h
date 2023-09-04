//
//  SLLinkedMap.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/8/23.
//

#import <Foundation/Foundation.h>
@class SLLinkedMapNode;

NS_ASSUME_NONNULL_BEGIN

@interface SLLinkedMap : NSObject

@property(nonatomic,assign)BOOL releaseAsynchronously;
@property(nonatomic,assign)BOOL releaseOnMainThread;

@property(nonatomic,assign)NSUInteger totalCount;
@property(nonatomic,assign)NSUInteger totalCost;

@property(nonatomic,strong,readonly)SLLinkedMapNode *headNode;
@property(nonatomic,strong,readonly)SLLinkedMapNode *tailNode;

/**
 * 插入一个元素到链表头
 * - Parameter node: 待插入元素
 */
- (void)insertNodeAtHead:(SLLinkedMapNode *)node;

/**
 * 将元素移动到链表头
 * - Parameter node: 待移动元素
 */
- (void)bringNodeToHead:(SLLinkedMapNode *)node;

/**
 * 将元素删除
 * - Parameter node: 待移除元素
 */
- (void)removeNode:(SLLinkedMapNode *)node;

/**
 * 移除尾元素
 * 
 * @return: 被移除的尾元素
 */
- (SLLinkedMapNode *)removeTailNode;

/**
 * 移除所有元素
 */
- (void)removeAllNodes;

/**
 * 是否缓存过指定key
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 * 获取key对应的元素
 * - Parameter key: 指定的key
 */
- (SLLinkedMapNode *)nodeForKey:(id)key;
@end

NS_ASSUME_NONNULL_END
