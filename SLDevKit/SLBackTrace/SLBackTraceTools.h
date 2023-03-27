//
//  SLBackTraceTools.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/20.
//

#import <Foundation/Foundation.h>
#import "SLSymbolModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLBackTraceTools : NSObject

+(NSArray <SLSymbolModel *>*)sl_backTraceWithThread:(NSThread *)thread;

@end

NS_ASSUME_NONNULL_END
