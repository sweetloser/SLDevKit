//
//  SLFoundationPrivate.h
//  SLDevKit
//
//  Created by sweetloser on 2022/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

BOOL SLObjectIsKindOfClass(NSString *className, id obj);


@interface NSObject (SLPrivate)

@end

@interface NSString (SLPrivate)

-(NSRange)sl_fullRange;

@end

@interface NSArray(SLPrivate)

-(id)_sl_safe_objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
