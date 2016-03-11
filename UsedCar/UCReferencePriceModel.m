//
//  UCReferencePriceModel.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCReferencePriceModel.h"

@implementation UCReferencePriceModel
- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.referenceprice = [json objectForKey:@"referenceprice"];
            self.newcarprice = [json objectForKey:@"newcarprice"];
            
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.referenceprice forKey:@"referenceprice"];
    [aCoder encodeObject:self.newcarprice forKey:@"newcarprice"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.referenceprice = [aDecoder decodeObjectForKey:@"referenceprice"];
        self.newcarprice = [aDecoder decodeObjectForKey:@"newcarprice"];
        
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"referenceprice : %@\n", self.referenceprice];
    result = [result stringByAppendingFormat:@"newcarprice : %@\n", self.newcarprice];
    
    
    return result;
}
@end
