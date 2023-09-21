//
//  NSArray+SLModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SLModel)

+ (NSArray *)sl_modelArrayWithClass:(Class)cls json:(id)json;

@end

NS_ASSUME_NONNULL_END
