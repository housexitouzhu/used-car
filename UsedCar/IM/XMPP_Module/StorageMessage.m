//
//  StorageMessage.m
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "StorageMessage.h"

#import "MessageBodyFactory.h"
#import "TextMessageBody.h"
#import "CarMessageBody.h"
#import "StorageContact.h"
#import "RegexKitLite.h"
#import "EmojiFaceData.h"

@implementation StorageMessage

- (id)initWithXMPPMessage:(XMPPMessage *)xMessage andOutgoing:(BOOL)outgoing
{
    if (self = [super init]) {
        
        if (outgoing) {
            self.isOutgoing = 1;
            self.jid = xMessage.toJid;
            self.fullJid = xMessage.toStr;
        }else{
            self.isOutgoing = 0;
            self.jid = xMessage.fromJid;
            self.fullJid = xMessage.fromStr;
        }
        
        if ([[[xMessage attributeForName:@"type"] stringValue] isEqualToString:@"chat"]) {
            if (xMessage.isChatMessage) {
                self.type = IMMessageTypeText;
            }else if (xMessage.isVoiceMessage){
                self.type = IMMessageTypeVoice;
            }else if (xMessage.isImageMessage){
                self.type = IMMessageTypeImage;
            }else if (xMessage.isCarMessage){
                self.type = IMMessageTypeCar;
            }
            self.mesBody = [MessageBodyFactory messageBodyWithJsonString:xMessage.body];
            
            self.message = xMessage.body;
            
            NSDate *timestamp = [xMessage delayedDeliveryDate];
            if (timestamp){
                self.timestamp = timestamp;
                self.createTime = [timestamp timeIntervalSince1970];
            }
            else
            {
                self.timestamp = [[NSDate alloc] init];
                self.createTime = [self.timestamp timeIntervalSince1970];
            }
        }
        
//        switch (self.type) {
//            case IMMessageTypeVoice:
//            case IMMessageTypeImage:
//            case IMMessageTypeCar:
//            {
//                self.mesBody = [MessageBodyFactory messageBodyWithJsonString:xMessage.body];
//            }
//                break;
//            default:
//                break;
//        }
        
        
    }
    return self;
}

- (id)initWithSendImage:(UIImage *)image andContact:(StorageContact *)contact
{
    if (self = [super init]) {
        self.type = IMMessageTypeImage;
        self.status = IMMessageStatusSending;
        self.originalImage = image;
        self.isOutgoing = YES;
        self.jid = contact.shortJid;
        self.fullJid = contact.fullJid;
        self.timestamp = [[NSDate alloc] init];
        self.createTime = [self.timestamp timeIntervalSince1970];
    }
    return self;
}

- (id)initWithSendImage:(UIImage *)image thumImage:(UIImage *)thumImage andContact:(StorageContact *)contact
{
    if (self = [super init]) {
        self.type = IMMessageTypeImage;
        self.status = IMMessageStatusSending;
        self.originalImage = image;
        self.smallImage = thumImage;
        self.isOutgoing = YES;
        self.jid = contact.shortJid;
        self.fullJid = contact.fullJid;
        self.timestamp = [[NSDate alloc] init];
        self.createTime = [self.timestamp timeIntervalSince1970];
    }
    return self;
}

- (id)initWithSendVoice:(NSData *)voiceData andContact:(StorageContact *)contact
{
    if (self = [super init]) {
        self.type = IMMessageTypeVoice;
        self.status = IMMessageStatusSending;
        self.amrData = voiceData;
        self.isOutgoing = YES;
        self.jid = contact.shortJid;
        self.fullJid = contact.fullJid;
        self.timestamp = [[NSDate alloc] init];
        self.createTime = [self.timestamp timeIntervalSince1970];
    }
    return self;
}

- (id)initWithText:(TextMessageBody *)body andContact:(StorageContact *)contact
{
    if (self = [super init]) {
        self.type = IMMessageTypeText;
        self.status = IMMessageStatusSending;
        self.message = body.jsonString;
        self.mesBody = body;
        self.isOutgoing = YES;
        self.jid = contact.shortJid;
        self.fullJid = contact.fullJid;
        self.timestamp = [[NSDate alloc] init];
        self.createTime = [self.timestamp timeIntervalSince1970];
    }
    return self;
}

- (id)initWithSpecMessageBody:(CarMessageBody *)body andContact:(StorageContact *)contact
{
    if (self = [super init]) {
        self.type = IMMessageTypeCar;
        self.status = IMMessageStatusSending;
        self.message = body.jsonString;
        self.mesBody = body;
        self.isOutgoing = YES;
        self.jid = contact.shortJid;
        self.fullJid = contact.fullJid;
        self.timestamp = [[NSDate alloc] init];
        self.createTime = [self.timestamp timeIntervalSince1970];
    }
    return self;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    switch (self.type) {
        case IMMessageTypeText:
        {
            self.noneFaceMessage = [self createNoneFaceMessage:message];
        }
            break;
        case IMMessageTypeVoice:
        case IMMessageTypeImage:
        case IMMessageTypeCar:
        {
            self.mesBody = [MessageBodyFactory messageBodyWithJsonString:message];
        }
            break;
        default:
            break;
    }
}

- (NSString *)mostRecentMessageString
{

    NSString *messageString = @"";
    switch (self.type) {
        case IMMessageTypeText:
        {
            messageString = ((TextMessageBody *)self.mesBody).message;
        }
            break;
        case IMMessageTypeImage:
        {
            messageString = @"[图片]";
        }
            break;
        case IMMessageTypeVoice:
        {
            messageString = @"[语音]";
        }
            break;
        case IMMessageTypeCar:
        {
            messageString = @"[车辆]";
        }
            break;
        default:
            break;
    }
    
    return messageString;
}


- (NSString *)createNoneFaceMessage:(NSString *)originalMessage
{
    NSMutableString *originalMessageCopy = [[NSMutableString alloc] initWithString:originalMessage];
    
    NSString *regString = @"\\[[\u2E80-\u9FFFa]{1,3}\\]";
    
    [originalMessageCopy replaceOccurrencesOfRegex:regString
                                        usingBlock:^NSString *(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                                            
                                            //NSLog(@" %@  ",capturedStrings);
                                            if ([EmojiFaceData isContainsEmojiText:*capturedStrings]) {
                                                return @"😄";
                                            }
                                            return *capturedStrings;
                                        }];

    
    return originalMessageCopy;
}

@end
