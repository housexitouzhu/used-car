//
//  UCCarSpecModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarSpecModel.h"

@implementation UCCarSpecModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.name = [json objectForKey:@"Name"];
            self.specId = [json objectForKey:@"SpecId"];
            self.fatherId = [json objectForKey:@"FatherId"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.specId forKey:@"SpecId"];
    [aCoder encodeObject:self.fatherId forKey:@"FatherId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.specId = [aDecoder decodeObjectForKey:@"SpecId"];
        self.fatherId = [aDecoder decodeObjectForKey:@"FatherId"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"Name : %@\n", self.name];
    result = [result stringByAppendingFormat:@"SpecId : %@\n", self.specId];
    result = [result stringByAppendingFormat:@"FatherId : %@\n", self.fatherId];
    
    return result;
}

@end
