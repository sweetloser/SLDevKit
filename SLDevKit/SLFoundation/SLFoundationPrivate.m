//
//  SLFoundationPrivate.m
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import "SLFoundationPrivate.h"
#import <objc/runtime.h>

BOOL SLObjectIsKindOfClass(NSString *className, id obj) {
    return [obj isKindOfClass:NSClassFromString(className)];
}

@implementation NSObject (SLFoundationPrivate)

+ (void)_sl_exchengeMethods:(NSArray<NSString *> *)selectorStingArr prefix:(NSString *)prefix {
    if (!prefix || [prefix isEqualToString:@""]) {
        prefix = @"sl_";
    }
    [selectorStingArr enumerateObjectsUsingBlock:^(NSString * _Nonnull origSelectorStr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newSelectorStr = [origSelectorStr stringByAppendingString:prefix];
        Method origMethod = class_getInstanceMethod(self, NSSelectorFromString(origSelectorStr));
        Method newMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorStr));
        
        const char *typeEncoding = method_getTypeEncoding(origMethod);
        
        BOOL canAddMethod = class_addMethod(self, NSSelectorFromString(newSelectorStr), method_getImplementation(newMethod), typeEncoding);
        if (canAddMethod) {
            class_replaceMethod(self, NSSelectorFromString(newSelectorStr), method_getImplementation(origMethod), typeEncoding);
        } else {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }];
}

@end

@implementation NSString (SLFoundationPrivate)

- (NSRange)sl_fullRange {
    return NSMakeRange(0, self.length);
}

@end

@implementation NSArray (SLFoundationPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript:idx];
    }
    return nil;
}

@end
