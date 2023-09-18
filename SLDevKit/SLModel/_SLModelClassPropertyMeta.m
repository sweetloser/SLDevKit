//
//  _SLModelClassPropertyMeta.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/15.
//

#import "_SLModelClassPropertyMeta.h"

@implementation _SLModelClassPropertyMeta

+ (instancetype)metaWithClassInfo:(_SLModelClassInfo *)classInfo propertyInfo:(_SLModelClassPropertyInfo *)propertyInfo generic:(Class)generic {
    
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    _SLModelClassPropertyMeta *meta = [[_SLModelClassPropertyMeta alloc] init];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & SLModelEncodingTypeMask) == SLModelEncodingTypeObject) {
        meta->_nsType = _sl_ClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = _sl_encodingTypeIsCNumber(meta->_type);
    }
    
    if ((meta->_type & SLModelEncodingTypeMask) == SLModelEncodingTypeStruct) {
        static NSSet *structTypes = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            // 32位
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            
            // 64位
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            
            structTypes = set;
        });
        
        if ([structTypes containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    
    meta->_cls = propertyInfo.cls;
    
    if (propertyInfo.getter && [classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
        meta->_getter = propertyInfo.getter;
    }
    
    if (propertyInfo.setter && [classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
        meta->_setter = propertyInfo.setter;
    }
    
    if (meta->_setter && meta->_getter) {
        switch (meta->_type & SLModelEncodingTypeMask) {
            case SLModelEncodingTypeBool:
            case SLModelEncodingTypeInt8:
            case SLModelEncodingTypeUInt8:
            case SLModelEncodingTypeInt16:
            case SLModelEncodingTypeUInt16:
            case SLModelEncodingTypeInt32:
            case SLModelEncodingTypeUInt32:
            case SLModelEncodingTypeInt64:
            case SLModelEncodingTypeUInt64:
            case SLModelEncodingTypeFloat:
            case SLModelEncodingTypeDouble:
            case SLModelEncodingTypeObject:
            case SLModelEncodingTypeClass:
            case SLModelEncodingTypeBlock:
            case SLModelEncodingTypeStruct:
            case SLModelEncodingTypeUnion: {
                meta->_isKVCCompatible = YES;
            }
                break;
            default:
                break;
        }
    }
    return meta;
}

@end
