//
//  UCResisterModel.m
//  UsedCar
//
//  Created by 张鑫 on 14-5-21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCRegisterDealerModel.h"

@implementation UCRegisterDealerModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.shopname = [json objectForKey:@"shopname"];
            self.companytype = [json objectForKey:@"companytype"];
            self.pid = [json objectForKey:@"pid"];
            self.cid = [json objectForKey:@"cid"];
            self.contactname = [json objectForKey:@"contactname"];
            self.phonenumber = [json objectForKey:@"phonenumber"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.shopname forKey:@"shopname"];
    [aCoder encodeObject:self.companytype forKey:@"companytype"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeObject:self.contactname forKey:@"contactname"];
    [aCoder encodeObject:self.phonenumber forKey:@"phonenumber"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.shopname = [aDecoder decodeObjectForKey:@"shopname"];
        self.companytype = [aDecoder decodeObjectForKey:@"companytype"];
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        self.contactname = [aDecoder decodeObjectForKey:@"contactname"];
        self.phonenumber = [aDecoder decodeObjectForKey:@"phonenumber"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"shopname : %@\n", self.shopname];
    result = [result stringByAppendingFormat:@"companytype : %@\n", self.companytype];
    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
    result = [result stringByAppendingFormat:@"contactname : %@\n", self.contactname];
    result = [result stringByAppendingFormat:@"phonenumber : %@\n", self.phonenumber];

    return result;
}

@end

