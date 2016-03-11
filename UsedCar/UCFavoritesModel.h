//
//  UCFavoritesModel.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-25.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCFavoritesModel : NSObject

@property (nonatomic, strong) NSString *hid;                   // 历史主键
@property (nonatomic, strong) NSString *quoteID;           // 信息id
@property (nonatomic, strong) NSString *name;              // 车型名称
@property (nonatomic, strong) NSString *price;             // 价格
@property (nonatomic, strong) NSString *image;             // 车型图片地址
@property (nonatomic, strong) NSString *mileage;           // 行驶里程
@property (nonatomic, strong) NSString *registrationDate;  // 上牌日期
@property (nonatomic, strong) NSString *publishDate;       // 信息发布日期
@property (nonatomic) NSNumber *isDealer;                  // 是否经销商
@property (nonatomic) NSNumber *hasCard;                       // 是否有牌照
@property (nonatomic) NSNumber *seriesId;                      // 车系id
@property (nonatomic) NSNumber *completeSale;                  // 信息完成度
@property (nonatomic) NSNumber *levelId;                       // 级别id
@property (nonatomic) NSNumber *isnewcar;                  // 新车
@property (nonatomic) NSNumber *invoice;                   // 延长质保

- (id)initWithJson:(NSDictionary *)json;

@end
