//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCActivityModel.h"

@implementation UCActivityModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.activityvss  = [json objectForKey:@"activityvss"];
            self.adlist = [NSMutableArray array];
            for(id item in [json objectForKey:@"adlist"])
            {
                if ([item isKindOfClass:[NSDictionary class]]){
                    [self.adlist addObject:[[AdlistItemModel alloc] initWithJson:item]];
                }
                else{
                    [self.adlist addObject:item];
                }
            }
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.activityvss forKey:@"activityvss"];
    [aCoder encodeObject:self.adlist forKey:@"adlist"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.activityvss = [aDecoder decodeObjectForKey:@"activityvss"];
        self.adlist = [aDecoder decodeObjectForKey:@"adlist"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"activityvss : %@\n",self.activityvss];
    result = [result stringByAppendingFormat:@"adlist : %@\n",self.adlist];
    
    return result;
}

@end


@implementation AdlistItemModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.title  = [json objectForKey:@"title"];
            self.position  = [json objectForKey:@"position"];
            self.url  = [json objectForKey:@"url"];
            self.pid  = [json objectForKey:@"pid"];
            self.cid  = [json objectForKey:@"cid"];
            
            self.articletitle  = [json objectForKey:@"articletitle"];
            self.content  = [json objectForKey:@"content"];
            self.shorturl  = [json objectForKey:@"shorturl"];
            self.icon  = [json objectForKey:@"icon"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    
    [aCoder encodeObject:self.articletitle forKey:@"articletitle"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.shorturl forKey:@"shorturl"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        
        self.articletitle = [aDecoder decodeObjectForKey:@"articletitle"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.shorturl = [aDecoder decodeObjectForKey:@"shorturl"];
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"title : %@\n",self.title];
    result = [result stringByAppendingFormat:@"position : %@\n",self.position];
    result = [result stringByAppendingFormat:@"url : %@\n",self.url];
    result = [result stringByAppendingFormat:@"pid : %@\n",self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n",self.cid];
    
    result = [result stringByAppendingFormat:@"articletitle : %@\n",self.articletitle];
    result = [result stringByAppendingFormat:@"content : %@\n",self.content];
    result = [result stringByAppendingFormat:@"shorturl : %@\n",self.shorturl];
    result = [result stringByAppendingFormat:@"icon : %@\n",self.icon];
    
    return result;
}

@end