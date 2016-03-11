//
//  UCCarSeriesModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCCarSeriesModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *seriesId;
@property (nonatomic, strong) NSString  *fatherId;

- (id)initWithJson:(NSDictionary *)json;

@end
