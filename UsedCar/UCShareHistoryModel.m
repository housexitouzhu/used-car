//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCShareHistoryModel.h"

@implementation UCShareHistoryModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.dealerid  = [json objectForKey:@"dealerid"];
            self.content  = [json objectForKey:@"content"];
            self.appid  = [json objectForKey:@"appid"];
            self.createtimeshow  = [json objectForKey:@"createtimeshow"];
            self.channeltype  = [json objectForKey:@"channeltype"];
            self.thumbnailurls  = [json objectForKey:@"thumbnailurls"];
            self.dealername  = [json objectForKey:@"dealername"];
            self.type  = [json objectForKey:@"type"];
            self.createtime  = [json objectForKey:@"createtime"];
            self.shareid  = [json objectForKey:@"shareid"];
            self.dealerlogo = [json objectForKey:@"dealerlogo"];
            self.carcount = [json objectForKey:@"carcount"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dealerid forKey:@"dealerid"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.appid forKey:@"appid"];
    [aCoder encodeObject:self.createtimeshow forKey:@"createtimeshow"];
    [aCoder encodeObject:self.channeltype forKey:@"channeltype"];
    [aCoder encodeObject:self.thumbnailurls forKey:@"thumbnailurls"];
    [aCoder encodeObject:self.dealername forKey:@"dealername"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.createtime forKey:@"createtime"];
    [aCoder encodeObject:self.shareid forKey:@"shareid"];
    [aCoder encodeObject:self.dealerlogo forKey:@"dealerlogo"];
    [aCoder encodeObject:self.carcount forKey:@"carcount"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.dealerid = [aDecoder decodeObjectForKey:@"dealerid"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.appid = [aDecoder decodeObjectForKey:@"appid"];
        self.createtimeshow = [aDecoder decodeObjectForKey:@"createtimeshow"];
        self.channeltype = [aDecoder decodeObjectForKey:@"channeltype"];
        self.thumbnailurls = [aDecoder decodeObjectForKey:@"thumbnailurls"];
        self.dealername = [aDecoder decodeObjectForKey:@"dealername"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.createtime = [aDecoder decodeObjectForKey:@"createtime"];
        self.shareid = [aDecoder decodeObjectForKey:@"shareid"];
        self.dealerlogo = [aDecoder decodeObjectForKey:@"dealerlogo"];
        self.carcount = [aDecoder decodeObjectForKey:@"carcount"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"dealerid : %@\n",self.dealerid];
    result = [result stringByAppendingFormat:@"content : %@\n",self.content];
    result = [result stringByAppendingFormat:@"appid : %@\n",self.appid];
    result = [result stringByAppendingFormat:@"createtimeshow : %@\n",self.createtimeshow];
    result = [result stringByAppendingFormat:@"channeltype : %@\n",self.channeltype];
    result = [result stringByAppendingFormat:@"thumbnailurls : %@\n",self.thumbnailurls];
    result = [result stringByAppendingFormat:@"dealername : %@\n",self.dealername];
    result = [result stringByAppendingFormat:@"type : %@\n",self.type];
    result = [result stringByAppendingFormat:@"createtime : %@\n",self.createtime];
    result = [result stringByAppendingFormat:@"shareid : %@\n",self.shareid];
    result = [result stringByAppendingFormat:@"dealerlogo : %@\n",self.dealerlogo];
    result = [result stringByAppendingFormat:@"carcount : %@\n",self.carcount];
    
    return result;
}

@end
