//
//  UIImage+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/10.
//

#import "UIImage+SLChainable.h"
#import "SLDefs.h"

@implementation UIImage (SLChainable)

- (SLChainableUIImageRectBlock)subImg {
    SL_CHAINABLE_RECT_BLOCK(
                            CGRect rect = value.value;
                            rect.origin.x *= self.scale;
                            rect.origin.y *= self.scale;
                            rect.size.width *= self.scale;
                            rect.size.height *= self.scale;
                            
                            CGImageRef ref = CGImageCreateWithImageInRect(self.CGImage, rect);
                            UIImage *image =  [UIImage imageWithCGImage:ref scale:self.scale orientation:self.imageOrientation];
                            CGImageRelease(ref);
                            return image;);
}

@end
