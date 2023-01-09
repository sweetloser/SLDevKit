//
//  SLBlockInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLBlockInfo : NSObject

@property(nonatomic,readonly,strong)id block;

@property(nonatomic,readonly,strong)NSMethodSignature *signature;

@property(nonatomic,readonly,assign)NSInteger argumentCount;

@property(nonatomic,readonly,assign)const char *returnType;

@property(nonatomic,readonly,assign)BOOL isReturningInt;
@property(nonatomic,readonly,assign)BOOL isReturningFloat;
@property(nonatomic,readonly,assign)BOOL isReturningObject;

-(instancetype)initWithBlock:(id)block;

- (BOOL)isAcceptingIntAtIndex:(NSInteger)index;
- (BOOL)isAcceptingFloatAtIndex:(NSInteger)index;
- (BOOL)isAcceptingObjectAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
