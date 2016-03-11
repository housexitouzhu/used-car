//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClaimRecordItem : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *carid;
@property (nonatomic,retain)NSString *CarName;
@property (nonatomic,retain)NSNumber *Mileage;
@property (nonatomic,retain)NSNumber *State;
@property (nonatomic,retain)NSString *CheckReason;
@property (nonatomic,retain)NSString *CheckTime;
@property (nonatomic,retain)NSString *AutoIcon;
@property (nonatomic,retain)NSString *ComplaintDate;
@property (nonatomic,retain)NSNumber *ClaimScore;
@property (nonatomic,retain)NSString *ClaimerReason;
@property (nonatomic,retain)NSString *mobile;
@property (nonatomic,retain)NSNumber *isnew;
@property (nonatomic,retain)NSString *registeDate;
@property (nonatomic,retain)NSString *username;
@property (nonatomic,retain)NSNumber *SalesId;
@property (nonatomic,retain)NSNumber *Price;
@property (nonatomic,retain)NSString *SalesName;
@property (nonatomic,retain)NSString *CheckMark;
 

-(id)initWithJson:(NSDictionary *)json;

@end
