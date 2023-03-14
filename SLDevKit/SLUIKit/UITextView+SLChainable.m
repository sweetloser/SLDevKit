//
//  UITextView+SLChainable.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/14.
//

#import "UITextView+SLChainable.h"
#import "SLUIKitUtils.h"
#import "UIFont+SLChainable.h"
#import "UIColor+SLChainable.h"

@implementation UITextView (SLChainable)

- (SLChainableUITextViewObjectBlock)str {
    SL_CHAINABLE_OBJECT_BLOCK([SLUIKitUtils _setTextWithStringObject:value forView:self]);
}

- (SLChainableUITextViewObjectBlock)fnt {
    SL_CHAINABLE_OBJECT_BLOCK(self.font = Fnt(value));
}

- (SLChainableUITextViewObjectBlock)tColor {
    SL_CHAINABLE_OBJECT_BLOCK(self.textColor = Color(value));
}

- (SLChainableUITextViewIntBlock)textAlign {
    SL_CHAINABLE_INT_BLOCK(self.textAlignment = value);
}

- (SLChainableUITextViewInsetsBlock)insets {
    SL_CHAINABLE_INSETS_BLOCK(self.textContainer.lineFragmentPadding = 0;
                              self.textContainerInset = value;);
}

- (SLChainableUITextViewIntBlock)editable_sl {
    SL_CHAINABLE_INT_BLOCK(self.editable = value;);
}

- (SLChainableUITextViewIntBlock)scrollable_sl {
    SL_CHAINABLE_INT_BLOCK(self.scrollEnabled = value);
}

- (SLChainableUITextViewObjectBlock)delegate_sl {
    SL_CHAINABLE_OBJECT_BLOCK(self.delegate = value);
}

- (SLChainableUITextViewIntBlock)showHIndicator {
    SL_CHAINABLE_INT_BLOCK(self.showsHorizontalScrollIndicator = value);
}

- (SLChainableUITextViewIntBlock)showVIndicator {
    SL_CHAINABLE_INT_BLOCK(self.showsVerticalScrollIndicator = value);
}

@end
