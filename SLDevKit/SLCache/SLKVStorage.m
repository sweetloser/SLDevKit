//
//  SLKVStorage.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import "SLKVStorage.h"
#import <sqlite3.h>
#import "SLKVStorageItem.h"

static const int kPathLengthMax = PATH_MAX - 64;

static NSString *const kDBFileName = @"manifest.sqlite";
static NSString *const kDBShmFileName = @"manifest.sqlite-shm";
static NSString *const kDBWalFileName = @"manifest.sqlite-wal";
static NSString *const kDataDirectoryName = @"data";
static NSString *const kTrashDirectoryName = @"trash";


@implementation SLKVStorage {
    
    NSString *_path;
    NSString *_dbPath;
    NSString *_dataPath;
    NSString *_trashPath;
    
    sqlite3 *_db;
    
    // sql语句缓存
    CFMutableDictionaryRef _dbStmtCache;
    
    dispatch_queue_t _trashQueue;
    
}


#pragma mark - 生命周期
- (instancetype)initWithPath:(NSString *)path type:(SLKVStorageType)type {
    
    if (path.length == 0 || path.length > kPathLengthMax) {
        NSLog(@"SLKVStorage init error: invalid path: [%@].", path);
        return nil;
    }
    
    if (type > SLKVStorageTypeFile) {
        NSLog(@"SLKVStorage init error: invalid type: [%lu].", (unsigned long)type);
        return nil;
    }
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _path = path;
    _type = type;
    
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    
    _trashQueue = dispatch_queue_create("com.sweetloser.cache.disk.trash", DISPATCH_QUEUE_SERIAL);
    
    // 创建文件目录
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:&error] ||
        ![fileManager createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:&error] ||
        ![fileManager createDirectoryAtPath:_trashPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"SLKVStorage init error:%@", error);
        return nil;
    }
    
    if (![self _dbOpen] || ![self _dbInitialize]) {
        // 数据库打开失败或者数据库初始化失败
        [self _dbClose];
        [self _reset];
        
        if (![self _dbOpen] || [self _dbInitialize]) {
            [self _dbClose];
            return nil;
        }
    }
    
    return self;
}

#pragma mark - 业务代码
- (BOOL)itemExistsForKey:(NSString *)key {
    if (key.length == 0) return NO;
    return [self _dbGetItemCountWithKey:key] > 0;
}
- (BOOL)removeItemForKey:(NSString *)key {
    if (key.length == 0) return NO;
    if (_type != SLKVStorageTypeSQLite) {
        NSString *fileName = [self _dbGetFilenameWithKey:key];
        if (fileName) {
            [self _fileDeleteWithName:fileName];
        }
    }
    return [self _dbDeleteItemWithKey:key];
}
- (BOOL)removeItemsToFitCount:(int)countLimit {
    if (countLimit == INT_MAX) return YES;
    if (countLimit < 0) [self removeAllItems];
    
    int totalCount = [self _dbGetTotalItemCount];
    if (totalCount < 0) return NO;
    if (totalCount <= countLimit) return YES;
    
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int preCount = 16;
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:preCount];
        for (SLKVStorageItem *item in items) {
            if (totalCount > countLimit) {
                if (item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                success = [self _dbDeleteItemWithKey:item.key];
                totalCount--;
            } else {
                break;
            }
            if (!success) break;
        }
    } while (totalCount > countLimit && items.count > 0 && success);
    
    if (success) [self _dbCheckpoint];
    
    return success;
}
- (BOOL)removeItemsToFitSize:(int)sizeLimit {
    if (sizeLimit == INT_MAX) return YES;
    if (sizeLimit < 0) [self removeAllItems];
    
    int totalSize = [self _dbGetTotalItemSize];
    if (totalSize < 0) return NO;
    if (totalSize <= sizeLimit) return YES;
    
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int preCount = 16;
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:preCount];
        for (SLKVStorageItem *item in items) {
            if (totalSize > sizeLimit) {
                if (item.fileName) {
                    [self _fileDeleteWithName:item.fileName];
                }
                success = [self _dbDeleteItemWithKey:item.key];
                totalSize -= item.size;
            } else {
                break;
            }
            if (!success) break;
        }
    } while (totalSize > sizeLimit && items.count > 0 && success);
    
    if (success) [self _dbCheckpoint];
    return success;
}
- (BOOL)removeItemsEarlierThanTime:(int)time {
    if (time == 0) return [self removeAllItems];
    
    if (time == INT_MAX) return YES;
    
    if (_type == SLKVStorageTypeSQLite) {
        // 仅数据库缓存
        if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
            [self _dbCheckpoint];
            return YES;
        }
    }else {
        // 数据库缓存+文件缓存
        NSArray <NSString *>*fileNames = [self _dbGetFileNamesWithTimeEarlierThan:time];
        for (NSString *fileName in fileNames) {
            [self _fileDeleteWithName:fileName];
        }
        if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
            [self _dbCheckpoint];
            return YES;
        }
    }
    
    return YES;
}
- (BOOL)removeAllItems {
    if (![self _dbClose]) return NO;
    
    [self _reset];
    
    if (![self _dbOpen]) return NO;
    
    if (![self _dbInitialize]) return NO;
    
    return YES;
}
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value {
    
    return [self saveItemWithKey:key value:value fileName:nil extendedData:nil];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value fileName:( NSString * _Nullable)fileName extendedData:(NSData * _Nullable)extendedData {
    if (key.length == 0 || value.length == 0) return NO;
    
    if (_type == SLKVStorageTypeFile && fileName.length == 0) return NO;
    
    if (fileName.length) {
        if (![self _fileWriteWithName:fileName data:value]) {
            return NO;
        }
        if (![self _dbSaveWithKey:key value:value fileName:fileName extendedData:extendedData]) {
            [self _fileDeleteWithName:fileName];
            return NO;
        }
        return YES;
    } else {
        // 文件名为空，则不需要文件缓存，需更新数据（如果之前缓存的数据使用了文件缓存，需要删除对应文件）
        if (_type != SLKVStorageTypeSQLite) {
            NSString *oldFileName = [self _dbGetFilenameWithKey:key];
            if (oldFileName) {
                [self _fileDeleteWithName:oldFileName];
            }
        }
        return [self _dbSaveWithKey:key value:value fileName:fileName extendedData:extendedData];
    }
}
- (SLKVStorageItem *)getItemForKey:(NSString *)key {
    if (key.length == 0) return nil;
    
    SLKVStorageItem *item = [self _dbGetItemWithKey:key excludeInlineData:NO];
    if (item) {
        // 更新访问时间
        [self _dbUpdateAccessTimeWithKey:key];
        
        if (item.fileName) {
            item.value = [self _fileReadWithName:item.fileName];
            if (!item.value) {
                [self _dbDeleteItemWithKey:key];
                item = nil;
            }
        }
    }
    return item;
}
#pragma mark - 文件操作
- (void)_reset {
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBShmFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBWalFileName] error:nil];
    
    [self _fileMoveAllToTrash];
    [self _fileEmptyTrashInBackground];
}
- (BOOL)_fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}
- (NSData *)_fileReadWithName:(NSString *)fileName {
    NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}
- (BOOL)_fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}
- (BOOL)_fileMoveAllToTrash {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *tempPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)uuid];
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tempPath error:nil];
    if (success) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return success;
}
- (void)_fileEmptyTrashInBackground {
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *fileManager = [NSFileManager new];
        NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:trashPath error:NULL];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [fileManager removeItemAtPath:fullPath error:NULL];
        }
    });
}
#pragma mark - 数据库操作
- (BOOL)_dbOpen {
    if (_db) return YES;
    
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        
        return YES;
    } else {
        _db = NULL;
        return NO;
    }
}
- (BOOL)_dbClose {
    if (!_db) return YES;
    BOOL retry = NO;
    int result = 0;
    BOOL stmtFinalized = NO;
    do {
        retry = NO;
        result = sqlite3_close(_db);
        if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                stmtFinalized = YES;
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, NULL)) != 0) {
                    sqlite3_finalize(stmt);
                    retry = YES;
                }
            }
        } else if (result != SQLITE_OK) {
            NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
        }
    } while (retry);
    
    _db = NULL;
    return YES;
}
- (BOOL)_dbInitialize {
    NSString *sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists manifest (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on manifest(last_access_time);";
    return [self _dbExecute:sql];
}
- (BOOL)_dbExecute:(NSString *)sql {
    if (sql.length == 0) return NO;
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        NSLog(@"%s line:%d sqlite exec failed (%d).", __FUNCTION__, __LINE__, result);
        free(error);
    }
    return result == SQLITE_OK;
}
- (void)_dbCheckpoint {
    if (![self _dbCheck]) return;
    sqlite3_wal_checkpoint(_db, NULL);
}
- (BOOL)_dbCheck {
    if (!_db) {
        return [self _dbOpen] && [self _dbInitialize];
    }
    return YES;
}
- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
    if (![self _dbCheck] || sql.length == 0 || _dbStmtCache == NULL) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void *)sql);
    if (!stmt) {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            return NULL;
        }
        CFDictionarySetValue(_dbStmtCache, (__bridge const void *)sql, (const void *)stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}
- (int)_dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = @"select count(key) from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite query error (%d):%s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
- (BOOL)_dbDeleteItemWithKey:(NSString *)key {
    if (![self _dbCheck]) return NO;
    NSString *sql = @"delete from manifest where key = ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d db delete error (%d):%s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}
- (BOOL)_dbSaveWithKey:(NSString *)key value:(NSData *)value fileName:(NSString *)fileName extendedData:(NSData *)extendedData {
    NSString *sql = @"insert or replace into manifest (key, filename, size, inline_data, modification_time, last_access_time, extended_data) values (?1, ?2, ?3, ?4, ?5, ?6, ?7);";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    int timestamp = (int)time(NULL);
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, fileName.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 3, (int)value.length);
    
    if (fileName.length == 0) {
        sqlite3_bind_blob(stmt, 4, value.bytes, (int)value.length, NULL);
    } else {
        sqlite3_bind_blob(stmt, 4, NULL, 0, NULL);
    }
    
    sqlite3_bind_int(stmt, 5, timestamp);
    sqlite3_bind_int(stmt, 6, timestamp);
    
    sqlite3_bind_blob(stmt, 7, extendedData.bytes, (int)extendedData.length, NULL);
    
    int result = sqlite3_step(stmt);
    
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}
-(SLKVStorageItem *)_dbGetItemWithKey:(NSString *)key excludeInlineData:(BOOL)excludeInlineData {
    NSString *sql;
    if (excludeInlineData) {
        sql = @"select key, filename, size, modification_time, last_access_time, extended_data from manifest where key = ?1;";
    } else {
        sql = @"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from manifest where key = ?1;";
    }
    
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    SLKVStorageItem *item = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self _dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return item;
}
- (NSArray <SLKVStorageItem *>*)_dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"select key, filename, size from manifest order by last_access_time asc limit ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    
    sqlite3_bind_int(stmt, 1, count);
    NSMutableArray *items = [NSMutableArray new];
    
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0);
            char *fileName = (char *)sqlite3_column_text(stmt, 1);
            int size = sqlite3_column_int(stmt, 2);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                SLKVStorageItem *item = [SLKVStorageItem new];
                item.key = keyStr;
                item.fileName = fileName ? [NSString stringWithUTF8String:fileName] : nil;
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error(%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            items = nil;
            break;
        }
    } while (1);
    
    return items;
}
- (SLKVStorageItem *)_dbGetItemFromStmt:(sqlite3_stmt *)stmt excludeInlineData:(BOOL)excludeInlineData {
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *fileName = (char *)sqlite3_column_text(stmt, i++);
    int size = sqlite3_column_int(stmt, i++);
    BytePtr inlineDatas = excludeInlineData ? NULL : (BytePtr)sqlite3_column_blob(stmt, i);
    int inlineDatasLength = excludeInlineData ? 0 : sqlite3_column_bytes(stmt, i++);
    
    int modificationTime = sqlite3_column_int(stmt, i++);
    int lastAccessTime = sqlite3_column_int(stmt, i++);
    
    BytePtr extendedDatas = (BytePtr)sqlite3_column_blob(stmt, i);
    int extendedDatasLength = sqlite3_column_bytes(stmt, i++);
    
    SLKVStorageItem *item = [SLKVStorageItem new];
    item.key = [NSString stringWithUTF8String:key];
    if (fileName && *fileName != 0) {
        item.fileName = [NSString stringWithUTF8String:fileName];
    }
    item.size = size;
    if (inlineDatasLength > 0 && inlineDatas) {
        item.value = [NSData dataWithBytes:inlineDatas length:inlineDatasLength];
    }
    
    item.modificationTime = modificationTime;
    item.lastAccessTime = lastAccessTime;
    
    if (extendedDatasLength > 0 && extendedDatas) {
        item.extendedData = [NSData dataWithBytes:extendedDatas length:extendedDatasLength];
    }
    
    return item;
}
-(BOOL)_dbUpdateAccessTimeWithKey:(NSString *)key {
    NSString *sql = @"update manifest set last_access_time = ?1 where key = ?2;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    
    if (!stmt) return NO;
    int timestamp = (int)time(NULL);
    sqlite3_bind_int(stmt, 1, timestamp);
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}
- (NSString *)_dbGetFilenameWithKey:(NSString *)key {
    NSString *sql = @"select filename from manifest where key =?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        char *fileName = (char *)sqlite3_column_text(stmt, 0);
        if (fileName && *fileName != 0) {
            return [NSString stringWithUTF8String:fileName];
        }
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line %d: sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return nil;
}
- (NSArray <NSString *>*)_dbGetFileNamesWithTimeEarlierThan:(int)time {
    NSString *sql = @"select filename from manifest where last_access_time < ?1 and filename is not null;";
    
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 0, time);
    
    NSMutableArray <NSString *>*fileNames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *fileName = (char *)sqlite3_column_text(stmt, 0);
            if (fileName && *fileName != 0) {
                NSString *fileNameStr = [NSString stringWithUTF8String:fileName];
                
                if (fileNameStr) [fileNames addObject:fileNameStr];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            fileNames = nil;
            break;
        }
    } while (1);
    
    return fileNames;
}
- (int)_dbGetTotalItemSize {
    NSString *sql = @"select sum(size) from manifest;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
- (int)_dbGetTotalItemCount {
    NSString *sql = @"select count(*) from manifest;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return -1;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return -1;
    }
    return sqlite3_column_int(stmt, 0);
}
- (BOOL)_dbDeleteItemsWithTimeEarlierThan:(int)time {
    NSString *sql = @"delete from manifest where last_access_time < ?1;";
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    
    sqlite3_bind_int(stmt, 0, time);
    
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}
@end
