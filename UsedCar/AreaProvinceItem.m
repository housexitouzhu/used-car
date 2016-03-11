//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "AreaProvinceItem.h"
#import "UCHotAreaModel.h"

@implementation AreaProvinceItem

- (id)initWithPN:(NSString *)PN PI:(NSNumber *)PI
{
    self = [super init];
    
    if (self) {
        self.PN = PN;
        self.PI = PI;
    }
    
    return self;
}

- (id)initWithHotAreaModel:(UCHotAreaModel *)mHotArea
{
    self = [super init];
    if (self) {
        self.PI = mHotArea.Id;
        self.PN = mHotArea.Name;
        self.CL = [NSMutableArray arrayWithArray:mHotArea.AreaId];
    }
    return self;
}

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];

    if (self) {
        if (json != nil) {
            self.PI = [json objectForKey:@"PI"];
            self.PN = [json objectForKey:@"PN"];
            self.FL = [json objectForKey:@"FL"];
            self.CL = [NSMutableArray array];

            for (id item in [json objectForKey : @"CL"]) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [self.CL addObject:[[AreaCityItem alloc] initWithJson:item]];
                } else {
                    [self.CL addObject:item];
                }
            }
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.PN forKey:@"PN"];
    [aCoder encodeObject:self.CL forKey:@"CL"];
    [aCoder encodeObject:self.PI forKey:@"PI"];
    [aCoder encodeObject:self.FL forKey:@"FL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.PN = [aDecoder decodeObjectForKey:@"PN"];
        self.CL = [aDecoder decodeObjectForKey:@"CL"];
        self.PI = [aDecoder decodeObjectForKey:@"PI"];
        self.FL = [aDecoder decodeObjectForKey:@"FL"];
    }

    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"PI : %@\n", self.PI];
    result = [result stringByAppendingFormat:@"PN : %@\n", self.PN];
    result = [result stringByAppendingFormat:@"FL : %@\n", self.FL];
    result = [result stringByAppendingFormat:@"CL : %@\n", self.CL];

    return result;
}

@end