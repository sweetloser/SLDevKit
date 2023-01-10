//
//  SLFoundationPrivate.m
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import "SLFoundationPrivate.h"

BOOL SLObjectIsKindOfClass(NSString *className, id obj) {
    return [obj isKindOfClass:NSClassFromString(className)];
}

@implementation NSObject (SLPrivate)

@end

@implementation NSString (SLPrivate)

- (NSRange)sl_fullRange {
    return NSMakeRange(0, self.length);
}

@end

@implementation NSArray (SLPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript:idx];
    }
    return nil;
}

@end
