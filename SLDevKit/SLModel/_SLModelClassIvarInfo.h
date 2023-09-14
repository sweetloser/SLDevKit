//
//  _SLModelClassIvarInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "_SLModelHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface _SLModelClassIvarInfo : NSObject

@property(nonatomic,assign,readonly)Ivar ivar;
@property(nonatomic,copy,readonly)NSString *name;
/// ivar 的偏移量
@property(nonatomic,assign,readonly)ptrdiff_t offset;
@property(nonatomic,copy,readonly)NSString *typeEncoding;
@property(nonatomic,assign,readonly)SLModelEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end

NS_ASSUME_NONNULL_END
