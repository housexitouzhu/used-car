//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "MoneyDetailItem.h"

@implementation MoneyDetailItem

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.Reason  = [json objectForKey:@"Reason"];
            self.Money  = [json objectForKey:@"Money"];
            self.State  = [json objectForKey:@"State"];
            self.Overage  = [json objectForKey:@"Overage"];
            self.StateName = [json objectForKey:@"StateName"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Reason forKey:@"Reason"];
    [aCoder encodeObject:self.Money forKey:@"Money"];
    [aCoder encodeObject:self.State forKey:@"State"];
    [aCoder encodeObject:self.Overage forKey:@"Overage"];
    [aCoder encodeObject:self.StateName forKey:@"StateName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.Reason = [aDecoder decodeObjectForKey:@"Reason"];
        self.Money = [aDecoder decodeObjectForKey:@"Money"];
        self.State = [aDecoder decodeObjectForKey:@"State"];
        self.Overage = [aDecoder decodeObjectForKey:@"Overage"];
        self.StateName = [aDecoder decodeObjectForKey:@"StateName"];
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"Reason : %@\n",self.Reason];
    result = [result stringByAppendingFormat:@"Money : %@\n",self.Money];
    result = [result stringByAppendingFormat:@"State : %@\n",self.State];
    result = [result stringByAppendingFormat:@"Overage : %@\n",self.Overage];
    result = [result stringByAppendingFormat:@"StateName : %@\n",self.StateName];
    return result;
}

@end
