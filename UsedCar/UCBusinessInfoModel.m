//
//  UCBusinessInfoModel.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-4.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCBusinessInfoModel.h"

@implementation UCBusinessInfoModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            
            self.address = [json objectForKey:@"address"];
            self.cname = [json objectForKey:@"cname"];
            self.latitude = [NSNumber numberWithFloat:[[json objectForKey:@"latitude"] doubleValue]];
            self.longtitude = [NSNumber numberWithFloat:[[json objectForKey:@"longtitude"] doubleValue]];
            self.managetype = [json objectForKey:@"managetype"];
            self.phone = [json objectForKey:@"phone"];
            self.pname = [json objectForKey:@"pname"];
            self.username = [json objectForKey:@"username"];
            self.money = [json objectForKey:@"money"];
            
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.cname forKey:@"cname"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longtitude forKey:@"longtitude"];
    [aCoder encodeObject:self.managetype forKey:@"managetype"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.pname forKey:@"pname"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.money forKey:@"money"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.cname = [aDecoder decodeObjectForKey:@"cname"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.longtitude = [aDecoder decodeObjectForKey:@"longtitude"];
        self.managetype = [aDecoder decodeObjectForKey:@"managetype"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.pname = [aDecoder decodeObjectForKey:@"pname"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.money = [aDecoder decodeObjectForKey:@"money"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"address : %@\n", self.address];
    result = [result stringByAppendingFormat:@"cname : %@\n", self.cname];
    result = [result stringByAppendingFormat:@"latitude : %@\n", self.latitude];
    result = [result stringByAppendingFormat:@"longtitude : %@\n", self.longtitude];
    result = [result stringByAppendingFormat:@"managetype : %@\n", self.managetype];
    result = [result stringByAppendingFormat:@"phone : %@\n", self.phone];
    result = [result stringByAppendingFormat:@"pname : %@\n", self.pname];
    result = [result stringByAppendingFormat:@"username : %@\n", self.username];
    result = [result stringByAppendingFormat:@"money : %@\n", self.money];
    
    return result;
}

@end
