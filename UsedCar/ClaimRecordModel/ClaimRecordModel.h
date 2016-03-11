//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClaimRecordItem.h"


@interface ClaimRecordModel : NSObject<NSCoding>

@property (nonatomic,retain)NSNumber *Count;
@property (nonatomic,retain)NSMutableArray *ClaimList;
 

-(id)initWithJson:(NSDictionary *)json;

@end
