//
//  UCEvaluationPriceModel.m
//  UsedCar
//
//  Created by 张鑫 on 14-1-2.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEvaluationPriceModel.h"

@implementation UCEvaluationPriceModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.newcarprice = [json objectForKey:@"newcarprice"];
            self.referenceprice = [json objectForKey:@"referenceprice"];
            self.url = [json objectForKey:@"url"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.newcarprice forKey:@"newcarprice"];
    [aCoder encodeObject:self.referenceprice forKey:@"referenceprice"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.newcarprice = [aDecoder decodeObjectForKey:@"newcarprice"];
        self.referenceprice = [aDecoder decodeObjectForKey:@"referenceprice"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"newcarprice : %@\n", self.newcarprice];
    result = [result stringByAppendingFormat:@"referenceprice : %@\n", self.referenceprice];
    result = [result stringByAppendingFormat:@"url : %@\n", self.url];

    return result;
}

@end
