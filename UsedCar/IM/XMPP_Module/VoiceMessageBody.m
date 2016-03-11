//
//  VoiceMessage.m
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "VoiceMessageBody.h"

@implementation VoiceMessageBody

-(id)init
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_VOICE];
    }
    return self;
}

- (id)initWithJsonObj:(id)jsonObj
{
    if ([super initWithJsonObj:jsonObj]) {
        id body = [jsonObj objectForKey:@"body"];
        self.uri = [body objectForKey:@"uri"];
        self.duration = [[body objectForKey:@"duration"] integerValue];
    }
    return self;
}

- (id)initWithVoiceUri:(NSString *)vUri andDuration:(NSInteger)duration
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_VOICE];
        self.uri = vUri;
        self.duration = duration;
    }
    return self;
}

- (NSString *)jsonString
{
    NSDictionary *jsonDic = @{
                              @"type":self.type,
                              @"body":@{
                                          @"url":self.uri,
                                          @"duration":@(self.duration)
                                      }
                              };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
