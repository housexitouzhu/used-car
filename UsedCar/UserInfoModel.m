//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UserInfoModel.h"
#import "SalesPersonModel.h"

@implementation UserInfoModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.carnotpassed  = [json objectForKey:@"carnotpassed"];
            self.carsaleing  = [json objectForKey:@"carsaleing"];
            self.userid  = [json objectForKey:@"userid"];
            self.userkey  = [json objectForKey:@"userkey"];
            self.type  = [json objectForKey:@"type"];
            self.salespersonlist = [NSMutableArray array];
            self.updatetime = [json objectForKey:@"updatetime"];
            self.bdpmstatue  = [json objectForKey:@"bdpmstatue"];
            self.username  = [json objectForKey:@"username"];
            self.carinvalid  = [json objectForKey:@"carinvalid"];
            self.isbailcar  = [json objectForKey:@"isbailcar"];
            self.carsaled  = [json objectForKey:@"carsaled"];
            self.carchecking  = [json objectForKey:@"carchecking"];
            self.mobile = [json objectForKey:@"mobile"];
            self.code = [json objectForKey:@"code"];
            self.dealerid = [json objectForKey:@"dealerid"];
            self.logo = [json objectForKey:@"logo"];
            self.adviser = [[UCAdviserModel alloc] initWithJson:[json objectForKey:@"adviser"]];
            
            for(id item in [json objectForKey:@"salespersonlist"])
            {
                if ([item isKindOfClass:[NSDictionary class]]){
                    [self.salespersonlist addObject:[[SalesPersonModel alloc] initWithJson:item]];
                }
                else{
                    [self.salespersonlist addObject:item];
                }
            }
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.carnotpassed forKey:@"carnotpassed"];
    [aCoder encodeObject:self.carsaleing forKey:@"carsaleing"];
    [aCoder encodeObject:self.userid forKey:@"userid"];
    [aCoder encodeObject:self.userkey forKey:@"userkey"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.salespersonlist forKey:@"salespersonlist"];
    [aCoder encodeObject:self.bdpmstatue forKey:@"bdpmstatue"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.carinvalid forKey:@"carinvalid"];
    [aCoder encodeObject:self.isbailcar forKey:@"isbailcar"];
    [aCoder encodeObject:self.carsaled forKey:@"carsaled"];
    [aCoder encodeObject:self.carchecking forKey:@"carchecking"];
    [aCoder encodeObject:self.updatetime forKey:@"updatetime"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.mobile forKey:@"code"];
    [aCoder encodeObject:self.dealerid forKey:@"dealerid"];
    [aCoder encodeObject:self.logo forKey:@"logo"];
    [aCoder encodeObject:self.adviser forKey:@"adviser"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.carnotpassed = [aDecoder decodeObjectForKey:@"carnotpassed"];
        self.carsaleing = [aDecoder decodeObjectForKey:@"carsaleing"];
        self.userid = [aDecoder decodeObjectForKey:@"userid"];
        self.userkey = [aDecoder decodeObjectForKey:@"userkey"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.salespersonlist = [aDecoder decodeObjectForKey:@"salespersonlist"];
        self.bdpmstatue = [aDecoder decodeObjectForKey:@"bdpmstatue"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.carinvalid = [aDecoder decodeObjectForKey:@"carinvalid"];
        self.isbailcar = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.carsaled = [aDecoder decodeObjectForKey:@"carsaled"];
        self.carchecking = [aDecoder decodeObjectForKey:@"carchecking"];
        self.updatetime = [aDecoder decodeObjectForKey:@"updatetime"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.mobile = [aDecoder decodeObjectForKey:@"code"];
        self.dealerid = [aDecoder decodeObjectForKey:@"dealerid"];
        self.logo = [aDecoder decodeObjectForKey:@"logo"];
        self.adviser = [aDecoder decodeObjectForKey:@"adviser"];
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"carnotpassed : %@\n",self.carnotpassed];
    result = [result stringByAppendingFormat:@"carsaleing : %@\n",self.carsaleing];
    result = [result stringByAppendingFormat:@"userid : %@\n",self.userid];
    result = [result stringByAppendingFormat:@"userkey : %@\n",self.userkey];
    result = [result stringByAppendingFormat:@"type : %@\n",self.type];
    result = [result stringByAppendingFormat:@"salespersonlist : %@\n",self.salespersonlist];
    result = [result stringByAppendingFormat:@"bdpmstatue : %@\n",self.bdpmstatue];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"carinvalid : %@\n",self.carinvalid];
    result = [result stringByAppendingFormat:@"isbailcar : %@\n",self.isbailcar];
    result = [result stringByAppendingFormat:@"carsaled : %@\n",self.carsaled];
    result = [result stringByAppendingFormat:@"carchecking : %@\n",self.carchecking];
    result = [result stringByAppendingFormat:@"updatetime : %@\n", self.updatetime];
    result = [result stringByAppendingFormat:@"mobile : %@\n", self.mobile];
    result = [result stringByAppendingFormat:@"code : %@\n", self.code];
    result = [result stringByAppendingFormat:@"dealerid : %@\n", self.dealerid];
    result = [result stringByAppendingFormat:@"logo : %@\n", self.logo];
    result = [result stringByAppendingFormat:@"adviser : %@\n", self.adviser];
    
    return result;
}

@end