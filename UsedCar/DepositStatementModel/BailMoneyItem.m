//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "BailMoneyItem.h"

@implementation BailMoneyItem

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
    if(json != nil)
    {
       self.MoneyDetail = [NSMutableArray array];
        for(id item in [json objectForKey:@"MoneyDetail"])
        {
            if ([item isKindOfClass:[NSDictionary class]]){
                [self.MoneyDetail addObject:[[MoneyDetailItem alloc] initWithJson:item]];
            }
            else{
                [self.MoneyDetail addObject:item];
            }
        }
        self.InsertTime  = [json objectForKey:@"InsertTime"];
     
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.MoneyDetail forKey:@"MoneyDetail"];
    [aCoder encodeObject:self.InsertTime forKey:@"InsertTime"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.MoneyDetail = [aDecoder decodeObjectForKey:@"MoneyDetail"];
        self.InsertTime = [aDecoder decodeObjectForKey:@"InsertTime"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"MoneyDetail : %@\n",self.MoneyDetail];
    result = [result stringByAppendingFormat:@"InsertTime : %@\n",self.InsertTime];

    return result;
}

@end
