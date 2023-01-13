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
    [self setValue:@(value) forKey:key];
}

@end
