//
//  _SLModelClassMethodInfo.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import "_SLModelClassMethodInfo.h"

@implementation _SLModelClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    
    self = [super init];
    if (!self) return nil;
    
    _method = method;
    _imp = method_getImplementation(method);
    _selector = method_getName(method);
    const char *name = sel_getName(_selector);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    
    unsigned int argumentCount = method_getNumberOfArguments(method);
    if (argumentCount > 0) {
        NSMutableArray *argumentTypeEncodings = [NSMutableArray arrayWithCapacity:argumentCount];
        for (int a = 0; a < argumentCount; a++) {
            char *argumentType = method_copyArgumentType(method, a);
            if (argumentType) {
                NSString *type = [NSString stringWithUTF8String:argumentType];
                [argumentTypeEncodings addObject:type];
                free(argumentType);
            } else {
                [argumentTypeEncodings addObject:@""];
            }
        }
        _argumentTypeEncodings = argumentTypeEncodings;
    }
    
    return self;
}

@end
