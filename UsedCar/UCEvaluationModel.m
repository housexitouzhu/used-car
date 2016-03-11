//
//  UCEvaluationModel.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-31.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCEvaluationModel.h"

@implementation UCEvaluationModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.pid = [json objectForKey:@"pid"];
            self.cid = [json objectForKey:@"cid"];
            self.mileage = [json objectForKey:@"mileage"];
            self.firstregtime = [json objectForKey:@"firstregtime"];
            self.brandid = [json objectForKey:@"brandid"];
            self.specid = [json objectForKey:@"specid"];
            self.seriesid = [json objectForKey:@"seriesid"];
            
            self.pidText = [json objectForKey:@"pidText"];
            self.cidText = [json objectForKey:@"cidText"];
            self.mileageText = [json objectForKey:@"mileageText"];
            self.brandText = [json objectForKey:@"brandText"];
            self.seriesidText = [json objectForKey:@"seriesidText"];
            self.specidText = [json objectForKey:@"specidText"];
            self.firstregtimeText = [json objectForKey:@"firstregtimeText"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeObject:self.mileage forKey:@"mileage"];
    [aCoder encodeObject:self.firstregtime forKey:@"firstregtime"];
    [aCoder encodeObject:self.brandid forKey:@"brandid"];
    [aCoder encodeObject:self.specid forKey:@"specid"];
    [aCoder encodeObject:self.seriesid forKey:@"seriesid"];
    
    [aCoder encodeObject:self.pidText forKey:@"pidText"];
    [aCoder encodeObject:self.cidText forKey:@"cidText"];
    [aCoder encodeObject:self.mileageText forKey:@"mileageText"];
    [aCoder encodeObject:self.brandText forKey:@"brandText"];
    [aCoder encodeObject:self.seriesidText forKey:@"seriesidText"];
    [aCoder encodeObject:self.specidText forKey:@"specidText"];
    [aCoder encodeObject:self.firstregtimeText forKey:@"firstregtimeText"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        self.mileage = [aDecoder decodeObjectForKey:@"mileage"];
        self.firstregtime = [aDecoder decodeObjectForKey:@"firstregtime"];
        self.brandid = [aDecoder decodeObjectForKey:@"brandid"];
        self.specid = [aDecoder decodeObjectForKey:@"specid"];
        self.seriesid = [aDecoder decodeObjectForKey:@"seriesid"];
        
        self.pidText = [aDecoder decodeObjectForKey:@"pidText"];
        self.cidText = [aDecoder decodeObjectForKey:@"cidText"];
        self.mileageText = [aDecoder decodeObjectForKey:@"mileageText"];
        self.brandText = [aDecoder decodeObjectForKey:@"brandText"];
        self.seriesidText = [aDecoder decodeObjectForKey:@"seriesidText"];
        self.specidText = [aDecoder decodeObjectForKey:@"specidText"];
        self.firstregtimeText = [aDecoder decodeObjectForKey:@"firstregtimeText"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
    result = [result stringByAppendingFormat:@"mileage : %@\n", self.mileage];
    result = [result stringByAppendingFormat:@"firstregtime : %@\n", self.firstregtime];
    result = [result stringByAppendingFormat:@"brandid : %@\n", self.brandid];
    result = [result stringByAppendingFormat:@"specid : %@\n", self.specid];
    result = [result stringByAppendingFormat:@"seriesid : %@\n", self.seriesid];
    
    result = [result stringByAppendingFormat:@"pidText : %@\n", self.pidText];
    result = [result stringByAppendingFormat:@"cidText : %@\n", self.cidText];
    result = [result stringByAppendingFormat:@"mileageText : %@\n", self.mileageText];
    result = [result stringByAppendingFormat:@"brandText : %@\n", self.brandText];
    result = [result stringByAppendingFormat:@"seriesidText : %@\n", self.seriesidText];
    result = [result stringByAppendingFormat:@"specidText : %@\n", self.specidText];
    result = [result stringByAppendingFormat:@"firstregtimeText : %@\n", self.firstregtimeText];
    
    return result;
}

- (BOOL)isNull
{
    if ((self.specid.integerValue == 0) && (self.mileage.doubleValue == 0) && (self.pid.integerValue == 0 || self.cid.integerValue == 0) && (self.firstregtime.length == 0))
        return YES;
    else
        return NO;
}

@end
