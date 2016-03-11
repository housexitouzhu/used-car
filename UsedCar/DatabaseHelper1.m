//
//  DatabaseHelper.m
//  CarMaster
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "DatabaseHelper1.h"

@interface DatabaseHelper1 ()

@property(nonatomic) sqlite3 *sql;
@property(nonatomic, copy) NSString *dbPath;

@end

@implementation DatabaseHelper1

- (id)init
{
    NSAssert(0, @"不要调用此方法, 应该使用 initWithDbName:(NSString*) 或 initWithDbPath:(NSString*)");
    return nil;
}

- (id)initWithDbName:(NSString *)dbName
{
    return [self initWithDbPath:[[NSBundle mainBundle] pathForResource:dbName ofType:@"sqlite"]];
}

- (id)initWithDbPath:(NSString *)dbPath
{
    self = [super init];
    
    if (self != nil) {
        self.dbPath = dbPath;
    }
    
    return self;
}

/* 创建数据库 */
- (BOOL)openOrCreateDatabase
{
    if (sqlite3_open([self.dbPath UTF8String], &_sql) != SQLITE_OK) {
        AMLog(@"打开或创建数据库失败");
        return NO;
    }
    return YES;
}

/* 创建表 */
- (BOOL)createTable:(NSString *)sqlCreateTable
{
    if (![self openOrCreateDatabase])
        return NO;

    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(self.sql, [sqlCreateTable UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK;
    if (!isOk)
        AMLog(@"创建数据表失败: %s (%@)", errorMsg, sqlCreateTable);

    [self closeDatabase];
    return isOk;
}

/* 关闭数据库 */
- (void)closeDatabase
{
    sqlite3_close(self.sql);
}

/* 事务开始 */
- (BOOL)beginTransaction
{
    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(self.sql, "begin transaction", 0, NULL, &errorMsg) == SQLITE_OK;
    return isOk;
}

/* 事务回滚 */
- (BOOL)rollbackTransaction
{
    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(self.sql, "rollback transaction", 0, NULL, &errorMsg) == SQLITE_OK;
    return isOk;
}


/* 事务提交 */
- (BOOL)commitTransaction
{
    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(self.sql, "commit transaction", 0, NULL, &errorMsg) == SQLITE_OK;
    return isOk;
}

/* 插入表 */
- (BOOL)insertTable:(NSString *)sqlInsert
{
    return [self insertTable:sqlInsert isOpenAndClose:YES];
}

/* 插入表 */
- (BOOL)insertTable:(NSString *)sqlInsert isOpenAndClose:(BOOL)isOpenAndClose
{
    if (isOpenAndClose)
        if (![self openOrCreateDatabase])
            return NO;
    
    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(_sql, [sqlInsert UTF8String], 0, NULL, &errorMsg) == SQLITE_OK;
    if (!isOk) {
        AMLog(@"插入表失败: %s (%@)", errorMsg, sqlInsert);
        errorMsg = NULL;
    }

    if (isOpenAndClose)
        [self closeDatabase];
    
    return isOk;
}

/* 查询有无列 */
- (BOOL)isExistColumn:(NSString *)sqlInsert isOpenAndClose:(BOOL)isOpenAndClose
{
    if (isOpenAndClose)
        if (![self openOrCreateDatabase])
            return NO;
    
    char *errorMsg = NULL;
    BOOL isOk = sqlite3_exec(_sql, [sqlInsert UTF8String], 0, NULL, &errorMsg) == SQLITE_OK;
    if (!isOk) {
        AMLog(@"查询列失败: %s (%@)", errorMsg, sqlInsert);
        errorMsg = NULL;
    }
    
    if (isOpenAndClose)
        [self closeDatabase];
    
    return isOk;
}

/* 更新表 */
- (BOOL)updataTable:(NSString *)sqlUpdata
{
    if (![self openOrCreateDatabase])
        return NO;
    
    char *errorMsg;
    BOOL isOk = sqlite3_exec(_sql, [sqlUpdata UTF8String], 0, NULL, &errorMsg) == SQLITE_OK;
    if (!isOk)
        AMLog(@"更新表失败: %s (%@)", errorMsg, sqlUpdata);
    
    [self closeDatabase];
    return isOk;
}

/* 查询表 */
- (NSMutableArray *)querryTable:(NSString *)sqlQuerry
{
    if (![self openOrCreateDatabase])
        return nil;
    
    int row = 0;
    int column = 0;
    char *errorMsg = NULL;
    char **dbResult = NULL;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (sqlite3_get_table(_sql, [sqlQuerry UTF8String], &dbResult, &row, &column, &errorMsg) == SQLITE_OK) {
        if (row != 0) {
            int index = column;
            for (int i = 0; i < row; i++) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                for (int j = 0; j < column; j++) {
                    if (dbResult[index]) {
                        NSString *value = [[NSString alloc]initWithUTF8String:dbResult[index]];
                        NSString *key = [[NSString alloc]initWithUTF8String:dbResult[j]];
                        [dic setObject:value forKey:key];
                    }
                    index++;
                }
                [array addObject:dic];
            }
        }
    } else {
        AMLog(@"查询表失败: %s (%@)", errorMsg, sqlQuerry);
        errorMsg = NULL;
        sqlite3_free_table(dbResult);
        [self closeDatabase];
        return nil;
    }
    
    sqlite3_free_table(dbResult);
    [self closeDatabase];
    return array;
}

/* 查询表回调 */
- (NSMutableArray *)querryTableByCallBack:(NSString *)sqlQuerry
{
    if (![self openOrCreateDatabase])
        return nil;
    
    char *errorMsg = NULL;
    NSMutableArray *arrayResult = [[NSMutableArray alloc]init];
    if (sqlite3_exec(self.sql, [sqlQuerry UTF8String], processData, (__bridge void *)arrayResult, &errorMsg) != SQLITE_OK) {
        AMLog(@"查询出错: %s (%@)", errorMsg, sqlQuerry);
    }
    
    [self closeDatabase];
    return arrayResult;
}

/* 处理数据 */
int processData(void *arrayResult, int columnCount, char **columnValue, char **columnName)
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < columnCount; i++) {
        if (columnValue[i]) {
            NSString *key = [[NSString alloc]initWithUTF8String:columnName[i]];
            NSString *value = [[NSString alloc]initWithUTF8String:columnValue[i]];
            [dic setObject:value forKey:key];
        }
    }
    [(__bridge NSMutableArray *)arrayResult addObject : dic];
    return 0;
}

@end