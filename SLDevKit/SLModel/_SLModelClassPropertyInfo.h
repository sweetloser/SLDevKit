//
//  _SLModelClassPropertyInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "_SLModelTools.h"
#import "_SLModelEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelClassPropertyInfo : NSObject

@property(nonatomic,assign,readonly)objc_property_t property;
@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly)SLModelEncodingType type;
@property(nonatomic,copy,readonly)NSString *typeEncoding;
@property(nonatomic,copy,readonly)NSString *ivarName;
@property(nullable,nonatomic,assign,readonly)Class cls;
@property(nullable,nonatomic,strong,readonly)NSArray <NSString *>*protocols;
@property(nonatomic,assign,readonly)SEL setter;
@property(nonatomic,assign,readonly)SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

NS_ASSUME_NONNULL_END
