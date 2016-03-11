//
//  UCCarBrandModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCCarBrandModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *brandId;

- (id)initWithJson:(NSDictionary *)json;


@end
