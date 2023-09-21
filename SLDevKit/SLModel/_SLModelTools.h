//
//  SLModelHeader.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//
#import "_SLModelEnum.h"

SLModelEncodingType _sl_typeEncodingGetType(const char * _Nullable typeEncoding);

SLModelEncodingNSType _sl_ClassGetNSType(Class _Nullable cls);

BOOL _sl_encodingTypeIsCNumber(SLModelEncodingType type);

