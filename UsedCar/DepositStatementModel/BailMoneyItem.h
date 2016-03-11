//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoneyDetailItem.h"


@interface BailMoneyItem : NSObject<NSCoding>

@property (nonatomic,retain)NSMutableArray *MoneyDetail;
@property (nonatomic,retain)NSString *InsertTime;
 

-(id)initWithJson:(NSDictionary *)json;

@end
