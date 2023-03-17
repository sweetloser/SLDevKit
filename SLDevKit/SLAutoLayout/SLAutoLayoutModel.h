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

/// 自动布局 - 设置左侧和另一个视图的右侧的间距
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认是设置相对父视图左侧边距；【前提是已经添加了父视图】
/// 用法：view.slLayout().leftSpaceToView_sl(10)
///      view1.slLayout().leftSpaceToView_sl(10, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)leftSpaceToView_sl;

/// 自动布局 - 设置右侧和另一个视图的左侧的间距
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认是设置相对父视图右侧边距；【前提是已经添加了父视图】
/// 用法：view.slLayout().rightSpaceToView_sl(10)
///      view1.slLayout().rightSpaceToView_sl(10, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)rightSpaceToView_sl;

/// 自动布局 - 设置上侧和另一个视图的下侧的间距
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认是设置相对父视图上侧边距；【前提是已经添加了父视图】
/// 用法：view.slLayout().topSpaceToView_sl(10)
///      view1.slLayout().topSpaceToView_sl(10, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)topSpaceToView_sl;

/// 自动布局 - 设置下侧和另一个视图的上侧的间距
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认是设置相对父视图下侧边距；【前提是已经添加了父视图】
/// 用法：view.slLayout().leftSpaceToView_sl(10)
///      view1.slLayout().leftSpaceToView_sl(10, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)bottomSpaceToView_sl;

/// 设置视图的x值
/// 参数列表【float】
/// 用法：view.slLayout().xIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)xIs_sl;

/// 设置视图的y值
/// 参数列表【float】
/// 用法：view.slLayout().yIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)yIs_sl;

/// 设置视图的x值和y值
/// 参数列表【float,...】
/// 用法：view.slLayout().xyIs_sl(100)             {100, 100}
///      view.slLayout().xyIs_sl(100, 200)        {100, 200}
SL_LAYOUT_MODEL_PROP(FloatList)xyIs_sl;

/// 设置视图center的x值
/// 参数列表【float】
/// 用法：view.slLayout().cxIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)cxIs_sl;

/// 设置视图center的y值
/// 参数列表【float】
/// 用法：view.slLayout().cyIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)cyIs_sl;

/// 设置视图center的x值和y值
/// 参数列表【float,...】
/// 用法：view.slLayout().cxyIs_sl(100)             {100, 100}
///      view.slLayout().cxyIs_sl(100, 200)        {100, 200}
SL_LAYOUT_MODEL_PROP(FloatList)cxyIs_sl;

/// 设置视图的width值
/// 参数列表【float】
/// 用法：view.slLayout().wIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)wIs_sl;

/// 设置视图的height值
/// 参数列表【float】
/// 用法：view.slLayout().hIs_sl(100)
SL_LAYOUT_MODEL_PROP(Float)hIs_sl;

/// 设置视图的width值和height值
/// 参数列表【float,...】
/// 用法：view.slLayout().whIs_sl(100)             {100, 100}
///      view.slLayout().whIs_sl(100, 200)        {100, 200}
SL_LAYOUT_MODEL_PROP(FloatList)whIs_sl;

/// 设置视图的x值、y值、width值和height值
/// 参数列表【float,...】
/// 用法：view.slLayout().xywhIs_sl(100)                         {100, 0, 0, 0}
///      view.slLayout().whIs_sl(100, 200)                      {100, 200, 0, 0}
///      view.slLayout().whIs_sl(100, 200, 300)                 {100, 200, 300, 0}
///      view.slLayout().whIs_sl(100, 200, 300, 400)            {100, 200, 300, 400}
SL_LAYOUT_MODEL_PROP(Rect)xywhIs_sl;

/// 自动布局 - 设置左侧和另一个视图的左侧对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().leftSpaceToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)leftEqualToView_sl;

/// 自动布局 - 设置上侧和另一个视图的上侧对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().topEqualToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)topEqualToView_sl;

/// 自动布局 - 设置右侧和另一个视图的右侧对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().rightEqualToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)rightEqualToView_sl;

/// 自动布局 - 设置下侧和另一个视图的下侧对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().bottomEqualToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)bottomEqualToView_sl;

/// 自动布局 - 设置centerX和另一个视图的centerX对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().centerXEqualToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)centerXEqualToView_sl;

/// 自动布局 - 设置centerY和另一个视图的centerY对齐
/// 参数列表【view】
/// 参数为必选参数
/// 用法：view1.slLayout().centerYEqualToView_sl(view2)
SL_LAYOUT_MODEL_PROP(Object)centerYEqualToView_sl;

/// 自动布局 - 设置视图的宽度和自己的高度一样
/// 参数列表：无参数
/// 用法：view1.slLayout().widthEqualToHeight_sl()
SL_LAYOUT_MODEL_PROP(Empty)widthEqualToHeight_sl;

/// 自动布局 - 设置视图的高度和自己的宽度一样
/// 参数列表：无参数
/// 用法：view1.slLayout().heightEqualToWidth_sl()
SL_LAYOUT_MODEL_PROP(Empty)heightEqualToWidth_sl;

/// 自动布局 - 设置视图的宽度和另一个视图的宽度成一个比例
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认设置相对父视图；【前提是已经添加了父视图】
/// 用法：view1.slLayout().widthRatioToView_sl(0.8, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)widthRatioToView_sl;

/// 自动布局 - 设置视图的高度和另一个视图的高度成一个比例
/// 参数列表【float，view[可选]】
/// 第一个参数为必选参数，第二个为可选参数
/// 当第二个参数不传时，默认设置相对父视图；【前提是已经添加了父视图】
/// 用法：view1.slLayout().heightRatioToView_sl(0.8, view2)
SL_LAYOUT_MODEL_PROP(FloatObjectList)heightRatioToView_sl;

/// 紧跟equal...(...)方法后面，设置偏移
/// 参数列表【float】
/// 用法：view.slLayout().leftEqualToView_sl(view2).offset_sl(25)
SL_LAYOUT_MODEL_PROP(Float)offset_sl;

/// 设置相对于父视图的padding
/// 参数列表【float,...】
/// 用法：view.slLayout().spaceToSuperview_sl(10)                       {10, 10, 10, 10}
///      view.slLayout().spaceToSuperview_sl(10, 20)                   {10, 20, 10, 20}
///      view.slLayout().spaceToSuperview_sl(10, 20, 30)               {10, 20, 30, 20}
///      view.slLayout().spaceToSuperview_sl(10, 20, 30, 40)           {10, 20, 30, 40}
SL_LAYOUT_MODEL_PROP(Insets)spaceToSuperview_sl;

@end

#define xyIs_sl(...)                    xyIs_sl(SL_MAKE_FLOAT_LIST(__VA_ARGS__))

#define whIs_sl(...)                    whIs_sl(SL_MAKE_FLOAT_LIST(__VA_ARGS__))

#define centerXYIs_sl(...)              centerXYIs_sl(SL_MAKE_FLOAT_LIST(__VA_ARGS__))

#define xywhIs_sl(...)                  xywhIs_sl((SLRect){__VA_ARGS__})

#define leftSpaceToView_sl(...)         leftSpaceToView_sl(__VA_ARGS__, nil)
#define rightSpaceToView_sl(...)        rightSpaceToView_sl(__VA_ARGS__, nil)
#define topSpaceToView_sl(...)          topSpaceToView_sl(__VA_ARGS__, nil)
#define bottomSpaceToView_sl(...)       bottomSpaceToView_sl(__VA_ARGS__, nil)

#define widthRatioToView_sl(...)        widthRatioToView_sl(__VA_ARGS__, nil)
#define heightRatioToView_sl(...)       heightRatioToView_sl(__VA_ARGS__, nil)

#define spaceToSuperview_sl(...)        spaceToSuperview_sl(SL_NORMALIZE_INSETS(__VA_ARGS__))
NS_ASSUME_NONNULL_END
