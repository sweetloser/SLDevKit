//
//  _SLModelMeta.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import "_SLModelMeta.h"
#import "SLMemoryCache.h"
#import "_SLModelClassPropertyMeta.h"
#import "SLHookHeader.h"

@implementation _SLModelMeta

+ (instancetype)metaWithClass:(Class)cls {
    static SLMemoryCache *memoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        memoryCache = [[SLMemoryCache alloc] init];
    });
    _SLModelMeta *modelMeta = memoryCache.objectForKey_sl(cls);
    if (!modelMeta) {
        modelMeta = [[_SLModelMeta alloc] initWithClass:cls];
        memoryCache.cacheObjectWithKey_sl(modelMeta, cls);
    }
    return modelMeta;
}

- (instancetype)initWithClass:(Class)cls {
    _classInfo = [_SLModelClassInfo classInfoWithClass:cls];
    if (!_classInfo) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    // 获取容器属性中的类
    // eg @property NSArray<Dog *>*dogs;        {"dogs": [Dog class]}
    NSDictionary *genericMapper = nil;
    if ([cls respondsToSelector:@selector(sl_modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<SLModel>)cls sl_modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary *tmp = [NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![key isKindOfClass:[NSString class]]) return;
                
                Class metaClass = object_getClass(obj);
                if (class_isMetaClass(metaClass)) {
                    tmp[key] = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmp[key] = cls;
                    }
                }
            }];
        }
    }
    
    // 获取类的所有属性信息（包括所有继承链中的属性）
    NSMutableDictionary *allPropertyMetas = [NSMutableDictionary new];
    _SLModelClassInfo *currentClassInfo = _classInfo;
    while (currentClassInfo && currentClassInfo.superCls != nil) {
        for (_SLModelClassPropertyInfo *propertyInfo in currentClassInfo.propertyInfos.allValues) {
            _SLModelClassPropertyMeta *meta = [_SLModelClassPropertyMeta metaWithClassInfo:_classInfo propertyInfo:propertyInfo generic:genericMapper[propertyInfo.name]];
            if (!meta || !meta.name) continue;
            if (!meta.getter || !meta.setter) continue;
            if (allPropertyMetas[meta.name]) continue;
            allPropertyMetas[meta.name] = meta;
        }
        currentClassInfo = currentClassInfo.superClassInfo;
    }
    
    if (allPropertyMetas.count) {
        _allPropertyMetas = allPropertyMetas.allValues.copy;
    }
    
    NSMutableDictionary *mapper = [NSMutableDictionary new];
    NSMutableArray *keyPathPropertyMetas = [NSMutableArray new];
    NSMutableArray *multiKeysPropertyMetas = [NSMutableArray new];
    if ([cls respondsToSelector:@selector(sl_modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id<SLModel>)cls sl_modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {
            _SLModelClassPropertyMeta *propertyMeta = allPropertyMetas[propertyName];
            
            if (!propertyMeta) return;
            
            [allPropertyMetas removeObjectForKey:propertyName];
            
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                // 一对一
                if (mappedToKey.length == 0) return;
                
                propertyMeta.mappedToKey = mappedToKey;
                
                // keypath
                NSArray *keyPaths = [mappedToKey componentsSeparatedByString:@"."];
                if (keyPaths.count > 1) {
                    propertyMeta.mappedToKeyPath = keyPaths;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                
                propertyMeta.next = mapper[propertyName] ? : nil;
                mapper[mappedToKey] = propertyMeta;
                
            } else if ([mappedToKey isKindOfClass:[NSArray class]]) {
                // 一对多
                NSMutableArray *mappedToKeyArray = [NSMutableArray new];
                for (NSString *oneKey in (NSArray *)mappedToKey) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0) continue;
                    
                    NSArray *keyPaths = [oneKey componentsSeparatedByString:@"."];
                    if (keyPaths.count > 1) {
                        [mappedToKeyArray addObject:keyPaths];
                    } else {
                        [mappedToKeyArray addObject:oneKey];
                    }
                    
                    if (!propertyMeta.mappedToKey) {
                        propertyMeta.mappedToKey = oneKey;
                        propertyMeta.mappedToKeyPath = keyPaths.count ? keyPaths : nil;
                    }
                }
                
                if (!propertyMeta.mappedToKey) return;
                
                propertyMeta.mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                
                propertyMeta.next = mapper[mappedToKey] ?: nil;
                mapper[mappedToKey] = propertyMeta;
            }
        }];
    }
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString *name, _SLModelClassPropertyMeta *propertyMeta, BOOL *stop) {
        propertyMeta.mappedToKey = name;
        propertyMeta.next = mapper[name] ?: nil;
        mapper[name] = propertyMeta;
    }];
    
    if (mapper.count) _mapper = mapper;
    
    if (keyPathPropertyMetas.count) _keyPathPropertyMetas = keyPathPropertyMetas;
    
    if (multiKeysPropertyMetas.count) _multiKeysPropertyMetas = multiKeysPropertyMetas;
    
    _keyMappedCount = _allPropertyMetas.count;
    _hasCustomWillTransformFromDictionary = ([cls instancesRespondToSelector:@selector(sl_modelCustomWillTransformFromDictionary:)]);
    _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(sl_modelCustomTransformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(sl_modelCustomTransformToDictionary:)]);
    _hasCustomClassFromDictionary = ([cls respondsToSelector:@selector(sl_modelCustomClassForDictionary:)]);
    
    return self;
}



@end
