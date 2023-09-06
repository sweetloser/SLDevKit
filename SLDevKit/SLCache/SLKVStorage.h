//
//  SLKVStorage.h
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import <Foundation/Foundation.h>

@class SLKVStorageItem;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SLKVStorageTypeFile,
    SLKVStorageTypeSQLite,
    SLKVStorageTypeMixed,
} SLKVStorageType;

@interface SLKVStorage : NSObject

@property(nonatomic,copy,readonly)NSString *path;
@property(nonatomic,assign,readonly)SLKVStorageType type;


- (instancetype)initWithPath:(NSString *)path type:(SLKVStorageType)type;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (BOOL)itemExistsForKey:(NSString *)key;

- (BOOL)removeItemForKey:(NSString *)key;
- (BOOL)removeAllItems;

- (BOOL)removeItemsEarlierThanTime:(int)time;
- (BOOL)removeItemsToFitCount:(int)countLimit;
- (BOOL)removeItemsToFitSize:(int)sizeLimit;


- (SLKVStorageItem *_Nullable)getItemForKey:(NSString *)key;

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *_Nullable)fileName extendedData:(NSData *_Nullable)extendedData;


@end

NS_ASSUME_NONNULL_END
