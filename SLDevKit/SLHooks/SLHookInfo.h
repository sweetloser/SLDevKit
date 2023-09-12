//
//  SLHookInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SLHookInfo <NSObject>

- (id)instance;
- (NSInvocation *)originalInvocation;

@end

@interface SLHookInfo : NSObject<SLHookInfo>

@property(nonatomic,unsafe_unretained,readonly)id instance;
@property(nonatomic,strong,readonly)NSInvocation *originalInvocation;
@property(nonatomic,strong,readonly)NSArray *arguments;

- (instancetype)initWithInstance:(id)instance invocation:(NSInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
