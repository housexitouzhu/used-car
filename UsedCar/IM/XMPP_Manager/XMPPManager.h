//
//  XMPPManager.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@class StorageMessage;

@protocol XMPPManagerDelegate;

@interface XMPPManager : NSObject

@property (strong,nonatomic) NSMutableSet *delegateQueue;

@property (strong,nonatomic) XMPPStream *xStream;
@property (strong,nonatomic) XMPPRoster *xRoster;
@property (strong,nonatomic) XMPPRosterCoreDataStorage *xRosterStorage;
@property (strong,nonatomic) XMPPReconnect *xReconnect;

@property (strong,nonatomic) XMPPvCardTempModule *xCard;

+ (id)sharedManager;

/*!
 *  @method
 *  @abstract  添加代理到代理队列
 *  @param delegate 代理对象
 */
- (void)addToDelegateQueue:(id<XMPPManagerDelegate>) delegate;

//移除代理到代理队列
- (void)removeFromDelegateQueue:(id<XMPPManagerDelegate>) delegate;

/*!
 *  @method
 *  @abstract  初始化Stream
 */
- (void)setupStream;

// 连接到服务器
- (BOOL)connectToServer;

// 断开Socket
- (void)logout;

/************************************ 注册操作 ****************************************/
- (BOOL)registerWithPassword:(NSString *)password;

/************************************ Message操作 ****************************************/

// 发送消息
- (void)sendStorageMessage:(StorageMessage *)message;

// 发送不存储的消息，针对图片和语音，属于先上传再发送XMPPMessage的，测试，对应的消息缓存已经存在
// 即不调用本地的willSend做插入数据库的缓存操作，但是会自动调用本地的didSend，做发送状态的更新
- (void)sendNoneInsertMessage:(XMPPMessage *)message;

/************************************ Roster操作 ****************************************/

/*!
 *  @method
 *  @abstract  添加好友
 *  @param jIdObj XMPPJID对象
 */
- (void)addUser:(XMPPJID *)jIdObj withNickname:(NSString *)nickName;

/************************************ vCard操作 ****************************************/

//更新自己的名片信息
- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp;

// 查找名片信息
- (void)fetchvCardTempForJID:(XMPPJID *)jid;

/*!
 *  @method
 *  @abstract  测试用的展示提醒的临时函数
 *  @param message 待展示的内容
 */
-(void)showAlertView:(NSString *)message;

@end

@protocol XMPPManagerDelegate <NSObject>

@optional

/*!
 *  @method
 *  @abstract  发送消息成功
 *  @param message 发送成功的XMPPMessage对象
 */

- (void) willSendMessage:(StorageMessage *)message;

- (void) didSendMessage:(NSNumber *)mesId;

- (void) didSendXMPPMessage:(XMPPMessage *)message;

- (void) didReceiveMessage:(StorageMessage *)message;

- (void) didFailToSendMessage:(NSNumber *)mesId;

- (void) didSendPresence:(XMPPPresence *)presence;

- (void) didReceivePresence:(XMPPPresence *)presence;

- (void) didFailToSendPresence:(XMPPPresence *)presence;

- (void) didAuthenticate;

- (void) didNotAuthenticate;

- (void) didRegister;

- (void) didNotRegister;

- (void) streamDidDisconnected:(XMPPStream *)sender;

- (void) streamConnectDidTimeout:(XMPPStream *)sender;

@end