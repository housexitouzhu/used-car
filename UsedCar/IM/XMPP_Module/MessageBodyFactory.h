//
//  MessageBodyFactory.h
//  IMDemo
//
//  Created by jun on 11/11/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageBody;

@interface MessageBodyFactory : NSObject

+ (MessageBody *)messageBodyWithJsonString:(NSString *)jsonString;

@end
