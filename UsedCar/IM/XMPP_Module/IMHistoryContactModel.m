//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "IMHistoryContactModel.h"

@implementation IMHistoryContactModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.itemid  = [json objectForKey:@"id"];
            self.namefrom  = [json objectForKey:@"namefrom"];
            self.objectid  = [json objectForKey:@"objectid"];
            self.memberid  = [json objectForKey:@"memberid"];
            self.dealername  = [json objectForKey:@"dealername"];
            self.createtime  = [json objectForKey:@"createtime"];
            self.timetoshow  = [json objectForKey:@"timetoshow"];
            self.state  = [json objectForKey:@"state"];
            self.carimgurl  = [json objectForKey:@"carimgurl"];
            self.nicknameTo  = [json objectForKey:@"nicknameTo"];
            self.salesid  = [json objectForKey:@"salesid"];
            self.reversestate  = [json objectForKey:@"reversestate"];
            self.carname  = [json objectForKey:@"carname"];
            self.nickname  = [json objectForKey:@"nickname"];
            self.nameto  = [json objectForKey:@"nameto"];
            self.dealerid  = [json objectForKey:@"dealerid"];
            self.typeID  = [json objectForKey:@"typeid"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.itemid forKey:@"itemid"];
    [aCoder encodeObject:self.namefrom forKey:@"namefrom"];
    [aCoder encodeObject:self.objectid forKey:@"objectid"];
    [aCoder encodeObject:self.memberid forKey:@"memberid"];
    [aCoder encodeObject:self.dealername forKey:@"dealername"];
    [aCoder encodeObject:self.createtime forKey:@"createtime"];
    [aCoder encodeObject:self.timetoshow forKey:@"timetoshow"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.carimgurl forKey:@"carimgurl"];
    [aCoder encodeObject:self.nicknameTo forKey:@"nicknameTo"];
    [aCoder encodeObject:self.salesid forKey:@"salesid"];
    [aCoder encodeObject:self.reversestate forKey:@"reversestate"];
    [aCoder encodeObject:self.carname forKey:@"carname"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.nameto forKey:@"nameto"];
    [aCoder encodeObject:self.dealerid forKey:@"dealerid"];
    [aCoder encodeObject:self.typeID forKey:@"typeID"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.itemid = [aDecoder decodeObjectForKey:@"itemid"];
        self.namefrom = [aDecoder decodeObjectForKey:@"namefrom"];
        self.objectid = [aDecoder decodeObjectForKey:@"objectid"];
        self.memberid = [aDecoder decodeObjectForKey:@"memberid"];
        self.dealername = [aDecoder decodeObjectForKey:@"dealername"];
        self.createtime = [aDecoder decodeObjectForKey:@"createtime"];
        self.timetoshow = [aDecoder decodeObjectForKey:@"timetoshow"];
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.carimgurl = [aDecoder decodeObjectForKey:@"carimgurl"];
        self.nicknameTo = [aDecoder decodeObjectForKey:@"nicknameTo"];
        self.salesid = [aDecoder decodeObjectForKey:@"salesid"];
        self.reversestate = [aDecoder decodeObjectForKey:@"reversestate"];
        self.carname = [aDecoder decodeObjectForKey:@"carname"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.nameto = [aDecoder decodeObjectForKey:@"nameto"];
        self.dealerid = [aDecoder decodeObjectForKey:@"dealerid"];
        self.typeID = [aDecoder decodeObjectForKey:@"typeID"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"itemid : %@\n",self.itemid];
    result = [result stringByAppendingFormat:@"namefrom : %@\n",self.namefrom];
    result = [result stringByAppendingFormat:@"objectid : %@\n",self.objectid];
    result = [result stringByAppendingFormat:@"memberid : %@\n",self.memberid];
    result = [result stringByAppendingFormat:@"dealername : %@\n",self.dealername];
    result = [result stringByAppendingFormat:@"createtime : %@\n",self.createtime];
    result = [result stringByAppendingFormat:@"timetoshow : %@\n",self.timetoshow];
    result = [result stringByAppendingFormat:@"state : %@\n",self.state];
    result = [result stringByAppendingFormat:@"carimgurl : %@\n",self.carimgurl];
    result = [result stringByAppendingFormat:@"nicknameTo : %@\n",self.nicknameTo];
    result = [result stringByAppendingFormat:@"salesid : %@\n",self.salesid];
    result = [result stringByAppendingFormat:@"reversestate : %@\n",self.reversestate];
    result = [result stringByAppendingFormat:@"carname : %@\n",self.carname];
    result = [result stringByAppendingFormat:@"nickname : %@\n",self.nickname];
    result = [result stringByAppendingFormat:@"nameto : %@\n",self.nameto];
    result = [result stringByAppendingFormat:@"dealerid : %@\n",self.dealerid];
    result = [result stringByAppendingFormat:@"typeID : %@\n",self.typeID];
    
    return result;
}

@end
