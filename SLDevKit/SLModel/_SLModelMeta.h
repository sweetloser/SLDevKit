//
//  _SLModelMeta.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/13.
//

#import <Foundation/Foundation.h>
#import "_SLModelClassInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelMeta : NSObject

@property(nonatomic,strong,readonly)_SLModelClassInfo *classInfo;

+ (instancetype)metaWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
