//
//  SLAutoLayoutModelItem.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLAutoLayoutModelItem : NSObject

@property(nonatomic,copy)NSNumber *value;

@property(nonatomic,weak)UIView *refView;

@property(nonatomic,strong)NSArray <UIView *>*refViewsArray;

@property(nonatomic,assign)CGFloat offset;


@end

NS_ASSUME_NONNULL_END
