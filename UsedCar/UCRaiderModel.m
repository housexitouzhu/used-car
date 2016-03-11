//
//  UCRaiderModel.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRaiderModel.h"

@implementation UCRaiderModel

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        if (json != nil) {
            
            self.articleid = [json objectForKey:@"articleid"];
            self.articletitle = [json objectForKey:@"articletitle"];
            self.articleintroduce= [json objectForKey:@"articleintroduce"];
            self.articlepublishdate = [json objectForKey:@"articlepublishdate"];

        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.articleid forKey:@"articleid"];
    [aCoder encodeObject:self.articletitle forKey:@"articletitle"];
    [aCoder encodeObject:self.articleintroduce forKey:@"articleintroduce"];
    [aCoder encodeObject:self.articlepublishdate forKey:@"articlepublishdate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.articleid = [aDecoder decodeObjectForKey:@"articleid"];
        self.articletitle = [aDecoder decodeObjectForKey:@"articletitle"];
        self.articleintroduce= [aDecoder decodeObjectForKey:@"articleintroduce"];
        self.articlepublishdate = [aDecoder decodeObjectForKey:@"articlepublishdate"];
    }
    return self;
}

@end
