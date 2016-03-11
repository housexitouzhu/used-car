//
//  XMPPMessage+UCMessage.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "XMPPMessage.h"

#define kXMPP_MESSAGE_UNKNOWN  000
#define kXMPP_MESSAGE_TEXT     100
#define kXMPP_MESSAGE_IMAGE    200
#define kXMPP_MESSAGE_VOICE    300
#define kXMPP_MESSAGE_CAR      400
#define kXMPP_MESSAGE_LOCATION 500
#define kXMPP_MESSAGE_VCARD    600


@interface XMPPMessage (UCMessage)

- (NSString *)fromJid;

- (NSString *)toJid;

- (void)setMessageId:(int)theId;

- (NSString *)messageId;

- (BOOL)isChatMessage;
- (BOOL)isChatMessageWithBody;

/*!
 *  @method
 *  @abstract  是否是语音消息
 *  @return
 */
- (BOOL)isVoiceMessage;
- (BOOL)isVoiceMessageWithBody;

/*!
 *  @method
 *  @abstract  是否是图片消息
 *  @return
 */
- (BOOL)isImageMessage;
- (BOOL)isImageMessageWithBody;

/*!
 *  @method
 *  @abstract  是否是车型消息
 *  @return
 */
- (BOOL)isCarMessage;
- (BOOL)isCarMessageWithBody;

/*!
 *  @method
 *  @abstract  是否是地理位置消息
 *  @return
 */
- (BOOL)isLocationMessage;
- (BOOL)isLocationMessageWithBody;

/*!
 *  @method
 *  @abstract  是否是名片消息
 *  @return
 */
- (BOOL)isVCardMessage;
- (BOOL)isVCardMessageWithBody;

@end
