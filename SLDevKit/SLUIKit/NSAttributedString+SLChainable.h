//
//  NSAttributedString+SLChainable.h
//  SLDevKit
//
//  Created by sweetloser on 2022/11/11.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (SLChainable)

@end

#define AttStr(...) [NSMutableAttributedString sl_attributedStringWithSubstrings:@[__VA_ARGS__]]


/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(NSMutableAttributedString)

#define SL_ATTRISTR_PROP(D)   SL_PROP(NSMutableAttributedString, D)

@interface NSMutableAttributedString (SLChainable)

/// 设置字体。(NSFontAttributeName)
/// font 内部使用的是Font宏，因此font能且仅能接受Font能接受的参数。
SL_ATTRISTR_PROP(Object)font;

/// 设置颜色。(NSForegroundColorAttributeName)
/// color 内部使用的是Color宏，因此color能且仅能接受Color能接受的参数。
SL_ATTRISTR_PROP(Object)color;

/// 设置背景颜色。(NSBackgroundColorAttributeName)
/// bgColor 内部使用的是Color宏，因此color能且仅能接受Color能接受的参数。
SL_ATTRISTR_PROP(Object)bgColor;

/// 设置链接。(NSLinkAttributeName)
/// 用法：.link(urlString), .systemLink(url)
SL_ATTRISTR_PROP(Object)link;

/// 设置字间距。(NSKernAttributeName)
/// 用法：.kern(3)
SL_ATTRISTR_PROP(Float)kern;

/// 设置边线宽度。(NSStrokeWidthAttributeName)
/// 用法：.stroke(1.f)
SL_ATTRISTR_PROP(Float)stroke;

/// 设置字体斜度。(NSObliquenessAttributeName)
/// 正数右倾斜，负数左倾斜
/// 用法：.obliqueness(1.f) .obliqueness(-2.f)
SL_ATTRISTR_PROP(Float)obliqueness;

/// 设置文本横向拉伸。(NSExpansionAttributeName)
/// 正数横向拉伸文本，负数压缩
/// 用法：.expansion(3.f) .expansion(-3.f) 
SL_ATTRISTR_PROP(Float)expansion;

/// 设置基线偏移。(NSBaselineOffsetAttributeName)
/// 正数向上偏移，负数向下偏移
/// 用法：.baselineOffset(3.f) .baselineOffset(-3.f)
SL_ATTRISTR_PROP(Float)baselineOffset;

/// 设置行间距。(ParagraphStyle.lineSpacing)
/// 用法：.lineSpacing(10.f)
SL_ATTRISTR_PROP(Float)lineSpacing;

/// 设置下划线。(NSUnderlineStyleAttributeName)
/// 参数类型：NSUnderlineStyle枚举值
/// 用法：.underline(NSUnderlineStyleSingle)
SL_ATTRISTR_PROP(Int)underline;

/// 设置删除线。(NSStrikethroughStyleAttributeName)
/// 参数类型：NSUnderlineStyle枚举值
/// 用法：.strikethrough(NSUnderlineStyleSingle)
SL_ATTRISTR_PROP(Int)strikethrough;

/// 设置对齐方式。(ParagraphStyle.alignment)
/// 参数类型：NSTextAlignment枚举值
/// 用法：.alignment(NSTextAlignmentCenter)
SL_ATTRISTR_PROP(Int)alignment;

/// 清空所有range，设置当前range为唯一range；
/// 默认情况下，对`NSMutableAttributedString`设置的属性作用于整个字符串；
/// 指定range后，设置的属性仅作用于指定range；
/// loc为负数时，指定的范围为从尾到头；注：-1为从最尾开始；
/// 用法：.range(1,5)  范围为：a[bcdef]ghigklmn
///      .range(-2,5) 范围为：abcdefgh[igklm]n
SL_ATTRISTR_PROP(TwoInt)range;

/// 不清空所有range，在原有range集合上增加一个range；
/// 默认情况下，对`NSMutableAttributedString`设置的属性作用于整个字符串；
/// 指定range后，设置的属性仅作用于指定range；
/// loc为负数时，指定的范围为从尾到头；注：-1为从最尾开始；
/// 用法：.addRange(1,5)  范围为：a[bcdef]ghigklmn
///      .addRange(-2,5) 范围为：abcdefgh[igklm]n
SL_ATTRISTR_PROP(TwoInt)addRange;

/// 清空所有range，设置当前match的range为唯一range
/// 默认情况下，对`NSMutableAttributedString`设置的属性作用于整个字符串；
/// 指定range后，设置的属性仅作用于指定range；
/// 支持参数类型：
///         1）正则字符串
///         2）NSRegularExpression对象
/// 用法：.match(@"[0-9]+")            匹配所有数字
///      .match(regularExpression)    匹配regularExpression能匹配的字符
SL_ATTRISTR_PROP(Object)match;

/// 不清空所有range，在原有range集合上增加match匹配的range；
/// 默认情况下，对`NSMutableAttributedString`设置的属性作用于整个字符串；
/// 指定range后，设置的属性仅作用于指定range；
/// 支持参数类型：
///         1）正则字符串
///         2）NSRegularExpression对象
/// 用法：.addMatch(@"[0-9]+")            匹配所有数字
///      .addMatch(regularExpression)    匹配regularExpression能匹配的字符
SL_ATTRISTR_PROP(Object)addMatch;

/// 清除所有range；
/// 清除range后，设置的属性将作用于整个字符串；
SL_ATTRISTR_PROP(Empty)cleanRange;

/// 设置结束。且不返回self。【某些情况下，并不需要返回self，以End()结尾，可以消除 unused 警告⚠️】
/// 用法：.End();
-(void(^)(void))End;

@end

NS_ASSUME_NONNULL_END
