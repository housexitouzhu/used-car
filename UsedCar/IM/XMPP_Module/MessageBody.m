//
//  CMessageBody.m
//  IMDemo
//
//  Created by jun on 10/29/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "MessageBody.h"

@implementation MessageBody

- (id)initWithJsonObj:(id)jsonObj
{
    if (self = [super init]) {
        self.type = [jsonObj objectForKey:@"type"];
    }
    return self;
}

- (NSString *)jsonString
{
    return nil;
}

@end
