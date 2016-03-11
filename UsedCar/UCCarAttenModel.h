//
//  UCCarAttenModel.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCCarAttenModel : NSObject

@property (nonatomic, strong) NSString *Name;                       // 车名字
@property (nonatomic, strong) NSString *areaname;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;

@property (nonatomic, strong) NSNumber *count;                      // 列表个数
@property (nonatomic, strong) NSNumber *attenID;                    // 关注ID
@property (nonatomic, strong) NSString *brandid;                    // 品牌
@property (nonatomic, strong) NSString *seriesid;                   // 车系
@property (nonatomic, strong) NSString *specid;                     // 车型
@property (nonatomic, strong) NSNumber *areaid; 
@property (nonatomic, strong) NSNumber *pid;
@property (nonatomic, strong) NSNumber *cid;
@property (nonatomic, strong) NSString *priceregion;                // 价格
@property (nonatomic, strong) NSString *mileageregion;              // 里程
@property (nonatomic, strong) NSString *registeageregion;           // 车龄
@property (nonatomic, strong) NSNumber *levelid;                    // 级别
@property (nonatomic, strong) NSNumber *gearboxid;                  // 变速箱
@property (nonatomic, strong) NSNumber *color;                      // 颜色
@property (nonatomic, strong) NSString *displacement;               // 排量
@property (nonatomic, strong) NSString *countryid;                  // 国别
@property (nonatomic, strong) NSNumber *countrytype;                // 属性
@property (nonatomic, strong) NSNumber *powertrain;                 // 驱动
@property (nonatomic, strong) NSNumber *structure;                  // 结构
@property (nonatomic, strong) NSNumber *sourceid;                   // 来源
@property (nonatomic, strong) NSNumber *haswarranty;                // 原厂质保
@property (nonatomic, strong) NSNumber *extrepair;                  // 延长质保
@property (nonatomic, strong) NSString *isnewcar;                   // 是否准新车
@property (nonatomic, strong) NSNumber *dealertype;                 // 销售状态，5：已售，9：在售
@property (nonatomic, strong) NSString *ispic;                      // 只在有图
@property (nonatomic, strong) NSString *lastdate;                   // 更新时间

@property (nonatomic, strong) NSString *brandidText;                // 品牌
@property (nonatomic, strong) NSString *seriesidText;               // 车系
@property (nonatomic, strong) NSString *specidText;                 // 车型
@property (nonatomic, strong) NSString *priceregionText;            // 价格
@property (nonatomic, strong) NSString *mileageregionText;          // 里程
@property (nonatomic, strong) NSString *registeageregionText;       // 车龄
@property (nonatomic, strong) NSString *levelidText;                // 级别
@property (nonatomic, strong) NSString *gearboxidText;              // 变速箱
@property (nonatomic, strong) NSString *colorText;                  // 颜色
@property (nonatomic, strong) NSString *displacementText;           // 排量
@property (nonatomic, strong) NSString *countryidText;              // 国别
@property (nonatomic, strong) NSString *countrytypeText;            // 属性
@property (nonatomic, strong) NSString *powertrainText;             // 驱动
@property (nonatomic, strong) NSString *structureText;              // 结构
@property (nonatomic, strong) NSString *sourceidText;               // 来源
@property (nonatomic, strong) NSString *haswarrantyText;            // 质保类型
@property (nonatomic, strong) NSString *extrepairText;                  // 延长质保
@property (nonatomic, strong) NSString *isnewcarText;               // 是否准新车
@property (nonatomic, strong) NSString *dealertypeText;             // 销售状态，5：已售，9：在售
@property (nonatomic, strong) NSString *ispicText;                  // 只在有图

- (id)initWithJson:(NSDictionary *)json;
- (void)setAreaValue:(UCAreaMode *)mArea;
- (void)setFilterValue:(UCFilterModel *)mFilter;
- (void)setTextValue;
- (NSInteger)conditionsCount;

@end