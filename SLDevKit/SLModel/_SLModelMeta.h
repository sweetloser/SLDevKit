//
//  _SLModelMeta.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import <Foundation/Foundation.h>
#import "_SLModelClassInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelMeta : NSObject

@property(nonatomic,strong,readonly)_SLModelClassInfo *classInfo;
@property(nonatomic,strong,readonly)NSArray *allPropertyMetas;
@property(nonatomic,strong,readonly)NSDictionary *mapper;
@property(nonatomic,strong,readonly)NSArray *keyPathPropertyMetas;
@property(nonatomic,strong,readonly)NSArray *multiKeysPropertyMetas;
@property(nonatomic,assign,readonly)NSUInteger keyMappedCount;
@property(nonatomic,assign,readonly)SLModelEncodingNSType nsType;

@property(nonatomic,assign,readonly)BOOL hasCustomWillTransformFromDictionary;
@property(nonatomic,assign,readonly)BOOL hasCustomTransformFromDictionary;
@property(nonatomic,assign,readonly)BOOL hasCustomTransformToDictionary;
@property(nonatomic,assign,readonly)BOOL hasCustomClassFromDictionary;

+ (instancetype)metaWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
