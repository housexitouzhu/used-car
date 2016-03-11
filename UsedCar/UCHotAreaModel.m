//
//  UCHotAreaModel.m
//  UsedCar
//
//  Created by 张鑫 on 14-6-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCHotAreaModel.h"

@implementation UCHotAreaModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.Id = [json objectForKey:@"Id"];
            self.Name = [json objectForKey:@"Name"];
            self.Pinyin = [json objectForKey:@"Pinyin"];
            self.IsProvince = [json objectForKey:@"IsProvince"];
            self.AreaId = [NSArray arrayWithArray:[[json objectForKey:@"AreaId"] componentsSeparatedByString:@","]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Id forKey:@"Id"];
    [aCoder encodeObject:self.Name forKey:@"Name"];
    [aCoder encodeObject:self.Pinyin forKey:@"Pinyin"];
    [aCoder encodeObject:self.IsProvince forKey:@"IsProvince"];
    [aCoder encodeObject:self.AreaId forKey:@"AreaId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.Id = [aDecoder decodeObjectForKey:@"Id"];
        self.Name = [aDecoder decodeObjectForKey:@"Name"];
        self.Pinyin = [aDecoder decodeObjectForKey:@"Pinyin"];
        self.IsProvince = [aDecoder decodeObjectForKey:@"IsProvince"];
        self.AreaId = [aDecoder decodeObjectForKey:@"AreaId"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"Id : %@\n", self.Id];
    result = [result stringByAppendingFormat:@"Name : %@\n", self.Name];
    result = [result stringByAppendingFormat:@"Pinyin : %@\n", self.Pinyin];
    result = [result stringByAppendingFormat:@"IsProvince : %@\n", self.IsProvince];
    result = [result stringByAppendingFormat:@"AreaId : %@\n", self.AreaId];
    
    return result;
}

@end
