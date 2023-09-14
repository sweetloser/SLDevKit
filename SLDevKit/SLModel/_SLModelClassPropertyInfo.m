//
//  _SLModelClassPropertyInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import "_SLModelClassPropertyInfo.h"
#import "_SLModelHeader.h"


@implementation _SLModelClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    SLModelEncodingType type = 0;
    unsigned int propertyAttriCount = 0;
    objc_property_attribute_t *propertyAttris = property_copyAttributeList(property, &propertyAttriCount);
    for (unsigned int i = 0; i < propertyAttriCount; i++) {
        objc_property_attribute_t attri = propertyAttris[i];
        switch (attri.name[0]) {
            case 'T': {
                // 属性的类型编码
                if (attri.value) {
                    _typeEncoding = [NSString stringWithUTF8String:attri.value];
                    type = _sl_typeEncodingGetType(attri.value);
                    if ((type & SLModelEncodingTypeMask) == SLModelEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        
                        // 只有当typeEncoding以 "@\"" 开头的，才是对象
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        // 扫描类名
                        // eg.@property id obj;             cls = nil
                        // eg.@property NSObject *obj       cls = NSObject
                        NSString *className = nil;
                        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&className]) {
                            if (className && className.length != 0) {
                                _cls = objc_getClass(className.UTF8String);
                            }
                        }
                        
                        // 扫描属性遵守的协议
                        // eg.@property id obj;                         protocols = nil;
                        // eg.@property id<UITableViewDelegate> obj     protocols = @[@"UITableViewDelegate"]
                        NSMutableArray *protocols = [NSMutableArray new];
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString *protocol = nil;
                            if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                [protocols addObject:protocol];
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols.count?protocols.copy:nil;
                    }
                }
            }
                break;
            case 'V': {
                // 属性对应的私有变量名
                if (attri.value) {
                    _ivarName = [NSString stringWithUTF8String:attri.value];
                }
            }
            case 'R': {
                type = type | SLModelEncodingTypePropertyReadOnly;
            }
                break;
            case 'C': {
                type = type | SLModelEncodingTypePropertyCopy;
            }
                break;
            case '&': {
                type = type | SLModelEncodingTypePropertyRetain;
            }
                break;
            case 'N': {
                type = type | SLModelEncodingTypePropertyNonatomic;
            }
                break;
            case 'D': {
                type = type | SLModelEncodingTypePropertyDynamic;
            }
                break;
            case 'W': {
                type = type | SLModelEncodingTypePropertyWeak;
            }
                break;
            case 'G': {
                type = type | SLModelEncodingTypePropertyCustomGetter;
                if (attri.value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attri.value]);
                }
            }
                break;
            case 'S': {
                type = type | SLModelEncodingTypePropertyCustomSetter;
                if (attri.value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attri.value]);
                }
            }
                break;
            default:
                break;
        }
    }
    if (propertyAttris) {
        free(propertyAttris);
        propertyAttris = NULL;
    }
    
    _type = type;
    
    // 根据属性名设置set方法和get方法
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            // 首字母大写
            NSString *fristChar2Up = [_name substringToIndex:1].uppercaseString;
            NSString *setterName = [NSString stringWithFormat:@"set%@%@:", fristChar2Up, [_name substringFromIndex:1]];
            _setter = NSSelectorFromString(setterName);
        }
    }
    
    return self;
}

@end
