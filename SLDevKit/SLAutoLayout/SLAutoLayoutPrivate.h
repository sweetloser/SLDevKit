//
//  SLAutoLayoutPrivate.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <Foundation/Foundation.h>
@class SLAutoLayoutModel;
NS_ASSUME_NONNULL_BEGIN

@interface UIView (SLAutoLayoutPrivate)

@property(nonatomic,strong)SLAutoLayoutModel *_Nullable ownLayoutModel;

@end

NS_ASSUME_NONNULL_END
