//
//  _SLModelClassPropertyMeta.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "_SLModelClassInfo.h"
#import "_SLModelClassPropertyInfo.h"
#import "_SLModelTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelClassPropertyMeta : NSObject

@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly)SLModelEncodingType type;
@property(nonatomic,assign,readonly)SLModelEncodingNSType nsType;
@property(nonatomic,assign,readonly)BOOL isCNumber;
@property(nonatomic,assign,readonly)Class cls;
@property(nonatomic,assign,readonly)Class genericCls;
@property(nonatomic,assign,readonly)SEL getter;
@property(nonatomic,assign,readonly)SEL setter;
@property(nonatomic,assign,readonly)BOOL isKVCCompatible;
@property(nonatomic,assign,readonly)BOOL isStructAvailableForKeyedArchiver;
@property(nonatomic,assign,readonly)BOOL hasCustomClassFromDictionary;

@property(nonatomic,copy,/*readonly*/)NSString *mappedToKey;
@property(nonatomic,strong,/*readonly*/)NSArray *mappedToKeyPath;
@property(nonatomic,strong,/*readonly*/)NSArray *mappedToKeyArray;

@property(nonatomic,strong,readonly)_SLModelClassPropertyInfo *info;
@property(nonatomic,strong,/*readonly*/)_SLModelClassPropertyMeta *next;


+ (instancetype)metaWithClassInfo:(_SLModelClassInfo *)classInfo propertyInfo:(_SLModelClassPropertyInfo *)propertyInfo generic:(Class)generic;

@end

NS_ASSUME_NONNULL_END
