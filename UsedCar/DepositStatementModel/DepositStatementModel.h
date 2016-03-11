//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BailDealerDetails.h"
#import "BailMoneyItem.h"


@interface DepositStatementModel : NSObject<NSCoding>

@property (nonatomic,retain) BailDealerDetails *BailDealerDetails;
@property (nonatomic,retain)NSMutableArray *BailMoneyList;
 

-(id)initWithJson:(NSDictionary *)json;

@end
