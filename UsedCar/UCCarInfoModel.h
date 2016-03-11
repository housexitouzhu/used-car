//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCFavoritesModel;
@class UCFavoritesCloudModel;
@class UCCarInfoEditModel;

@interface UCCarInfoModel : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *carid;
@property (nonatomic, strong) NSString *carname;
@property (nonatomic, strong) NSNumber *cid;
@property (nonatomic, strong) NSString *cname;
@property (nonatomic, strong) NSNumber *pid;
@property (nonatomic, strong) NSString *pname;
@property (nonatomic, strong) NSNumber *specid;             //
@property (nonatomic, strong) NSString *pdate;              // 列表页的时间
@property (nonatomic, strong) NSString *publishdate;        // 发布时间
@property (nonatomic, strong) NSString *price;              // 价格
@property (nonatomic, strong) NSString *image;              // 存列表缩略图
@property (nonatomic, strong) NSString *imageLargeURLs;     // 原图列表的 string

@property (nonatomic, strong) NSString *registrationdate;   // 年份
@property (nonatomic, strong) NSString *mileage;            // 公里数

@property (nonatomic, strong) NSNumber *sourceid;           // 来源
@property (nonatomic, strong) NSNumber *isnewcar;           // 近似新车
@property (nonatomic, strong) NSNumber *invoice;            // 延长质保 invoice/extendedrepair
@property (strong, nonatomic) NSNumber *haswarranty;        // 原厂质保
@property (strong, nonatomic) NSNumber *haswarrantydate;    // 质保延长时间(月份)
@property (strong, nonatomic) NSNumber *creditid;           // 厂家认证
@property (nonatomic, strong) NSNumber *state;              // 销售线索车源状态

@property (nonatomic, strong) NSNumber *dealertype;         // 9,在售 5,已售
@property (nonatomic, strong) NSNumber *goodcarofpic;       // 0,表示无图 1,表示有图
@property (nonatomic, strong) NSNumber *isoutsite;          //
@property (strong, nonatomic) NSNumber *isNew;              // 是否是新添加的车源 0 否 1 是

@property (strong, nonatomic) NSNumber *hasDeposit;         //有 保证金
@property (nonatomic, strong) NSNumber *sharetimes;         //分享次数


- (id)initWithJson:(NSDictionary *)json;
- (UCCarInfoModel *)initWithFavoriteModel:(UCFavoritesModel *)mFavorite;
- (UCCarInfoModel *)initWithFavoriteCloudModel:(UCFavoritesCloudModel *)mFavorite;
- (UCCarInfoModel *)initWithCarInfoEditModelModel:(UCCarInfoEditModel *)mCarInfoEdit;

@end