//
//  UCFavoritesModel.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFavoritesModel.h"

@implementation UCFavoritesModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.hid = [json objectForKey:@"Hid"];
            self.quoteID = [json objectForKey:@"ID"];
            self.name = [json objectForKey:@"Name"];
            self.price = [json objectForKey:@"Price"];
            self.image = [json objectForKey:@"Image"];
            self.mileage = [json objectForKey:@"Mileage"];
            self.registrationDate = [json objectForKey:@"RegistrationDate"];
            self.publishDate = [json objectForKey:@"PublishDate"];
            self.isDealer = [json objectForKey:@"IsDealer"];
            self.hasCard = [json objectForKey:@"HasCard"];
            self.seriesId = [json objectForKey:@"SeriesId"];
            self.completeSale = [json objectForKey:@"CompleteSale"];
            self.levelId = [json objectForKey:@"LevelId"];
            self.isnewcar = [NSNumber numberWithInteger:0];//[json objectForKey:@"IsNewCar"];
            self.invoice = [NSNumber numberWithInteger:0];//[json objectForKey:@"Invoice"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.hid forKey:@"Hid"];
    [aCoder encodeObject:self.quoteID forKey:@"ID"];
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.price forKey:@"Price"];
    [aCoder encodeObject:self.image forKey:@"Image"];
    [aCoder encodeObject:self.mileage forKey:@"Mileage"];
    [aCoder encodeObject:self.registrationDate forKey:@"RegistrationDate"];
    [aCoder encodeObject:self.publishDate forKey:@"PublishDate"];
    [aCoder encodeObject:self.isDealer forKey:@"IsDealer"];
    [aCoder encodeObject:self.hasCard forKey:@"HasCard"];
    [aCoder encodeObject:self.seriesId forKey:@"SeriesId"];
    [aCoder encodeObject:self.completeSale forKey:@"CompleteSale"];
    [aCoder encodeObject:self.levelId forKey:@"LevelId"];
    [aCoder encodeObject:self.isnewcar forKey:@"IsNewCar"];
    [aCoder encodeObject:self.invoice forKey:@"Invoice"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.hid = [aDecoder decodeObjectForKey:@"Hid"];
        self.quoteID = [aDecoder decodeObjectForKey:@"ID"];
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.price = [aDecoder decodeObjectForKey:@"Price"];
        self.image = [aDecoder decodeObjectForKey:@"Image"];
        self.mileage = [aDecoder decodeObjectForKey:@"Mileage"];
        self.registrationDate = [aDecoder decodeObjectForKey:@"RegistrationDate"];
        self.publishDate = [aDecoder decodeObjectForKey:@"PublishDate"];
        self.isDealer = [aDecoder decodeObjectForKey:@"IsDealer"];
        self.hasCard = [aDecoder decodeObjectForKey:@"HasCard"];
        self.seriesId = [aDecoder decodeObjectForKey:@"SeriesId"];
        self.completeSale = [aDecoder decodeObjectForKey:@"CompleteSale"];
        self.levelId = [aDecoder decodeObjectForKey:@"LevelId"];
        self.isnewcar = [aDecoder decodeObjectForKey:@"IsNewCar"];
        self.invoice = [aDecoder decodeObjectForKey:@"Invoice"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"Hid : %@\n", self.hid];
    result = [result stringByAppendingFormat:@"ID : %@\n", self.quoteID];
    result = [result stringByAppendingFormat:@"Name : %@\n", self.name];
    result = [result stringByAppendingFormat:@"Price : %@\n", self.price];
    result = [result stringByAppendingFormat:@"Image : %@\n", self.image];
    result = [result stringByAppendingFormat:@"Mileage : %@\n", self.mileage];
    result = [result stringByAppendingFormat:@"RegistrationDate : %@\n", self.registrationDate];
    result = [result stringByAppendingFormat:@"PublishDate : %@\n", self.publishDate];
    result = [result stringByAppendingFormat:@"IsDealer : %@\n", self.isDealer];
    result = [result stringByAppendingFormat:@"HasCard : %@\n", self.hasCard];
    result = [result stringByAppendingFormat:@"SeriesId : %@\n", self.seriesId];
    result = [result stringByAppendingFormat:@"CompleteSale : %@\n", self.completeSale];
    result = [result stringByAppendingFormat:@"LevelId : %@\n", self.levelId];
    result = [result stringByAppendingFormat:@"IsNewCar : %@\n", self.isnewcar];
    result = [result stringByAppendingFormat:@"Invoice : %@\n", self.invoice];
    
    return result;
}

@end
