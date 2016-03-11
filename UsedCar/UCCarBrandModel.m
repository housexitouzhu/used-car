//
//  UCCarBrandModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarBrandModel.h"

@implementation UCCarBrandModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.name = [json objectForKey:@"Name"];
            self.brandId = [json objectForKey:@"BrandId"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.brandId forKey:@"BrandId"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.brandId = [aDecoder decodeObjectForKey:@"BrandId"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"Name : %@\n", self.name];
    result = [result stringByAppendingFormat:@"BrandId : %@\n", self.brandId];
    
    return result;
}

@end
