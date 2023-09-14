//
//  _SLModelClassInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import "_SLModelClassInfo.h"
#import "SLMemoryCache.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "_SLModelClassIvarInfo.h"

@implementation _SLModelClassInfo
{
    BOOL _needUpdate;
}
#pragma mark - 初始化方法
+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    
    static SLMemoryCache *_memoryCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _memoryCache = [[SLMemoryCache alloc] init];
    });
    
    _SLModelClassInfo *classInfo = _memoryCache.objectForKey_sl(cls);
    
    if (classInfo && classInfo->_needUpdate) {
        [classInfo _update];
    }
    
    if (!classInfo) {
        classInfo = [[_SLModelClassInfo alloc] initWithClass:cls];
        _memoryCache.cacheObjectWithKey_sl(classInfo, cls);
    }
    return classInfo;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    
    return self;
}


- (void)_updateMethodInfo {
    Class cls = self.cls;
    _methodInfos = nil;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary dictionaryWithCapacity:methodCount];
        _methodInfos = methodInfos;
        for (int m = 0; m < methodCount; m++) {
            Method method = methods[m];
            _SLModelClassMethodInfo *methodInfo = [[_SLModelClassMethodInfo alloc] initWithMethod:method];
            methodInfos[methodInfo.name] = methodInfo;
        }
        free(methods);
    } else {
        _methodInfos = @{};
    }
}
- (void)_updatePropertyInfo {
    Class cls = self.cls;
    _propertyInfos = nil;
    unsigned int propertyCount = 0;
    objc_property_t *propertys = class_copyPropertyList(cls, &propertyCount);
    if (propertys) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
        _propertyInfos = propertyInfos;
        for (unsigned int p = 0; p < propertyCount; p++) {
            objc_property_t property = propertys[p];
            _SLModelClassPropertyInfo *propertyInfo = [[_SLModelClassPropertyInfo alloc] initWithProperty:property];
            if (propertyInfo.name) {
                propertyInfos[propertyInfo.name] = propertyInfo;
            }
        }
        free(propertys);
    } else {
        _propertyInfos = @{};
    }
}
- (void)_updateIvarInfo {
    Class cls = self.cls;
    _ivarInfos = nil;
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            _SLModelClassIvarInfo *ivarInfo = [[_SLModelClassIvarInfo alloc] initWithIvar:ivar];
            if (ivarInfo.name) {
                ivarInfos[ivarInfo.name] = ivarInfo;
            }
        }
        free(ivars);
    } else {
        _ivarInfos = @{};
    }
}

- (void)_update {
    [self _updateMethodInfo];
    [self _updatePropertyInfo];
    [self _updateIvarInfo];
    _needUpdate = NO;
}

@end
