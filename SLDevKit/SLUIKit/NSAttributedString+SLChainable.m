//
//  NSAttributedString+SLChainable.m
//  SLDevKit
//
//  Created by sweetloser on 2022/11/11.
//

#import "NSAttributedString+SLChainable.h"
#import "SLFoundationPrivate.h"

@implementation NSAttributedString (SLChainable)

@end

@implementation NSMutableAttributedString (SLChainable)

- (SLChainableNSMutableAttributedStringObjectBlock)font {
    SL_CHAINABLE_OBJECT_BLOCK([self sl_applyAttribute:NSFontAttributeName withValue:(UIFont *)value]);
}
@end
