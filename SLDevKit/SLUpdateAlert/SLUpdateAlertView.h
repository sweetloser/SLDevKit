//
//  SLUpdateAlertView.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/4/26.
//

#import <UIKit/UIKit.h>
#import "SLDefs.h"
#import "SLUIKit.h"

@class SLUpdateAlertView;

NS_ASSUME_NONNULL_BEGIN

#define SL_UPDATEALERT_PROP(D)   SL_PROP(SLUpdateAlertView, D)
SL_DEFINE_CHAINABLE_BLOCKS(SLUpdateAlertView)

#define SLUpdateAlert [SLUpdateAlertView new]

@interface SLUpdateAlertView : UIView

SL_UPDATEALERT_PROP(Object)img_sl;
SL_UPDATEALERT_PROP(TwoFloat)imgSize_sl;

/// 更新视图的左右边距
SL_UPDATEALERT_PROP(Float)margin_sl;

SL_UPDATEALERT_PROP(Object)tips_sl;
SL_UPDATEALERT_PROP(Object)version_sl;
SL_UPDATEALERT_PROP(Object)desc_sl;

SL_UPDATEALERT_PROP(Float)borderRadius_sl;

SL_UPDATEALERT_PROP(CallBack)updateOnClick_sl;

@property(nonatomic,copy)void(^show)(void);

-(void)dismissAlert;

@end

#define tips_sl(...)        tips_sl(SL_IS_ATTSTRING_ARGS(__VA_ARGS__)? SL_RETURN_OBJECT(__VA_ARGS__): Str(__VA_ARGS__))
#define version_sl(...)     version_sl(SL_IS_ATTSTRING_ARGS(__VA_ARGS__)? SL_RETURN_OBJECT(__VA_ARGS__): Str(__VA_ARGS__))
#define desc_sl(...)        desc_sl(SL_IS_ATTSTRING_ARGS(__VA_ARGS__)? SL_RETURN_OBJECT(__VA_ARGS__): Str(__VA_ARGS__))

#define updateOnClick_sl(x) updateOnClick_sl(self, ({ id __self = self; __weak typeof(self) self = __self; __self = self; x; }) )


NS_ASSUME_NONNULL_END
