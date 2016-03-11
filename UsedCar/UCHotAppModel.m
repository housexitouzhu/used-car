//
//  UCHotAppModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-1-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCHotAppModel.h"

@implementation UCHotAppModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.name = [json objectForKey:@"name"];
            self.icon = [json objectForKey:@"icon"];
            self.url = [json objectForKey:@"url"];
            self.descriptions = [json objectForKey:@"description"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.descriptions forKey:@"description"];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.descriptions = [aDecoder decodeObjectForKey:@"description"];
    }
    
    return self;
}

@end
