//
//  UCReserVationModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCViewCarModel.h"

@implementation UCViewCarModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.telePhone = [json objectForKey:@"id"];
            self.phoneId = [json objectForKey:@"logo"];
            self.name = [json objectForKey:@"Name"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.telePhone forKey:@"id"];
    [aCoder encodeObject:self.phoneId forKey:@"logo"];
    [aCoder encodeObject:self.name forKey:@"Name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.phoneId = [aDecoder decodeObjectForKey:@"id"];
        self.telePhone = [aDecoder decodeObjectForKey:@"logo"];
        self.name = [aDecoder decodeObjectForKey:@"carName"];
    }
    
    return self;
}


@end
