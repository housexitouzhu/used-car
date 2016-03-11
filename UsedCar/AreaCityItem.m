//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "AreaCityItem.h"

@implementation AreaCityItem

- (id)initWithCN:(NSString *)CN CI:(NSNumber *)CI
{
    self = [super init];
    
    if (self) {
        self.CN = CN;
        self.CI = CI;
    }
    
    return self;
}

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];

    if (self) {
        if (json != nil) {
            self.CN = [json objectForKey:@"CN"];
            self.CI = [json objectForKey:@"CI"];
//            self.Lng = [json objectForKey:@"Lng"];
//            self.Lat = [json objectForKey:@"Lat"];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.CN forKey:@"CN"];
    [aCoder encodeObject:self.CI forKey:@"CI"];
//    [aCoder encodeObject:self.Lng forKey:@"Lng"];
//    [aCoder encodeObject:self.Lat forKey:@"Lat"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.CN = [aDecoder decodeObjectForKey:@"CN"];
        self.CI = [aDecoder decodeObjectForKey:@"CI"];
//        self.Lng = [aDecoder decodeObjectForKey:@"Lng"];
//        self.Lat = [aDecoder decodeObjectForKey:@"Lat"];
    }

    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"CN : %@\n", self.CN];
    result = [result stringByAppendingFormat:@"CI : %@\n", self.CI];
//    result = [result stringByAppendingFormat:@"Lng : %@\n", self.Lng];
//    result = [result stringByAppendingFormat:@"Lat : %@\n", self.Lat];

    return result;
}


@end