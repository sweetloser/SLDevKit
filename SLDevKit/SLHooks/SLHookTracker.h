//
//  SLHookTracker.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLHookTracker : NSObject

@property(nonatomic,strong)Class trackedClass;
@property(nonatomic,strong)NSMutableSet *selectorNames;
@property(nonatomic,weak)SLHookTracker *parentTracker;

- (instancetype)initWithTrackedClass:(Class)trackedClass parentTracker:(SLHookTracker *)parentTracker;

@end

NS_ASSUME_NONNULL_END
