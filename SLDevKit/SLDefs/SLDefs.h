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


/// `readonly` 属性前缀
#define SL_READONLY             @property(nonatomic, readonly)

/// T:类型     D:block描述
/// eg:SL_PROP(NSString, Empty) str   ==>@property(nonatomic, readonly)SLChainedNSStringEmptyBlock str
#define SL_PROP(T, D)           SL_READONLY SLChainable##T##D##Block

/// 重定义链式block的前半部分(未包含参数部分)
/// eg:SL_CHAINABLE_TYPE(NSString, Empty)   ==> typedef NSString *(^SLChainedNSStringEmptyBlock)
#define SL_CHAINABLE_TYPE(T, D)       typedef T *_Nonnull(^SLChainable##T##D##Block)

#define SL_DEFINE_CHAINABLE_BLOCKS(T)                       \
SL_CHAINABLE_TYPE(T, Empty)(void);                          \
SL_CHAINABLE_TYPE(T, Object)(id);                           \
SL_CHAINABLE_TYPE(T, TwoObject)(id, id);                    \
SL_CHAINABLE_TYPE(T, ObjectList)(id, ...);                  \
SL_CHAINABLE_TYPE(T, Int)(NSInteger);                       \
SL_CHAINABLE_TYPE(T, UInt)(NSUInteger);                     \
SL_CHAINABLE_TYPE(T, Float)(CGFloat);                       \
SL_CHAINABLE_TYPE(T, TwoFloat)(CGFloat,CGFloat);

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
// 一个CGFloat参数
#define SL_CHAINABLE_FLOAT_BLOCK(...)   SL_CHAINABLE_BLOCK(CGFloat, __VA_ARGS__)

#pragma mark - 类型判断
// 获取 x 的type encode(类型编码)
#define SL_TYPE(x)                  @encode(typeof(x))
#define SL_TYPE_FIRST_LETTER(x)     (SL_TYPE(x)[0])

/// 类型判断,判断给定两个类型是否相等
/// - Parameters:
///   - _ts: 类型的encode字符串 eg "i","d"
///   - _t: 给定类型 eg.int,double
#define SL_IS_TYPE_OF(_ts, _t)          (strcmp(_ts,@encode(_t))==0)

#define SL_IS_OBJECT(x)         (strchr("@#",SL_TYPE_FIRST_LETTER(x)) != NULL)

#define SL_IS_STRING_CLASS(x)    SLObjectIsKindOfClass(@"NSString", x)
#define SL_IS_STRING(x)         (SL_IS_OBJECT(x) && SL_IS_STRING_CLASS(x))


#endif /* SLDefs_h */
