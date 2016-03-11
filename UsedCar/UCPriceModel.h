//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UCPriceModel : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *specid;
@property (nonatomic,retain)NSNumber *mileage;
@property (nonatomic,retain)NSString *firstregtime;
@property (nonatomic,retain)NSNumber *pid;
@property (nonatomic,retain)NSNumber *cid;
@property (nonatomic,retain)NSNumber *price;

-(id)initWithJson:(NSDictionary *)json;

@end
