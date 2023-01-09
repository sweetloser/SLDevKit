//
//  NSArray+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/9.
//

#import "NSArray+SLChainable.h"
#import "SLBlockInfo.h"

@implementation NSArray (SLChainable)

- (NSArray * _Nonnull (^)(id _Nonnull))forEach {
    return ^(id object) {
        if ([object isKindOfClass:[NSString class]]) {
            // 参数为方法名
            [self makeObjectsPerformSelector:NSSelectorFromString((NSString *)object)];
        } else {
            // 参数为block对象
            SLBlockInfo *blockInfo = [[SLBlockInfo alloc] initWithBlock:object];
            if (blockInfo.argumentCount > 0) {
                for (NSInteger index = 0; index < self.count; ++index) {
                    [self sl_invokeBlock:blockInfo withValue:self[index] atIndex:index];
                }
            }
        }
        return self;
    };
}

#pragma mark - private
- (id)sl_invokeBlock:(SLBlockInfo *)blockInfo withValue:(id)value atIndex:(NSInteger)index {
    id result = nil;
    
#define INVOKE_WITH_RETURN_TYPE(x)  \
    [blockInfo isAcceptingIntAtIndex:0]?\
        ((x (^)(long long, NSInteger, id))blockInfo.block)([value longLongValue], index, self):\
        [blockInfo isAcceptingFloatAtIndex:0]?\
            ((x (^)(double, NSInteger, id))blockInfo.block)([value doubleValue], index, self):\
            ((x (^)(id, NSInteger, id))blockInfo.block)(value, index, self)
    
    if ([blockInfo isReturningInt]) {
        result = @(INVOKE_WITH_RETURN_TYPE(long long));
    } else if ([blockInfo isReturningFloat]) {
        result = @(INVOKE_WITH_RETURN_TYPE(double));
    } else {
        result = INVOKE_WITH_RETURN_TYPE(id);
    }
    return result;
}

@end
