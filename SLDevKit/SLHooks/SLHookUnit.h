//
//  SLHookUnit.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/8.
//

#import <Foundation/Foundation.h>
#import "SLHookHeader.h"

@protocol SLHookInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * 一个hook单元
 *
 */
@interface SLHookUnit : NSObject

@property(nonatomic,assign)SEL selector;
@property(nonatomic,strong)id block;
@property(nonatomic,strong)NSMethodSignature *blockSignature;
@property(nonatomic,weak)id object;
@property(nonatomic,assign)SLHookOptions options;

+ (instancetype)hookUnitWithSelector:(SEL)selector object:(id)object options:(SLHookOptions)options block:(id)block error:(__strong NSError **)errror;

- (BOOL)invokeWithInfo:(id<SLHookInfo>)info;

@end

NS_ASSUME_NONNULL_END
