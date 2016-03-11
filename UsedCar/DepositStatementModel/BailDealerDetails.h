//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BailDealerDetails : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *BailMoney;
@property (nonatomic,retain)NSNumber *CurMoney;
@property (nonatomic,retain)NSString *EndDate;
@property (nonatomic,retain)NSNumber *State;
 

-(id)initWithJson:(NSDictionary *)json;

@end
