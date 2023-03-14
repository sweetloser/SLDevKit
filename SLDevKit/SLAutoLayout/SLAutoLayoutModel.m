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

@interface SLAutoLayoutModel ()

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

- (SLChainableSLAutoLayoutModelFloatBlock)xIs {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"x"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)yIs {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"y"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)centerXIs {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"centerX"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)centerYIs {
    SL_CHAINABLE_FLOAT_BLOCK([self _frameWithValue:value key:@"centerY"]);
}

- (SLChainableSLAutoLayoutModelFloatBlock)widthIs {
    SL_CHAINABLE_FLOAT_BLOCK(SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
                             item.value = @(value);
                             self.width = item;);
}

- (SLChainableSLAutoLayoutModelFloatBlock)heightIs {
    SL_CHAINABLE_FLOAT_BLOCK(SLAutoLayoutModelItem *item = [SLAutoLayoutModelItem new];
                             item.value = @(value);
                             self.height = item;);
}

- (SLChainableSLAutoLayoutModelObjectBlock)leftEqualToView {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalLeft"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)topEqualToView {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalTop"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)rightEqualToView {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalRight"]);
}

- (SLChainableSLAutoLayoutModelObjectBlock)bottomEqualToView {
    SL_CHAINABLE_OBJECT_BLOCK([self _equalToView:value key:@"equalBottom"]);
}

- (SLChainableSLAutoLayoutModelEmptyBlock)widthEqualToHeight {
    SL_CHAINABLE_EMPTY_BLOCK(
                             self.widthEqualHeight = [SLAutoLayoutModelItem new];
                             self.lastModelItem = self.widthEqualHeight;
                             );
}

- (SLChainableSLAutoLayoutModelEmptyBlock)heightEqualToWidth {
    SL_CHAINABLE_EMPTY_BLOCK(
                             self.heightEqualWidth = [SLAutoLayoutModelItem new];
                             self.lastModelItem = self.heightEqualWidth;);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)widthRatioToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(NSAssert(arguments.count == 1, @"参数格式为(CGFolat, UIView)");
                                         self.ratio_width = [[SLAutoLayoutModelItem alloc] init];
                                         self.ratio_width.value = @(value);
                                         self.ratio_width.refView = arguments.firstObject;);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)heightRatioToView_sl {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(NSAssert(arguments.count == 1, @"参数格式为(CGFolat, UIView)");
                                         self.ratio_height = [[SLAutoLayoutModelItem alloc] init];
                                         self.ratio_height.value = @(value);
                                         self.ratio_height.refView = arguments.firstObject;);
}

- (SLChainableSLAutoLayoutModelFloatBlock)offset {
    SL_CHAINABLE_FLOAT_BLOCK(self.lastModelItem.offset = value;);
}

- (SLChainableSLAutoLayoutModelInsetsBlock)spaceToSuperview_sl {
    SL_CHAINABLE_INSETS_BLOCK(UIView *superview = self.needsAutoResizeView.superview;
                              NSLog(@"superview:%@",superview);
                              NSLog(@"%@",self.needsAutoResizeView);
                              NSLog(@"%@",NSStringFromUIEdgeInsets(value));
                              self.needsAutoResizeView.slLayout().leftSpaceToView_sl(value.left, superview).rightSpaceToView_sl(value.right, superview).bottomSpaceToView_sl(value.bottom, superview).topSpaceToView_sl(value.top, superview));
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
    if (views == 0) {
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
