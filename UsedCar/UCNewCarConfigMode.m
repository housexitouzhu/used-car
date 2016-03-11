//
//  UCNewCarConfigMode.m
//  UsedCar
//
//  Created by 张鑫 on 14-2-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCNewCarConfigMode.h"

@implementation UCNewCarConfigMode

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.configurations = [NSMutableArray array];
            
            NSArray *paramitems = [json objectForKey:@"paramitems"];
            for (int i = 0; i < paramitems.count; i++) {
                NSDictionary *dicTemp = [paramitems objectAtIndex:i];
                [self.configurations addObject:dicTemp];
            }
            
            NSArray *configitems = [json objectForKey:@"configitems"];
            for (int i = 0; i < configitems.count; i++) {
                NSDictionary *dicTemp = [configitems objectAtIndex:i];
                [self.configurations addObject:dicTemp];
            }
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.configurations forKey:@"configurations"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.configurations = [aDecoder decodeObjectForKey:@"configurations"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"configurations : %@\n", self.configurations];
    
    return result;
}

@end
