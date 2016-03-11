//
//  CMessageBody.h
//  IMDemo
//
//  Created by jun on 10/29/13.
//  Copyright (c) 2013 jun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage+UCMessage.h"

//#define kMessageTypeText     (@"uc_text")
//#define kMessageTypeImage    (@"uc_image")
//#define kMessageTypeVoice    (@"uc_voice")
//#define kMessageTypeCar      (@"uc_car")
//#define kMessageTypeLocation (@"uc_location")
//#define kMessageTypeVCard    (@"uc_vcard")

@interface MessageBody : NSObject

// 信息类型
@property (nonatomic, strong) NSNumber *type;

- (id)initWithJsonObj:(id)jsonObj;

- (NSString *)jsonString;

@end
