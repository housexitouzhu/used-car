//
//  ImageMessage.m
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "ImageMessageBody.h"

@implementation ImageMessageBody

-(id)init
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_IMAGE];
    }
    return self;
}

- (id)initWithJsonObj:(id)jsonObj
{
    if (self = [super initWithJsonObj:jsonObj]) {
        id body = [jsonObj objectForKey:@"body"];
        self.smallUri = [body objectForKey:@"smalluri"];
        self.uri = [body objectForKey:@"uri"];
    }
    return self;
}

- (id)initWithSmallUri:(NSString *)sUri largeUri:(NSString *)largeUri
{
    if (self = [super init]) {
        self.type = [NSNumber numberWithInteger:kXMPP_MESSAGE_IMAGE];
        self.smallUri = sUri;
        self.uri = largeUri;
    }
    return self;
}

- (NSString *)jsonString
{
    NSDictionary *jsonDic = @{
                              @"type":self.type,
                              @"body":@{
                                        @"smalluri":self.smallUri,
                                        @"uri":self.uri
                                      }
                              };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
