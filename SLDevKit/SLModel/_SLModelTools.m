//
//  SLModelTools.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import "_SLModelHeader.h"

SLModelEncodingType _sl_typeEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    
    if (!type) return SLModelEncodingTypeUnknow;
    
    size_t typeLen = strlen(type);
    if(typeLen == 0) return SLModelEncodingTypeUnknow;
    
    switch (*type) {
        case 'v': return SLModelEncodingTypeVoid;
        case 'B': return SLModelEncodingTypeBool;
        case 'c': return SLModelEncodingTypeInt8;
        case 'C': return SLModelEncodingTypeUInt8;
        case 's': return SLModelEncodingTypeInt16;
        case 'S': return SLModelEncodingTypeUInt16;
        case 'i': return SLModelEncodingTypeInt32;
        case 'I': return SLModelEncodingTypeUInt32;
        case 'l': return SLModelEncodingTypeInt32;
        case 'L': return SLModelEncodingTypeUInt32;
        case 'q': return SLModelEncodingTypeInt64;
        case 'Q': return SLModelEncodingTypeUInt64;
        case 'f': return SLModelEncodingTypeFloat;
        case 'd': return SLModelEncodingTypeDouble;
        case 'D': return SLModelEncodingTypeLongDouble;
        case '#': return SLModelEncodingTypeClass;
        case ':': return SLModelEncodingTypeSEL;
        case '*': return SLModelEncodingTypeCString;
        case '^': return SLModelEncodingTypePoint;
        case '[': return SLModelEncodingTypeCArray;
        case '(': return SLModelEncodingTypeUnion;
        case '{': return SLModelEncodingTypeStruct;
        case '@': {
            if (typeLen == 2 && *(type + 1) == '?') {
                return SLModelEncodingTypeBlock;
            } else {
                return SLModelEncodingTypeObject;
            }
        }
        default:
            break;
    }
    
    return SLModelEncodingTypeUnknow;
}

SLModelEncodingNSType _sl_ClassGetNSType(Class cls) {
    if (!cls) return SLModelEncodingNSTypeUnknow;
    
    if ([cls isKindOfClass:[NSMutableString class]]) return SLModelEncodingNSTypeNSMutableString;
    if ([cls isKindOfClass:[NSString class]]) return SLModelEncodingNSTypeNSString;
    if ([cls isKindOfClass:[NSDecimalNumber class]]) return SLModelEncodingNSTypeNSDecimalNumber;
    if ([cls isKindOfClass:[NSNumber class]]) return SLModelEncodingNSTypeNSNumber;
    if ([cls isKindOfClass:[NSValue class]]) return SLModelEncodingNSTypeNSValue;
    if ([cls isKindOfClass:[NSMutableData class]]) return SLModelEncodingNSTypeNSMutableData;
    if ([cls isKindOfClass:[NSData class]]) return SLModelEncodingNSTypeNSData;
    if ([cls isKindOfClass:[NSDate class]]) return SLModelEncodingNSTypeNSDate;
    if ([cls isKindOfClass:[NSURL class]]) return SLModelEncodingNSTypeNSURL;
    if ([cls isKindOfClass:[NSMutableArray class]]) return SLModelEncodingNSTypeNSMutableArray;
    if ([cls isKindOfClass:[NSArray class]]) return SLModelEncodingNSTypeNSArray;
    if ([cls isKindOfClass:[NSMutableDictionary class]]) return SLModelEncodingNSTypeNSMutableDictionary;
    if ([cls isKindOfClass:[NSDictionary class]]) return SLModelEncodingNSTypeNSDictionary;
    if ([cls isKindOfClass:[NSMutableSet class]]) return SLModelEncodingNSTypeNSMutableSet;
    if ([cls isKindOfClass:[NSSet class]]) return SLModelEncodingNSTypeNSSet;
    
    return SLModelEncodingNSTypeUnknow;
}

BOOL _sl_encodingTypeIsCNumber(SLModelEncodingType type) {
    switch (type & SLModelEncodingTypeMask) {
        case SLModelEncodingTypeBool:
        case SLModelEncodingTypeInt8:
        case SLModelEncodingTypeUInt8:
        case SLModelEncodingTypeInt16:
        case SLModelEncodingTypeUInt16:
        case SLModelEncodingTypeInt32:
        case SLModelEncodingTypeUInt32:
        case SLModelEncodingTypeInt64:
        case SLModelEncodingTypeFloat:
        case SLModelEncodingTypeDouble:
        case SLModelEncodingTypeLongDouble:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}
