//
//  UCDealerDepositModel.h
//  UsedCar
//
//  Created by Sun Honglin on 14-8-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCDealerDepositModel : NSObject<NSCoding>

@property (nonatomic,retain)NSString *bmoney;
@property (nonatomic,retain)NSString *enddate;
@property (nonatomic,retain)NSString *startdate;
@property (nonatomic,retain)NSString *bstatuename;
@property (nonatomic,retain)NSString *inserttime;
@property (nonatomic,retain)NSString *lasttime;
@property (nonatomic,retain)NSNumber *bdpmstatue;
@property (nonatomic,retain)NSNumber *bstatue;
@property (nonatomic,retain)NSNumber *btype;
@property (nonatomic,retain)NSNumber *remainday;
@property (nonatomic,retain)NSString *bailcurmoney;

-(id)initWithJson:(NSDictionary *)json;

@end
