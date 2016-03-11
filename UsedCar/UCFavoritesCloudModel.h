//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UCFavoritesCloudModel : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *state;
@property (nonatomic,retain)NSString *publishdate;
@property (nonatomic,retain)NSNumber *carid;
@property (nonatomic,retain)NSString *mileage;
@property (nonatomic,retain)NSNumber *levelid;
@property (nonatomic,retain)NSNumber *isnewcar;
@property (nonatomic,retain)NSString *registrationdate;
@property (nonatomic,retain)NSString *price;
@property (nonatomic,retain)NSString *image;
@property (nonatomic,retain)NSNumber *extendedrepair;
@property (nonatomic,retain)NSString *carname;
@property (nonatomic,retain)NSNumber *sourceid;
@property (nonatomic,retain)NSNumber *specid;
@property (nonatomic,retain)NSString *pdate;
 

-(id)initWithJson:(NSDictionary *)json;

@end
