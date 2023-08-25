//
//  SLCustomFieldItemModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLCustomFieldItemModel : NSObject

/// 输入值
@property(nonatomic,copy)NSString *value;
/// 提示语
@property(nonatomic,copy)NSString *hint;
/// 是否聚焦
@property(nonatomic,assign)BOOL focus;
/// 聚焦时是否显示光标
@property(nonatomic,assign)BOOL cursor;
/// 光标颜色
@property(nonatomic,strong)UIColor *cursorColor;
/// 边框宽度
@property(nonatomic,assign)CGFloat borderWidth;
/// 边框圆角
@property(nonatomic,assign)CGFloat borderRadius;

/// 边框颜色 对应三种状态【1、聚焦；2、已输入；3、未输入】
@property(nonatomic,strong)UIColor *focusBorderColor;
@property(nonatomic,strong)UIColor *enteredBorderColor;
@property(nonatomic,strong)UIColor *emptyBorderColor;

@end

NS_ASSUME_NONNULL_END
