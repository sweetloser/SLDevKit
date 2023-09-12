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

@protocol SLHookUnit <NSObject>

- (BOOL)remove;

@end

/**
 * 一个hook单元
 *
 */
@interface SLHookUnit : NSObject<SLHookUnit>

@property(nonatomic,assign,nullable)SEL selector;
@property(nonatomic,strong,nullable)id block;
@property(nonatomic,strong,nullable)NSMethodSignature *blockSignature;
@property(nonatomic,weak,nullable)id object;
@property(nonatomic,assign)SLHookOptions options;

+ (instancetype)hookUnitWithSelector:(SEL)selector object:(id)object options:(SLHookOptions)options block:(id)block error:(__strong NSError **)errror;

- (BOOL)invokeWithInfo:(id<SLHookInfo>)info;

@end

NS_ASSUME_NONNULL_END
