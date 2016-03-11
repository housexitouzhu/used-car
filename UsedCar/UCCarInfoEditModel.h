//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesPersonModel.h"

@interface UCCarInfoEditModel : NSObject <NSCopying>

@property (nonatomic, strong) NSString  *vincode;
@property (nonatomic, strong) NSNumber  *purposeid;//
@property (nonatomic, strong) NSString  *seriesname;//
@property (nonatomic, strong) NSNumber  *brandid;//
@property (nonatomic, strong) NSString  *productname;//
@property (nonatomic, strong) NSString  *verifytime;//
@property (nonatomic, strong) NSString  *veticaltaxtime;//
@property (nonatomic, strong) NSString  *usercomment;//
@property (nonatomic, strong) NSString  *errortext;
@property (nonatomic, strong) NSNumber  *drivemileage;/*由int改string*/
@property (nonatomic, strong) NSNumber  *views;
@property (nonatomic, strong) NSNumber  *bookprice;//
@property (nonatomic, strong) NSNumber  *seriesid;//
@property (nonatomic, strong) NSString  *insurancedate;//
@property (nonatomic, strong) NSString  *imgurls;//
@property (nonatomic, strong) NSNumber  *state;
@property (nonatomic, strong) NSNumber  *provinceid;//
@property (nonatomic, strong) NSNumber  *cityid;//
@property (nonatomic, strong) NSNumber  *colorid;
@property (nonatomic, strong) NSNumber  *productid;//
@property (nonatomic, strong) NSString  *firstregtime;
@property (nonatomic, strong) NSString  *thumbimgurls;
@property (nonatomic, strong) NSNumber  *carid;//
@property (nonatomic, strong) NSString  *carname;//
@property (nonatomic, strong) NSString  *brandname;//
@property (nonatomic, strong) NSString  *displacement;//
@property (nonatomic, strong) NSString  *gearbox;//
@property (nonatomic, strong) NSNumber  *isincludetransferfee;//
@property (nonatomic, strong) NSNumber  *isfixprice;//
@property (nonatomic, strong) NSNumber  *drivingpermit;//
@property (nonatomic, strong) NSNumber  *registration;//
@property (nonatomic, strong) NSNumber  *invoice;//
@property (nonatomic, strong) NSNumber *isnewcar;               // 新车
@property (nonatomic, strong) NSNumber *extendedrepair;         // 延长质保
@property (nonatomic, strong) NSNumber *qualityassdate;//         // 延长质保时间
@property (nonatomic, strong) NSNumber *qualityassmile;/*由int改string*/        // 延长质保公里
@property (nonatomic, strong) NSString *dctionimg;//              // 质检大图
@property (nonatomic, strong) NSString *dctionthumbimg;
@property (nonatomic, strong) NSNumber *certificatetype;        // 0 为无检测图，10为有检测图
@property (nonatomic, strong) NSNumber *isTextReport;           // 自己填的字段，区别是否开启延长质保
@property (nonatomic, strong) NSNumber *isExtendedrepair;       // 自己填的字段，区别是否开启上传检测报告
@property (nonatomic, strong) NSString *driverlicenseimage;     // 行驶证
@property (nonatomic, strong) SalesPersonModel *salesPerson;

//多加的字段
@property (nonatomic,strong ) NSNumber *isbailcar;
@property (nonatomic,strong ) NSNumber *sharetimes;
@property (nonatomic,strong ) NSNumber *levelid;
@property (nonatomic,strong ) NSNumber *bailmoney;
@property (nonatomic,strong ) NSNumber *carsourceid;
@property (nonatomic,strong ) NSNumber *fromtype;


@property (nonatomic, strong) NSString  *purposeidText;
@property (nonatomic, strong) NSString  *seriesnameText;
@property (nonatomic, strong) NSString  *productnameText;
@property (nonatomic, strong) NSString  *verifytimeText;
@property (nonatomic, strong) NSString  *veticaltaxtimeText;
@property (nonatomic, strong) NSString  *usercommentText;
@property (nonatomic, strong) NSString  *errortextText;
@property (nonatomic, strong) NSString  *drivemileageText;
@property (nonatomic, strong) NSString  *viewsText;
@property (nonatomic, strong) NSString  *bookpriceText;
@property (nonatomic, strong) NSString  *insurancedateText;
@property (nonatomic, strong) NSString  *imgurlsText;
@property (nonatomic, strong) NSString  *provinceidText;
@property (nonatomic, strong) NSString  *cityidText;
@property (nonatomic, strong) NSString  *coloridText;
@property (nonatomic, strong) NSString  *firstregtimeText;
@property (nonatomic, strong) NSString  *thumbimgurlsText;
@property (nonatomic, strong) NSString  *carnameText;
@property (nonatomic, strong) NSString  *brandnameText;
@property (nonatomic, strong) NSString  *displacementText;
@property (nonatomic, strong) NSString  *gearboxText;
@property (nonatomic, strong) NSString  *isincludetransferfeeText;
@property (nonatomic, strong) NSString  *drivingpermitText;
@property (nonatomic, strong) NSString  *registrationText;
@property (nonatomic, strong) NSString  *invoiceText;

- (id)initWithJson:(NSDictionary *)json;
- (BOOL)isNull;
- (BOOL)isEqualModel:(UCCarInfoEditModel *)mCarInfo;
- (NSString *)json;
- (void)setTextValue;

@end