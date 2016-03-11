//
//  UCCarSpecModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-5-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCCarSpecModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *specId;
@property (nonatomic, strong) NSString  *fatherId;

- (id)initWithJson:(NSDictionary *)json;

@end
