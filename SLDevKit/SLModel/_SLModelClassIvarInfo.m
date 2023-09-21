//
//  _SLModelClassIvarInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import "_SLModelClassIvarInfo.h"
#import "_SLModelTools.h"

@implementation _SLModelClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = _sl_typeEncodingGetType(typeEncoding);
    }
    return self;
}

@end
