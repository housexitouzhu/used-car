//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "ClaimRecordItem.h"

@implementation ClaimRecordItem

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.carid  = [json objectForKey:@"carid"];
            self.CarName  = [json objectForKey:@"CarName"];
            self.Mileage  = [json objectForKey:@"Mileage"];
            self.State  = [json objectForKey:@"State"];
            self.CheckReason  = [json objectForKey:@"CheckReason"];
            self.CheckTime  = [json objectForKey:@"CheckTime"];
            self.AutoIcon  = [json objectForKey:@"AutoIcon"];
            self.ComplaintDate  = [json objectForKey:@"ComplaintDate"];
            self.ClaimScore  = [json objectForKey:@"ClaimScore"];
            self.ClaimerReason  = [json objectForKey:@"ClaimerReason"];
            self.mobile  = [json objectForKey:@"mobile"];
            self.isnew  = [json objectForKey:@"isnew"];
            self.registeDate  = [json objectForKey:@"registeDate"];
            self.username  = [json objectForKey:@"username"];
            self.SalesId  = [json objectForKey:@"SalesId"];
            self.Price  = [json objectForKey:@"Price"];
            self.SalesName  = [json objectForKey:@"SalesName"];
            self.CheckMark  = [json objectForKey:@"CheckMark"];
     
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.carid forKey:@"carid"];
    [aCoder encodeObject:self.CarName forKey:@"CarName"];
    [aCoder encodeObject:self.Mileage forKey:@"Mileage"];
    [aCoder encodeObject:self.State forKey:@"State"];
    [aCoder encodeObject:self.CheckReason forKey:@"CheckReason"];
    [aCoder encodeObject:self.CheckTime forKey:@"CheckTime"];
    [aCoder encodeObject:self.AutoIcon forKey:@"AutoIcon"];
    [aCoder encodeObject:self.ComplaintDate forKey:@"ComplaintDate"];
    [aCoder encodeObject:self.ClaimScore forKey:@"ClaimScore"];
    [aCoder encodeObject:self.ClaimerReason forKey:@"ClaimerReason"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.isnew forKey:@"isnew"];
    [aCoder encodeObject:self.registeDate forKey:@"registeDate"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.SalesId forKey:@"SalesId"];
    [aCoder encodeObject:self.Price forKey:@"Price"];
    [aCoder encodeObject:self.SalesName forKey:@"SalesName"];
    [aCoder encodeObject:self.CheckMark forKey:@"CheckMark"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.carid = [aDecoder decodeObjectForKey:@"carid"];
         self.CarName = [aDecoder decodeObjectForKey:@"CarName"];
         self.Mileage = [aDecoder decodeObjectForKey:@"Mileage"];
         self.State = [aDecoder decodeObjectForKey:@"State"];
         self.CheckReason = [aDecoder decodeObjectForKey:@"CheckReason"];
         self.CheckTime = [aDecoder decodeObjectForKey:@"CheckTime"];
         self.AutoIcon = [aDecoder decodeObjectForKey:@"AutoIcon"];
         self.ComplaintDate = [aDecoder decodeObjectForKey:@"ComplaintDate"];
         self.ClaimScore = [aDecoder decodeObjectForKey:@"ClaimScore"];
         self.ClaimerReason = [aDecoder decodeObjectForKey:@"ClaimerReason"];
         self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
         self.isnew = [aDecoder decodeObjectForKey:@"isnew"];
         self.registeDate = [aDecoder decodeObjectForKey:@"registeDate"];
         self.username = [aDecoder decodeObjectForKey:@"username"];
         self.SalesId = [aDecoder decodeObjectForKey:@"SalesId"];
         self.Price = [aDecoder decodeObjectForKey:@"Price"];
         self.SalesName = [aDecoder decodeObjectForKey:@"SalesName"];
         self.CheckMark = [aDecoder decodeObjectForKey:@"CheckMark"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"carid : %@\n",self.carid];
    result = [result stringByAppendingFormat:@"CarName : %@\n",self.CarName];
    result = [result stringByAppendingFormat:@"Mileage : %@\n",self.Mileage];
    result = [result stringByAppendingFormat:@"State : %@\n",self.State];
    result = [result stringByAppendingFormat:@"CheckReason : %@\n",self.CheckReason];
    result = [result stringByAppendingFormat:@"CheckTime : %@\n",self.CheckTime];
    result = [result stringByAppendingFormat:@"AutoIcon : %@\n",self.AutoIcon];
    result = [result stringByAppendingFormat:@"ComplaintDate : %@\n",self.ComplaintDate];
    result = [result stringByAppendingFormat:@"ClaimScore : %@\n",self.ClaimScore];
    result = [result stringByAppendingFormat:@"ClaimerReason : %@\n",self.ClaimerReason];
    result = [result stringByAppendingFormat:@"mobile : %@\n",self.mobile];
    result = [result stringByAppendingFormat:@"isnew : %@\n",self.isnew];
    result = [result stringByAppendingFormat:@"registeDate : %@\n",self.registeDate];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"SalesId : %@\n",self.SalesId];
    result = [result stringByAppendingFormat:@"Price : %@\n",self.Price];
    result = [result stringByAppendingFormat:@"SalesName : %@\n",self.SalesName];
    result = [result stringByAppendingFormat:@"CheckMark : %@\n",self.CheckMark];

    return result;
}

@end
