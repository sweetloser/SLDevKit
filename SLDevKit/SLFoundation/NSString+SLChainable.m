//
//  NSString+SLChainable.m
//  Pods-SLDevKit_Example
//
//  Created by sweetloser on 2022/11/4.
//

#import "NSString+SLChainable.h"
#import "SLFoundationPrivate.h"


NSString *SLFormatStringWithArgumentsCount(NSInteger count, ...) {
    va_list argList;
    va_start(argList, count);
    
    NSString *result;
    NSString *formatStr = va_arg(argList, id);
    
    if (count <= 1) {
        result = formatStr;
    } else {
        result = [[NSString alloc] initWithFormat:formatStr arguments:argList];
    }
    
    va_end(argList);
    
    return result;
}

NSString *SLStringFromTypeAndValue(const char *type, const void *value) {
    size_t typeLength = strlen(type);
    
    // 将value解析为指定类型数据
    #define VALUE_OF_TYPE(_t) (*(_t *)value)
    
    if (typeLength == 1) {
        // 基本数据类型 ===>  NSString
        #define CASE_TYPE_TO_STR(_ts0,_t)     case _ts0:return [@(VALUE_OF_TYPE(_t)) stringValue];
        switch (type[0]) {
            case '@': { // oc 对象
                id  object = *(__strong id*)value;
                return [object description];
            }
            CASE_TYPE_TO_STR('i', int);
            CASE_TYPE_TO_STR('l', long);
            
            CASE_TYPE_TO_STR('f', float);
            CASE_TYPE_TO_STR('d', double);
            
            CASE_TYPE_TO_STR('s', short);
            CASE_TYPE_TO_STR('B', BOOL);
            CASE_TYPE_TO_STR('q', long long);
            
            CASE_TYPE_TO_STR('I', unsigned int);
            CASE_TYPE_TO_STR('L', unsigned long);
            CASE_TYPE_TO_STR('S', unsigned short);
            CASE_TYPE_TO_STR('Q', unsigned long long);
            case 'c':// char
            case 'C':// unsigned char
                return [[NSString alloc] initWithCharacters:value length:1];
            case '*':// char *
                return [[NSString alloc] initWithUTF8String:*(char **)value];
            case ':':// SEL
                return NSStringFromSelector(*(SEL *)value);
            case '#':// Class
                return NSStringFromClass(*(Class *)value);
            default:
                break;
        }
    }
    
    #define SL_IS_TYPE_OF_(_t)      SL_IS_TYPE_OF(type, _t)
    // const char *
    if (SL_IS_TYPE_OF_(const char *)) {
        return [[NSString alloc] initWithFormat:@"%s", *(const char**)value];
    }
    
    // char数组
    if (typeLength > 1 && type[0]=='[' && type[typeLength-1]==']' && type[typeLength-2]=='c') {
        return [[NSString alloc] initWithFormat:@"%s", (char *)value];
    }
    
    #define IF_IS_TYPE_RETURN_SRE_(_t1, _t2)    if(SL_IS_TYPE_OF_(_t1)) return NSStringFrom##_t2(VALUE_OF_TYPE(_t1))
    #define IF_IS_TYPE_RETURN_SRE(t)    IF_IS_TYPE_RETURN_SRE_(t,t)
    
    // CGRect
    IF_IS_TYPE_RETURN_SRE(CGRect);
    
    // CGSize
    IF_IS_TYPE_RETURN_SRE(CGSize);
    
    // CGPoint
    IF_IS_TYPE_RETURN_SRE(CGPoint);
    
    // NSRange
    IF_IS_TYPE_RETURN_SRE_(NSRange, Range);

    // UIEdgeInsets
    IF_IS_TYPE_RETURN_SRE(UIEdgeInsets);
        
    // UIOffset
    IF_IS_TYPE_RETURN_SRE(UIOffset);

    // CGVector
    IF_IS_TYPE_RETURN_SRE(CGVector);

    // CGAffineTransform
    IF_IS_TYPE_RETURN_SRE(CGAffineTransform);

    
    return @"";
}

@implementation NSString (SLChainable)

- (SLChainableNSStringObjectBlock)a {
    SL_CHAINABLE_OBJECT_BLOCK(return[self stringByAppendingString:SLStrFromValue(value)];);
}

- (SLChainableNSStringObjectBlock)ap {
    SL_CHAINABLE_OBJECT_BLOCK(return[self stringByAppendingPathComponent:SLStrFromValue(value)]);
}

- (SLChainableNSStringUIntBlock)subFromIndex {
    SL_CHAINABLE_UINT_BLOCK(
                            NSAssert(self.length>=value, @"index value can not be greater than string length!");
                            return[self substringFromIndex:value]);
}

- (SLChainableNSStringUIntBlock)subToIndex {
    SL_CHAINABLE_UINT_BLOCK(
                            NSAssert(self.length>=value, @"index value can not be greater than string length!");
                            return [self substringToIndex:value]);
}

- (SLChainableNSStringObjectBlock)subMatch {
    return ^NSString *(id _obj) {
        NSRegularExpression *rexp = (NSRegularExpression *)_obj;
        if (![rexp isKindOfClass:NSRegularExpression.class]) {
            rexp = [[NSRegularExpression alloc] initWithPattern:_obj options:0 error:nil];
        }
        NSRange range = [rexp rangeOfFirstMatchInString:self options:0 range:[self sl_fullRange]];
        if (range.location != NSNotFound) {
            return [self substringWithRange:range];
        }
        return @"";
    };
}

- (SLChainableNSStringTwoObjectBlock)replaceStr {
    return ^NSString *(id _obj1, id _obj2) {
        NSRegularExpression *rexp = (NSRegularExpression *)_obj1;
        if (![_obj1 isKindOfClass:NSRegularExpression.class]) {
            rexp = [[NSRegularExpression alloc] initWithPattern:_obj1 options:0 error:nil];
        }
        
        return [rexp stringByReplacingMatchesInString:self options:0 range:[self sl_fullRange] withTemplate:_obj2];
    };
}

- (SLChainableNSStringEmptyBlock)inDocument {
    return ^NSString *(){
        static NSString * documentPath = nil;
        if (documentPath == nil) {
            documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        }
        return [documentPath stringByAppendingPathComponent:self];
    };
}

- (SLChainableNSStringEmptyBlock)inCaches {
    return ^NSString *() {
        static NSString *cachesPath = nil;
        if (cachesPath == nil) {
            cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        }
        return [cachesPath stringByAppendingPathComponent:self];
    };
}

- (SLChainableNSStringEmptyBlock)inTmp {
    return ^NSString*() {
        static NSString * tmpPath = nil;
        if (tmpPath == nil) {
            tmpPath = NSTemporaryDirectory();
        }
        return [tmpPath stringByAppendingPathComponent:self];
    };
}

- (SLChainableNSStringEmptyBlock)base64Encode {
    SL_CHAINABLE_EMPTY_BLOCK(NSData *_srcData = [self dataUsingEncoding:NSUTF8StringEncoding];
                             NSData *_encodeData = [_srcData _base64Encode];
                             return [[NSString alloc] initWithData:_encodeData encoding:NSUTF8StringEncoding];);
}
- (SLChainableNSStringEmptyBlock)base64Decode {
    SL_CHAINABLE_EMPTY_BLOCK(NSData *_encodeData = [self dataUsingEncoding:NSUTF8StringEncoding];
                             NSData *_decodeData = [_encodeData _base64Decode];
                             return [[NSString alloc] initWithData:_decodeData encoding:NSUTF8StringEncoding];);
}

@end
