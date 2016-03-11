//
//  StorageContact.m
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "StorageContact.h"
#import "StorageMessage.h"
#import "IMHistoryContactModel.h"

@implementation StorageContact

- (void)setFullJid:(NSString *)fullJid
{
    _fullJid = fullJid;
    _shortJid = [self jidFromJidString:fullJid];
}

- (NSString *)jidFromJidString:(NSString *)jidString
{
    NSRange range = [jidString rangeOfString:@"@"];
    if (range.location > 0) {
        return [jidString substringToIndex:range.location];
    }
    return jidString;
}

- (void)updateMostRecentMessage:(StorageMessage *)message
{
    self.mostRecentTime = message.createTime;
    self.mostRecentDate = message.timestamp;
    self.mostRecentMessage = message.mostRecentMessageString;
    self.mostRecentStatus = message.status;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"mostRecentTime : %f\n",self.mostRecentTime];
    result = [result stringByAppendingFormat:@"mostRecentDate : %@\n",self.mostRecentDate];
    result = [result stringByAppendingFormat:@"mostRecentMessage : %@\n",self.mostRecentMessage];
    result = [result stringByAppendingFormat:@"mostRecentStatus : %d\n",self.mostRecentStatus];
    
    return result;
}

@end
