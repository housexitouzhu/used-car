//
//  UCCarDetailInfoModel.h
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesPersonModel.h"
#import "DealerModel.h"

@class UCCarInfoEditModel;

@interface UCCarDetailInfoModel : NSObject

@property (nonatomic, strong) NSString *pdate;
@property (nonatomic, strong) NSString *publicdate;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *imgurls;
@property (nonatomic, strong) NSString *registrationdate;
@property (nonatomic, strong) NSString *carname;
@property (nonatomic, strong) NSNumber *drivemileage;           // 行驶里程
@property (nonatomic, strong) NSNumber *carid;
@property (nonatomic, strong) NSNumber *sourceid;
@property (nonatomic, strong) NSNumber *levelid;                // 级别id
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSNumber *bookprice;
@property (nonatomic, strong) NSNumber *isincludetransferfee;
@property (nonatomic, strong) NSNumber *provinceid;
@property (nonatomic, strong) NSNumber *cityid;
@property (nonatomic, strong) NSNumber *purposeid;
@property (nonatomic, strong) NSNumber *colorid;
@property (nonatomic, strong) NSNumber *brandid;                // 品牌
@property (nonatomic, strong) NSNumber *seriesid;               // 车系
@property (nonatomic, strong) NSNumber *productid;              // 车型
@property (nonatomic, strong) NSString *displacement;           // 排量
@property (nonatomic, strong) NSString *gearbox;                // 变速箱
@property (nonatomic, strong) NSString *firstregtime;           // 首次上牌时间
@property (nonatomic, strong) NSString *verifytime;             // 车辆年审时间
@property (nonatomic, strong) NSString *insurancedate;          // 交强险截止日期
@property (nonatomic, strong) NSString *veticaltaxtime;         // 车船使用税有效时间
@property (nonatomic, strong) NSNumber *drivingpermit;          // 行驶证
@property (nonatomic, strong) NSNumber *registration;           // 登记证
@property (nonatomic, strong) NSNumber *invoice;                // 购车发票
@property (nonatomic, strong) NSString *usercomment;            // 卖家描述
@property (nonatomic, strong) NSString *configs;                // 车辆配置
@property (nonatomic, strong) NSString *thumbimgurls;           // 缩略图
@property (nonatomic, strong) NSNumber *userid;                 // 商家id
@property (nonatomic, strong) NSNumber *memberid;               // 个人id
@property (nonatomic, strong) NSString *dealername;             // 商家名称
@property (nonatomic, strong) NSNumber *isnewcar;               // 新车
@property (nonatomic, strong) NSNumber *extendedrepair;         // 延长质保
@property (nonatomic, strong) NSNumber *certificatetype;        // 是否上传认证报告（0、普通车源，未上传质检报告;10、普通车源，上传了质检报告;20、认证车源，未上传认证报告;30、认证车源，上传了认证报告）
@property (nonatomic, strong) NSNumber *qualityassdate;         // 延长质保时间
@property (nonatomic, strong) NSNumber *qualityassmile ;        // 延长质保公里
@property (strong, nonatomic) NSNumber *haswarranty;            // 原厂质保
@property (nonatomic, strong) NSNumber *creditid;               // 厂家认证
@property (nonatomic, strong) NSString *dctionimg;              // 检测报告图片
@property (nonatomic, strong) NSString *dctionthumbimg;
@property (nonatomic, strong) NSNumber *hasDeposit;             // 有保证金
@property (nonatomic, strong) NSNumber *bailmoney;              // 保证金额

@property (nonatomic, strong) NSNumber *state;                  // 1:在售 2:已售
@property (nonatomic, strong) NSNumber *carsourceid;            // 来源id（1200表示58，1100表示淘车网) 1000 - 2000 都属于站外
@property (nonatomic, strong) NSString *carsourcename;          // 来源名称
@property (nonatomic, strong) NSString *carsourceurl;           // 来源的原url
@property (nonatomic, strong) NSString *selldate;               // 已售日期

@property (nonatomic, strong) NSString *pdateText;
@property (nonatomic, strong) NSString *publicdateText;
@property (nonatomic, strong) NSString *priceText;
@property (nonatomic, strong) NSString *registrationdateText;
@property (nonatomic, strong) NSString *carnameText;
@property (nonatomic, strong) NSString *drivemileageText;            // 行驶里程
@property (nonatomic, strong) NSString *caridText;
@property (nonatomic, strong) NSString *sourceidText;
@property (nonatomic, strong) NSString *levelidText;                // 级别id
@property (nonatomic, strong) NSString *viewsText;
@property (nonatomic, strong) NSString *bookpriceText;
@property (nonatomic, strong) NSString *isincludetransferfeeText;
@property (nonatomic, strong) NSString *provinceidText;
@property (nonatomic, strong) NSString *cityidText;
@property (nonatomic, strong) NSString *purposeidText;
@property (nonatomic, strong) NSString *coloridText;
@property (nonatomic, strong) NSString *seriesidText;                // 车系
@property (nonatomic, strong) NSString *productidText;               // 车型
@property (nonatomic, strong) NSString *displacementText;            // 排量
@property (nonatomic, strong) NSString *gearboxText;                 // 变速箱
@property (nonatomic, strong) NSString *firstregtimeText;            // 首次上牌时间
@property (nonatomic, strong) NSString *verifytimeText;              // 车辆年审时间
@property (nonatomic, strong) NSString *insurancedateText;           // 交强险截止日期
@property (nonatomic, strong) NSString *veticaltaxtimeText;          // 车船使用税有效时间
@property (nonatomic, strong) NSString *drivingpermitText;           // 行驶证
@property (nonatomic, strong) NSString *registrationText;            // 登记证
@property (nonatomic, strong) NSString *invoiceText;                 // 购车发票
@property (nonatomic, strong) NSString *usercommentText;             // 卖家描述
@property (nonatomic, strong) NSString *configsText;                 // 车辆配置
@property (nonatomic, strong) NSString *thumbimgurlsText;            // 缩略图

@property (nonatomic, strong) SalesPersonModel *salesPerson;
@property (nonatomic, strong) DealerModel *dealer;                  // 商家
//@property (nonatomic, strong) 

- (id)initWithJson:(NSDictionary *)json;
- (id)initWithCarInfoEditModel:(UCCarInfoEditModel *)mCarinfoEdit;

- (NSString *)jsonString;

@end
