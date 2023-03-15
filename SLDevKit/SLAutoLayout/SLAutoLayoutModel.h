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


SL_LAYOUT_MODEL_PROP(FloatObjectList)leftSpaceToView_sl;

SL_LAYOUT_MODEL_PROP(FloatObjectList)rightSpaceToView_sl;

SL_LAYOUT_MODEL_PROP(FloatObjectList)topSpaceToView_sl;

SL_LAYOUT_MODEL_PROP(FloatObjectList)bottomSpaceToView_sl;

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

SL_LAYOUT_MODEL_PROP(Object)centerXEqualToView;

SL_LAYOUT_MODEL_PROP(Object)centerYEqualToView;

SL_LAYOUT_MODEL_PROP(Empty)widthEqualToHeight;

SL_LAYOUT_MODEL_PROP(Empty)heightEqualToWidth;

SL_LAYOUT_MODEL_PROP(FloatObjectList)widthRatioToView_sl;

SL_LAYOUT_MODEL_PROP(FloatObjectList)heightRatioToView_sl;

SL_LAYOUT_MODEL_PROP(Float)offset;

SL_LAYOUT_MODEL_PROP(Insets)spaceToSuperview_sl;

@end

#define leftSpaceToView_sl(...)         leftSpaceToView_sl(__VA_ARGS__, nil)
#define rightSpaceToView_sl(...)        rightSpaceToView_sl(__VA_ARGS__, nil)
#define topSpaceToView_sl(...)          topSpaceToView_sl(__VA_ARGS__, nil)
#define bottomSpaceToView_sl(...)       bottomSpaceToView_sl(__VA_ARGS__, nil)

#define widthRatioToView_sl(...)        widthRatioToView_sl(__VA_ARGS__, nil)
#define heightRatioToView_sl(...)       heightRatioToView_sl(__VA_ARGS__, nil)

#define spaceToSuperview_sl(...)        spaceToSuperview_sl(SL_NORMALIZE_INSETS(__VA_ARGS__))
NS_ASSUME_NONNULL_END
