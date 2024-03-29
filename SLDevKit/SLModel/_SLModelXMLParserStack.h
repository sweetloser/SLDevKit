//
//  _SLModelXMLParserStack.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelXMLParserStack : NSObject

+ (instancetype)stack;

- (void)push:(id)object;
- (id)pop;

@end

NS_ASSUME_NONNULL_END
