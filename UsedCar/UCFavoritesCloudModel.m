//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCFavoritesCloudModel.h"

@implementation UCFavoritesCloudModel

-(id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    if(self)
    {
        if(json != nil)
        {
           self.state  = [json objectForKey:@"state"];
            self.publishdate  = [json objectForKey:@"publishdate"];
            self.carid  = [json objectForKey:@"carid"];
            self.mileage  = [json objectForKey:@"mileage"];
            self.levelid = [json objectForKey:@"levelid"];
            self.isnewcar  = [json objectForKey:@"isnewcar"];
            self.registrationdate  = [json objectForKey:@"registrationdate"];
            self.price  = [json objectForKey:@"price"];
            self.image  = [json objectForKey:@"image"];
            self.extendedrepair  = [json objectForKey:@"extendedrepair"];
            self.carname  = [json objectForKey:@"carname"];
            self.sourceid  = [json objectForKey:@"sourceid"];
            self.specid  = [json objectForKey:@"specid"];
            self.pdate  = [json objectForKey:@"pdate"];
     
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.publishdate forKey:@"publishdate"];
    [aCoder encodeObject:self.carid forKey:@"carid"];
    [aCoder encodeObject:self.mileage forKey:@"mileage"];
    [aCoder encodeObject:self.levelid forKey:@"levelid"];
    [aCoder encodeObject:self.isnewcar forKey:@"isnewcar"];
    [aCoder encodeObject:self.registrationdate forKey:@"registrationdate"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.extendedrepair forKey:@"extendedrepair"];
    [aCoder encodeObject:self.carname forKey:@"carname"];
    [aCoder encodeObject:self.sourceid forKey:@"sourceid"];
    [aCoder encodeObject:self.specid forKey:@"specid"];
    [aCoder encodeObject:self.pdate forKey:@"pdate"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.publishdate = [aDecoder decodeObjectForKey:@"publishdate"];
        self.carid = [aDecoder decodeObjectForKey:@"carid"];
        self.mileage = [aDecoder decodeObjectForKey:@"mileage"];
        self.levelid = [aDecoder decodeObjectForKey:@"levelid"];
        self.isnewcar = [aDecoder decodeObjectForKey:@"isnewcar"];
        self.registrationdate = [aDecoder decodeObjectForKey:@"registrationdate"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.extendedrepair = [aDecoder decodeObjectForKey:@"extendedrepair"];
        self.carname = [aDecoder decodeObjectForKey:@"carname"];
        self.sourceid = [aDecoder decodeObjectForKey:@"sourceid"];
        self.specid = [aDecoder decodeObjectForKey:@"specid"];
        self.pdate = [aDecoder decodeObjectForKey:@"pdate"];
 
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"state : %@\n",self.state];
    result = [result stringByAppendingFormat:@"publishdate : %@\n",self.publishdate];
    result = [result stringByAppendingFormat:@"carid : %@\n",self.carid];
    result = [result stringByAppendingFormat:@"mileage : %@\n",self.mileage];
    result = [result stringByAppendingFormat:@"levelid : %@\n",self.levelid];
    result = [result stringByAppendingFormat:@"isnewcar : %@\n",self.isnewcar];
    result = [result stringByAppendingFormat:@"registrationdate : %@\n",self.registrationdate];
    result = [result stringByAppendingFormat:@"price : %@\n",self.price];
    result = [result stringByAppendingFormat:@"image : %@\n",self.image];
    result = [result stringByAppendingFormat:@"extendedrepair : %@\n",self.extendedrepair];
    result = [result stringByAppendingFormat:@"carname : %@\n",self.carname];
    result = [result stringByAppendingFormat:@"sourceid : %@\n",self.sourceid];
    result = [result stringByAppendingFormat:@"specid : %@\n",self.specid];
    result = [result stringByAppendingFormat:@"pdate : %@\n",self.pdate];

    return result;
}

@end
