//
//  _SLModelClassMethodInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelClassMethodInfo : NSObject

@property(nonatomic,assign,readonly)Method method;
@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly)SEL selector;
@property(nonatomic,assign,readonly)IMP imp;
@property(nonatomic,copy,readonly)NSString *typeEncoding;
@property(nonatomic,copy,readonly)NSString *returnTypeEncoding;
@property(nonatomic,strong,readonly)NSArray <NSString *>*argumentTypeEncodings;

- (instancetype)initWithMethod:(Method)method;

@end

NS_ASSUME_NONNULL_END
