//
//  NSArray+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/9.
//

#import "NSArray+SLChainable.h"
#import "SLFoundationPrivate.h"
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
                    [self _sl_invokeBlock:blockInfo withValue:self[index] atIndex:index];
                }
            }
        }
        return self;
    };
}

- (NSArray * _Nonnull (^)(id _Nonnull))map {
    return ^(id block) {
        return [self _sl_invokeBlockForEachElement:block filterResult:NO];
    };
}

- (NSArray * _Nonnull (^)(id _Nonnull))filter {
    return ^(id block) {
        return [self _sl_invokeBlockForEachElement:block filterResult:YES];
    };
}
- (id  _Nonnull (^)(id _Nonnull, ...))reduce {
    return ^(id blockOrInitialValue, ...) {
        id block = nil;
        id initialValue = nil;
        id result = nil;
        
        if (SL_IS_BLOCK(blockOrInitialValue)) {
            // 第一个参数为block
            block = blockOrInitialValue;
        } else {
            // 第一个参数为累加器初始值
            initialValue = blockOrInitialValue;
            result = initialValue;
            // 第二个参数为block
            block = SL_FIRAT_VA_ARGS(blockOrInitialValue, id);
        }
        
        if (block) {
            SLBlockInfo *blockInfo = [[SLBlockInfo alloc] initWithBlock:block];
            if (blockInfo.argumentCount > 0) {
                NSInteger startIndex = 0;
                if (!result) {
                    // 没有初始值；则将第一个元素置为初始值，从第二个元素开始累加
                    result = [self _sl_safe_objectAtIndexedSubscript:0];
                    startIndex = 1;
                }
                
                for (NSInteger i = startIndex; i < self.count; ++i) {
                    result = [self _sl_invokeBlock:blockInfo withAccumulator:result value:self[i] atIndex:i];
                }
            }
        }
        
        return result;
    };
}

#pragma mark - private
- (id)_sl_invokeBlock:(SLBlockInfo *)blockInfo withValue:(id)value atIndex:(NSInteger)index {
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

- (NSArray *)_sl_invokeBlockForEachElement:(id)block filterResult:(BOOL)filter {
    if (block) {
        SLBlockInfo *blockInfo = [[SLBlockInfo alloc] initWithBlock:block];
        
        if (blockInfo.argumentCount > 0) {
            NSMutableArray *targets = [NSMutableArray arrayWithCapacity:self.count];
            
            for (NSInteger i = 0; i < self.count; ++i) {
                id result = [self _sl_invokeBlock:blockInfo withValue:self[i] atIndex:i];
                
                if (!filter) {
                    [targets addObject:result];
                } else if ([result boolValue]) {
                    [targets addObject:self[i]];
                }
            }
            
            return (NSArray *)[targets copy];
        }
    }
    return self;
}

- (id)_sl_invokeBlock:(SLBlockInfo *)blockInfo withAccumulator:(id)accumulator value:(id)value atIndex:(NSInteger)index {
    id result = nil;
    
#define INVOKE_WITH_RETURN_TYPE2(x)  \
    [blockInfo isAcceptingIntAtIndex:0]?\
    ((x (^)(long long, long long, NSInteger, id))blockInfo.block)([accumulator longLongValue], [value longLongValue], index, self):\
    [blockInfo isAcceptingFloatAtIndex:0]?\
        ((x (^)(double, double, NSInteger, id))blockInfo.block)([accumulator longLongValue], [value doubleValue], index, self):\
        ((x (^)(id, id, NSInteger, id))blockInfo.block)(accumulator, value, index, self)
    
    if (blockInfo.isReturningInt) {
        result = @(INVOKE_WITH_RETURN_TYPE2(long long));
    } else if (blockInfo.isReturningFloat) {
        result = @(INVOKE_WITH_RETURN_TYPE2(double));
    } else {
        result = INVOKE_WITH_RETURN_TYPE2(id);
    }
    
    return result;
}

@end
