//
//  UIImage+SLChainable.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/10.
//

#import <UIKit/UIKit.h>
#import "SLUIKitUtils.h"

NS_ASSUME_NONNULL_BEGIN

/// 快捷创建一个UIImage对象
/// 支持的参数类型：1）UIImage对象
///              2）@"图片名"
///              3）@"#图片名"  【以#为标识，创建可拉伸的图片】
///              4）Color宏支持的类型  【从指定颜色中创建一个UIImage对象】
#define Img(x)      [SLUIKitUtils _imageWithImageObject:x]

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(UIImage)

#define SL_IMG_PROP(D)   SL_PROP(UIImage, D)

@interface UIImage (SLChainable)

SL_IMG_PROP(Rect)subImg;

@end

#define subImg(...)         subImg((SLRect){__VA_ARGS__})

NS_ASSUME_NONNULL_END
