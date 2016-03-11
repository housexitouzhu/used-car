//
//  XMPPManager.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "XMPPManager.h"
#import "MessageBody.h"
#import "IMCacheManage.h"
#import "IMUserInfoModel.h"
#import "StorageMessage.h"
#import "XMPPDBCacheManager.h"

@interface XMPPManager()<XMPPStreamDelegate,UIAlertViewDelegate,XMPPvCardTempModuleDelegate,XMPPvCardTempModuleStorage>

@end

@implementation XMPPManager

- (BOOL)configureWithParent:(XMPPvCardTempModule *)aParent queue:(dispatch_queue_t)queue
{
    return YES;
}

/**
 * Returns a vCardTemp object or nil
 **/
- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    return nil;
}

/**
 * Used to set the vCardTemp object when we get it from the XMPP server.
 **/
- (void)setvCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    
}

- (XMPPvCardTemp *)myvCardTempForXMPPStream:(XMPPStream *)stream
{
    return nil;
}

- (BOOL)shouldFetchvCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
{
    return YES;
}

+ (id)sharedManager
{
    static XMPPManager *xmppManager = nil;
    if (xmppManager == nil) {
        xmppManager = [[XMPPManager alloc] init];
        [xmppManager setupStream];
    }
    return xmppManager;
}

-(NSMutableSet *)delegateQueue
{
    if (_delegateQueue == nil) {
        _delegateQueue = [NSMutableSet set];
    }
    return _delegateQueue;
}

- (void)addToDelegateQueue:(id<XMPPManagerDelegate>) delegate
{
    if (delegate != nil && ![self.delegateQueue containsObject:delegate]) {
        [self.delegateQueue addObject:delegate];
    }
}

- (void)removeFromDelegateQueue:(id<XMPPManagerDelegate>) delegate
{
    if (delegate != nil) {
        [self.delegateQueue removeObject:delegate];
    }
}

- (void)setupStream
{
    self.xStream = [[XMPPStream alloc] init];
    [self.xStream setKeepAliveInterval:30];
    [self.xStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.xReconnect = [[XMPPReconnect alloc] init];
    [self.xReconnect activate:self.xStream];
    
    self.xRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    self.xRoster = [[XMPPRoster alloc]initWithRosterStorage:self.xRosterStorage];
    [self.xRoster activate:self.xStream];
    [self.xRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.xCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self];
    [self.xCard activate:self.xStream];
    [self.xCard addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (BOOL)connectToServer
{
    IMUserInfoModel *model = [IMCacheManage currentIMUserInfo];
    NSString *fulljid = model.fullJid;
    NSString *ps = model.pwd;
    
    NSString *host = model.server;
    NSInteger port = model.port.integerValue;
    
    if (fulljid == nil || ps == nil || host == nil || port == 0) {
        return NO;
    }
    
    [self.xStream setHostName:host];
    [self.xStream setHostPort:port];
    
    XMPPJID *myjid = [XMPPJID jidWithString:fulljid];
    NSError *error ;
    [self.xStream setMyJID:myjid];
    
    if (![self.xStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        AMLog(@"connectToServer error : %@",error.description);
        return NO;
    }
    
    return YES;
}

- (void)logout
{
    [self.xStream disconnectAfterSending];
}

- (BOOL)registerWithPassword:(NSString *)password
{
    NSError *error;
    
    BOOL result = [self.xStream registerWithPassword:password error:&error];
    
    if (result == NO) {
        // 注册时发生错误
        
        
    }
    return result;
}

- (void)sendStorageMessage:(StorageMessage *)message
{
    NSInteger messageType = NSNotFound;
    switch (message.type) {
        case IMMessageTypeText:
        {
            messageType = kXMPP_MESSAGE_TEXT;
        }
            break;
        case IMMessageTypeCar:
        {
            messageType = kXMPP_MESSAGE_CAR;
        }
            break;
        case IMMessageTypeImage:
        {
            messageType = kXMPP_MESSAGE_IMAGE;
        }
            break;
        case IMMessageTypeVoice:
        {
            messageType = kXMPP_MESSAGE_VOICE;
        }
            break;
        case IMMessageTypeLocation:
        {
            messageType = kXMPP_MESSAGE_LOCATION;
        }
            break;
        case IMMessageTypeVCard:
        {
            messageType = kXMPP_MESSAGE_VCARD;
        }
            break;
        default:
            break;
    }
    
    XMPPJID *jid = [XMPPJID jidWithString:message.fullJid];
    
//    XMPPMessage *xMessage = [XMPPMessage messageWithType:[NSString stringWithFormat:@"%d",messageType] to:jid];
    XMPPMessage *xMessage = [XMPPMessage messageWithType:@"chat" to:jid];
    [xMessage addBody:message.message];
    [xMessage setMessageId:message.mesId];
    [self.xStream sendElement:xMessage];
}

- (void)sendNoneInsertMessage:(XMPPMessage *)message
{
    [self.xStream sendElement:message];
}

- (void)addUser:(XMPPJID *)jIdObj withNickname:(NSString *)nickName
{
    [self.xRoster addUser:jIdObj withNickname:nickName];
}

- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp
{
    [self.xCard updateMyvCardTemp:vCardTemp];
}

- (void)fetchvCardTempForJID:(XMPPJID *)jid
{
    [self.xCard fetchvCardTempForJID:jid ignoreStorage:YES];
}

// 用来枚举delegateQueue中的delegate并进行调用
- (void)callDelegateWithSelector:(SEL)selector andObject:(id)object
{
    [self.delegateQueue enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj respondsToSelector:selector]) {
            [obj performSelector:selector withObject:object afterDelay:0];
        }
    }];
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    AMLog(@"xmppStreamWillConnect");
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    AMLog(@"xmppStreamDidConnect");
    
    if ([IMCacheManage currentIMUserInfo].pwd) {
        NSError *error ;
        if (![self.xStream authenticateWithPassword:[IMCacheManage currentIMUserInfo].pwd error:&error]) {
            AMLog(@"error authenticate : %@",error.description);
        }
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    AMLog(@"xmppStreamDidAuthenticate");
    
//    [self showAlertView:@"登陆验证成功!"];
    
//#warning 现在是一个弱在线模式，所以登陆成功后不应该广播自己的在线状态，(上线时考虑是否去除该逻辑)
    // 认证通过后广播自己的状态
    /*
     presence 的状态：
     available 上线
     away 离开
     do not disturb 忙碌
     unavailable 下线
     */
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xStream sendElement:presence];
    [self callDelegateWithSelector:@selector(didAuthenticate) andObject:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    AMLog(@"didNotAuthenticate: %@",error.description);
    
//    [self showAlertView:@"登陆验证失败，请重试"];
    
    [self callDelegateWithSelector:@selector(didNotAuthenticate) andObject:nil];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
//    [self showAlertView:@"用户注册成功"];
    
    [self callDelegateWithSelector:@selector(didRegister) andObject:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
//    [self showAlertView:@"当前用户已经存在"];
    
    [self callDelegateWithSelector:@selector(didNotRegister) andObject:nil];
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    AMLog(@"xmppStreamConnectDidTimeout");
    [self callDelegateWithSelector:@selector(streamConnectDidTimeout:) andObject:sender];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    AMLog(@"xmppStreamDidDisconnect: %@ %@",error.description , sender.myJID);
    [self callDelegateWithSelector:@selector(streamDidDisconnected:) andObject:sender];
}

- (void)willSendMessage:(XMPPMessage *)message
{
    //此时保存message到数据库，且消息为 等待发送 状态
    StorageMessage *sMessage = [[StorageMessage alloc] initWithXMPPMessage:message andOutgoing:YES];
    sMessage.status = IMMessageStatusSending;
    
    // 收到消息后，存储到本地数据库缓存
    NSInteger mesId = [[XMPPDBCacheManager sharedManager] insertMessage:sMessage];
    
    [self callDelegateWithSelector:@selector(willSendMessage:) andObject:sMessage];
    [message setMessageId:mesId];
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    AMLog(@"didSendMessage:%@",message.description);
    
    //此时保存message到数据库，且消息为 发送成功 状态
    int mesId = [[message messageId] intValue];
    NSString *jid = message.toJid;
    
    StorageMessage *sMessage = [[StorageMessage alloc] initWithXMPPMessage:message andOutgoing:YES];
    //修改message状态，并同步到数据库；
    [[XMPPDBCacheManager sharedManager] updateStatus:IMMessageStatusNormal withMesId:mesId andJid:jid];
    
    //更新用户信息
    if (sMessage.type == IMMessageTypeCar) {
        [[XMPPDBCacheManager sharedManager] updateContactWithCarMessage:sMessage];
    }
    
    //更新最新接收到的消息内容
    [[XMPPDBCacheManager sharedManager] updateContactRecentMessage:sMessage];
    
    [self callDelegateWithSelector:@selector(didSendMessage:) andObject:@(mesId)];
    [self callDelegateWithSelector:@selector(didSendXMPPMessage:) andObject:message];

    
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    AMLog(@"didSendPresence:%@",presence.description);
    
    [self callDelegateWithSelector:@selector(didSendPresence:) andObject:presence];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    AMLog(@"didFailToSendIQ:%@",error.description);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    AMLog(@"didFailToSendMessage:%@",error.description);
    
    //此时保存message到数据库，且消息为 发送成功 状态
    int mesId = [[message messageId] intValue];
    NSString *jid = message.toJid;
    
    //修改message状态，并同步到数据库；
    [[XMPPDBCacheManager sharedManager] updateStatus:IMMessageStatusFailure withMesId:mesId andJid:jid];
    
    [self callDelegateWithSelector:@selector(didFailToSendMessage:) andObject:@(mesId)];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    AMLog(@"didFailToSendPresence:%@",error.description);
    
    [self callDelegateWithSelector:@selector(didFailToSendPresence:) andObject:presence];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    AMLog(@"didReceiveMessage:%@",message.description);
    
    NSString *childName = [[message childAtIndex:0] name];
    if ([childName isEqualToString:@"body"]) {
        
        StorageMessage *sMessage = [[StorageMessage alloc] initWithXMPPMessage:message andOutgoing:NO];
        
        if (sMessage.type == IMMessageTypeVoice) {
            sMessage.unRead = 1;
        }
        
        // 收到消息后，存储到本地数据库缓存
        [[XMPPDBCacheManager sharedManager] insertMessage:sMessage withContactCheck:YES];
        
        //更新最新接收到的消息内容
        [[XMPPDBCacheManager sharedManager] updateContactRecentMessage:sMessage];
        //更新用户信息
        if (sMessage.type == IMMessageTypeCar) {
            [[XMPPDBCacheManager sharedManager] updateContactWithCarMessage:sMessage];
        }
        
        [self callDelegateWithSelector:@selector(didReceiveMessage:) andObject:sMessage];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    AMLog(@"didReceivePresence:%@",presence.description);
    
    [self callDelegateWithSelector:@selector(didReceivePresence:) andObject:presence];
}

#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    // 收到订阅状态的请求
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:@"添加你为好友~" delegate:self cancelButtonTitle:@"不添加" otherButtonTitles:@"添加", nil];
    alertView.tag = 10;
    
    [alertView show];
}

#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    AMLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    AMLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}

#pragma mark - XMPPvCardTempModuleDelegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    AMLog(@" get fetch VCard : %@",vCardTemp);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
}

#pragma mark - showAlertView

-(void)showAlertView:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10 && buttonIndex == 1) {
        XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
        [[self xRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        //不同意订阅状态
        //      [self.xmppRoster rejectPresenceSubscriptionRequestFrom:jid] ;
    }
}


@end
