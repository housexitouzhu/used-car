//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCFavoritesCloudModel.h"


@interface UCFavoritesCloudListModel : NSObject<NSCoding>

@property (nonatomic,retain)NSMutableArray *carlist;
@property (nonatomic,retain)NSNumber *pagecount;
@property (nonatomic,retain)NSNumber *rowcount;
@property (nonatomic,retain)NSNumber *pageindex;
@property (nonatomic,retain)NSNumber *pagesize;
 

-(id)initWithJson:(NSDictionary *)json;

@end
