//
//  UCDealerDepositModel.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerDepositModel.h"

@implementation UCDealerDepositModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.bmoney  = [json objectForKey:@"bmoney"];
            self.enddate  = [json objectForKey:@"enddate"];
            self.startdate  = [json objectForKey:@"startdate"];
            self.bstatuename  = [json objectForKey:@"bstatuename"];
            self.inserttime  = [json objectForKey:@"inserttime"];
            self.lasttime  = [json objectForKey:@"lasttime"];
            self.bdpmstatue  = [json objectForKey:@"bdpmstatue"];
            self.bstatue  = [json objectForKey:@"bstatue"];
            self.btype  = [json objectForKey:@"btype"];
            self.remainday  = [json objectForKey:@"remainday"];
            self.bailcurmoney  = [json objectForKey:@"bailcurmoney"];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bmoney forKey:@"bmoney"];
    [aCoder encodeObject:self.enddate forKey:@"enddate"];
    [aCoder encodeObject:self.startdate forKey:@"startdate"];
    [aCoder encodeObject:self.bstatuename forKey:@"bstatuename"];
    [aCoder encodeObject:self.inserttime forKey:@"inserttime"];
    [aCoder encodeObject:self.lasttime forKey:@"lasttime"];
    [aCoder encodeObject:self.bdpmstatue forKey:@"bdpmstatue"];
    [aCoder encodeObject:self.bstatue forKey:@"bstatue"];
    [aCoder encodeObject:self.btype forKey:@"btype"];
    [aCoder encodeObject:self.remainday forKey:@"remainday"];
    [aCoder encodeObject:self.bailcurmoney forKey:@"bailcurmoney"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.bmoney = [aDecoder decodeObjectForKey:@"bmoney"];
        self.enddate = [aDecoder decodeObjectForKey:@"enddate"];
        self.startdate = [aDecoder decodeObjectForKey:@"startdate"];
        self.bstatuename = [aDecoder decodeObjectForKey:@"bstatuename"];
        self.inserttime = [aDecoder decodeObjectForKey:@"inserttime"];
        self.lasttime = [aDecoder decodeObjectForKey:@"lasttime"];
        self.bdpmstatue = [aDecoder decodeObjectForKey:@"bdpmstatue"];
        self.bstatue = [aDecoder decodeObjectForKey:@"bstatue"];
        self.btype = [aDecoder decodeObjectForKey:@"btype"];
        self.remainday = [aDecoder decodeObjectForKey:@"remainday"];
        self.bailcurmoney = [aDecoder decodeObjectForKey:@"bailcurmoney"];
        
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"bmoney : %@\n",self.bmoney];
    result = [result stringByAppendingFormat:@"enddate : %@\n",self.enddate];
    result = [result stringByAppendingFormat:@"startdate : %@\n",self.startdate];
    result = [result stringByAppendingFormat:@"bstatuename : %@\n",self.bstatuename];
    result = [result stringByAppendingFormat:@"inserttime : %@\n",self.inserttime];
    result = [result stringByAppendingFormat:@"lasttime : %@\n",self.lasttime];
    result = [result stringByAppendingFormat:@"bdpmstatue : %@\n",self.bdpmstatue];
    result = [result stringByAppendingFormat:@"bstatue : %@\n",self.bstatue];
    result = [result stringByAppendingFormat:@"btype : %@\n",self.btype];
    result = [result stringByAppendingFormat:@"remainday : %@\n",self.remainday];
    result = [result stringByAppendingFormat:@"bailcurmoney : %@\n",self.bailcurmoney];
    
    return result;
}

@end
