//
//  UIImageView+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/2/9.
//

#import "UIImageView+SLChainable.h"
#import "UIView+SLChainable.h"
#import "NSArray+SLChainable.h"
#import "UIImage+SLChainable.h"

@implementation UIImageView (SLChainable)

- (SLChainableUIImageViewObjectBlock)img {
    SL_CHAINABLE_OBJECT_BLOCK(
                              if ([value isKindOfClass:[NSArray class]]) {
                                  // 如果参数是一个数组，这设置动态图
                                  NSArray *images = ((NSArray *)value).map(^(id imageObj){
                                      return Img(imageObj);
                                  });
                                  self.animationImages = images;
                              } else {
                                  self.image = Img(value);
                              }
                              );
}

- (SLChainableUIImageViewObjectBlock)highImg {
    SL_CHAINABLE_OBJECT_BLOCK(
                              if ([value isKindOfClass:[NSArray class]]) {
                                  NSArray *images = ((NSArray *)value).map(^(id imageObj) {
                                      return Img(imageObj);
                                  });
                                  self.highlightedAnimationImages = images;
                              } else {
                                  self.highlightedImage = Img(value);
                              }
                              );
}

- (SLChainableUIImageViewIntBlock)cMode {
    SL_CHAINABLE_INT_BLOCK(self.contentMode = (UIViewContentMode)value;);
}

@end
