//
//  UCSaleLeadModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSalesLeadsModel.h"

@implementation UCSalesLeadsModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.name = [json objectForKey:@"name"];
            self.mobile = [json objectForKey:@"mobile"];
            self.carcount = [json objectForKey:@"carcount"];
            self.remark = [json objectForKey:@"remark"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.carcount forKey:@"carcount"];
    [aCoder encodeObject:self.remark forKey:@"remark"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.carcount = [aDecoder decodeObjectForKey:@"carcount"];
        self.remark = [aDecoder decodeObjectForKey:@"remark"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"name : %@\n", self.name];
    result = [result stringByAppendingFormat:@"mobile : %@\n", self.mobile];
    result = [result stringByAppendingFormat:@"carcount : %@\n", self.carcount];
    result = [result stringByAppendingFormat:@"remark : %@\n", self.remark];
    
    return result;
}



@end
