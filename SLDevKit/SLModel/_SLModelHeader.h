//
//  SLModelHeader.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SLModelEncodingType) {
    
    // 以下为类型
    SLModelEncodingTypeMask         = 0xFF,
    SLModelEncodingTypeUnknow       = 0x00,
    SLModelEncodingTypeVoid         = 0x01,
    SLModelEncodingTypeBool         = 0x02,
    SLModelEncodingTypeInt8         = 0x03,
    SLModelEncodingTypeUInt8        = 0x04,
    SLModelEncodingTypeInt16        = 0x05,
    SLModelEncodingTypeUInt16       = 0x06,
    SLModelEncodingTypeInt32        = 0x07,
    SLModelEncodingTypeUInt32       = 0x08,
    SLModelEncodingTypeInt64        = 0x09,
    SLModelEncodingTypeUInt64       = 0x0A,
    SLModelEncodingTypeFloat        = 0x0B,
    SLModelEncodingTypeDouble       = 0x0C,
    SLModelEncodingTypeLongDouble   = 0x0D,
    SLModelEncodingTypeObject       = 0x0E,
    SLModelEncodingTypeClass        = 0x0F,
    SLModelEncodingTypeSEL          = 0x10,
    SLModelEncodingTypeBlock        = 0x11,
    SLModelEncodingTypePoint        = 0x12,
    SLModelEncodingTypeStruct       = 0x13,
    SLModelEncodingTypeUnion        = 0x14,
    SLModelEncodingTypeCString      = 0x15,
    SLModelEncodingTypeCArray       = 0x16,
    
    // 以下为属性的描述词
    SLModelEncodingTypePropertyMask         = 0xFF0000,
    SLModelEncodingTypePropertyReadOnly     = 0x010000,         //
    SLModelEncodingTypePropertyCopy         = 0x020000,         //
    SLModelEncodingTypePropertyRetain       = 0x040000,         //
    SLModelEncodingTypePropertyNonatomic    = 0x080000,         //
    SLModelEncodingTypePropertyWeak         = 0x100000,         //
    SLModelEncodingTypePropertyCustomSetter = 0x200000,         //
    SLModelEncodingTypePropertyCustomGetter = 0x400000,         //
    SLModelEncodingTypePropertyDynamic      = 0x800000,         //
};

typedef NS_ENUM(NSUInteger, SLModelEncodingNSType) {
    SLModelEncodingNSTypeUnknow = 0,
    SLModelEncodingNSTypeNSString,
    SLModelEncodingNSTypeNSMutableString,
    SLModelEncodingNSTypeNSValue,
    SLModelEncodingNSTypeNSNumber,
    SLModelEncodingNSTypeNSDecimalNumber,
    SLModelEncodingNSTypeNSData,
    SLModelEncodingNSTypeNSMutableData,
    SLModelEncodingNSTypeNSDate,
    SLModelEncodingNSTypeNSURL,
    SLModelEncodingNSTypeNSArray,
    SLModelEncodingNSTypeNSMutableArray,
    SLModelEncodingNSTypeNSDictionary,
    SLModelEncodingNSTypeNSMutableDictionary,
    SLModelEncodingNSTypeNSSet,
    SLModelEncodingNSTypeNSMutableSet,
};

SLModelEncodingType _sl_typeEncodingGetType(const char * _Nullable typeEncoding);

SLModelEncodingNSType _sl_ClassGetNSType(Class _Nullable cls);

BOOL _sl_encodingTypeIsCNumber(SLModelEncodingType type);

typedef struct {
    void * _Nullable modelMeta;
    void * _Nullable model;
    void * _Nullable dictionary;
} SLModelSetContext;

@protocol SLModel <NSObject>

/**
 * 当属性为容器（NSArray、NSDictionary、NSSet）时，需通过重写该方法，返回容器对应的数据类型
 * 映射关系为：{"属性名":数据类}
 * key为属性值，value为类对象或者字符串
 *
 *eg. 在类`Person`中有如下容器属性：
 *      @property NSArray <Dog *>*dogs;
 *
 *    则需要实现`sl_modelContainerPropertyGenericClass`方法，并返回`Dog`类:
 *      + (NSDictionary <NSString *, id>*)sl_modelContainerPropertyGenericClass {
 *          return @{@"dogs": [Dog class]};
 *      }
 *
 *    或者:
 *      + (NSDictionary <NSString *, id>*)sl_modelContainerPropertyGenericClass {
 *          return @{@"dogs": @"Dog"};
 *      }
 */
+ (NSDictionary <NSString *, id>*_Nullable)sl_modelContainerPropertyGenericClass;

/**
 * map
 */
+ (nullable NSDictionary <NSString *, id> *)sl_modelCustomPropertyMapper;

- (NSDictionary *_Nullable)sl_modelCustomWillTransformFromDictionary:(NSDictionary *_Nullable)dic;
- (BOOL)sl_modelCustomTransformFromDictionary:(NSDictionary *_Nullable)dic;
- (BOOL)sl_modelCustomTransformToDictionary:(NSMutableDictionary *_Nullable)dic;
+ (nullable Class)sl_modelCustomClassForDictionary:(NSDictionary *_Nullable)dictionary;

@end

