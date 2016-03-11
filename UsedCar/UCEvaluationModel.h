//
//  UCEvaluationModel.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-31.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCEvaluationModel : NSObject

@property (nonatomic, strong) NSNumber *pid;
@property (nonatomic, strong) NSNumber *cid;
@property (nonatomic, strong) NSNumber *mileage;           // 行驶里程
@property (nonatomic, strong) NSString *firstregtime;      // 首次上牌时间
@property (nonatomic, strong) NSNumber *specid;            // 车型
@property (nonatomic, strong) NSNumber *seriesid;          // 车系id
@property (nonatomic, strong) NSNumber *brandid;            // 车品牌

@property (nonatomic, strong) NSString *pidText;
@property (nonatomic, strong) NSString *cidText;
@property (nonatomic, strong) NSString *mileageText;
@property (nonatomic, strong) NSString *brandText;
@property (nonatomic, strong) NSString *seriesidText;
@property (nonatomic, strong) NSString *specidText;
@property (nonatomic, strong) NSString *firstregtimeText;

- (id)initWithJson:(NSDictionary *)json;
- (BOOL)isNull;

@end
