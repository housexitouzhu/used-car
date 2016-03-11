//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "DealerModel.h"

@implementation DealerModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.cname  = [json objectForKey:@"cname"];
            self.descriptioninfo  = [json objectForKey:@"description"];
            self.phone  = [json objectForKey:@"phone"];
            self.kindid  = [json objectForKey:@"kindid"];
            self.latitude  = [json objectForKey:@"latitude"];
            self.longtitude  = [json objectForKey:@"longtitude"];
            self.logo  = [json objectForKey:@"logo"];
            self.address  = [json objectForKey:@"address"];
            self.username  = [json objectForKey:@"username"];
            self.isbailcar  = [json objectForKey:@"isbailcar"];
            self.pname  = [json objectForKey:@"pname"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cname forKey:@"cname"];
    [aCoder encodeObject:self.descriptioninfo forKey:@"descriptioninfo"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.kindid forKey:@"kindid"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longtitude forKey:@"longtitude"];
    [aCoder encodeObject:self.logo forKey:@"logo"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.isbailcar forKey:@"isbailcar"];
    [aCoder encodeObject:self.pname forKey:@"pname"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.cname = [aDecoder decodeObjectForKey:@"cname"];
        self.descriptioninfo = [aDecoder decodeObjectForKey:@"descriptioninfo"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.kindid = [aDecoder decodeObjectForKey:@"kindid"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.longtitude = [aDecoder decodeObjectForKey:@"longtitude"];
        self.logo = [aDecoder decodeObjectForKey:@"logo"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.isbailcar = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.pname = [aDecoder decodeObjectForKey:@"pname"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"cname : %@\n",self.cname];
    result = [result stringByAppendingFormat:@"descriptioninfo : %@\n",self.descriptioninfo];
    result = [result stringByAppendingFormat:@"phone : %@\n",self.phone];
    result = [result stringByAppendingFormat:@"kindid : %@\n",self.kindid];
    result = [result stringByAppendingFormat:@"latitude : %@\n",self.latitude];
    result = [result stringByAppendingFormat:@"longtitude : %@\n",self.longtitude];
    result = [result stringByAppendingFormat:@"logo : %@\n",self.logo];
    result = [result stringByAppendingFormat:@"address : %@\n",self.address];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"isbailcar : %@\n",self.isbailcar];
    result = [result stringByAppendingFormat:@"pname : %@\n",self.pname];
    
    return result;
}

@end
