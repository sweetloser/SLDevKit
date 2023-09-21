//
//  NSDictionary+SLModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (SLModel)

+ (NSDictionary *)sl_modelDictionaryWithClass:(Class)cls json:(id)json;

@end

NS_ASSUME_NONNULL_END
