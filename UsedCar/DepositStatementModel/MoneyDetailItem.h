//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MoneyDetailItem : NSObject<NSCoding>

@property (nonatomic,retain)NSString *Reason;
@property (nonatomic,retain)NSNumber *Money;
@property (nonatomic,retain)NSNumber *State;
@property (nonatomic,retain)NSString *StateName;
@property (nonatomic,retain)NSNumber *Overage;
 

-(id)initWithJson:(NSDictionary *)json;

@end
