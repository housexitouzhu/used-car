//
//  UCEvaluationPriceModel.h
//  UsedCar
//
//  Created by 张鑫 on 14-1-2.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCEvaluationPriceModel : NSObject

@property (nonatomic, strong) NSString *newcarprice;
@property (nonatomic, strong) NSString *referenceprice;
@property (nonatomic, strong) NSString *url;

- (id)initWithJson:(NSDictionary *)json;

@end
