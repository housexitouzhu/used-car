//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "IMUserInfoModel.h"

@implementation IMUserInfoModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.name        = [json objectForKey:@"name"];
            self.nickname    = [json objectForKey:@"nickname"];
            self.pwd         = [json objectForKey:@"pwd"];
            self.server      = [json objectForKey:@"server"];
            self.port        = [json objectForKey:@"port"];
            self.domain      = [json objectForKey:@"domain"];
            self.imgupload   = [json objectForKey:@"imgupload"];
            self.imgprefix   = [json objectForKey:@"imgprefix"];
            self.voiceupload = [json objectForKey:@"voiceupload"];
            self.voiceprefix = [json objectForKey:@"voiceprefix"];
            
            if (self.name && self.server) {
                self.fullJid = [NSString stringWithFormat:@"%@@%@/%@",self.name, self.domain, kXMPP_USER_RESOURCE];
            }
        }
    }
    return self;
}

- (void)setServer:(NSString *)server{
    _server = server;
    if (self.name && self.server) {
        self.fullJid = [NSString stringWithFormat:@"%@@%@/%@",self.name, self.domain, kXMPP_USER_RESOURCE];
    }
}

- (void)setName:(NSString *)name{
    _name = name;
    if (self.name && self.server) {
        self.fullJid = [NSString stringWithFormat:@"%@@%@/%@",self.name, self.domain, kXMPP_USER_RESOURCE];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.pwd forKey:@"pwd"];
    [aCoder encodeObject:self.server forKey:@"server"];
    [aCoder encodeObject:self.port forKey:@"port"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
    [aCoder encodeObject:self.imgupload forKey:@"imgupload"];
    [aCoder encodeObject:self.imgprefix forKey:@"imgprefix"];
    [aCoder encodeObject:self.voiceupload forKey:@"voiceupload"];
    [aCoder encodeObject:self.voiceprefix forKey:@"voiceprefix"];
    
    if (self.name && self.server) {
        self.fullJid = [NSString stringWithFormat:@"%@@%@/%@",self.name, self.domain, kXMPP_USER_RESOURCE];
        [aCoder encodeObject:self.fullJid forKey:@"fullJid"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.name        = [aDecoder decodeObjectForKey:@"name"];
        self.nickname    = [aDecoder decodeObjectForKey:@"nickname"];
        self.pwd         = [aDecoder decodeObjectForKey:@"pwd"];
        self.server      = [aDecoder decodeObjectForKey:@"server"];
        self.port        = [aDecoder decodeObjectForKey:@"port"];
        self.domain      = [aDecoder decodeObjectForKey:@"domain"];
        self.fullJid     = [aDecoder decodeObjectForKey:@"fullJid"];
        self.imgupload   = [aDecoder decodeObjectForKey:@"imgupload"];
        self.imgprefix   = [aDecoder decodeObjectForKey:@"imgprefix"];
        self.voiceupload = [aDecoder decodeObjectForKey:@"voiceupload"];
        self.voiceprefix = [aDecoder decodeObjectForKey:@"voiceprefix"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"name : %@\n",self.name];
    result = [result stringByAppendingFormat:@"nickname : %@\n",self.nickname];
    result = [result stringByAppendingFormat:@"pwd : %@\n",self.pwd];
    result = [result stringByAppendingFormat:@"server : %@\n",self.server];
    result = [result stringByAppendingFormat:@"port : %@\n",self.port];
    result = [result stringByAppendingFormat:@"domain : %@\n",self.domain];
    result = [result stringByAppendingFormat:@"fullJid : %@\n",self.fullJid];
    result = [result stringByAppendingFormat:@"imgupload : %@\n",self.imgupload];
    result = [result stringByAppendingFormat:@"imgprefix : %@\n",self.imgprefix];
    result = [result stringByAppendingFormat:@"voiceupload : %@\n",self.voiceupload];
    result = [result stringByAppendingFormat:@"voiceprefix : %@\n",self.voiceprefix];
    
    return result;
}

@end
