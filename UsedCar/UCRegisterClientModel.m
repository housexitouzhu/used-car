//
//  UCClientRegisterModel.m
//  UsedCar
//
//  Created by Sun Honglin on 14-9-24.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterClientModel.h"

@implementation UCRegisterClientModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.nickname = [json objectForKey:@"nickname"];
            self.userpwd = [json objectForKey:@"userpwd"];
            self.mobile = [json objectForKey:@"mobile"];
            self.validecode = [json objectForKey:@"validecode"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.userpwd forKey:@"userpwd"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.validecode forKey:@"validecode"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.userpwd = [aDecoder decodeObjectForKey:@"userpwd"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.validecode = [aDecoder decodeObjectForKey:@"validecode"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"nickname : %@\n", self.nickname];
    result = [result stringByAppendingFormat:@"userpwd : %@\n", self.userpwd];
    result = [result stringByAppendingFormat:@"mobile : %@\n", self.mobile];
    result = [result stringByAppendingFormat:@"validecode : %@\n", self.validecode];
    
    return result;
}

@end
