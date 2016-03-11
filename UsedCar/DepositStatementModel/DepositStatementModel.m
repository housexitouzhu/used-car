//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "DepositStatementModel.h"

@implementation DepositStatementModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
            self.BailDealerDetails  = [[BailDealerDetails alloc] initWithJson:[json objectForKey:@"BailDealerDetails"]];
            self.BailMoneyList = [NSMutableArray array];
                for(id item in [json objectForKey:@"BailMoneyList"])
                {
                    if ([item isKindOfClass:[NSDictionary class]]){
                    [self.BailMoneyList addObject:[[BailMoneyItem alloc] initWithJson:item]];
                }
                else{
                    [self.BailMoneyList addObject:item];
                }
        }

        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.BailDealerDetails forKey:@"BailDealerDetails"];
[aCoder encodeObject:self.BailMoneyList forKey:@"BailMoneyList"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.BailDealerDetails = [aDecoder decodeObjectForKey:@"BailDealerDetails"];
 self.BailMoneyList = [aDecoder decodeObjectForKey:@"BailMoneyList"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"BailDealerDetails : %@\n",self.BailDealerDetails];
result = [result stringByAppendingFormat:@"BailMoneyList : %@\n",self.BailMoneyList];

    return result;
}

@end
