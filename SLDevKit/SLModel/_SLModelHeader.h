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

SLModelEncodingType _sl_typeEncodingGetType(const char *typeEncoding);
