//
//  XMPPDBCacheManager.m
//  IMDemo
//
//  Created by jun on 11/8/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "XMPPDBCacheManager.h"
#import "XMPPFileCacheManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "NSString+Util.h"
#import "IMCacheManage.h"
#import "AMCacheManage.h"
#import "CarMessageBody.h"
#import "MessageBodyFactory.h"
#import "IMHistoryContactModel.h"

#define kMessagePageSize (15)

@interface XMPPDBCacheManager()

@property (nonatomic,retain) FMDatabaseQueue *dbQueue;

@end

@implementation XMPPDBCacheManager

+ (id)sharedManager
{
    NSString *jid = [IMCacheManage currentIMUserInfo].name;
    return jid ? [XMPPDBCacheManager sharedManagerByJID:jid] : nil;
}

+ (id)sharedManagerByJID:(NSString *)jid
{
    static XMPPDBCacheManager *manager = nil;
    static NSString *managerJID = nil;

    // 切换jid时读取新数据库地址
    if (![managerJID isEqualToString:jid]) {
        manager = nil;
        managerJID = jid;
    }
    
    if (manager == nil) {
        manager = [[XMPPDBCacheManager alloc] init];

        BOOL exists = [[IMCacheManage sharedManager] createDBFileIfNessaryByJID:jid];
        if (exists) {
            //如果存在，打开一个数据库
            NSString *dbPath = [[IMCacheManage sharedManager] currentDBPathByUserID:jid];

            manager.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return manager;
}

- (BOOL)createMessageTableIfNessaryWithName:(NSString *)tableName
{
    __block BOOL result;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next])
        {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            
            if (0 == count)
            {
                result = NO;
            }
            else
            {
                result = YES;
            }
        }
        [rs close];
    }];
    
    if (result == NO) {
        result = [self createMessageTableWithName:tableName];
    }
    
    return result;
}

- (BOOL)createMessageTableWithName:(NSString *)tableName
{
    
    /*
     CREATE TABLE chat_message (
     mesId integer PRIMARY KEY AUTOINCREMENT NOT NULL,
     message text,
     status integer DEFAULT(0),
     unRead integer DEFAULT(0),
     imgStatus integer DEFAULT(0),
     voiceStatus integer DEFAULT(0),
     createTime integer DEFAULT(0),
     type integer DEFAULT(0),
     isOutgoing integer DEFAULT(0)
     );
     
     CREATE INDEX Index0 ON chat_message (mesId);
     CREATE INDEX Index1 ON chat_message (status);
     CREATE INDEX Index2 ON chat_message (createTime);
     */
    __block BOOL result = NO;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE %@ (mesId integer PRIMARY KEY AUTOINCREMENT NOT NULL,message text,status integer DEFAULT(0),unRead integer DEFAULT(0),imgStatus integer DEFAULT(0),voiceStatus integer DEFAULT(0),createTime integer DEFAULT(0),type integer DEFAULT(0),isOutgoing integer DEFAULT(0))",tableName];
        
        BOOL createTableSuccess = [db executeUpdate:createTableSql];
        if (createTableSuccess) {
            NSString *createIndex0Sql = [NSString stringWithFormat:@"CREATE INDEX %@_index0 ON %@ (mesId)",tableName,tableName];
            BOOL createIndex0Success = [db executeUpdate:createIndex0Sql];
            if (createIndex0Success) {
                
                NSString *createIndex1Sql = [NSString stringWithFormat:@"CREATE INDEX %@_index1 ON %@ (status)",tableName,tableName];
                BOOL createIndex1Success = [db executeUpdate:createIndex1Sql];
                if (createIndex1Success) {
                    NSString *createIndex2Sql = [NSString stringWithFormat:@"CREATE INDEX %@_index2 ON %@ (createTime)",tableName,tableName];
                    BOOL createIndex2Success = [db executeUpdate:createIndex2Sql];
                    if (createIndex2Success) {
                        
                        result = YES;
                    }
                }
            }
        }
        
        if (result == NO) {
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

- (NSString *)tableNameWithJid:(NSString *)jid
{
    NSString *jidMd5 = jid.md5;
    NSString *tableName = [NSString stringWithFormat:@"chat_%@",jidMd5];
    return tableName;
}

- (NSInteger)insertMessage:(StorageMessage *)message
{
    return [self insertMessage:message withContactCheck:NO];
}

- (NSInteger)insertMessage:(StorageMessage *)message withContactCheck:(BOOL)check
{
    __block NSInteger result = -1;
    if (message != nil) {
        NSString *tableName = [self tableNameWithJid:message.jid];
        if ([self createMessageTableIfNessaryWithName:tableName]) {
            
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(message,status,unRead,imgStatus,voiceStatus,createTime,type,isOutgoing) VALUES (?,?,?,?,?,?,?,?)",tableName];
                
                BOOL success = [db executeUpdate:sql,message.message,@(message.status),@(message.unRead),@(message.imgStatus),@(message.voiceStatus),@(message.createTime),@(message.type),@(message.isOutgoing)];
                
                if (success) {
                    NSInteger mesId = (NSInteger)[db lastInsertRowId];
                    message.mesId = mesId;
                    result = (NSInteger)mesId;
                }
            }];
        }
    }
    
    if (check) {

        [self insertContactIfNessaryWithMessage:message];
    }
    
    return result;
}

- (NSArray *)firstPageMessagesWithJid:(NSString *)jid
{
    return [self messagesWithPage:0 andJid:jid];
}

- (NSArray *)messagesWithPage:(NSInteger)page andJid:(NSString *)jid
{
    __block NSMutableArray *array = nil;
    if (page >= 0 && jid != nil && jid.length > 0) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:jid];
            NSInteger offset = kMessagePageSize * page;
            //ASC 升序  DESC 降序
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY mesId DESC LIMIT %d OFFSET %d",tableName,kMessagePageSize,offset];
            
            FMResultSet *resultSet = [db executeQuery:sql];
            
            array = [NSMutableArray array];
            while ([resultSet next])
            {
                StorageMessage *message = [self messageFromResultSet:resultSet];
                message.jid = jid;
                message.fullJid = [NSString stringWithFormat:@"%@@%@/%@",jid,[IMCacheManage currentIMUserInfo].domain,kXMPP_USER_RESOURCE];
                [array addObject:message];
            }
            [resultSet close];
        }];
    }
    
    if (array.count == 0) {
        array = nil;
    }else{
        //倒序array
        NSArray * reverseArray = [[array reverseObjectEnumerator] allObjects];
        array = [[NSMutableArray alloc] initWithArray:reverseArray];
    }
    
    return array;
}

- (NSArray *)nextPageMessagesWithMessage:(StorageMessage *)message
{
    __block NSMutableArray *array = nil;
    if (message != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:message.jid];
            //ASC 升序  DESC 降序
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE mesId < %d ORDER BY mesId DESC LIMIT %d OFFSET 0",tableName,message.mesId,kMessagePageSize];
            
            FMResultSet *resultSet = [db executeQuery:sql];
            
            array = [NSMutableArray array];
            while ([resultSet next])
            {
                StorageMessage *mes = [self messageFromResultSet:resultSet];
                mes.jid = message.jid;
                [array addObject:mes];
            }
            [resultSet close];
        }];
    }
    
    if (array.count == 0) {
        array = nil;
    }else{
        //倒序array
        NSArray * reverseArray = [[array reverseObjectEnumerator] allObjects];
        array = [[NSMutableArray alloc] initWithArray:reverseArray];
    }
    
    return array;
}

- (StorageMessage *)messageFromResultSet:(FMResultSet *)resultSet
{
    StorageMessage *message = [[StorageMessage alloc] init];
    message.mesId = [resultSet intForColumnIndex:0];
    message.status = [resultSet intForColumnIndex:2];
    message.unRead = [resultSet intForColumnIndex:3];
    message.imgStatus = [resultSet intForColumnIndex:4];
    message.voiceStatus = [resultSet intForColumnIndex:5];
    message.createTime = [resultSet intForColumnIndex:6];
    message.timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:message.createTime];
    //要先设置type，再设置Message
    message.type = [resultSet intForColumnIndex:7];
    message.message = [resultSet stringForColumnIndex:1];
    message.isOutgoing = [resultSet intForColumnIndex:8];
    message.mesBody = [MessageBodyFactory messageBodyWithJsonString:message.message];
    return message;
}

- (StorageContact *)contactFromResultSet:(FMResultSet *)resultSet
{
    StorageContact *contact = [[StorageContact alloc] init];
    contact.contactId = [resultSet intForColumnIndex:0];
    contact.shortJid = [resultSet stringForColumnIndex:1];
    contact.fullJid = [resultSet stringForColumnIndex:2];
    contact.carJson = [resultSet stringForColumnIndex:3];
    contact.nickName = [resultSet stringForColumnIndex:4];
    contact.dealerid = [resultSet stringForColumnIndex:5];
    contact.salesid = [resultSet stringForColumnIndex:6];
    contact.memberid = [resultSet stringForColumnIndex:7];
    contact.dealerName = [resultSet stringForColumnIndex:8];
    contact.carid = [resultSet stringForColumnIndex:9];
    contact.photo = [resultSet stringForColumnIndex:10];
    contact.carName = [resultSet stringForColumnIndex:11];
    contact.isComplete = [resultSet intForColumnIndex:12];
    contact.unReadNum = [resultSet intForColumnIndex:13];
    contact.mostRecentMessage = [resultSet stringForColumnIndex:14];
    contact.mostRecentTime = [resultSet doubleForColumnIndex:15];
    contact.mostRecentDate = [NSDate dateWithTimeIntervalSince1970:contact.mostRecentTime];
    contact.mostRecentStatus = [resultSet intForColumnIndex:16];
    contact.isDeleted =  [resultSet intForColumnIndex:17];
    
    return contact;
}

- (StorageMessage *)messageWithMesId:(NSInteger)mesId andJid:(NSString *)jid
{
    __block StorageMessage *result = nil;
    if (mesId >= 0 && jid != nil && jid.length > 0) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:jid];
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE mesId = ?",tableName];
            FMResultSet *resultSet = [db executeQuery:sql,@(mesId)];
            if([resultSet next])
            {
                result = [self messageFromResultSet:resultSet];
                result.jid = jid;
                result.fullJid = [NSString stringWithFormat:@"%@@%@/%@",jid,[IMCacheManage currentIMUserInfo].domain,kXMPP_USER_RESOURCE];
            }
            [resultSet close];
        }];
    }
    return result;
}

- (BOOL)updateStatusWithMessage:(StorageMessage *)message
{
    if (message != nil) {
        return [self updateStatus:message.status withMesId:message.mesId andJid:message.jid];
    }
    return NO;
}

- (BOOL)updateStatus:(NSInteger)status withMesId:(NSInteger)mesId andJid:(NSString *)jid
{
    __block BOOL result = NO;
    if (status >= 0 && mesId >=0 && jid != nil && jid.length > 0) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:jid];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET status = ? WHERE mesId = ?",tableName];
            result = [db executeUpdate:sql,@(status),@(mesId)];
            AMLog(@"Update Message::: %@ status:%d mesId:%d", result?@"OK":@"<<<<! Fail !>>>>", status, mesId);
        }];
    }
    return result;
}

- (BOOL)updateUnreadWithMessage:(StorageMessage *)message
{
    if (message != nil) {
        return [self updateUnread:message.unRead withMesId:message.mesId andJid:message.jid];
    }
    return NO;
}

- (BOOL)updateUnread:(NSInteger)unread withMesId:(NSInteger)mesId andJid:(NSString *)jid
{
    __block BOOL result = NO;
    if (unread >= 0 && mesId >=0 && jid != nil && jid.length > 0) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:jid];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET unRead = ? WHERE mesId = ?",tableName];
            result = [db executeUpdate:sql,@(unread),@(mesId)];
        }];
    }
    return result;
}

- (BOOL)updateMessageBodyWithMessage:(StorageMessage *)message
{
    if (message != nil) {
        return [self updateMessageBody:message.message withMesId:message.mesId andJid:message.jid];
    }
    return NO;
}

- (BOOL)updateMessageBody:(NSString *)mBody withMesId:(NSInteger)mesId andJid:(NSString *)jid
{
    __block BOOL result = NO;
    if (mBody != nil && mBody.length > 0 && mesId >=0 && jid != nil && jid.length > 0) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *tableName = [self tableNameWithJid:jid];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET message = ? WHERE mesId = ?",tableName];
            result = [db executeUpdate:sql,mBody,@(mesId)];
        }];
    }
    return result;
}

// 是否已经存在对应jid的用户信息
- (NSInteger)hasContactWithJid:(NSString *)jid
{
    __block BOOL result = NO;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {

        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count',contactId from Contacts where jid_short = ?", jid];
        while ([rs next])
        {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            NSInteger contactId = [rs intForColumn:@"contactId"];
            
            if (0 == count)
            {
                result = -1;
            }
            else
            {
                result = contactId;
            }
        }
        [rs close];
    }];
    
    return result;
}

// 是否已经存在对应contact的用户信息
- (NSInteger)hasContact:(StorageContact *)contact
{
    return [self hasContactWithJid:contact.shortJid];
}

//添加用户到本地数据库
- (NSInteger)insertContact:(StorageContact *)contact
{
    __block NSInteger result = -1;
    if (contact != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO Contacts (jid_short,jid_full,carJson,nickName,dealerid,salesid,memberid,dealerName,carid,photo,carName,unReadNum,mostRecentMessage,mostRecentTime,mostRecentStatus,isDeleted) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
            
            BOOL success = [db executeUpdate:sql,contact.shortJid,contact.fullJid,contact.carJson,contact.nickName,contact.dealerid,contact.memberid,contact.dealerName,contact.salesid,contact.carid,contact.photo,contact.carName,@(contact.unReadNum),contact.mostRecentMessage,@(contact.mostRecentTime),@(contact.mostRecentStatus),@(0)];
            
            if (success) {
                NSInteger contactId = (NSInteger)[db lastInsertRowId];
                contact.contactId = contactId;
                result = (NSInteger)contactId;
            }
        }];
    }
    return result;
}

//添加用户到本地数据库 (只创建jid和full_jid)
- (NSInteger)insertContactIfNessaryWithMessage:(StorageMessage *)message
{
    __block NSInteger result = -1;
    if (message != nil) {
        
        result = [self hasContactWithJid:message.jid];
        
        if (result >= 0) {
            return result;
        }else{
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO Contacts (jid_short,jid_full,unReadNum,mostRecentMessage,mostRecentTime,mostRecentStatus,isDeleted) VALUES (?,?,?,?,?,?,?)"];
                
                BOOL success = [db executeUpdate:sql,message.jid,message.fullJid,@(0),message.mostRecentMessageString,@(message.createTime),@(message.status),@(0)];
                
                if (success) {
                    long long contactId = [db lastInsertRowId];
                    result = (NSInteger)contactId;
                }
            }];
        }
    }
    return result;
}

//更新本地用户信息
- (BOOL)updateContact:(StorageContact *)contact
{
    __block BOOL result = NO;
    
    if (contact != nil && contact.shortJid != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET carJson = ?, nickName = ?, dealerid = ?, salesid = ?, memberid = ?, dealerName = ?, carid= ?, photo = ?, carName = ?, unReadNum = ?, isComplete = 1 WHERE jid_short = ?"];
            
            result = [db executeUpdate:sql,contact.carJson,contact.nickName,contact.dealerid,contact.salesid,contact.memberid,contact.dealerName,contact.carid,contact.photo,contact.carName, @(contact.unReadNum),contact.shortJid];
        }];
    }
    return result;
}

//从接口补全contact
- (BOOL)updateContactWithIMHistoryModel:(IMHistoryContactModel *)model
{
    __block BOOL result = NO;
    
    if (model != nil && model.nameto != nil) {
        NSString *tableName = [self tableNameWithJid:model.nameto];
        if ([self createMessageTableIfNessaryWithName:tableName]) {
            [self insertContactIfNessaryWithIMHistroyContactModel:model];
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET nickName = ?, dealerid = ?, salesid = ?, memberid = ?, dealerName = ?, carid = ?, photo = ?, carName = ?, isComplete = 1 WHERE jid_short = ?"];
                
                result = [db executeUpdate:sql,model.nicknameTo,model.dealerid,model.memberid,model.salesid,model.dealername,model.objectid.stringValue, model.carimgurl,model.carname,model.nameto];
            }];
        }
    }
    
    
    
    return result;
}

//添加用户到本地数据库 (只创建jid和full_jid)
- (NSInteger)insertContactIfNessaryWithIMHistroyContactModel:(IMHistoryContactModel *)model
{
    __block NSInteger result = -1;
    if (model != nil) {
        
        result = [self hasContactWithJid:model.nameto];
        
        if (result >= 0) {
            return result;
        }else{
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO Contacts (jid_short,jid_full,unReadNum,isDeleted) VALUES (?,?,?,?)"];
                
                BOOL success = [db executeUpdate:sql,model.nameto,[IMCacheManage getFullJid:model.nameto],@(0),@(0)];
                
                if (success) {
                    long long contactId = [db lastInsertRowId];
                    result = (NSInteger)contactId;
                }
            }];
        }
    }
    return result;
}

// 设置已读
- (BOOL)setMessagesIsReadedWithJid:(NSString *)jid
{
    __block BOOL result = NO;
    
    if (jid != nil && [self hasContactWithJid:jid] > 0) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET unReadNum = ? WHERE jid_short = ?"];
            
            result = [db executeUpdate:sql,@(0), jid];
        }];
    }
    return result;
}

//根据车辆卡片更新联系人
- (BOOL)updateContactWithCarMessage:(StorageMessage *)message
{
    __block BOOL result = NO;
    
    if ( message != nil && message.jid != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            CarMessageBody *carMes = (CarMessageBody *)message.mesBody;
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET carJson = ?, memberid = ?, carid = ?, photo = ?, carName = ?, isComplete = 0 WHERE jid_short = ?"];
            
            result = [db executeUpdate:sql,
                      carMes.carJson,
                      carMes.memberid.stringValue,
                      carMes.carid.stringValue,
                      carMes.carimage,
                      carMes.carname,
                      message.jid];
        }];
    }
    
    return result;
    
}
////根据车辆卡片更新联系人
//- (BOOL)updateContactWithCarMessage:(StorageMessage *)message
//{
//    __block BOOL result = NO;
//
//    if ( message != nil && message.jid != nil) {
//
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//            CarMessageBody *carMes = (CarMessageBody *)message.mesBody;
//
//            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET nickName = ?, dealerid = ?, dealerJson = ?, dealerName = ?, photo = ?, carName = ?  WHERE jid_short = ?"];
//
//            result = [db executeUpdate:sql,
//                      carMes.nickname,
//                      carMes.dealerid
//                      carMes.dealername,
//                      carMes.carimage,
//                      carMes.carname,
//                      message.jid];
//        }];
//    }
//
//    return result;
//
//}

//- (BOOL)updateContactLastInput:(StorageContact *)contact
//{
//    __block BOOL result = NO;
//    if (contact != nil && contact.shortJid != nil) {
//        
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//            
//            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET unReadNum = ?, lastInput = ? WHERE jid_short = ?"];
//            
//            result = [db executeUpdate:sql,@(contact.unReadNum),contact.lastInput,contact.shortJid];
//        }];
//    }
//    return result;
//}

//
- (BOOL)updateContactRecentMessage:(StorageMessage *)message
{
    __block BOOL result = NO;
    
    if ( message != nil && message.jid != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sql = nil;
            // 自动区分是否未读加1
            if (message.isOutgoing) {
                sql = [NSString stringWithFormat:@"UPDATE Contacts SET mostRecentMessage = ?, mostRecentTime = ?,mostRecentStatus = ?, isDeleted = 0 WHERE jid_short = ?"];
            } else {
                sql = [NSString stringWithFormat:@"UPDATE Contacts SET unReadNum=unReadNum+1, mostRecentMessage = ?, mostRecentTime = ?,mostRecentStatus = ?, isDeleted = 0 WHERE jid_short = ?"];
            }
            NSString *messageString = message.mostRecentMessageString;
            result = [db executeUpdate:sql,messageString,@(message.createTime),@(message.status),message.jid];
        }];
    }
    
    return result;
}

- (BOOL)updateContactRecentMessageWithContact:(StorageContact *)contact
{
    __block BOOL result = NO;
    
    if (contact != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET unReadNum = ?, mostRecentMessage = ?, mostRecentTime = ?,mostRecentStatus = ? WHERE jid_short = ?"];
            result = [db executeUpdate:sql,@(contact.unReadNum),contact.mostRecentMessage,@(contact.mostRecentTime),@(contact.mostRecentStatus),contact.shortJid];
        }];
    }
    
    return result;
}

- (BOOL)updateContactRecentMessageStatus:(StorageMessage *)message
{
    __block BOOL result = NO;
    
    if ( message != nil && message.jid != nil) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET mostRecentStatus = ? WHERE jid_short = ?"];
            
            result = [db executeUpdate:sql,@(message.status),message.jid];
        }];
    }
    
    return result;
}

- (NSMutableArray *)allContacts
{
    __block NSMutableArray *array = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        //ASC 升序  DESC 降序
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Contacts WHERE isComplete = 1 and isDeleted = 0 ORDER BY mostRecentTime DESC"];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        array = [NSMutableArray array];
        while ([resultSet next])
        {
            StorageContact *contact = [self contactFromResultSet:resultSet];
            [array addObject:contact];
        }
        [resultSet close];
    }];
    
    if (array.count == 0) {
        array = nil;
    }
    
    return array;
}

- (NSArray *)getInCompleteContacts
{
    __block NSMutableArray *array = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        //ASC 升序  DESC 降序
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Contacts WHERE isComplete = 0 and mostRecentMessage is NULL ORDER BY mostRecentTime DESC"];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        array = [NSMutableArray array];
        while ([resultSet next])
        {
            StorageContact *contact = [self contactFromResultSet:resultSet];
            [array addObject:contact];
        }
        [resultSet close];
    }];
    
    if (array.count == 0) {
        array = nil;
    }
    
    return array;
}

- (BOOL)cleanupContact:(StorageContact *)contact
{
    __block BOOL result = NO;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *tableName = [self tableNameWithJid:contact.shortJid];
        NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
        
        result = [db executeUpdate:dropSql];
        if (result) {
            
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM Contacts WHERE jid_short = ?"];
            result = [db executeUpdate:deleteSql,contact.shortJid];
        }
        
        if (result == NO) {
            *rollback = YES;
            return;
        }
    }];
    
    return result;
}

- (BOOL)cleanupMessagesWithContact:(StorageContact *)contact
{
    __block BOOL result = NO;
    
    if (contact) {
        
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *tableName = [self tableNameWithJid:contact.shortJid];
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
            result = [db executeUpdate:deleteSql];
            
            if (result) {
                NSString *sql = [NSString stringWithFormat:@"UPDATE Contacts SET unReadNum = ?, mostRecentMessage = ?,mostRecentStatus = ? WHERE jid_short = ?"];
                result = [db executeUpdate:sql,@(0),@"",@(0),contact.shortJid];
                
                if (result) {
                    NSString *sqldelete = [NSString stringWithFormat:@"UPDATE Contacts SET isDeleted = 1 WHERE jid_short = ?"];
                    result = [db executeUpdate:sqldelete,contact.shortJid];
                    
                    if (result) {
                        contact.unReadNum = 0;
                        contact.mostRecentMessage = @"";
                        contact.mostRecentStatus = 0;
                    }else{
                        *rollback = YES;
                    }
                }
            }
        }];
    }
    
    return result;
}

@end
