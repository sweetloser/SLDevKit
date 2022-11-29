//
//  NSString+SLChainable.h
//  Pods-SLDevKit_Example
//
//  Created by sweetloser on 2022/11/4.
//

#import <Foundation/Foundation.h>
#import "SLDefs.h"


NS_ASSUME_NONNULL_BEGIN

/// 格式化创建字符串
/// 参数:格式化字符串以及对应参数
#define SLFormatStr(...)    ({SLFormatStringWithArgumentsCount(SL_NUMBER_OF_VA_ARGS(__VA_ARGS__), __VA_ARGS__);})

/// 从一个值中创建字符串
/// 支持:int,float,double,unsign int, 等基本数据类型
///     CGRect,CGPoint,等结构体
///     OC对象
#define SLStrFromValue(v)   ({typeof(v) _v = v;SLStringFromTypeAndValue(@encode(typeof(v)), &_v);})
#define SLStrFromValueArgs(v,...)  SLStrFromValue(v)

#define SL_IS_STRING_ARGS(x,...)   SL_IS_STRING(x)

/// 从一个值中创建字符串
/// 参数可以是:
/// 1) c 字符串
/// 2) 任意基础数据类型
/// 3) 任何OC对象
/// 4) CGRect, CGPoint, CGSize, NSRange, UIEdgeInsets等结构体
/// 5) SEL
/// 6) Class
/// 7) 格式化字符串
#define SLStr(...)      (SL_IS_STRING_ARGS(__VA_ARGS__)?SLFormatStr(__VA_ARGS__):SLStrFromValueArgs(__VA_ARGS__))


#define SL_STRING_PROP(D)   SL_PROP(NSString, D)

/// 定义对应的block类型
SL_DEFINE_CHAINABLE_BLOCKS(NSString)

@interface NSString (SLChainable)


/// 字符串拼接.  eg:str.a(@"append");    ==>str+"append"
SL_STRING_PROP(Object)a;

#define a(...) a(SLStr(__VA_ARGS__))

/// 路径拼接.   eg:str.a(@"root");      ==>str+"/root"
SL_STRING_PROP(Object)ap;

/// 获取子字符串. eg:str:@"ABCDEFG"   str.subFromIndex(3) ==> @"DEFG"
SL_STRING_PROP(UInt)subFromIndex;

/// 获取子字符串. eg:str:@"ABCDEFG"   str.subToIndex(3)   ==> @"ABC"
SL_STRING_PROP(UInt)subToIndex;

/// 获取匹配的子字符串
SL_STRING_PROP(Object)subMatch;

/// 替换字符串
/// 基于`-[NSRegularExpression stringByReplacingMatchesInString:options:range:withTemplate:]`实现
/// 
SL_STRING_PROP(TwoObject)replaceStr;

/// 将字符串转化为沙盒内document路径.
/// eg:@"x.png".inDocument() ===> ${document path}/x.png
SL_STRING_PROP(Empty)inDocument;

/// 将字符串转化为沙盒内caches路径.
/// eg:@"x.png".inCaches() ===> ${caches path}/x.png
SL_STRING_PROP(Empty)inCaches;

/// 将字符串转化为沙盒内tmp路径.
/// eg:@"x.png".inTmp() ===> ${tmp path}/x.png
SL_STRING_PROP(Empty)inTmp;


@end

/// 从格式化字符串参数列表中初始化字符串
/// - Parameter count: 参数个数
NSString *SLFormatStringWithArgumentsCount(NSInteger count, ...);

/// 从任意类型中初始化一个字符串
/// - Parameters:
///   - type: 数据的 encode
///   - value: 数据
NSString *SLStringFromTypeAndValue(const char *type, const void *value);

NS_ASSUME_NONNULL_END
