//
//  SLSymbolModel.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/3/27.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSymbolModel : NSObject

@property(nonatomic,copy)NSString *imageName;

@property(nonatomic,assign)NSInteger imageBase;

@property(nonatomic,assign)NSUInteger symbolAddress;

@property(nonatomic,copy)NSString *symbolName;

-(instancetype)initWithDLInfo:(Dl_info *)info;

@end

NS_ASSUME_NONNULL_END
