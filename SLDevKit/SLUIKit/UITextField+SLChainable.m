//
//  UITextField+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/2/10.
//

#import "UITextField+SLChainable.h"
#import "SLUIKitUtils.h"
#import "UIFont+SLChainable.h"
#import "UIColor+SLChainable.h"

@implementation UITextField (SLChainable)

- (SLChainableUITextFieldObjectBlock)str {
    SL_CHAINABLE_OBJECT_BLOCK([SLUIKitUtils _setTextWithStringObject:value forView:self]);
}
- (SLChainableUITextFieldObjectBlock)hint {
    SL_CHAINABLE_OBJECT_BLOCK(
                              if ([value isKindOfClass:[NSAttributedString class]]) {
                                  self.attributedPlaceholder = value;
                              } else {
                                  self.placeholder = value;
                              }
                              );
}

- (SLChainableUITextFieldObjectBlock)fnt {
    SL_CHAINABLE_OBJECT_BLOCK(self.font = Fnt(value));
}
- (SLChainableUITextFieldObjectBlock)tColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.textColor = Color(value));
}

- (SLChainableUITextFieldIntBlock)textAlign {
    SL_CHAINABLE_INT_BLOCK(self.textAlignment = value);
}

- (SLChainableUITextFieldIntBlock)secure {
    SL_CHAINABLE_INT_BLOCK(self.secureTextEntry = value);
}

- (SLChainableUITextFieldIntBlock)clearMode {
    SL_CHAINABLE_INT_BLOCK(self.clearButtonMode = value);
}
@end
