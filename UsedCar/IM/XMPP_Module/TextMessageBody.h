//
//  TextMessageBody.h
//  UsedCar
//
//  Created by Sun Honglin on 14-11-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "MessageBody.h"

@interface TextMessageBody : MessageBody

@property (nonatomic, strong) NSString *message;

- (id)initWithMessage:(NSString*)message;

@end
