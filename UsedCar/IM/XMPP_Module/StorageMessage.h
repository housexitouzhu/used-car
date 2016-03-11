//
//  StorageMessage.h
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPMessage+UCMessage.h"
#import "NSXMLElement+XEP_0203.h"

typedef enum : NSUInteger {
    IMMessageTypeNoneInit = 0,
    IMMessageTypeText = 1,
    IMMessageTypeImage = 2,
    IMMessageTypeVoice = 3,
    IMMessageTypeCar = 4,
    IMMessageTypeLocation = 5,
    IMMessageTypeVCard = 6
} IMMessageType;


typedef enum : NSUInteger {
    IMMessageStatusNormal = 0,
    IMMessageStatusSending = 1,
    IMMessageStatusFailure = 2,
    IMMessageStatusDownLoadFailure = 3
} IMMessageStatus;


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
 CREATE INDEX Index2 ON chat_message (status);
 CREATE INDEX Index0 ON chat_message (mesId);
 CREATE INDEX Index1 ON chat_message (createTime);
 
 */

@class MessageBody,TextMessageBody,CarMessageBody,ImageMessageBody,StorageContact;

@interface StorageMessage : NSObject

/*!
 *  @property
 *  @abstract  消息id，用于本地查找、加载缓存的唯一标识
 */
@property (nonatomic) NSInteger mesId;

/*!
 *  @property
 *  @abstract  消息体
 */
@property (nonatomic,strong) NSString *message;

/*!
 *  @property
 *  @abstract  替换掉表情字符的message文本，用于计算文本尺寸
 */
@property (nonatomic,strong) NSString *noneFaceMessage;

/*!
 *  @property
 *  @abstract  对message解析出来的不同类型的messageBody
 */
@property (nonatomic,strong) MessageBody *mesBody;

/*!
 *  @property
 *  @abstract  Message类型
 */
@property (nonatomic) IMMessageType type;

/*!
 *  @property
 *  @abstract  消息状态：正常状态、（等待）发送中、发送失败
 */
@property (nonatomic) IMMessageStatus status;

/*!
 *  @property
 *  @abstract  消息是否已读
 */
@property (nonatomic) NSInteger unRead;

/*!
 *  @property
 *  @abstract  图片状态
 */
@property (nonatomic) NSInteger imgStatus;

/*!
 *  @property
 *  @abstract  语音状态
 */
@property (nonatomic) NSInteger voiceStatus;

/*!
 *  @property
 *  @abstract  消息时间戳
 */
@property (nonatomic) double createTime;

/*!
 *  @property
 *  @abstract  消息时间戳
 */
@property (nonatomic,strong) NSDate *timestamp;

/*!
 *  @property
 *  @abstract  消息是发出的还是接收的；
 */
@property (nonatomic) NSInteger isOutgoing;

@property (nonatomic,strong) NSString *jid;

@property (nonatomic,strong) NSString *fullJid;

@property (nonatomic) NSInteger duration;

@property (nonatomic,strong) UIImage *smallImage;

@property (nonatomic,strong) UIImage *originalImage;

@property (nonatomic,strong) NSData *amrData;

@property (nonatomic,strong) NSData *wavData;

- (id)initWithXMPPMessage:(XMPPMessage *)xMessage andOutgoing:(BOOL)outgoing;

- (id)initWithSendImage:(UIImage *)image andContact:(StorageContact *)contact;

- (id)initWithSendImage:(UIImage *)image thumImage:(UIImage *)thumImage andContact:(StorageContact *)contact;

- (id)initWithSendVoice:(NSData *)voiceData andContact:(StorageContact *)contact;

- (id)initWithText:(TextMessageBody *)body andContact:(StorageContact *)contact;

- (id)initWithSpecMessageBody:(CarMessageBody *)body andContact:(StorageContact *)contact;

- (NSString *)mostRecentMessageString;

@end
