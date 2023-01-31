//
//  SLAutoLayoutModel.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/12.
//

#import "SLAutoLayoutModel.h"
#import "SLAutoLayoutModelItem.h"

@interface SLAutoLayoutModel ()

@property(nonatomic,copy)NSNumber *centerX;
@property(nonatomic,copy)NSNumber *centerY;

@end

@implementation SLAutoLayoutModel

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)leftToView {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"left"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)rightToView {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"right"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)topToView {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"top"]);
}

- (SLChainableSLAutoLayoutModelFloatObjectListBlock)bottomToView {
    SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK([self _marginToView:arguments value:value key:@"bottom"]);
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

#pragma mark - private
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
}

@end
