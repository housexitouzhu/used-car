//
//  VoiceMessage.h
//  IMDemo
//
//  Created by jun on 11/4/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import "MessageBody.h"

@interface VoiceMessageBody : MessageBody

// 语音信息URL
@property (nonatomic, strong) NSString *uri;

// 语音时长
@property (nonatomic) NSInteger duration;

- (id)initWithVoiceUri:(NSString *)vUri andDuration:(NSInteger)duration;

@end
