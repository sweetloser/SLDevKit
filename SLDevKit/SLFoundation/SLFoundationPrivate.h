//
//  SLFoundationPrivate.h
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

BOOL SLObjectIsKindOfClass(NSString *className, id obj);


@interface NSObject (SLFoundationPrivate)

+(void)_sl_exchengeMethods:(NSArray<NSString *> *)selectorStingArr prefix:(NSString *)prefix;

@end

@interface NSString (SLFoundationPrivate)

-(NSRange)sl_fullRange;

@end

@interface NSArray(SLFoundationPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface NSData (SLFoundationPrivate)

-(NSData *)_base64Encode;

-(NSData *)_base64Decode;

@end

NS_ASSUME_NONNULL_END
