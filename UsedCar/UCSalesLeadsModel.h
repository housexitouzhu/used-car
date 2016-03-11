//
//  UCSaleLeadModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-19.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCSalesLeadsModel : NSObject

@property (nonatomic, strong) NSString *name;       // 姓名
@property (nonatomic, strong) NSString *mobile;     // 电话
@property (nonatomic, strong) NSNumber *carcount;   // 意向车总数
@property (nonatomic, strong) NSString *remark;     // 标注

- (id)initWithJson:(NSDictionary *)json;

@end
