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

