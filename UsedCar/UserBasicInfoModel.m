//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UserBasicInfoModel.h"

@implementation UserBasicInfoModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
             self.cname       = [json objectForKey:@"cname"];
             self.phone       = [json objectForKey:@"phone"];
             self.managetype  = [json objectForKey:@"managetype"];
             self.memberId    = [json objectForKey:@"memberId"];
             self.address     = [json objectForKey:@"address"];
             self.dealerstate = [json objectForKey:@"dealerstate"];
             self.username    = [json objectForKey:@"username"];
             self.isbailcar   = [json objectForKey:@"isbailcar"];
             self.bdpmstatue  = [json objectForKey:@"bdpmstatue"];
             self.dealerid    = [json objectForKey:@"dealerid"];
             self.pname       = [json objectForKey:@"pname"];
     
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cname forKey:@"cname"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.managetype forKey:@"managetype"];
    [aCoder encodeObject:self.memberId forKey:@"memberId"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.dealerstate forKey:@"dealerstate"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.isbailcar forKey:@"isbailcar"];
    [aCoder encodeObject:self.bdpmstatue forKey:@"bdpmstatue"];
    [aCoder encodeObject:self.dealerid forKey:@"dealerid"];
    [aCoder encodeObject:self.pname forKey:@"pname"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.cname       = [aDecoder decodeObjectForKey:@"cname"];
        self.phone       = [aDecoder decodeObjectForKey:@"phone"];
        self.managetype  = [aDecoder decodeObjectForKey:@"managetype"];
        self.memberId    = [aDecoder decodeObjectForKey:@"memberId"];
        self.address     = [aDecoder decodeObjectForKey:@"address"];
        self.dealerstate = [aDecoder decodeObjectForKey:@"dealerstate"];
        self.username    = [aDecoder decodeObjectForKey:@"username"];
        self.isbailcar   = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.bdpmstatue  = [aDecoder decodeObjectForKey:@"bdpmstatue"];
        self.dealerid    = [aDecoder decodeObjectForKey:@"dealerid"];
        self.pname       = [aDecoder decodeObjectForKey:@"pname"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"cname : %@\n",self.cname];
    result = [result stringByAppendingFormat:@"phone : %@\n",self.phone];
    result = [result stringByAppendingFormat:@"managetype : %@\n",self.managetype];
    result = [result stringByAppendingFormat:@"memberId : %@\n",self.memberId];
    result = [result stringByAppendingFormat:@"address : %@\n",self.address];
    result = [result stringByAppendingFormat:@"dealerstate : %@\n",self.dealerstate];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"isbailcar : %@\n",self.isbailcar];
    result = [result stringByAppendingFormat:@"bdpmstatue : %@\n",self.bdpmstatue];
    result = [result stringByAppendingFormat:@"dealerid : %@\n",self.dealerid];
    result = [result stringByAppendingFormat:@"pname : %@\n",self.pname];

    return result;
}

@end
