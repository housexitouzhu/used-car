//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "BailDealerDetails.h"

@implementation BailDealerDetails

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
    if(json != nil)
    {
       self.BailMoney  = [json objectForKey:@"BailMoney"];
 self.CurMoney  = [json objectForKey:@"CurMoney"];
 self.EndDate  = [json objectForKey:@"EndDate"];
 self.State  = [json objectForKey:@"State"];
 
    }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.BailMoney forKey:@"BailMoney"];
[aCoder encodeObject:self.CurMoney forKey:@"CurMoney"];
[aCoder encodeObject:self.EndDate forKey:@"EndDate"];
[aCoder encodeObject:self.State forKey:@"State"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.BailMoney = [aDecoder decodeObjectForKey:@"BailMoney"];
 self.CurMoney = [aDecoder decodeObjectForKey:@"CurMoney"];
 self.EndDate = [aDecoder decodeObjectForKey:@"EndDate"];
 self.State = [aDecoder decodeObjectForKey:@"State"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"BailMoney : %@\n",self.BailMoney];
result = [result stringByAppendingFormat:@"CurMoney : %@\n",self.CurMoney];
result = [result stringByAppendingFormat:@"EndDate : %@\n",self.EndDate];
result = [result stringByAppendingFormat:@"State : %@\n",self.State];

    return result;
}

@end
