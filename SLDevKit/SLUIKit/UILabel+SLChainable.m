//
//  UILabel+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/1/11.
//

#import "UILabel+SLChainable.h"
#import "NSString+SLChainable.h"
#import "SLFoundationPrivate.h"
#import "SLUIKitUtils.h"
#import "UIFont+SLChainable.h"
#import "UIColor+SLChainable.h"

@implementation UILabel (SLChainable)

- (SLChainableUILabelObjectBlock)str {
    SL_CHAINABLE_OBJECT_BLOCK([SLUIKitUtils _setTextWithStringObject:value forView:self]);
}

- (SLChainableUILabelObjectBlock)fnt {
    SL_CHAINABLE_OBJECT_BLOCK(self.font = Fnt(value));
}

- (SLChainableUILabelObjectBlock)color {
    SL_CHAINABLE_OBJECT_BLOCK(self.textColor = Color(value));
}

- (SLChainableUILabelIntBlock)lines {
    SL_CHAINABLE_INT_BLOCK(self.numberOfLines = value);
}

- (SLChainableUILabelIntBlock)textAlign {
    SL_CHAINABLE_INT_BLOCK(self.textAlignment = value;);
}

@end
