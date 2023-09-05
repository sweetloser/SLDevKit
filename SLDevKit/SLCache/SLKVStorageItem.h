//
//  SLKVStorageItem.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLKVStorageItem : NSObject

@property(nonatomic,copy)NSString *key;
@property(nonatomic,strong)NSData *value;
@property(nonatomic,copy,nullable)NSString *fileName;
@property(nonatomic,assign)int size;
@property(nonatomic,assign)int modificationTime;
@property(nonatomic,assign)int lastAccessTime;
@property(nonatomic,strong)NSData *extendedData;
@end

NS_ASSUME_NONNULL_END
