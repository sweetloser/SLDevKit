//
//  NSObject+SLModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SLModel)

+ (nullable instancetype)sl_modelWithJson:(id)json;

+ (nullable instancetype)sl_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)sl_modelSetWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
