//
//  UCCarSeriesModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarSeriesModel.h"

@implementation UCCarSeriesModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.name = [json objectForKey:@"Name"];
            self.seriesId = [json objectForKey:@"SeriesId"];
            self.fatherId = [json objectForKey:@"FatherId"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.seriesId forKey:@"SeriesId"];
    [aCoder encodeObject:self.fatherId forKey:@"FatherId"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.seriesId = [aDecoder decodeObjectForKey:@"SeriesId"];
        self.fatherId = [aDecoder decodeObjectForKey:@"FatherId"];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"Name : %@\n", self.name];
    result = [result stringByAppendingFormat:@"SeriesId : %@\n", self.seriesId];
    result = [result stringByAppendingFormat:@"FatherId : %@\n", self.fatherId];
    
    return result;
}

@end
