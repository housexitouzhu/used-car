//
//  MessageBodyFactory.m
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "MessageBodyFactory.h"

#import "MessageBody.h"
#import "TextMessageBody.h"
#import "ImageMessageBody.h"
#import "VoiceMessageBody.h"
#import "CarMessageBody.h"

@implementation MessageBodyFactory

+ (MessageBody *)messageBodyWithJsonString:(NSString *)jsonString
{
    if (jsonString != nil && jsonString.length>0) {
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        
        NSInteger type = [[jsonObj objectForKey:@"type"] integerValue];
        if (type == kXMPP_MESSAGE_TEXT) {
            return [[TextMessageBody alloc] initWithJsonObj:jsonObj];
        }else if (type == kXMPP_MESSAGE_IMAGE) {
            
            return [[ImageMessageBody alloc] initWithJsonObj:jsonObj];
            
        }else if (type == kXMPP_MESSAGE_VOICE){
            
            return [[VoiceMessageBody alloc] initWithJsonObj:jsonObj];
            
        }else if (type == kXMPP_MESSAGE_CAR){
            
            return [[CarMessageBody alloc] initWithJsonObj:jsonObj];
            
        }else{
            
            // other types, did nothing
        }
    }
    return nil;
}

+ (MessageBody *)messageBodyWithType:(NSNumber *)type
{
    NSInteger typeint = type.integerValue;
    if (typeint == kXMPP_MESSAGE_TEXT) {
        return [[TextMessageBody alloc] init];
    }
    if (typeint == kXMPP_MESSAGE_IMAGE) {
        
        return [[ImageMessageBody alloc] init];
        
    }else if (typeint == kXMPP_MESSAGE_VOICE){
        
        return [[VoiceMessageBody alloc] init];
        
    }else if (typeint == kXMPP_MESSAGE_CAR){
        
        return [[CarMessageBody alloc] init];
        
    }else{
        
        // other types, did nothing
    }
    return nil;
}

@end
