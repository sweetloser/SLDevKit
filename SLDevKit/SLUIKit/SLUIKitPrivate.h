//
//  SLUIKitPrivate.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (SLUIKitPrivate)

@property (nonatomic, assign) BOOL slAddAttributeIfNotExists;
@property (nonatomic, assign) BOOL slIsJustSettingEffectedRanges;
@property (nonatomic, strong) NSMutableIndexSet *slEffectedRanges;

-(void)sl_applyAttribute:(NSString *)name withValue:(id)value;
-(void)sl_setParagraphStyleValue:(id)value forKey:(NSString *)key;
-(void)sl_setParagraphStyleValue:(id)value forKey:(NSString *)key range:(NSRange)range;
@end

@interface UIColor(SLUIKitPrivate)

-(UIColor *)_colorWithHueOffset:(CGFloat)ho saturationOffset:(CGFloat)so brightnessOffset:(CGFloat)bo;

@end

@interface UIView (SLUIKitPrivate)

@property(nonatomic,assign)UIEdgeInsets slTouchInsets;

- (void)_sl_addChild:(id)value;

@end

NS_ASSUME_NONNULL_END
