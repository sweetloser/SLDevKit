//
//  SLAutoLayoutModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "SLAutoLayoutModel.h"
#import "SLAutoLayoutModelItem.h"
#import "SLAutoLayoutPrivate.h"
#import "UIView+SLAutoLayout.h"

// 在`UIView+SLAutoLayout.m`中实现了`fixedWidth` 和 `fixedHeight` 的getter和setter方法，这里仅需要引入即可，不需要重复实现
@interface UIView (SLAutoLayout_)

/// 设置固定宽度【设置了之后，宽度就不会在自动布局中被修改】
@property(nonatomic,copy)NSNumber *fixedWidth;

/// 设置固定高度【设置了之后，高度度就不会在自动布局中被修改】
@property(nonatomic,copy)NSNumber *fixedHeight;

@end

@interface SLAutoLayoutModel ()

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

@end

@implementation SLAutoLayoutModel

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)leftSpaceToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"left"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)rightSpaceToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"right"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)topSpaceToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"top"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)bottomSpaceToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"bottom"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)xIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"x"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)yIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"y"]);
}

- (SLChainableSLAutoLayoutModelFloatListBlock)xyIs_sl {
    SL_CHAINABLE_FLOAT_LIST_BLOCK(
                                  if (value.validCount == 1) {
                                      self.xIs_sl(value.f1).yIs_sl(value.f1);
                                  } else if (value.validCount > 1) {
                                      self.xIs_sl(value.f1).yIs_sl(value.f2);
                                  });
}

- (SLChainableSLAutoLayoutModelFloatBlock)cxIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"centerX"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)cyIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"centerY"]);
}

- (SLChainableSLAutoLayoutModelFloatListBlock)cxyIs_sl {
    SL_CHAINABLE_FLOAT_LIST_BLOCK(
                                  if (value.validCount == 1) {
                                      self.cxIs_sl(value.f1).cyIs_sl(value.f1);
                                  } else if (value.validCount > 1) {
                                      self.cxIs_sl(value.f1).cyIs_sl(value.f2);
                                  });
}

- (SLChainableSLAutoLayoutModelFloatBlock)wIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK(self.needsAutoResizeView.fixedWidth = @(value);
                             SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
                             item.value = @(value);
                             self.width = item;);
}

- (SLChainableSLAutoLayoutModelFloatBlock)hIs_sl {
    SL_CHAINABLE_FLOAT_BLOCK(self.needsAutoResizeView.fixedHeight = @(value);
                             SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
                             item.value = @(value);
                             self.height = item;);
}

- (SLChainableSLAutoLayoutModelFloatListBlock)whIs_sl {
    SL_CHAINABLE_FLOAT_LIST_BLOCK(
                                  if (value.validCount == 1) {
                                      self.wIs_sl(value.f1).hIs_sl(value.f1);
                                  } else if (value.validCount > 1) {
                                      self.wIs_sl(value.f1).hIs_sl(value.f2);
                                  });
}

- (SLChainableSLAutoLayoutModelRectBlock)xywhIs_sl {
    SL_CHAINABLE_RECT_BLOCK(
                            self.xyIs_sl(value.value.origin.x, value.value.origin.y);
                            self.whIs_sl(value.value.size.width, value.value.size.height));
}

- (SLChainableSLAutoLayoutModelObjectBlock)leftEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalLeft"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)topEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalTop"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)rightEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalRight"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)bottomEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalBottom"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)centerXEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalCenterX"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)centerYEqualToView_sl {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalCenterY"]);
}

- (SLChainableSLAutoLayoutModelEmptyBlock)widthEqualToHeight_sl {
    SL_CHAINABLE_EMPTY_BLOCK(
                             self.widthEqualHeight = [SLAutoLayoutModelItem new];
                             self.lastModelItem = self.widthEqualHeight;
                             );
}

- (SLChainableSLAutoLayoutModelEmptyBlock)heightEqualToWidth_sl {
    SL_CHAINABLE_EMPTY_BLOCK(
                             self.heightEqualWidth = [SLAutoLayoutModelItem new];
                             self.lastModelItem = self.heightEqualWidth;);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)widthRatioToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(
                                         self.ratio_width = [[SLAutoLayoutModelItem alloc] init];
                                         self.ratio_width.value = @(value);
                                         if (arguments.count == 0) {
                                             self.ratio_width.refView = self.needsAutoResizeView.superview;
                                         } else {
                                             self.ratio_width.refView = arguments.firstObject;
                                         });
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)heightRatioToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(
                                         self.ratio_height = [[SLAutoLayoutModelItem alloc] init];
                                         self.ratio_height.value = @(value);
                                         if (arguments.count == 0) {
                                             self.ratio_height.refView = self.needsAutoResizeView.superview;
                                             
                                         } else {
                                             self.ratio_height.refView = arguments.firstObject;
                                         });
}

- (SLChainableSLAutoLayoutModelFloatBlock)offset_sl {
    SL_CHAINABLE_FLOAT_BLOCK(self.lastModelItem.offset = value;);
}

- (SLChainableSLAutoLayoutModelInsetsBlock)spaceToSuperview_sl {
    SL_CHAINABLE_INSETS_BLOCK(UIView *superview = self.needsAutoResizeView.superview;
                              self.leftSpaceToView_sl(value.left, superview).rightSpaceToView_sl(value.right, superview).bottomSpaceToView_sl(value.bottom, superview).topSpaceToView_sl(value.top, superview));
}

#pragma mark - private
-(void)_frameWithValue:(CGFloat)value key:(NSString *)key {
    if ([key isEqualToString:@"x"]) {
        self.needsAutoResizeView.left_sl(value);
    } else if ([key isEqualToString:@"y"]) {
        self.needsAutoResizeView.top_sl(value);
    } else if ([key isEqualToString:@"centerX"]) {
        self.centerX = @(value);
    } else if ([key isEqualToString:@"centerY"]) {
        self.centerY = @(value);
    }
}
-(void)_marginToView:(NSArray *)views value:(CGFloat)value key:(NSString *)key {
    SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
    item.value = @(value);
    if (views.count == 0) {
        item.refView = self.needsAutoResizeView.superview;}
    else if (views.count == 1) {
        item.refView = views.firstObject;
    } else {
        item.refViewsArray = [views copy];
    }
    [self setValue:item forKey:key];
}
-(void)_equalToView:(UIView *)view key:(NSString *)key {
    SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
    item.refView = view;
    [self setValue:item forKey:key];
    self.lastModelItem = item;
}

@end
