//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCFavoritesCloudListModel.h"

@implementation UCFavoritesCloudListModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
           self.carlist = [NSMutableArray array];
            for(id item in [json objectForKey:@"carlist"])
            {
                if ([item isKindOfClass:[NSDictionary class]]){
                    [self.carlist addObject:[[UCFavoritesCloudModel alloc] initWithJson:item]];
                }
                else{
                    [self.carlist addObject:item];
                }
            }
            self.pagecount  = [json objectForKey:@"pagecount"];
            self.rowcount  = [json objectForKey:@"rowcount"];
            self.pageindex  = [json objectForKey:@"pageindex"];
            self.pagesize  = [json objectForKey:@"pagesize"];
     
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.carlist forKey:@"carlist"];
    [aCoder encodeObject:self.pagecount forKey:@"pagecount"];
    [aCoder encodeObject:self.rowcount forKey:@"rowcount"];
    [aCoder encodeObject:self.pageindex forKey:@"pageindex"];
    [aCoder encodeObject:self.pagesize forKey:@"pagesize"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.carlist = [aDecoder decodeObjectForKey:@"carlist"];
        self.pagecount = [aDecoder decodeObjectForKey:@"pagecount"];
        self.rowcount = [aDecoder decodeObjectForKey:@"rowcount"];
        self.pageindex = [aDecoder decodeObjectForKey:@"pageindex"];
        self.pagesize = [aDecoder decodeObjectForKey:@"pagesize"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"carlist : %@\n",self.carlist];
    result = [result stringByAppendingFormat:@"pagecount : %@\n",self.pagecount];
    result = [result stringByAppendingFormat:@"rowcount : %@\n",self.rowcount];
    result = [result stringByAppendingFormat:@"pageindex : %@\n",self.pageindex];
    result = [result stringByAppendingFormat:@"pagesize : %@\n",self.pagesize];

    return result;
}

@end
