//
//  _SLModelEnum.h
//  Pods
//
//  Created by zengxiangxiang on 2023/9/21.
//

#ifndef _SLModelEnum_h
#define _SLModelEnum_h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SLModelEncodingType) {
    
    // 以下为类型
    SLModelEncodingTypeMask                 = 0x0000FF,
    SLModelEncodingTypeUnknow               = 0x000000,
    SLModelEncodingTypeVoid                 = 0x000001,
    SLModelEncodingTypeBool                 = 0x000002,
    SLModelEncodingTypeInt8                 = 0x000003,
    SLModelEncodingTypeUInt8                = 0x000004,
    SLModelEncodingTypeInt16                = 0x000005,
    SLModelEncodingTypeUInt16               = 0x000006,
    SLModelEncodingTypeInt32                = 0x000007,
    SLModelEncodingTypeUInt32               = 0x000008,
    SLModelEncodingTypeInt64                = 0x000009,
    SLModelEncodingTypeUInt64               = 0x00000A,
    SLModelEncodingTypeFloat                = 0x00000B,
    SLModelEncodingTypeDouble               = 0x00000C,
    SLModelEncodingTypeLongDouble           = 0x00000D,
    SLModelEncodingTypeObject               = 0x00000E,
    SLModelEncodingTypeClass                = 0x00000F,
    SLModelEncodingTypeSEL                  = 0x000010,
    SLModelEncodingTypeBlock                = 0x000011,
    SLModelEncodingTypePoint                = 0x000012,
    SLModelEncodingTypeStruct               = 0x000013,
    SLModelEncodingTypeUnion                = 0x000014,
    SLModelEncodingTypeCString              = 0x000015,
    SLModelEncodingTypeCArray               = 0x000016,
    
    // 以下为属性的描述词
    SLModelEncodingTypePropertyMask         = 0xFF0000,
    SLModelEncodingTypePropertyReadOnly     = 0x010000,         // readonly
    SLModelEncodingTypePropertyCopy         = 0x020000,         // copy
    SLModelEncodingTypePropertyRetain       = 0x040000,         // strong
    SLModelEncodingTypePropertyNonatomic    = 0x080000,         // nonatimic
    SLModelEncodingTypePropertyWeak         = 0x100000,         // weak
    SLModelEncodingTypePropertyCustomSetter = 0x200000,         // setter=
    SLModelEncodingTypePropertyCustomGetter = 0x400000,         // getter=
    SLModelEncodingTypePropertyDynamic      = 0x800000,         // @dynamic
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

#endif /* _SLModelEnum_h */
