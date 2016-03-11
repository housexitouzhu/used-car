//
//  TextMessageBody.m
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "TextMessageBody.h"

@implementation TextMessageBody

-(id)init
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_TEXT];
    }
    return self;
}

- (id)initWithJsonObj:(id)jsonObj
{
    if (self = [super initWithJsonObj:jsonObj]) {
        id body = [jsonObj objectForKey:@"body"];
        self.message = [body objectForKey:@"message"];
    }
    return self;
}

- (id)initWithMessage:(NSString*)message
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_TEXT];
        self.message = message;
    }
    return self;
}

- (NSString *)jsonString
{
    NSDictionary *jsonDic = @{
                              @"type":self.type,
                              @"body":@{
                                        @"message":self.message,
                                      }
                              };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
