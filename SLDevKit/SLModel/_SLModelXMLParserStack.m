//
//  _SLModelXMLParserStack.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/22.
//

#import "_SLModelXMLParserStack.h"

@implementation _SLModelXMLParserStack
{
    NSMutableArray *_items;
}
+ (instancetype)stack {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
}

- (void)push:(id)object {
    if (object) {
        [_items insertObject:object atIndex:0];
    }
}

- (id)pop {
    id one = nil;
    if (_items.count > 0) {
        one = [_items objectAtIndex:0];
        [_items removeObjectAtIndex:0];
    }
    return one;
}

- (NSString *)description {
    return [_items description];
}


@end
