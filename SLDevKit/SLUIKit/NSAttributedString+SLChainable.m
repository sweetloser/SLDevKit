//
//  NSAttributedString+SLChainable.m
//  SLDevKit
//
//  Created by sweetloser on 2022/11/11.
//

#import "NSAttributedString+SLChainable.h"
#import "UIFont+SLChainable.h"
#import "SLUIKitPrivate.h"
#import "SLFoundationPrivate.h"
#import "UIColor+SLChainable.h"

@implementation NSAttributedString (SLChainable)

@end

@implementation NSMutableAttributedString (SLChainable)

- (SLChainableNSMutableAttributedStringObjectBlock)fnt {
    SL_CHAINABLE_OBJECT_BLOCK([self sl_applyAttribute:NSFontAttributeName withValue:Fnt(value)]);
}

- (SLChainableNSMutableAttributedStringObjectBlock)color {
    SL_CHAINABLE_OBJECT_BLOCK([self sl_applyAttribute:NSForegroundColorAttributeName withValue:Color(value)]);
}

- (SLChainableNSMutableAttributedStringObjectBlock)bgColor {
    SL_CHAINABLE_OBJECT_BLOCK([self sl_applyAttribute:NSBackgroundColorAttributeName withValue:Color(value)]);
}

- (SLChainableNSMutableAttributedStringObjectBlock)link {
    SL_CHAINABLE_OBJECT_BLOCK([self sl_applyAttribute:NSLinkAttributeName withValue:value]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)kern {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_applyAttribute:NSKernAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)stroke {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_applyAttribute:NSStrokeWidthAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)obliqueness {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_applyAttribute:NSObliquenessAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)expansion {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_applyAttribute:NSExpansionAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)baselineOffset {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_applyAttribute:NSBaselineOffsetAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringFloatBlock)lineSpacing {
    SL_CHAINABLE_FLOAT_BLOCK([self sl_setParagraphStyleValue:@(value) forKey:@"lineSpacing"]);
}
- (SLChainableNSMutableAttributedStringIntBlock)underline {
    SL_CHAINABLE_INT_BLOCK([self sl_applyAttribute:NSUnderlineStyleAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringIntBlock)strikethrough {
    SL_CHAINABLE_INT_BLOCK([self sl_applyAttribute:NSStrikethroughStyleAttributeName withValue:@(value)]);
}

- (SLChainableNSMutableAttributedStringIntBlock)alignment {
    SL_CHAINABLE_INT_BLOCK([self sl_setParagraphStyleValue:@(value) forKey:@"alignment"]);
}

- (SLChainableNSMutableAttributedStringTwoIntBlock)range {
    SL_CHAINABLE_TWO_INT_BLOCK([self.slEffectedRanges removeAllIndexes];self.addRange(value1, value2));
}

- (SLChainableNSMutableAttributedStringTwoIntBlock)addRange {
    SL_CHAINABLE_TWO_INT_BLOCK([self.slEffectedRanges addIndexesInRange:NSMakeRange(value1, value2)]);
}

- (SLChainableNSMutableAttributedStringObjectBlock)match {
    SL_CHAINABLE_OBJECT_BLOCK(
                              [self.slEffectedRanges removeAllIndexes];self.addMatch(value));
}

- (SLChainableNSMutableAttributedStringObjectBlock)addMatch {
    SL_CHAINABLE_OBJECT_BLOCK(NSRegularExpression *exp = nil;
                              if ([value isKindOfClass:[NSRegularExpression class]]) {
                                  exp = value;
                              } else {
                                  exp = [[NSRegularExpression alloc] initWithPattern:value options:0 error:nil];
                              }
                              NSArray *matchs = [exp matchesInString:self.string options:0 range:[self.string sl_fullRange]];
                              for (NSTextCheckingResult *result in matchs) {
                                  [self.slEffectedRanges addIndexesInRange:result.range];
                              });
}

- (SLChainableNSMutableAttributedStringEmptyBlock)cleanRange {
    SL_CHAINABLE_EMPTY_BLOCK([self.slEffectedRanges removeAllIndexes]);
}

- (void (^)(void))End {
    return ^{};
}

@end
