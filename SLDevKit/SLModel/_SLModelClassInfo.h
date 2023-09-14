//
//  _SLModelClassInfo.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/14.
//

#import <Foundation/Foundation.h>
#import "_SLModelClassIvarInfo.h"
#import "_SLModelClassPropertyInfo.h"
#import "_SLModelClassMethodInfo.h"

NS_ASSUME_NONNULL_BEGIN
/**
 Class的定义
 typedef struct objc_class *Class;
 
 struct objc_class {
     Class _Nonnull isa;                                          // objc_class 结构体的实例指针

 #if !__OBJC2__
     Class _Nullable super_class;                                 // 指向父类的指针
     const char * _Nonnull name;                                  // 类的名字
     long version;                                                // 类的版本信息，默认为 0
     long info;                                                   // 类的信息，供运行期使用的一些位标识
     long instance_size;                                          // 该类的实例变量大小;
     struct objc_ivar_list * _Nullable ivars;                     // 该类的实例变量列表
     struct objc_method_list * _Nullable * _Nullable methodLists; // 方法定义的列表
     struct objc_cache * _Nonnull cache;                          // 方法缓存
     struct objc_protocol_list * _Nullable protocols;             // 遵守的协议列表
 #endif
 */
@interface _SLModelClassInfo : NSObject

@property(nonatomic,assign,readonly)Class cls;
@property(nonatomic,assign,readonly)Class superCls;
@property(nonatomic,assign,readonly)Class metaCls;
@property(nonatomic,assign,readonly)BOOL isMeta;
@property(nonatomic,copy,readonly)NSString *name;
@property(nullable,nonatomic,strong)_SLModelClassInfo *superClassInfo;

@property(nullable,nonatomic,strong,readonly)NSDictionary <NSString *, _SLModelClassIvarInfo *> *ivarInfos;
@property(nullable,nonatomic,strong,readonly)NSDictionary <NSString *, _SLModelClassPropertyInfo *> *propertyInfos;
@property(nullable,nonatomic,strong,readonly)NSDictionary <NSString *, _SLModelClassMethodInfo *> *methodInfos;

+ (instancetype)classInfoWithClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
