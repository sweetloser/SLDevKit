//
//  SLLinkedMapNode.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLLinkedMapNode : NSObject

@property(nonatomic,strong)id key;
@property(nonatomic,strong)id value;

/// 链表结构
@property(nonatomic,weak)SLLinkedMapNode *preNode;
@property(nonatomic,weak)SLLinkedMapNode *nextNode;

@property(nonatomic,assign)NSTimeInterval time;
@property(nonatomic,assign)NSUInteger cost;

@end

NS_ASSUME_NONNULL_END
