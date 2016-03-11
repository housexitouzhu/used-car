//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCCarInfoEditModel.h"
#import "AreaProvinceItem.h"

@implementation UCCarInfoEditModel

- (id)init
{
    self = [super init];
    
    if (self) {
        // 负数时间戳标识本地未填完数据
        self.carid = [NSNumber numberWithDouble:-[[NSDate date] timeIntervalSince1970]];
        self.salesPerson = [[SalesPersonModel alloc] init];
        //        self.isincludetransferfee = [NSNumber numberWithBool:NO];
        //        self.isfixprice = [NSNumber numberWithBool:NO];
    }
    
    return self;
}

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.vincode = [json objectForKey:@"vincode"];
            self.purposeid = [json objectForKey:@"purposeid"];
            self.seriesname = [json objectForKey:@"seriesname"];
            self.brandid = [json objectForKey:@"brandid"];
            self.productname = [json objectForKey:@"productname"];
            self.verifytime = [json objectForKey:@"verifytime"];
            self.veticaltaxtime = [json objectForKey:@"veticaltaxtime"];
            self.usercomment = [json objectForKey:@"usercomment"];
            self.errortext = [json objectForKey:@"errortext"];
            self.drivemileage = [json objectForKey:@"drivemileage"];
            self.views = [json objectForKey:@"views"];
            self.bookprice = [json objectForKey:@"bookprice"];
            self.seriesid = [json objectForKey:@"seriesid"];
            self.insurancedate = [json objectForKey:@"insurancedate"];
            self.imgurls = [json objectForKey:@"imgurls"];
            self.state = [json objectForKey:@"state"];
            self.provinceid = [json objectForKey:@"provinceid"];
            self.cityid = [json objectForKey:@"cityid"];
            self.colorid = [json objectForKey:@"colorid"];
            self.productid = [json objectForKey:@"productid"];
            self.firstregtime = [json objectForKey:@"firstregtime"];
            self.thumbimgurls = [json objectForKey:@"thumbimgurls"];
            self.carid = [json objectForKey:@"carid"];
            self.carname = [json objectForKey:@"carname"];
            self.brandname = [json objectForKey:@"brandname"];
            self.displacement = [json objectForKey:@"displacement"];
            self.gearbox = [json objectForKey:@"gearbox"];
            self.isincludetransferfee = [json objectForKey:@"isincludetransferfee"];
            self.isfixprice = [json objectForKey:@"isfixprice"];
            self.drivingpermit = [json objectForKey:@"drivingpermit"];
            self.registration = [json objectForKey:@"registration"];
            self.invoice = [json objectForKey:@"invoice"];
            self.isnewcar = [json objectForKey:@"isnewcar"];
            self.extendedrepair = [json objectForKey:@"extendedrepair"];
            self.qualityassdate = [json objectForKey:@"qualityassdate"];
            self.qualityassmile = [json objectForKey:@"qualityassmile"];
            self.dctionimg = [json objectForKey:@"dctionimg"];
            self.dctionthumbimg = [json objectForKey:@"dctionthumbimg"];
            self.certificatetype = [json objectForKey:@"certificatetype"];
            self.isTextReport = [json objectForKey:@"isTextReport"];
            self.isExtendedrepair = [json objectForKey:@"isExtendedrepair"];
            self.driverlicenseimage = [json objectForKey:@"driverlicenseimage"];
            self.salesPerson = [[SalesPersonModel alloc] initWithJson:[json objectForKey:@"salesperson"]];
            
            self.isbailcar = [json objectForKey:@"isbailcar"];
            self.sharetimes = [json objectForKey:@"sharetimes"];
            self.levelid = [json objectForKey:@"levelid"];
            self.bailmoney = [json objectForKey:@"bailmoney"];
            self.carsourceid = [json objectForKey:@"carsourceid"];
            self.fromtype = [json objectForKey:@"fromtype"];
        }
    }
    
    return self;
}

- (void)setTextValue
{
    // 筛选条件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *colors = values[@"CarColors"];
    NSArray *carPurposes = values[@"CarPurposes"];
    
    self.purposeidText = @"";
    if ([self.purposeid integerValue] > 0)
        self.purposeidText = [carPurposes objectAtIndex:[self.purposeid integerValue] - 1];
    self.seriesnameText = self.seriesname.length > 0 ? self.seriesname : @"";
    self.brandnameText = self.brandnameText.length > 0 ? self.brandnameText : @"";
    self.productnameText = self.productnameText.length > 0 ? self.productnameText : @"";
    
    self.verifytimeText = @"";
    if (self.verifytime.length > 0) {
        NSArray *verifytimes = [self.verifytime componentsSeparatedByString:@"-"];
        if ([verifytimes count] > 1) {
            self.verifytimeText = [NSString stringWithFormat:@"%@年%@月",[verifytimes objectAtIndex:0],[verifytimes objectAtIndex:1]];
        }
    }
    if (self.veticaltaxtime.length > 0)
        self.veticaltaxtimeText = [self.veticaltaxtime isEqualToString:@"已过期"] ? self.veticaltaxtime : [NSString stringWithFormat:@"%@年",self.veticaltaxtime];
    else
        self.veticaltaxtimeText = @"";
    
    self.usercommentText = self.usercomment.length > 0 ? self.usercomment : @"";
    self.errortextText = self.errortext.length > 0 ? self.errortext : @"无被退回原因";
    self.drivemileageText = [self.drivemileage stringValue].length > 0 ? [NSString stringWithFormat:@"%.2f", [self.drivemileage doubleValue]] : @"";
    self.viewsText = self.views.stringValue.length > 0 ? [self.views stringValue] : @"0";
    self.bookpriceText = [self.bookprice stringValue].length > 0 ? [NSString stringWithFormat:@"%.2f", [self.bookprice doubleValue]] : @"";
    
    self.insurancedateText = @"";
    if (self.insurancedate.length > 0) {
        NSArray *insurancedates = [self.insurancedate componentsSeparatedByString:@"-"];
        if ([insurancedates count] > 1) {
            self.insurancedateText = [NSString stringWithFormat:@"%@年%@月",[insurancedates objectAtIndex:0],[insurancedates objectAtIndex:1]];
        }
    }
    
    self.imgurlsText = self.imgurls.length > 0 ? self.imgurls : @"";
    
    //获得城市
    self.provinceidText = @"";
    self.cityidText = @"";
    if ([self.provinceid integerValue] > 0) {
        NSArray *areProvinces = [OMG areaProvinces];
        for (AreaProvinceItem *apItem in areProvinces) {
            if ([apItem.PI isEqualToNumber: self.provinceid]) {
                //设置省
                self.provinceidText = [apItem.PN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([self.cityid integerValue] > 0) {
                    for (AreaCityItem *acItem in apItem.CL) {
                        if ([acItem.CI isEqualToNumber: self.cityid]) {
                            //设置市
                            self.cityidText = [acItem.CN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            break;
                        }
                    }
                }
                break;
            }
        }
    }
    
    self.coloridText = self.colorid ? [colors objectAtIndex:[self.colorid integerValue] - 1] : @"";
    
    //首次上牌时间
    self.firstregtimeText = @"";
    if (self.firstregtime.length > 0) {
        NSArray *firstregtimes = [self.firstregtime componentsSeparatedByString:@"-"];
        if ([firstregtimes count] > 1) {
            self.firstregtimeText = [NSString stringWithFormat:@"%@年%@月",[firstregtimes objectAtIndex:0],[firstregtimes objectAtIndex:1]];
        }
    }
    
    self.thumbimgurlsText = self.thumbimgurls.length > 0 ? self.thumbimgurls : @"";
    
    self.displacementText = (self.displacement.length > 0 && ![self.displacement isEqualToString:@"0"]) ? self.displacement : @"";
    self.gearboxText = self.gearbox.length > 0 ? self.gearbox : @"";
    
    if (self.carname.length > 0) {
        self.carnameText = self.carname;
    } else {
        //车名
        NSString *strName = nil;
        NSString *strGearbox = nil;
        NSString *strDisplacement = nil;
        if (self.productname.length > 0 && self.seriesname.length > 0)
            strName = [NSString stringWithFormat:@"%@%@", (self.seriesname.length > 0 ? self.seriesname : @""), (self.productname.length > 0 ? [NSString stringWithFormat:@" %@",self.productname] : @"")];
        else
            strName = self.carname.length > 0 ? self.carname : @"";
        strGearbox = self.gearbox.length > 0 ? [NSString stringWithFormat:@" %@", self.gearbox] : @"";
        strDisplacement = self.displacement.length > 0 ? [NSString stringWithFormat:@" %@L",self.displacement] : @"";
        self.carnameText = [NSString stringWithFormat:@"%@%@%@", strName, strGearbox, strDisplacement];
    }
    
    self.isincludetransferfeeText = @"";
    if (self.isincludetransferfee)
        self.isincludetransferfeeText = self.isincludetransferfee.boolValue ? @"包含": @"不含";
    
    self.drivingpermitText = @"";
    if (self.drivingpermit) {
        if ([self.drivingpermit integerValue] == 1)
            self.drivingpermitText = @"有";
        else if ([self.drivingpermit integerValue] == 2)
            self.drivingpermitText = @"补办中";
        else if ([self.drivingpermit integerValue] == 3)
            self.drivingpermitText = @"丢失";
    }
    self.registrationText = @"";
    if (self.registration) {
        if ([self.registration integerValue] == 1)
            self.registrationText = @"有";
        else if ([self.registration integerValue] == 2)
            self.registrationText = @"补办中";
        else if ([self.registration integerValue] == 3)
            self.registrationText = @"丢失";
    }
    self.invoiceText = @"";
    if (self.invoice) {
        if ([self.invoice integerValue] == 1)
            self.invoiceText = @"有";
        else if ([self.invoice integerValue] == 2)
            self.invoiceText = @"补办中";
        else if ([self.invoice integerValue] == 3)
            self.invoiceText = @"丢失";
    }
}

- (id)copyWithZone:(NSZone*)zone
{
    UCCarInfoEditModel *copy = [[[self class] allocWithZone:zone] init];
    
    copy.vincode = self.vincode;
    copy.purposeid = self.purposeid;
    copy.seriesname = self.seriesname;
    copy.brandid = self.brandid;
    copy.productname = self.productname;
    copy.verifytime = self.verifytime;
    copy.veticaltaxtime = self.veticaltaxtime;
    copy.usercomment = self.usercomment;
    copy.errortext = self.errortext;
    copy.drivemileage = self.drivemileage;
    copy.views = self.views;
    copy.bookprice = self.bookprice;
    copy.seriesid = self.seriesid;
    copy.insurancedate = self.insurancedate;
    copy.imgurls = self.imgurls;
    copy.state = self.state;
    copy.provinceid = self.provinceid;
    copy.cityid = self.cityid;
    copy.colorid = self.colorid;
    copy.productid = self.productid;
    copy.firstregtime = self.firstregtime;
    copy.thumbimgurls = self.thumbimgurls;
    copy.carid = self.carid;
    copy.carname = self.carname;
    copy.brandname = self.brandname;
    copy.displacement = self.displacement;
    copy.gearbox = self.gearbox;
    copy.isincludetransferfee = self.isincludetransferfee;
    copy.isfixprice = self.isfixprice;
    copy.drivingpermit = self.drivingpermit;
    copy.registration = self.registration;
    copy.invoice = self.invoice;
    copy.isnewcar = self.isnewcar;
    copy.extendedrepair = self.extendedrepair;
    copy.dctionimg = self.dctionimg;
    copy.dctionthumbimg = self.dctionthumbimg;
    copy.qualityassdate = self.qualityassdate;
    copy.qualityassmile = self.qualityassmile;
    copy.certificatetype = self.certificatetype;
    copy.isTextReport = self.isTextReport;
    copy.isExtendedrepair = self.isExtendedrepair;
    copy.driverlicenseimage = self.driverlicenseimage;
    copy.salesPerson.salesid = self.salesPerson.salesid;
    copy.salesPerson.salesqq = self.salesPerson.salesqq;
    copy.salesPerson.salesname = self.salesPerson.salesname;
    copy.salesPerson.salesphone = self.salesPerson.salesphone;
    copy.salesPerson.salestype = self.salesPerson.salestype;
    
    copy.isbailcar = self.isbailcar;
    copy.sharetimes = self.sharetimes;
    copy.levelid = self.levelid;
    copy.bailmoney = self.bailmoney;
    copy.carsourceid = self.carsourceid;
    copy.fromtype = self.fromtype;
    
    return copy;
}


- (BOOL)isNull
{
    //self.carid == nil &&
    if(   self.vincode == nil
       && self.purposeid == nil
       && self.seriesname == nil
       && self.brandid == nil
       && self.productname == nil
       && self.verifytime == nil
       && self.veticaltaxtime == nil
       && self.usercomment == nil
       && self.errortext == nil
       && (self.drivemileage == nil || self.drivemileage.doubleValue == 0)
       && self.views == nil
       && (self.bookprice == nil || self.bookprice.doubleValue == 0)
       && self.seriesid == nil
       && self.insurancedate == nil
       && self.imgurls == nil
       && self.state == nil
       && self.provinceid == nil
       && self.cityid == nil
       && self.colorid == nil
       && self.productid == nil
       && self.firstregtime == nil
       && self.thumbimgurls == nil
       && self.carname == nil
       && self.brandname == nil
       && self.displacement == nil
       && self.gearbox == nil
       && (self.isincludetransferfee == nil || !self.isincludetransferfee.boolValue)
       && (self.isfixprice == nil || !self.isfixprice.boolValue)
       && self.drivingpermit == nil
       && self.registration == nil
       && self.invoice == nil
       && (self.extendedrepair == nil || !self.extendedrepair.boolValue)
       && self.certificatetype == nil
       && self.dctionimg == nil
       && self.dctionthumbimg == nil
       && (self.isTextReport == nil || !self.isTextReport.boolValue)
       && (self.isExtendedrepair == nil || !self.isExtendedrepair.boolValue)
       && self.driverlicenseimage == nil
       && self.salesPerson.salesid == nil
       && self.salesPerson.salesqq == nil
       && (self.salesPerson.salesname == nil || self.salesPerson.salesname.length == 0)
       && (self.salesPerson.salesphone == nil || self.salesPerson.salesphone.length == 0)
       && self.isbailcar == nil
       && self.sharetimes == nil
       && self.levelid == nil
       && self.bailmoney == nil
       && self.carsourceid == nil
       && self.fromtype == nil)
        return YES;
    else
        return NO;
}

- (BOOL)isEqualModel:(UCCarInfoEditModel *)mCarInfoEdit
{
    if((mCarInfoEdit.vincode == self.vincode || [mCarInfoEdit.vincode isEqualToString:self.vincode]) &&
       (mCarInfoEdit.purposeid == self.purposeid || [mCarInfoEdit.purposeid isEqualToNumber:self.purposeid]) &&
       (mCarInfoEdit.seriesname == self.seriesname || [mCarInfoEdit.seriesname isEqualToString:self.seriesname]) &&
       (mCarInfoEdit.brandid == self.brandid || [mCarInfoEdit.brandid isEqualToNumber:self.brandid]) &&
       (mCarInfoEdit.productname == self.productname || [mCarInfoEdit.productname isEqualToString:self.productname]) &&
       (mCarInfoEdit.verifytime == self.verifytime || [mCarInfoEdit.verifytime isEqualToString:self.verifytime]) &&
       (mCarInfoEdit.veticaltaxtime == self.veticaltaxtime || [mCarInfoEdit.veticaltaxtime isEqualToString:self.veticaltaxtime]) &&
       (mCarInfoEdit.usercomment == self.usercomment || [mCarInfoEdit.usercomment isEqualToString:self.usercomment]) &&
       (mCarInfoEdit.errortext == self.errortext || [mCarInfoEdit.errortext isEqualToString:self.errortext]) &&
       (mCarInfoEdit.drivemileage == self.drivemileage || [mCarInfoEdit.drivemileage isEqualToNumber:self.drivemileage]) &&
       (mCarInfoEdit.views == self.views || [mCarInfoEdit.views isEqualToNumber:self.views]) &&
       (mCarInfoEdit.bookprice == self.bookprice || [mCarInfoEdit.bookprice isEqualToNumber:self.bookprice]) &&
       (mCarInfoEdit.seriesid == self.seriesid || [mCarInfoEdit.seriesid isEqualToNumber:self.seriesid]) &&
       (mCarInfoEdit.insurancedate == self.insurancedate || [mCarInfoEdit.insurancedate isEqualToString:self.insurancedate]) &&
       (mCarInfoEdit.imgurls == self.imgurls || [mCarInfoEdit.imgurls isEqualToString:self.imgurls]) &&
       (mCarInfoEdit.state == self.state || [mCarInfoEdit.state isEqualToNumber:self.state]) &&
       (mCarInfoEdit.provinceid == self.provinceid || [mCarInfoEdit.provinceid isEqualToNumber:self.provinceid]) &&
       (mCarInfoEdit.cityid == self.cityid || [mCarInfoEdit.cityid isEqualToNumber:self.cityid]) &&
       (mCarInfoEdit.colorid == self.colorid || [mCarInfoEdit.colorid isEqualToNumber:self.colorid]) &&
       (mCarInfoEdit.productid == self.productid || [mCarInfoEdit.productid isEqualToNumber:self.productid]) &&
       (mCarInfoEdit.firstregtime == self.firstregtime || [mCarInfoEdit.firstregtime isEqualToString:self.firstregtime]) &&
       (mCarInfoEdit.thumbimgurls == self.thumbimgurls || [mCarInfoEdit.thumbimgurls isEqualToString:self.thumbimgurls]) &&
       (mCarInfoEdit.carid == self.carid || [mCarInfoEdit.carid isEqualToNumber:self.carid]) &&
       (mCarInfoEdit.carname == self.carname || [mCarInfoEdit.carname isEqualToString:self.carname]) &&
       (mCarInfoEdit.brandname == self.brandname || [mCarInfoEdit.brandname isEqualToString:self.brandname]) &&
       (mCarInfoEdit.displacement == self.displacement || [mCarInfoEdit.displacement isEqualToString:self.displacement]) &&
       (mCarInfoEdit.gearbox == self.gearbox || [mCarInfoEdit.gearbox isEqualToString:self.gearbox]) &&
       (mCarInfoEdit.isincludetransferfee == self.isincludetransferfee || [mCarInfoEdit.isincludetransferfee isEqualToNumber:self.isincludetransferfee]) &&
       (mCarInfoEdit.isfixprice == self.isfixprice || [mCarInfoEdit.isfixprice isEqualToNumber:self.isfixprice]) &&
       (mCarInfoEdit.drivingpermit == self.drivingpermit || [mCarInfoEdit.drivingpermit isEqualToNumber:self.drivingpermit]) &&
       (mCarInfoEdit.registration == self.registration || [mCarInfoEdit.registration isEqualToNumber:self.registration]) &&
       (mCarInfoEdit.invoice == self.invoice || [mCarInfoEdit.invoice isEqualToNumber:self.invoice]) &&
       (mCarInfoEdit.dctionimg == self.dctionimg || [mCarInfoEdit.dctionimg isEqualToString:self.dctionimg]) &&
       (mCarInfoEdit.dctionthumbimg == self.dctionthumbimg || [mCarInfoEdit.dctionthumbimg isEqualToString:self.dctionthumbimg]) &&
       (mCarInfoEdit.certificatetype == self.certificatetype || [mCarInfoEdit.certificatetype isEqualToNumber:self.certificatetype]) &&
       (mCarInfoEdit.isTextReport == self.isTextReport || [mCarInfoEdit.isTextReport isEqualToNumber:self.isTextReport]) &&
       (mCarInfoEdit.isExtendedrepair == self.isExtendedrepair || [mCarInfoEdit.isExtendedrepair isEqualToNumber:self.isExtendedrepair]) &&
       (mCarInfoEdit.qualityassdate == self.qualityassdate || [mCarInfoEdit.qualityassdate isEqualToNumber:self.qualityassdate]) &&
       (mCarInfoEdit.qualityassmile == self.qualityassmile || mCarInfoEdit.qualityassmile.floatValue == self.qualityassmile.floatValue) &&
       (mCarInfoEdit.extendedrepair == self.extendedrepair || [mCarInfoEdit.extendedrepair isEqualToNumber:self.extendedrepair]) &&
       (mCarInfoEdit.driverlicenseimage == self.driverlicenseimage || [mCarInfoEdit.driverlicenseimage isEqualToString:self.driverlicenseimage]) &&
       (mCarInfoEdit.salesPerson.salesid == self.salesPerson.salesid || [mCarInfoEdit.salesPerson.salesid isEqualToNumber:self.salesPerson.salesid]) &&
       (mCarInfoEdit.salesPerson.salesqq == self.salesPerson.salesqq || [mCarInfoEdit.salesPerson.salesqq isEqualToString:self.salesPerson.salesqq]) &&
       (mCarInfoEdit.salesPerson.salesname == self.salesPerson.salesname || [mCarInfoEdit.salesPerson.salesname isEqualToString:self.salesPerson.salesname]) &&
       (mCarInfoEdit.salesPerson.salesphone == self.salesPerson.salesphone || [mCarInfoEdit.salesPerson.salesphone isEqualToString:self.salesPerson.salesphone]))
        return YES;
    else
        return NO;
}

- (NSString *)json
{
    // 车辆信息
    NSMutableDictionary *dicCarInfo = [[NSMutableDictionary alloc] init];
    [dicCarInfo setValue:self.vincode forKey:@"vincode"];
    [dicCarInfo setValue:self.carid.doubleValue < 0 ? [NSNumber numberWithInt:0] : self.carid forKey:@"carid"];
    [dicCarInfo setValue:self.carname forKey:@"carname"];
    [dicCarInfo setValue:self.brandid forKey:@"brandid"];
    [dicCarInfo setValue:self.seriesid forKey:@"seriesid"];
    [dicCarInfo setValue:self.productid forKey:@"productid"];
    [dicCarInfo setValue:self.displacement forKey:@"displacement"];
    [dicCarInfo setValue:self.gearbox forKey:@"gearbox"];
    [dicCarInfo setValue:self.isincludetransferfee forKey:@"isincludetransferfee"];
    [dicCarInfo setValue:self.bookprice forKey:@"bookprice"];
    [dicCarInfo setValue:self.isfixprice forKey:@"isfixprice"];
    [dicCarInfo setValue:self.provinceid forKey:@"provinceid"];
    [dicCarInfo setValue:self.cityid forKey:@"cityid"];
    [dicCarInfo setValue:self.drivemileage forKey:@"drivemileage"];
    [dicCarInfo setValue:self.purposeid forKey:@"purposeid"];
    [dicCarInfo setValue:self.colorid forKey:@"colorid"];
    [dicCarInfo setValue:self.firstregtime forKey:@"firstregtime"];
    [dicCarInfo setValue:self.verifytime forKey:@"verifytime"];
    [dicCarInfo setValue:self.veticaltaxtime forKey:@"veticaltaxtime"];
    [dicCarInfo setValue:self.insurancedate forKey:@"insurancedate"];
    [dicCarInfo setValue:self.usercomment forKey:@"usercomment"];
    [dicCarInfo setValue:self.imgurls forKey:@"imgurls"];
    [dicCarInfo setValue:self.drivingpermit forKey:@"drivingpermit"];
    [dicCarInfo setValue:self.registration forKey:@"registration"];
    [dicCarInfo setValue:self.invoice forKey:@"invoice"];
    [dicCarInfo setValue:self.qualityassdate forKey:@"qualityassdate"];
    [dicCarInfo setValue:self.qualityassmile forKey:@"qualityassmile"];
    [dicCarInfo setValue:self.dctionimg forKey:@"dctionimg"];
    [dicCarInfo setValue:self.certificatetype forKey:@"certificatetype"];
    [dicCarInfo setValue:self.driverlicenseimage forKey:@"driverlicenseimage"];
    
    [dicCarInfo setValue:self.isbailcar forKey:@"isbailcar"];
    [dicCarInfo setValue:self.sharetimes forKey:@"sharetimes"];
    [dicCarInfo setValue:self.levelid forKey:@"levelid"];
    [dicCarInfo setValue:self.bailmoney forKey:@"bailmoney"];
    [dicCarInfo setValue:self.carsourceid forKey:@"carsourceid"];
    [dicCarInfo setValue:self.fromtype forKey:@"fromtype"];
    
    
    // 销售代表
    NSMutableDictionary *dicSalesPerson = [NSMutableDictionary dictionary];
    [dicSalesPerson setValue:self.salesPerson.salesid forKey:@"salesid"];
    [dicSalesPerson setValue:self.salesPerson.salesname forKey:@"salesname"];
    [dicSalesPerson setValue:self.salesPerson.salesphone forKey:@"salesphone"];
    [dicSalesPerson setValue:self.salesPerson.salesqq forKey:@"salesqq"];
    
    [dicCarInfo setValue:dicSalesPerson forKey:@"salesperson"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicCarInfo options:kNilOptions error:NULL];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.vincode forKey:@"vincode"];
    [aCoder encodeObject:self.purposeid forKey:@"purposeid"];
    [aCoder encodeObject:self.seriesname forKey:@"seriesname"];
    [aCoder encodeObject:self.brandid forKey:@"brandid"];
    [aCoder encodeObject:self.productname forKey:@"productname"];
    [aCoder encodeObject:self.verifytime forKey:@"verifytime"];
    [aCoder encodeObject:self.veticaltaxtime forKey:@"veticaltaxtime"];
    [aCoder encodeObject:self.usercomment forKey:@"usercomment"];
    [aCoder encodeObject:self.errortext forKey:@"errortext"];
    [aCoder encodeObject:self.drivemileage forKey:@"drivemileage"];
    [aCoder encodeObject:self.views forKey:@"views"];
    [aCoder encodeObject:self.bookprice forKey:@"bookprice"];
    [aCoder encodeObject:self.seriesid forKey:@"seriesid"];
    [aCoder encodeObject:self.insurancedate forKey:@"insurancedate"];
    [aCoder encodeObject:self.imgurls forKey:@"imgurls"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.provinceid forKey:@"provinceid"];
    [aCoder encodeObject:self.cityid forKey:@"cityid"];
    [aCoder encodeObject:self.colorid forKey:@"colorid"];
    [aCoder encodeObject:self.productid forKey:@"productid"];
    [aCoder encodeObject:self.firstregtime forKey:@"firstregtime"];
    [aCoder encodeObject:self.thumbimgurls forKey:@"thumbimgurls"];
    [aCoder encodeObject:self.carid forKey:@"carid"];
    [aCoder encodeObject:self.carname forKey:@"carname"];
    [aCoder encodeObject:self.brandname forKey:@"brandname"];
    [aCoder encodeObject:self.displacement forKey:@"displacement"];
    [aCoder encodeObject:self.gearbox forKey:@"gearbox"];
    [aCoder encodeObject:self.isincludetransferfee forKey:@"isincludetransferfee"];
    [aCoder encodeObject:self.isfixprice forKey:@"isfixprice"];
    [aCoder encodeObject:self.drivingpermit forKey:@"drivingpermit"];
    [aCoder encodeObject:self.registration forKey:@"registration"];
    [aCoder encodeObject:self.invoice forKey:@"invoice"];
    [aCoder encodeObject:self.isnewcar forKey:@"isnewcar"];
    [aCoder encodeObject:self.extendedrepair forKey:@"extendedrepair"];
    [aCoder encodeObject:self.qualityassdate forKey:@"qualityassdate"];
    [aCoder encodeObject:self.qualityassmile forKey:@"qualityassmile"];
    [aCoder encodeObject:self.dctionimg forKey:@"dctionimg"];
    [aCoder encodeObject:self.dctionthumbimg forKey:@"dctionthumbimg"];
    [aCoder encodeObject:self.salesPerson forKey:@"salesPerson"];
    [aCoder encodeObject:self.certificatetype forKey:@"certificatetype"];
    [aCoder encodeObject:self.isTextReport forKey:@"isTextReport"];
    [aCoder encodeObject:self.isExtendedrepair forKey:@"isExtendedrepair"];
    [aCoder encodeObject:self.driverlicenseimage forKey:@"driverlicenseimage"];
    
    [aCoder encodeObject:self.purposeidText forKey:@"purposeidText"];
    [aCoder encodeObject:self.seriesnameText forKey:@"seriesnameText"];
    [aCoder encodeObject:self.productnameText forKey:@"productnameText"];
    [aCoder encodeObject:self.verifytimeText forKey:@"verifytimeText"];
    [aCoder encodeObject:self.veticaltaxtimeText forKey:@"veticaltaxtimeText"];
    [aCoder encodeObject:self.usercommentText forKey:@"usercommentText"];
    [aCoder encodeObject:self.errortextText forKey:@"errortextText"];
    [aCoder encodeObject:self.drivemileageText forKey:@"drivemileageText"];
    [aCoder encodeObject:self.viewsText forKey:@"viewsText"];
    [aCoder encodeObject:self.bookpriceText forKey:@"bookpriceText"];
    [aCoder encodeObject:self.insurancedateText forKey:@"insurancedateText"];
    [aCoder encodeObject:self.imgurlsText forKey:@"imgurlsText"];
    [aCoder encodeObject:self.provinceidText forKey:@"provinceidText"];
    [aCoder encodeObject:self.cityidText forKey:@"cityidText"];
    [aCoder encodeObject:self.coloridText forKey:@"coloridText"];
    [aCoder encodeObject:self.firstregtimeText forKey:@"firstregtimeText"];
    [aCoder encodeObject:self.thumbimgurlsText forKey:@"thumbimgurlsText"];
    [aCoder encodeObject:self.carnameText forKey:@"carnameText"];
    [aCoder encodeObject:self.brandnameText forKey:@"brandnameText"];
    [aCoder encodeObject:self.displacementText forKey:@"displacementText"];
    [aCoder encodeObject:self.gearboxText forKey:@"gearboxText"];
    [aCoder encodeObject:self.isincludetransferfeeText forKey:@"isincludetransferfeeText"];
    [aCoder encodeObject:self.drivingpermitText forKey:@"drivingpermitText"];
    [aCoder encodeObject:self.registrationText forKey:@"registrationText"];
    [aCoder encodeObject:self.invoiceText forKey:@"invoiceText"];
    
    [aCoder encodeObject:self.isbailcar forKey:@"isbailcar"];
    [aCoder encodeObject:self.sharetimes forKey:@"sharetimes"];
    [aCoder encodeObject:self.levelid forKey:@"levelid"];
    [aCoder encodeObject:self.bailmoney forKey:@"bailmoney"];
    [aCoder encodeObject:self.carsourceid forKey:@"carsourceid"];
    [aCoder encodeObject:self.fromtype forKey:@"fromtype"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.vincode = [aDecoder decodeObjectForKey:@"vincode"];
        self.purposeid = [aDecoder decodeObjectForKey:@"purposeid"];
        self.seriesname = [aDecoder decodeObjectForKey:@"seriesname"];
        self.brandid = [aDecoder decodeObjectForKey:@"brandid"];
        self.productname = [aDecoder decodeObjectForKey:@"productname"];
        self.verifytime = [aDecoder decodeObjectForKey:@"verifytime"];
        self.veticaltaxtime = [aDecoder decodeObjectForKey:@"veticaltaxtime"];
        self.usercomment = [aDecoder decodeObjectForKey:@"usercomment"];
        self.errortext = [aDecoder decodeObjectForKey:@"errortext"];
        self.drivemileage = [aDecoder decodeObjectForKey:@"drivemileage"];
        self.views = [aDecoder decodeObjectForKey:@"views"];
        self.bookprice = [aDecoder decodeObjectForKey:@"bookprice"];
        self.seriesid = [aDecoder decodeObjectForKey:@"seriesid"];
        self.insurancedate = [aDecoder decodeObjectForKey:@"insurancedate"];
        self.imgurls = [aDecoder decodeObjectForKey:@"imgurls"];
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.provinceid = [aDecoder decodeObjectForKey:@"provinceid"];
        self.cityid = [aDecoder decodeObjectForKey:@"cityid"];
        self.colorid = [aDecoder decodeObjectForKey:@"colorid"];
        self.productid = [aDecoder decodeObjectForKey:@"productid"];
        self.firstregtime = [aDecoder decodeObjectForKey:@"firstregtime"];
        self.thumbimgurls = [aDecoder decodeObjectForKey:@"thumbimgurls"];
        self.carid = [aDecoder decodeObjectForKey:@"carid"];
        self.carname = [aDecoder decodeObjectForKey:@"carname"];
        self.brandname = [aDecoder decodeObjectForKey:@"brandname"];
        self.displacement = [aDecoder decodeObjectForKey:@"displacement"];
        self.gearbox = [aDecoder decodeObjectForKey:@"gearbox"];
        self.isincludetransferfee = [aDecoder decodeObjectForKey:@"isincludetransferfee"];
        self.isfixprice = [aDecoder decodeObjectForKey:@"isfixprice"];
        self.drivingpermit = [aDecoder decodeObjectForKey:@"drivingpermit"];
        self.registration = [aDecoder decodeObjectForKey:@"registration"];
        self.invoice = [aDecoder decodeObjectForKey:@"invoice"];
        self.isnewcar = [aDecoder decodeObjectForKey:@"isnewcar"];
        self.extendedrepair = [aDecoder decodeObjectForKey:@"extendedrepair"];
        self.qualityassdate = [aDecoder decodeObjectForKey:@"qualityassdate"];
        self.qualityassmile = [aDecoder decodeObjectForKey:@"qualityassmile"];
        self.dctionimg = [aDecoder decodeObjectForKey:@"dctionimg"];
        self.dctionthumbimg = [aDecoder decodeObjectForKey:@"dctionthumbimg"];
        self.certificatetype = [aDecoder decodeObjectForKey:@"certificatetype"];
        self.isTextReport = [aDecoder decodeObjectForKey:@"isTextReport"];
        self.isExtendedrepair = [aDecoder decodeObjectForKey:@"isExtendedrepair"];
        self.driverlicenseimage = [aDecoder decodeObjectForKey:@"driverlicenseimage"];
        self.salesPerson = [aDecoder decodeObjectForKey:@"salesPerson"];
        
        self.purposeidText = [aDecoder decodeObjectForKey:@"purposeidText"];
        self.seriesnameText = [aDecoder decodeObjectForKey:@"seriesnameText"];
        self.productnameText = [aDecoder decodeObjectForKey:@"productnameText"];
        self.verifytimeText = [aDecoder decodeObjectForKey:@"verifytimeText"];
        self.veticaltaxtimeText = [aDecoder decodeObjectForKey:@"veticaltaxtimeText"];
        self.usercommentText = [aDecoder decodeObjectForKey:@"usercommentText"];
        self.errortextText = [aDecoder decodeObjectForKey:@"errortextText"];
        self.drivemileageText = [aDecoder decodeObjectForKey:@"drivemileageText"];
        self.viewsText = [aDecoder decodeObjectForKey:@"viewsText"];
        self.bookpriceText = [aDecoder decodeObjectForKey:@"bookpriceText"];
        self.insurancedateText = [aDecoder decodeObjectForKey:@"insurancedateText"];
        self.imgurlsText = [aDecoder decodeObjectForKey:@"imgurlsText"];
        self.provinceidText = [aDecoder decodeObjectForKey:@"provinceidText"];
        self.cityidText = [aDecoder decodeObjectForKey:@"cityidText"];
        self.coloridText = [aDecoder decodeObjectForKey:@"coloridText"];
        self.firstregtimeText = [aDecoder decodeObjectForKey:@"firstregtimeText"];
        self.thumbimgurlsText = [aDecoder decodeObjectForKey:@"thumbimgurlsText"];
        self.carnameText = [aDecoder decodeObjectForKey:@"carnameText"];
        self.brandnameText = [aDecoder decodeObjectForKey:@"brandnameText"];
        self.displacementText = [aDecoder decodeObjectForKey:@"displacementText"];
        self.gearboxText = [aDecoder decodeObjectForKey:@"gearboxText"];
        self.isincludetransferfeeText = [aDecoder decodeObjectForKey:@"isincludetransferfeeText"];
        self.drivingpermitText = [aDecoder decodeObjectForKey:@"drivingpermitText"];
        self.registrationText = [aDecoder decodeObjectForKey:@"registrationText"];
        self.invoiceText = [aDecoder decodeObjectForKey:@"invoiceText"];
        
        self.isbailcar = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.sharetimes = [aDecoder decodeObjectForKey:@"sharetimes"];
        self.levelid = [aDecoder decodeObjectForKey:@"levelid"];
        self.bailmoney = [aDecoder decodeObjectForKey:@"bailmoney"];
        self.carsourceid = [aDecoder decodeObjectForKey:@"carsourceid"];
        self.fromtype = [aDecoder decodeObjectForKey:@"fromtype"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"vincode : %@\n", self.vincode];
    result = [result stringByAppendingFormat:@"purposeid : %@\n", self.purposeid];
    result = [result stringByAppendingFormat:@"seriesname : %@\n", self.seriesname];
    result = [result stringByAppendingFormat:@"brandid : %@\n", self.brandid];
    result = [result stringByAppendingFormat:@"productname : %@\n", self.productname];
    result = [result stringByAppendingFormat:@"verifytime : %@\n", self.verifytime];
    result = [result stringByAppendingFormat:@"veticaltaxtime : %@\n", self.veticaltaxtime];
    result = [result stringByAppendingFormat:@"usercomment : %@\n", self.usercomment];
    result = [result stringByAppendingFormat:@"errortext : %@\n", self.errortext];
    result = [result stringByAppendingFormat:@"drivemileage : %@\n", self.drivemileage];
    result = [result stringByAppendingFormat:@"views : %@\n", self.views];
    result = [result stringByAppendingFormat:@"bookprice : %@\n", self.bookprice];
    result = [result stringByAppendingFormat:@"seriesid : %@\n", self.seriesid];
    result = [result stringByAppendingFormat:@"insurancedate : %@\n", self.insurancedate];
    result = [result stringByAppendingFormat:@"imgurls : %@\n", self.imgurls];
    result = [result stringByAppendingFormat:@"state : %@\n", self.state];
    result = [result stringByAppendingFormat:@"provinceid : %@\n", self.provinceid];
    result = [result stringByAppendingFormat:@"cityid : %@\n", self.cityid];
    result = [result stringByAppendingFormat:@"colorid : %@\n", self.colorid];
    result = [result stringByAppendingFormat:@"productid : %@\n", self.productid];
    result = [result stringByAppendingFormat:@"firstregtime : %@\n", self.firstregtime];
    result = [result stringByAppendingFormat:@"thumbimgurls : %@\n", self.thumbimgurls];
    result = [result stringByAppendingFormat:@"carid : %@\n", self.carid];
    result = [result stringByAppendingFormat:@"carname : %@\n", self.carname];
    result = [result stringByAppendingFormat:@"brandname : %@\n", self.brandname];
    result = [result stringByAppendingFormat:@"displacement : %@\n", self.displacement];
    result = [result stringByAppendingFormat:@"gearbox : %@\n", self.gearbox];
    result = [result stringByAppendingFormat:@"isincludetransferfee : %@\n", self.isincludetransferfee];
    result = [result stringByAppendingFormat:@"isfixprice : %@\n", self.isfixprice];
    result = [result stringByAppendingFormat:@"drivingpermit : %@\n", self.drivingpermit];
    result = [result stringByAppendingFormat:@"registration : %@\n", self.registration];
    result = [result stringByAppendingFormat:@"invoice : %@\n", self.invoice];
    result = [result stringByAppendingFormat:@"isnewcar : %@\n", self.isnewcar];
    result = [result stringByAppendingFormat:@"extendedrepair : %@\n", self.extendedrepair];
    result = [result stringByAppendingFormat:@"qualityassdate : %@\n", self.qualityassdate];
    result = [result stringByAppendingFormat:@"qualityassmile : %@\n", self.qualityassmile];
    result = [result stringByAppendingFormat:@"dctionimg : %@\n", self.dctionimg];
    result = [result stringByAppendingFormat:@"dctionthumbimg : %@\n", self.dctionthumbimg];
    result = [result stringByAppendingFormat:@"certificatetype : %@\n", self.certificatetype];
    result = [result stringByAppendingFormat:@"isTextReport : %@\n", self.isTextReport];
    result = [result stringByAppendingFormat:@"isExtendedrepair : %@\n", self.isExtendedrepair];
    result = [result stringByAppendingFormat:@"drivingpermitText : %@\n", self.drivingpermitText];
    result = [result stringByAppendingFormat:@"salesPerson : %@\n", self.salesPerson];
    
    result = [result stringByAppendingFormat:@"isbailcar : %@\n", self.isbailcar];
    result = [result stringByAppendingFormat:@"sharetimes : %@\n", self.sharetimes];
    result = [result stringByAppendingFormat:@"levelid : %@\n", self.levelid];
    result = [result stringByAppendingFormat:@"bailmoney : %@\n", self.bailmoney];
    result = [result stringByAppendingFormat:@"carsourceid : %@\n", self.carsourceid];
    result = [result stringByAppendingFormat:@"fromtype : %@\n", self.fromtype];
    
    return result;
}

@end