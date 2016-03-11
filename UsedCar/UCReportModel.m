//
//  UCReportModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-6-20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCReportModel.h"

@implementation UCReportModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.carId = [json objectForKey:@"carid"];
            self.brandId = [json objectForKey:@"brandid"];
            self.seriesId = [json objectForKey:@"seriesid"];
            self.mobile = [json objectForKey:@"mobile"];
            self.userName = [json objectForKey:@"uname"];
            self.type = [json objectForKey:@"type"];
            self.specId = [json objectForKey:@"specid"];
            self.context = [json objectForKey:@"context"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.carId forKey:@"carid"];
    [aCoder encodeObject:self.brandId forKey:@"brandid"];
    [aCoder encodeObject:self.seriesId forKey:@"seriesid"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.userName forKey:@"uname"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.specId forKey:@"specid"];
    [aCoder encodeObject:self.context forKey:@"context"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.carId = [aDecoder decodeObjectForKey:@"carid"];
        self.brandId = [aDecoder decodeObjectForKey:@"brandid"];
        self.seriesId = [aDecoder decodeObjectForKey:@"seriesid"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.userName = [aDecoder decodeObjectForKey:@"uname"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.specId = [aDecoder decodeObjectForKey:@"specid"];
        self.context = [aDecoder decodeObjectForKey:@"context"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"carid : %@\n", self.carId];
    result = [result stringByAppendingFormat:@"brandid : %@\n", self.brandId];
    result = [result stringByAppendingFormat:@"seriesid : %@\n", self.seriesId];
    result = [result stringByAppendingFormat:@"mobile : %@\n", self.mobile];
    result = [result stringByAppendingFormat:@"uname : %@\n", self.userName];
    result = [result stringByAppendingFormat:@"type : %@\n", self.type];
    result = [result stringByAppendingFormat:@"specId : %@\n", self.specId];
    result = [result stringByAppendingFormat:@"context : %@\n", self.context];
    return result;
}
@end
