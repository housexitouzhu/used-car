//
//  XMPPDBCacheManager.h
//  IMDemo
//
//  Created by jun on 11/8/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "StorageMessage.h"
#import "StorageContact.h"
@class IMHistoryContactModel;

@interface XMPPDBCacheManager : NSObject

+ (id)sharedManager;

/************************************ 消息 操作 ****************************************/

/*!
 *  @method
 *  @abstract  检测jid的聊天记录表是否存在，不存在创建一个
 *  @param jid
 *  @return 是否创建成功
 */
- (BOOL)createMessageTableIfNessaryWithName:(NSString *)tableName;

/*!
 *  @method
 *  @abstract  添加信息到数据库
 *  @param message    要存储的message
 *  @param isOutgoing 是发出还是接收
 *  @return 插入后自增Id
 */
- (NSInteger)insertMessage:(StorageMessage *)message;

- (NSInteger)insertMessage:(StorageMessage *)message withContactCheck:(BOOL)check;

/*!
 *  @method
 *  @abstract  按页提取数据 (从0开始)第一页的数据
 *  @param jid
 *  @return
 */
- (NSArray *)firstPageMessagesWithJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  按页提取数据 (从0开始)
 *  @param page 要拿的页数
 *  @param jid
 *  @return
 */
- (NSArray *)messagesWithPage:(NSInteger)page andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  获取下一页的消息
 *  @param message
 *  @return
 */
- (NSArray *)nextPageMessagesWithMessage:(StorageMessage *)message;

/*!
 *  @method
 *  @abstract 根据mesId和jid获取指定Message
 *  @param mesId
 *  @param jid
 *  @return 查找到的Message
 */
- (StorageMessage *)messageWithMesId:(NSInteger)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract update message 的status属性
 *  @param message
 */
- (BOOL)updateStatusWithMessage:(StorageMessage *)message;

/*!
 *  @method
 *  @abstract  更新对应mesId的消息的状态为指定状态
 *  @param status
 *  @param mesId
 *  @param jid
 *  @return
 */
- (BOOL)updateStatus:(NSInteger)status withMesId:(NSInteger)mesId andJid:(NSString *)jid;

- (BOOL)updateUnreadWithMessage:(StorageMessage *)message;

- (BOOL)updateUnread:(NSInteger)unread withMesId:(NSInteger)mesId andJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  更新相应消息的Message Body
 *  @param message
 *  @return
 */
- (BOOL)updateMessageBodyWithMessage:(StorageMessage *)message;




/*!
 *  @method
 *  @abstract  更新相应消息的Message Body
 *  @param mBody
 *  @param mesId
 *  @param jid
 *  @return
 */
- (BOOL)updateMessageBody:(NSString *)mBody withMesId:(NSInteger)mesId andJid:(NSString *)jid;

/************************************ 用户 操作 ****************************************/

/*!
 *  @method
 *  @abstract 是否已经存在对应jid的用户信息
 *  @param jid
 *  @return 
 */
- (NSInteger)hasContactWithJid:(NSString *)jid;

/*!
 *  @method
 *  @abstract  是否已经存在对应contact的用户信息
 *  @param contact
 *  @return
 */
- (NSInteger)hasContact:(StorageContact *)contact;

/*!
 *  @method
 *  @abstract  添加用户到本地数据库
 *  @param contact
 *  @return
 */
- (NSInteger)insertContact:(StorageContact *)contact;

//添加用户到本地数据库 (只创建jid和full_jid)
- (NSInteger)insertContactIfNessaryWithMessage:(StorageMessage *)message;

//更新本地用户信息
- (BOOL)updateContact:(StorageContact *)contact;

//从接口补全contact
- (BOOL)updateContactWithIMHistoryModel:(IMHistoryContactModel *)model;

//设置消息已读
- (BOOL)setMessagesIsReadedWithJid:(NSString *)jid;

//根据车辆卡片更新联系人
- (BOOL)updateContactWithCarMessage:(StorageMessage *)message;

////更新用户的最后输入信息和未读消息数
//- (BOOL)updateContactLastInput:(StorageContact *)contact;

//更新用户的最新消息
- (BOOL)updateContactRecentMessage:(StorageMessage *)message;

//更新用户的最新消息
- (BOOL)updateContactRecentMessageWithContact:(StorageContact *)contact;

//更新用户的最新消息的发生那个状态
- (BOOL)updateContactRecentMessageStatus:(StorageMessage *)message;

//获取当前用户的所有联系人列表
- (NSMutableArray *)allContacts;

//获取不完整的联系人
- (NSArray *)getInCompleteContacts;

/************************************  删除指定用户及聊天记录的操作  ****************************************/

//删除联系人和历史消息
- (BOOL)cleanupContact:(StorageContact *)contact;

//只清除联系人聊天记录，不删联系人
- (BOOL)cleanupMessagesWithContact:(StorageContact *)contact;

@end
