//
//  UCReportModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-6-20.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCReportModel : NSObject

@property (nonatomic, strong) NSNumber *carId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *brandId;
@property (nonatomic, strong) NSNumber *seriesId;
@property (nonatomic, strong) NSNumber *specId;
@property (nonatomic, strong) NSString *context;
@property (nonatomic, strong) NSString *mobile;

@end
