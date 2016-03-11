//
//  DatabaseHelper.h
//  CarMaster
//
//  Created by Alan on 13-8-16.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface DatabaseHelper1 : NSObject

- (id)initWithDbName:(NSString *)dbName;
- (id)initWithDbPath:(NSString *)dbPath;
- (BOOL)openOrCreateDatabase;
- (void)closeDatabase;
- (BOOL)beginTransaction;
- (BOOL)rollbackTransaction;
- (BOOL)commitTransaction;
- (BOOL)createTable:(NSString *)sqlCreateTable;
- (BOOL)insertTable:(NSString *)sqlInsert;
- (BOOL)insertTable:(NSString *)sqlInsert isOpenAndClose:(BOOL)isOpenAndClose;
- (BOOL)isExistColumn:(NSString *)sqlInsert isOpenAndClose:(BOOL)isOpenAndClose;
- (BOOL)updataTable:(NSString *)sqlUpdata;
- (NSMutableArray *)querryTable:(NSString *)sqlQuerry;
- (NSMutableArray *)querryTableByCallBack:(NSString *)sqlQuerry;

@end