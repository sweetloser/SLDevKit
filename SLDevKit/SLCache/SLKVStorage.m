//
//  SLKVStorage.m
//  SLDevKit
//
//  Created by zengxiangxiang on 2023/9/4.
//

#import "SLKVStorage.h"
#import <sqlite3.h>

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
    
}


#pragma mark - 生命周期
- (instancetype)initWithPath:(NSString *)path type:(SLKVStorageType)type {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _path = path;
    _type = type;
    
    _dbPath = [path stringByAppendingPathComponent:kDBFileName];
    _dataPath = [path stringByAppendingPathComponent:kDataDirectoryName];
    _trashPath = [path stringByAppendingPathComponent:kTrashDirectoryName];
    
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
        return nil;
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
    return [self _dbDeleteItemWithKey:key];
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

@end
