//
//  SLAutoLayoutModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"
@class SLAutoLayoutModel,SLAutoLayoutModelItem;

NS_ASSUME_NONNULL_BEGIN

#define SL_LAYOUT_MODEL_PROP(D) SL_PROP(SLAutoLayoutModel, D)

SL_DEFINE_CHAINABLE_BLOCKS(SLAutoLayoutModel)

@interface SLAutoLayoutModel : NSObject

@property(nonatomic,strong)SLAutoLayoutModelItem *height;
@property(nonatomic,strong)SLAutoLayoutModelItem *width;
@property(nonatomic,strong)SLAutoLayoutModelItem *left;
@property(nonatomic,strong)SLAutoLayoutModelItem *right;
@property(nonatomic,strong)SLAutoLayoutModelItem *top;
@property(nonatomic,strong)SLAutoLayoutModelItem *bottom;

@property(nonatomic,strong) NSNumber *centerX;
@property(nonatomic,strong) NSNumber *centerY;

@property(nonatomic,strong)SLAutoLayoutModelItem *equalLeft;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalTop;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalRight;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalBottom;

@property(nonatomic,strong)SLAutoLayoutModelItem *equalCenterX;
@property(nonatomic,strong)SLAutoLayoutModelItem *equalCenterY;

@property(nonatomic,strong)SLAutoLayoutModelItem *widthEqualHeight;
@property(nonatomic,strong)SLAutoLayoutModelItem *heightEqualWidth;

@property (nonatomic, strong) SLAutoLayoutModelItem *ratio_width;
@property (nonatomic, strong) SLAutoLayoutModelItem *ratio_height;

// 用来记录offset作用于哪个item；
@property(nonatomic,strong)SLAutoLayoutModelItem *lastModelItem;


/// 需要布局的view
@property(nonatomic,weak)UIView *needsAutoResizeView;

SL_LAYOUT_MODEL_PROP(FloatObjectList)leftToView;

SL_LAYOUT_MODEL_PROP(FloatObjectList)rightToView;

SL_LAYOUT_MODEL_PROP(FloatObjectList)topToView;

SL_LAYOUT_MODEL_PROP(FloatObjectList)bottomToView;

SL_LAYOUT_MODEL_PROP(Float)xIs;

SL_LAYOUT_MODEL_PROP(Float)yIs;

SL_LAYOUT_MODEL_PROP(Float)centerXIs;

SL_LAYOUT_MODEL_PROP(Float)centerYIs;

SL_LAYOUT_MODEL_PROP(Float)widthIs;

SL_LAYOUT_MODEL_PROP(Float)heightIs;

SL_LAYOUT_MODEL_PROP(Object)leftEqualToView;

SL_LAYOUT_MODEL_PROP(Object)topEqualToView;

SL_LAYOUT_MODEL_PROP(Object)rightEqualToView;

SL_LAYOUT_MODEL_PROP(Object)bottomEqualToView;

SL_LAYOUT_MODEL_PROP(Empty)widthEqualToHeight;

SL_LAYOUT_MODEL_PROP(Empty)heightEqualToWidth;

SL_LAYOUT_MODEL_PROP(FloatObjectList)widthRatioToView;

SL_LAYOUT_MODEL_PROP(FloatObjectList)heightRatioToView;

SL_LAYOUT_MODEL_PROP(Float)offset;

@end

#define leftToView(...)         leftToView(__VA_ARGS__, nil)
#define rightToView(...)        rightToView(__VA_ARGS__, nil)
#define topToView(...)          topToView(__VA_ARGS__, nil)
#define bottomToView(...)       bottomToView(__VA_ARGS__, nil)

NS_ASSUME_NONNULL_END
