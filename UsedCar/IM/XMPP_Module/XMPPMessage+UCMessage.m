//
//  XMPPMessage+UCMessage.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "XMPPMessage+UCMessage.h"
#import "NSXMLElement+XMPP.h"

@implementation XMPPMessage (UCMessage)

- (NSString *)fromJid
{
    NSString *fromStr = self.fromStr;
    NSRange range = [fromStr rangeOfString:@"@"];
    if (range.location > 0) {
        return [fromStr substringToIndex:range.location];
    }
    
    return fromStr;
}

- (NSString *)toJid
{
    NSString *toStr = self.toStr;
    NSRange range = [toStr rangeOfString:@"@"];
    if (range.location > 0) {
        return [toStr substringToIndex:range.location];
    }
    
    return toStr;
}

- (void)setMessageId:(int)theId
{
    if(theId >= 0)
    {
        [self addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%d",theId]];
    }
}

- (NSString *)messageId
{
    return [[self attributeForName:@"id"] stringValue];
}

#pragma mark - 

- (NSInteger)messageType{
    
    if (self.body != nil && self.body.length>0) {
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        NSInteger type = [[jsonObj objectForKey:@"type"] integerValue];
        return type;
    }
    else{
        return kXMPP_MESSAGE_UNKNOWN;
    }
//    return [[[self attributeForName:@"type"] stringValue] integerValue];
}

- (BOOL)isChatMessage
{
    return [self messageType] == kXMPP_MESSAGE_TEXT;
}

- (BOOL)isChatMessageWithBody
{
    if ([self isChatMessage])
    {
        return [self isMessageWithBody];
    }
    
    return NO;
}

- (BOOL)isVoiceMessage
{
    return [self messageType] == kXMPP_MESSAGE_VOICE;
}

- (BOOL)isVoiceMessageWithBody
{
    if ([self isVoiceMessage])
    {
        return [self isMessageWithBody];
    }
    
    return NO;
}

- (BOOL)isImageMessage
{
    return [self messageType] == kXMPP_MESSAGE_IMAGE;
}

- (BOOL)isImageMessageWithBody
{
    if ([self isVoiceMessage])
    {
        return [self isMessageWithBody];
    }
    
    return NO;
}


- (BOOL)isCarMessage
{
    return [self messageType] == kXMPP_MESSAGE_CAR;
}

- (BOOL)isCarMessageWithBody
{
    if ([self isCarMessage])
    {
        return [self isMessageWithBody];
    }
    
    return NO;
}

- (BOOL)isLocationMessage{
    return [self messageType] == kXMPP_MESSAGE_LOCATION;
}

- (BOOL)isLocationMessageWithBody{
    if ([self isLocationMessage])
    {
        return [self isLocationMessage];
    }
    
    return NO;
}

- (BOOL)isVCardMessage{
    return [self messageType] == kXMPP_MESSAGE_VCARD;
}

- (BOOL)isVCardMessageWithBody{
    if ([self isVCardMessage])
    {
        return [self isVCardMessage];
    }
    
    return NO;
}

@end
