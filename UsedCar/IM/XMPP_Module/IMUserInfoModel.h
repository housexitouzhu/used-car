//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>

//#if HostStatus
//#define kXMPP_DOMAIN_LOCAL @"localhost.localdomain"
//#else
//#define kXMPP_DOMAIN_LOCAL @"baojia.autohome.com.cn"
//#endif

#define kXMPP_USER_RESOURCE @"usedcarios"

@interface IMUserInfoModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *name; //jID
@property (nonatomic, strong) NSString *nickname;   // 用户手机号
@property (nonatomic, strong) NSString *pwd;

@property (nonatomic, strong) NSString *fullJid;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *domain;

@property (nonatomic, strong) NSString *imgupload;
@property (nonatomic, strong) NSString *imgprefix;

@property (nonatomic, strong) NSString *voiceupload;
@property (nonatomic, strong) NSString *voiceprefix;

-(id)initWithJson:(NSDictionary *)json;


@end
