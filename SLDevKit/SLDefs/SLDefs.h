//
//  SLDefs.h
//  Pods
//
//  Created by sweetloser on 2022/11/4.
//

#ifndef SLDefs_h
#define SLDefs_h
#import <objc/objc.h>
#import <objc/runtime.h>

#pragma mark - typedef
typedef struct SLEdgeInsets {
    UIEdgeInsets value;
} SLEdgeInsets;

typedef struct SLRect {
    CGRect value;
} SLRect;

typedef struct SLFloatList {
    CGFloat f1, f2, f3, f4, f5, f6, f7, f8, f9, f10;
    CGFloat validCount;
} SLFloatList;

typedef void(^SLObjectBlock)(id);

#define Exp(x)              ({x;})

#pragma mark - 将float参数列表转化为SLFloatList结构体类型
/**
 {
    SLFloatList _floatList = (SLFloatList){__VA_ARGS__};
    // 设置 validCount 最多可以传10个参数
    _floatList.validCount = MIN(10, SL_NUMBER_OF_VA_ARGS(__VA_ARGS__));
    // 返回 _floatList
    _floatList;
 }
 */
#define SL_MAKE_FLOAT_LIST(...)     ({SLFloatList _floatList = (SLFloatList){__VA_ARGS__};  \
_floatList.validCount = MIN(10,SL_NUMBER_OF_VA_ARGS(__VA_ARGS__));    \
_floatList;})

#define SL_NORMALIZE_INSETS(...)       SLConvertSLEdgeInsetsToUIEdgeInsets((SLEdgeInsets){__VA_ARGS__}, SL_NUMBER_OF_VA_ARGS(__VA_ARGS__))


#pragma mark - 获取可变参数列表中【参数都为id类型】的参数，存储在数组(arguments)中
#define SL_GET_VARIABLE_OBJECT_ARGUMENTS(start) \
NSMutableArray *arguments = [NSMutableArray array];\
va_list argList;\
va_start(argList, start);\
id argument = 0;\
while ((argument = va_arg(argList, id))) {\
    [arguments addObject:argument];\
}\
va_end(argList);

#pragma mark - 获取变参的参数个数
// eg:SL_NUMBER_OF_VA_ARGS(a,b,c,d,e,f) ===> 6
//  SL_NUMBER_OF_VA_ARGS(a,b,c,d,e,f)  宏展开为:SL_NUMBER_OF_VA_ARGS_(a,b,c,d,e,f,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)    // 原参数后又加了64个参数
// 进一步展开为:SL_ARG_N(...) ===> (a,b,c,d,e,f,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
// 从SL_ARG_N的定义可以看出,N为第64个参数,即 6.
// 因此,最终可得:SL_NUMBER_OF_VA_ARGS(a,b,c,d,e,f) ===> 6
// reference:http://stackoverflow.com/questions/2124339/c-preprocessor-va-args-number-of-arguments
#define SL_ARG_N(      \
_1, _2, _3, _4, _5, _6, _7, _8, _9, _10,    \
_11,_12,_13,_14,_15,_16,_17,_18,_19,_20,    \
_21,_22,_23,_24,_25,_26,_27,_28,_29,_30,   \
_31,_32,_33,_34,_35,_36,_37,_38,_39,_40,    \
_41,_42,_43,_44,_45,_46,_47,_48,_49,_50,    \
_51,_52,_53,_54,_55,_56,_57,_58,_59,_60,    \
_61,_62,_63,N,...)    N

#define SL_RESQ_N()                     \
63,62,61,60,                            \
59,58,57,56,55,54,53,52,51,50,          \
49,48,47,46,45,44,43,42,41,40,          \
39,38,37,36,35,34,33,32,31,30,          \
29,28,27,26,25,24,23,22,21,20,          \
19,18,17,16,15,14,13,12,11,10,          \
9,8,7,6,5,4,3,2,1,0

#define SL_NUMBER_OF_VA_ARGS_(...)      SL_ARG_N(__VA_ARGS__)
#define SL_NUMBER_OF_VA_ARGS(...)       SL_NUMBER_OF_VA_ARGS_(__VA_ARGS__, SL_RESQ_N())

#pragma mark - block property设置 - 宏定义
/// `readonly` 属性前缀
#define SL_READONLY             @property(nonatomic, readonly)

/// T:类型     D:block描述
/// eg:SL_PROP(NSString, Empty) str   ==>@property(nonatomic, readonly)SLChainedNSStringEmptyBlock str
#define SL_PROP(T, D)           SL_READONLY SLChainable##T##D##Block

#pragma mark - block property 类型 - typedef
/// typedef链式block的前半部分(未包含参数部分)
/// eg:SL_CHAINABLE_TYPE(NSString, Empty)   ==> typedef NSString *(^SLChainedNSStringEmptyBlock)
#define SL_CHAINABLE_TYPE(T, D)       typedef T *_Nonnull(^SLChainable##T##D##Block)

#define SL_DEFINE_CHAINABLE_BLOCKS(T)                                       \
SL_CHAINABLE_TYPE(T, Empty)(void);                                          \
SL_CHAINABLE_TYPE(T, Object)(_Nullable id);                                 \
SL_CHAINABLE_TYPE(T, TwoObject)(_Nullable id, _Nullable id);                \
SL_CHAINABLE_TYPE(T, ObjectList)(_Nullable id, ...);                        \
SL_CHAINABLE_TYPE(T, Int)(NSInteger);                                       \
SL_CHAINABLE_TYPE(T, TwoInt)(NSInteger,NSInteger);                          \
SL_CHAINABLE_TYPE(T, IntObjectList)(NSInteger, ...);                        \
SL_CHAINABLE_TYPE(T, UInt)(NSUInteger);                                     \
SL_CHAINABLE_TYPE(T, Float)(CGFloat);                                       \
SL_CHAINABLE_TYPE(T, TwoFloat)(CGFloat,CGFloat);                            \
SL_CHAINABLE_TYPE(T, FourFloat)(CGFloat,CGFloat,CGFloat,CGFloat);           \
SL_CHAINABLE_TYPE(T, FloatList)(SLFloatList);                               \
SL_CHAINABLE_TYPE(T, FloatObjectList)(CGFloat, ...);                        \
SL_CHAINABLE_TYPE(T, Insets)(UIEdgeInsets);                                 \
SL_CHAINABLE_TYPE(T, Rect)(SLRect);                                         \
SL_CHAINABLE_TYPE(T, CallBack)(_Nullable id, _Nullable id);

#pragma mark - 链式block的实现 - typedef
//
#define SL_CHAINABLE_BLOCK(T, ...) return ^(T value) {__VA_ARGS__; return self;}

// 无参数
#define SL_CHAINABLE_EMPTY_BLOCK(...)  return ^{__VA_ARGS__;return self;}
// 一个OC对象参数
#define SL_CHAINABLE_OBJECT_BLOCK(...)  SL_CHAINABLE_BLOCK(id, __VA_ARGS__)
// 一个NSUInteger参数
#define SL_CHAINABLE_UINT_BLOCK(...)     SL_CHAINABLE_BLOCK(NSUInteger, __VA_ARGS__)
// 一个NSInteger参数
#define SL_CHAINABLE_INT_BLOCK(...)     SL_CHAINABLE_BLOCK(NSInteger, __VA_ARGS__)
// 两个NSInteger参数
#define SL_CHAINABLE_TWO_INT_BLOCK(...)     return ^(NSInteger value1, NSInteger value2){__VA_ARGS__; return self;}
// 一个NSInteger参数+多个【可能是0个】Object参数
#define SL_CHAINABLE_INT_OBJECT_LIST_BLOCK(...)     return ^(NSInteger value, ...) {SL_GET_VARIABLE_OBJECT_ARGUMENTS(value); __VA_ARGS__; return self;}
// 一个CGFloat参数
#define SL_CHAINABLE_FLOAT_BLOCK(...)   SL_CHAINABLE_BLOCK(CGFloat, __VA_ARGS__)
// 多个CGFloat参数
#define SL_CHAINABLE_FLOAT_LIST_BLOCK(...)  SL_CHAINABLE_BLOCK(SLFloatList, __VA_ARGS__)
// 一个CGFloat参数+多个【可能是0个】Object参数
#define SL_CHAINABLE_FLOAT_OBJECT_LIST_BLOCK(...)    return ^(CGFloat value, ...) {SL_GET_VARIABLE_OBJECT_ARGUMENTS(value); __VA_ARGS__; return self;}
// 一个UIEdgeInsets参数
#define SL_CHAINABLE_INSETS_BLOCK(...)     SL_CHAINABLE_BLOCK(UIEdgeInsets, __VA_ARGS__)
// 一个CGRect参数
#define SL_CHAINABLE_RECT_BLOCK(...)     SL_CHAINABLE_BLOCK(SLRect, __VA_ARGS__)
// 两个id参数
#define SL_CHAINABLE_2OBJECT_BLOCK(...)    return ^(id target, id object) {__weak id weakTarget = target; __weak id weakSelf = self; __VA_ARGS__; weakTarget = nil; weakSelf = nil; return self;}

#pragma mark - 类型判断
// 获取 x 的type encode(类型编码)
#define SL_TYPE(x)                  @encode(typeof(x))
#define SL_TYPE_FIRST_LETTER(x)     (SL_TYPE(x)[0])

/// 类型判断,判断给定两个类型是否相等
/// - Parameters:
///   - _ts: 类型的encode字符串 eg "i","d"
///   - _t: 给定类型 eg.int,double
#define SL_IS_TYPE_OF(_ts, _t)          (strcmp(_ts,@encode(_t))==0)
/// 判断 x 是否为 NSString 类（或子类）
#define SL_IS_STRING_CLASS(x)    SLObjectIsKindOfClass(@"NSString", x)

/// 判断 x 是否为 NSAttributedString 类（或子类）
#define SL_IS_ATT_CLASS(x)    SLObjectIsKindOfClass(@"NSAttributedString", x)

#define SL_CHECK_IS_INT(x)          (strchr("liBLIcsqCSQ", x) != NULL)
#define SL_CHECK_IS_FLOAT(x)        (strchr("df", x) != NULL)
#define SL_CHECK_IS_PRIMITIVE(x)    (strchr("liBdfLIcsqCSQ", x) != NULL)
#define SL_CHECK_IS_OBJECT(x)      (strchr("@#", x) != NULL)

/// 判断 x 是否为OC对象
#define SL_IS_OBJECT(x)         (strchr("@#",SL_TYPE_FIRST_LETTER(x)) != NULL)
/// 判断 x 是否为NSString对象
#define SL_IS_STRING(x)         (SL_IS_OBJECT(x) && SL_IS_STRING_CLASS(x))
/// 判断 x 是否为NSAttributedString对象
#define SL_IS_ATTSTRING(x)         (SL_IS_OBJECT(x) && SL_IS_ATT_CLASS(x))
#define SL_IS_INT(x)            SL_CHECK_IS_INT(SL_TYPE_FIRST_LETTER(x))
/// 判断 x 是否为block对象
#define SL_IS_BLOCK(x)          (x && [NSStringFromClass([x class]) rangeOfString:@"__NS.+Block__" options:NSRegularExpressionSearch].location != NSNotFound)

#pragma mark - 获取可变参数中的第一个参数
#define SL_FIRAT_VA_ARGS(start, type)   \
Exp(                                    \
va_list argList;                        \
va_start(argList, start);               \
type value = va_arg(argList, type);     \
va_end(argList);                        \
value)

#pragma mark - 系统判断
// 系统是否高于 n 。eg.    SL_SYSTEM_VERSION_HIGHER_EQUAL(8) ===> 判断手机系统是否为iOS 8 及以上。
#define SL_SYSTEM_VERSION_HIGHER_EQUAL(n)  ([[[UIDevice currentDevice] systemVersion] floatValue] >= n)

#pragma mark - 自动生成setter 和 getter方法

#define SL_SYNTHESIZE_BOOL(getter, setter, ...) \
- (BOOL)getter {\
return [objc_getAssociatedObject(self, _cmd) boolValue];\
}\
- (void)setter:(BOOL)getter {\
objc_setAssociatedObject(self, @selector(getter), @(getter), OBJC_ASSOCIATION_RETAIN);\
__VA_ARGS__;\
}

#define SL_SYNTHESIZE_OBJECT(getter, setter, ...) \
- (id)getter {\
return objc_getAssociatedObject(self, _cmd);\
}\
- (void)setter:(id)getter {\
objc_setAssociatedObject(self, @selector(getter), getter, OBJC_ASSOCIATION_RETAIN);\
__VA_ARGS__;\
}

#define SL_SYNTHESIZE_STRUCT(getter, setter, type, ...) \
- (type)getter {\
return [objc_getAssociatedObject(self, _cmd) type##Value];\
}\
- (void)setter:(type)getter {\
objc_setAssociatedObject(self, @selector(getter), [NSValue valueWith##type:getter], OBJC_ASSOCIATION_RETAIN);\
__VA_ARGS__;\
}


#pragma mark - ===========================内联函数声明===========================
#if !defined(SL_INLINE)
#if (defined (__GNUC__) && (__GNUC__ == 4)) || defined (__clang__)
#define SL_INLINE static __inline__ __attribute__((always_inline))
#else
#define SL_INLINE static __inline__
#endif
#endif

#endif /* SLDefs_h */
