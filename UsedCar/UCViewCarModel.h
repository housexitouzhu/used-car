//
//  UCReserVationModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCViewCarModel : NSObject

@property (nonatomic, strong) NSString *phoneId;
@property (nonatomic, strong) NSString *telePhone;
@property (nonatomic, strong) NSString *name;

- (id)initWithJson:(NSDictionary *)json;

@end
