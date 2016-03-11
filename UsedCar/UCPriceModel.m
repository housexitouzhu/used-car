//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCPriceModel.h"

@implementation UCPriceModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.specid  = [json objectForKey:@"specid"];
            self.mileage  = [json objectForKey:@"mileage"];
            self.firstregtime  = [json objectForKey:@"firstregtime"];
            self.pid  = [json objectForKey:@"pid"];
            self.cid  = [json objectForKey:@"cid"];
            self.price  = [json objectForKey:@"price"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.specid forKey:@"specid"];
    [aCoder encodeObject:self.mileage forKey:@"mileage"];
    [aCoder encodeObject:self.firstregtime forKey:@"firstregtime"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeObject:self.price forKey:@"price"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.specid = [aDecoder decodeObjectForKey:@"specid"];
        self.mileage = [aDecoder decodeObjectForKey:@"mileage"];
        self.firstregtime = [aDecoder decodeObjectForKey:@"firstregtime"];
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"specid : %@\n",self.specid];
    result = [result stringByAppendingFormat:@"mileage : %@\n",self.mileage];
    result = [result stringByAppendingFormat:@"firstregtime : %@\n",self.firstregtime];
    result = [result stringByAppendingFormat:@"pid : %@\n",self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n",self.cid];
    result = [result stringByAppendingFormat:@"price : %@\n",self.price];
    
    return result;
}

@end
