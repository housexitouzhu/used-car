//
//  UCCarDetailInfoModel.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCCarDetailInfoModel.h"
#import "DatabaseHelper1.h"
#import "UCCarInfoEditModel.h"
#import "AreaProvinceItem.h"
#import "NSString+Util.h"

@implementation UCCarDetailInfoModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        
        // 筛选条件
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *levelValues = values[@"Levels"];
        NSArray *colors = values[@"CarColors"];
        NSArray *carPurposes = values[@"CarPurposes"];
        
        self.pdateText = @"";
        self.publicdateText = @"";
        self.priceText = @"";
        self.registrationdateText = @"";
        self.carnameText = @"";
        self.drivemileageText = @"";
        self.caridText = @"";
        self.sourceidText = @"";
        self.levelidText = @"";
        self.viewsText = @"";
        self.bookpriceText = @"";
        self.isincludetransferfeeText = @"";
        self.provinceidText = @"";
        self.cityidText = @"";
        self.purposeidText = @"";
        self.coloridText = @"";
        self.firstregtimeText = @"";
        self.verifytimeText = @"";
        self.insurancedateText = @"";
        self.veticaltaxtimeText = @"";
        self.drivingpermitText = @"";
        self.registrationText = @"";
        self.invoiceText = @"";
        self.usercommentText = @"";
        self.configsText = @"";
        self.gearboxText = @"";
        self.displacementText = @"";
        self.seriesidText = @"";
        self.productidText = @"";
        self.thumbimgurlsText = @"";
        self.dealername = @"";
        
        if (json != nil) {
            self.pdate                = [json objectForKey:@"pdate"];
            self.publicdate           = [json objectForKey:@"publicdate"];
            self.price                = [json objectForKey:@"price"];
            self.imgurls              = [json objectForKey:@"imgurls"];
            self.registrationdate     = [json objectForKey:@"registrationdate"];
            self.carname              = [json objectForKey:@"carname"];
            self.drivemileage         = [json objectForKey:@"drivemileage"];
            self.carid                = [json objectForKey:@"carid"];
            self.sourceid             = [json objectForKey:@"sourceid"];
            self.levelid              = [json objectForKey:@"levelid"];
            self.views                = [json objectForKey:@"views"];
            self.bookprice            = [json objectForKey:@"bookprice"];
            self.isincludetransferfee = [json objectForKey:@"isincludetransferfee"];
            self.provinceid           = [json objectForKey:@"provinceid"];
            self.cityid               = [json objectForKey:@"cityid"];
            self.purposeid            = [json objectForKey:@"purposeid"];
            self.colorid              = [json objectForKey:@"colorid"];
            self.firstregtime         = [json objectForKey:@"firstregtime"];
            self.verifytime           = [json objectForKey:@"verifytime"];
            self.insurancedate        = [json objectForKey:@"insurancedate"];
            self.veticaltaxtime       = [json objectForKey:@"veticaltaxtime"];
            self.drivingpermit        = [json objectForKey:@"drivingpermit"];
            self.registration         = [json objectForKey:@"registration"];
            self.invoice              = [json objectForKey:@"invoice"];
            self.usercomment          = [json objectForKey:@"usercomment"];
            self.configs              = [json objectForKey:@"configs"];
            self.gearbox              = [json objectForKey:@"gearbox"];
            self.displacement         = [json objectForKey:@"displacement"];
            self.brandid              = [json objectForKey:@"brandid"];
            self.seriesid             = [json objectForKey:@"seriesid"];
            self.productid            = [json objectForKey:@"productid"];
            self.thumbimgurls         = [json objectForKey:@"thumbimgurls"];
            self.salesPerson          = [[SalesPersonModel alloc] initWithJson:[json objectForKey:@"salesperson"]];
            self.dealer               = [[DealerModel alloc] initWithJson:[json objectForKey:@"dealer"]];
            self.userid               = [json objectForKey:@"userid"];
            self.memberid             = [json objectForKey:@"memberid"];
            self.dealername           = [json objectForKey:@"dealername"];
            self.isnewcar             = [json objectForKey:@"isnewcar"];
            self.extendedrepair       = [json objectForKey:@"extendedrepair"];
            self.certificatetype      = [json objectForKey:@"certificatetype"];
            self.qualityassdate       = [json objectForKey:@"qualityassdate"];
            self.qualityassmile       = [json objectForKey:@"qualityassmile"];
            self.dctionimg            = [json objectForKey:@"dctionimg"];
            self.dctionthumbimg       = [json objectForKey:@"dctionthumbimg"];
            self.haswarranty          = [json objectForKey:@"haswarranty"];
            self.creditid             = [json objectForKey:@"creditid"];
            self.hasDeposit           = [json objectForKey:@"isbailcar"];
            self.bailmoney            = [json objectForKey:@"bailmoney"];

            self.state                = [json objectForKey:@"state"];
            self.carsourceid          = [json objectForKey:@"carsourceid"];
            self.carsourcename        = [json objectForKey:@"carsourcename"];
            self.carsourceurl         = [json objectForKey:@"carsourceurl"];
            self.selldate             = [json objectForKey:@"selldate"];
            
            self.publicdateText = @"";
            if (self.publicdate.length > 0) {
                self.publicdateText = [OMG stringFromDateWithFormat:@"yyyy-MM-dd" date:[OMG dateFromStringWithFormat:@"yyyy-MM-dd HH:mm:ss" string:self.publicdate]];
            }
            
            self.viewsText = self.views ? [self.views stringValue] : @"";
            AreaProvinceItem *apItem = [OMG areaProvince:self.provinceid.integerValue];
            AreaCityItem *acItem = [OMG areaCity:self.cityid.integerValue apItem:apItem];
            self.provinceidText = apItem.PN;
            self.cityidText = acItem.CN;
            self.carnameText = self.carname.length > 0 ? self.carname.trim : @"";
            self.bookpriceText = [self.bookprice stringValue].length > 0 ? [NSString stringWithFormat:@"%.2f", [self.bookprice doubleValue]] : @"";
            if (self.isincludetransferfee)
                self.isincludetransferfeeText = [self.isincludetransferfee integerValue] == 0 ? @"不含" : @"包含";
            else
                self.isincludetransferfeeText = @"";
            self.drivemileageText = [self.drivemileage stringValue].length > 0 ? [NSString stringWithFormat:@"%.2f", [self.drivemileage doubleValue]] : @"";
            self.purposeidText = @"";
            if ([self.purposeid integerValue] > 0)
                self.purposeidText = [carPurposes objectAtIndex:[self.purposeid integerValue] - 1];
            self.coloridText = ([self.colorid integerValue] > 0 && [self.colorid integerValue] <= 11) ? [colors objectAtIndex:[self.colorid integerValue] - 1] : @"";
            
            self.firstregtimeText = self.firstregtime.length > 0 ? self.firstregtime : @"";
            self.verifytimeText = self.verifytime.length > 0 ? self.verifytime : @"";
            self.insurancedateText = self.insurancedate.length > 0 ? self.insurancedate : @"";
            self.veticaltaxtimeText = self.veticaltaxtime.length > 0 ? self.veticaltaxtime : @"";
            //            self.txtdrivingpermit = self.drivingpermit ? [self.drivingpermit stringValue] : @"";
            if (self.drivingpermit) {
                if ([self.drivingpermit integerValue] == 1)
                    self.drivingpermitText = @"有";
                else if ([self.drivingpermit integerValue] == 2)
                    self.drivingpermitText = @"补办中";
                else if ([self.drivingpermit integerValue] == 3)
                    self.drivingpermitText = @"丢失";
                else
                    self.drivingpermitText = @"";
            }else{
                self.drivingpermitText = @"";
            }
            if (self.registration) {
                if ([self.registration integerValue] == 1)
                    self.registrationText = @"有";
                else if ([self.registration integerValue] == 2)
                    self.registrationText = @"补办中";
                else if ([self.registration integerValue] == 3)
                    self.registrationText = @"丢失";
                else
                    self.registrationText = @"";
            }else{
                self.registrationText = @"";
            }
            if (self.invoice) {
                if ([self.invoice integerValue] == 1)
                    self.invoiceText = @"有";
                else if ([self.invoice integerValue] == 2)
                    self.invoiceText = @"补办中";
                else if ([self.invoice integerValue] == 3)
                    self.invoiceText = @"丢失";
                else
                    self.invoiceText = @"";
            }else{
                self.invoiceText = @"";
            }
            if (self.sourceid)
                self.sourceidText = [self.sourceid integerValue] == 1 ? @"个人" : @"商家";
            else
                self.sourceidText = @"";
            if (self.levelid) {
                for (int i = 0; i < [levelValues count]; i++) {
                    NSDictionary *temp = [levelValues objectAtIndex:i];
                    if ([[temp objectForKey:@"Value"] isEqualToString:[self.levelid stringValue]]) {
                        self.levelidText = [temp objectForKey:@"Name"];
                        break;
                    }
                }
            }else{
                self.levelidText = @"";
            }
            self.usercommentText = self.usercomment.length > 0 ? self.usercomment : @"";
            self.configsText = self.configs.length > 0 ? [self.configs stringByReplacingOccurrencesOfString:@"," withString:@"、"] : @"";
            self.gearboxText = self.gearbox.length > 0 ? self.gearbox : @"";
            self.displacementText = self.displacement.length > 0 ? self.displacement : @"";
            //            self.txtseriesid = self.seriesid.length > 0 ? self.seriesid : @"";
            //            self.txtproductid = self.productid.length > 0 ? self.productid : @"";
            self.thumbimgurlsText = self.thumbimgurls.length > 0 ? self.thumbimgurls : nil;
            
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pdate forKey:@"pdate"];
    [aCoder encodeObject:self.publicdate forKey:@"publicdate"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.imgurls forKey:@"imgurls"];
    [aCoder encodeObject:self.registrationdate forKey:@"registrationdate"];
    [aCoder encodeObject:self.carname forKey:@"carname"];
    [aCoder encodeObject:self.drivemileage forKey:@"drivemileage"];
    [aCoder encodeObject:self.carid forKey:@"carid"];
    [aCoder encodeObject:self.sourceid forKey:@"sourceid"];
    [aCoder encodeObject:self.levelid forKey:@"levelid"];
    [aCoder encodeObject:self.views forKey:@"views"];
    [aCoder encodeObject:self.bookprice forKey:@"bookprice"];
    [aCoder encodeObject:self.isincludetransferfee forKey:@"isincludetransferfee"];
    [aCoder encodeObject:self.provinceid forKey:@"provinceid"];
    [aCoder encodeObject:self.cityid forKey:@"cityid"];
    [aCoder encodeObject:self.purposeid forKey:@"purposeid"];
    [aCoder encodeObject:self.colorid forKey:@"colorid"];
    [aCoder encodeObject:self.firstregtime forKey:@"firstregtime"];
    [aCoder encodeObject:self.verifytime forKey:@"verifytime"];
    [aCoder encodeObject:self.insurancedate forKey:@"insurancedate"];
    [aCoder encodeObject:self.veticaltaxtime forKey:@"veticaltaxtime"];
    [aCoder encodeObject:self.drivingpermit forKey:@"drivingpermit"];
    [aCoder encodeObject:self.registration forKey:@"registration"];
    [aCoder encodeObject:self.invoice forKey:@"invoice"];
    [aCoder encodeObject:self.usercomment forKey:@"usercomment"];
    [aCoder encodeObject:self.configs forKey:@"configs"];
    [aCoder encodeObject:self.gearbox forKey:@"gearbox"];
    [aCoder encodeObject:self.displacement forKey:@"displacement"];
    [aCoder encodeObject:self.brandid forKey:@"brandid"];
    [aCoder encodeObject:self.seriesid forKey:@"seriesid"];
    [aCoder encodeObject:self.productid forKey:@"productid"];
    [aCoder encodeObject:self.thumbimgurls forKey:@"thumbimgurls"];
    [aCoder encodeObject:self.salesPerson forKey:@"salesPerson"];
    [aCoder encodeObject:self.dealer forKey:@"dealer"];
    [aCoder encodeObject:self.userid forKey:@"userid"];
    [aCoder encodeObject:self.memberid forKey:@"memberid"];
    [aCoder encodeObject:self.dealername forKey:@"dealername"];
    [aCoder encodeObject:self.isnewcar forKey:@"isnewcar"];
    [aCoder encodeObject:self.extendedrepair forKey:@"extendedrepair"];
    [aCoder encodeObject:self.certificatetype forKey:@"certificatetype"];
    [aCoder encodeObject:self.qualityassdate forKey:@"qualityassdate"];
    [aCoder encodeObject:self.qualityassmile forKey:@"qualityassmile"];
    [aCoder encodeObject:self.dctionimg forKey:@"dctionimg"];
    [aCoder encodeObject:self.dctionthumbimg forKey:@"dctionthumbimg"];
    [aCoder encodeObject:self.haswarranty forKey:@"haswarranty"];
    [aCoder encodeObject:self.creditid forKey:@"creditid"];
    [aCoder encodeObject:self.hasDeposit forKey:@"isbailcar"];
    [aCoder encodeObject:self.bailmoney forKey:@"bailmoney"];
    
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.carsourceid forKey:@"carsourceid"];
    [aCoder encodeObject:self.carsourcename forKey:@"carsourcename"];
    [aCoder encodeObject:self.carsourceurl forKey:@"carsourceurl"];
    [aCoder encodeObject:self.selldate forKey:@"selldate"];
    
    [aCoder encodeObject:self.pdateText forKey:@"pdateText"];
    [aCoder encodeObject:self.publicdateText forKey:@"publicdateText"];
    [aCoder encodeObject:self.priceText forKey:@"priceText"];
    [aCoder encodeObject:self.registrationdateText forKey:@"registrationdateText"];
    [aCoder encodeObject:self.carnameText forKey:@"carnameText"];
    [aCoder encodeObject:self.drivemileageText forKey:@"drivemileageText"];
    [aCoder encodeObject:self.caridText forKey:@"caridText"];
    [aCoder encodeObject:self.sourceidText forKey:@"sourceidText"];
    [aCoder encodeObject:self.levelidText forKey:@"levelidText"];
    [aCoder encodeObject:self.viewsText forKey:@"viewsText"];
    [aCoder encodeObject:self.bookpriceText forKey:@"bookpriceText"];
    [aCoder encodeObject:self.isincludetransferfeeText forKey:@"isincludetransferfeeText"];
    [aCoder encodeObject:self.provinceidText forKey:@"provinceidText"];
    [aCoder encodeObject:self.cityidText forKey:@"cityidText"];
    [aCoder encodeObject:self.purposeidText forKey:@"purposeidText"];
    [aCoder encodeObject:self.coloridText forKey:@"coloridText"];
    [aCoder encodeObject:self.firstregtimeText forKey:@"firstregtimeText"];
    [aCoder encodeObject:self.verifytimeText forKey:@"verifytimeText"];
    [aCoder encodeObject:self.insurancedateText forKey:@"insurancedateText"];
    [aCoder encodeObject:self.veticaltaxtimeText forKey:@"veticaltaxtimeText"];
    [aCoder encodeObject:self.drivingpermitText forKey:@"drivingpermitText"];
    [aCoder encodeObject:self.registrationText forKey:@"registrationText"];
    [aCoder encodeObject:self.invoiceText forKey:@"invoiceText"];
    [aCoder encodeObject:self.usercommentText forKey:@"usercommentText"];
    [aCoder encodeObject:self.configsText forKey:@"configsText"];
    [aCoder encodeObject:self.gearboxText forKey:@"gearboxText"];
    [aCoder encodeObject:self.displacementText forKey:@"displacementText"];
    [aCoder encodeObject:self.seriesidText forKey:@"seriesidText"];
    [aCoder encodeObject:self.productidText forKey:@"productidText"];
    [aCoder encodeObject:self.thumbimgurlsText forKey:@"thumbimgurlsText"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.pdate                = [aDecoder decodeObjectForKey:@"pdate"];
        self.publicdate           = [aDecoder decodeObjectForKey:@"publicdate"];
        self.price                = [aDecoder decodeObjectForKey:@"price"];
        self.imgurls              = [aDecoder decodeObjectForKey:@"imgurls"];
        self.registrationdate     = [aDecoder decodeObjectForKey:@"registrationdate"];
        self.carname              = [aDecoder decodeObjectForKey:@"carname"];
        self.drivemileage         = [aDecoder decodeObjectForKey:@"drivemileage"];
        self.carid                = [aDecoder decodeObjectForKey:@"carid"];
        self.sourceid             = [aDecoder decodeObjectForKey:@"sourceid"];
        self.levelid              = [aDecoder decodeObjectForKey:@"levelid"];
        self.views                = [aDecoder decodeObjectForKey:@"views"];
        self.bookprice            = [aDecoder decodeObjectForKey:@"bookprice"];
        self.isincludetransferfee = [aDecoder decodeObjectForKey:@"isincludetransferfee"];
        self.provinceid           = [aDecoder decodeObjectForKey:@"provinceid"];
        self.cityid               = [aDecoder decodeObjectForKey:@"cityid"];
        self.purposeid            = [aDecoder decodeObjectForKey:@"purposeid"];
        self.colorid              = [aDecoder decodeObjectForKey:@"colorid"];
        self.firstregtime         = [aDecoder decodeObjectForKey:@"firstregtime"];
        self.verifytime           = [aDecoder decodeObjectForKey:@"verifytime"];
        self.insurancedate        = [aDecoder decodeObjectForKey:@"insurancedate"];
        self.veticaltaxtime       = [aDecoder decodeObjectForKey:@"veticaltaxtime"];
        self.drivingpermit        = [aDecoder decodeObjectForKey:@"drivingpermit"];
        self.registration         = [aDecoder decodeObjectForKey:@"registration"];
        self.invoice              = [aDecoder decodeObjectForKey:@"invoice"];
        self.usercomment          = [aDecoder decodeObjectForKey:@"usercomment"];
        self.configs              = [aDecoder decodeObjectForKey:@"configs"];
        self.gearbox              = [aDecoder decodeObjectForKey:@"gearbox"];
        self.displacement         = [aDecoder decodeObjectForKey:@"displacement"];
        self.brandid              = [aDecoder decodeObjectForKey:@"brandid"];
        self.seriesid             = [aDecoder decodeObjectForKey:@"seriesid"];
        self.productid            = [aDecoder decodeObjectForKey:@"productid"];
        self.thumbimgurls         = [aDecoder decodeObjectForKey:@"thumbimgurls"];
        self.salesPerson          = [aDecoder decodeObjectForKey:@"salesPerson"];
        self.dealer               = [aDecoder decodeObjectForKey:@"dealer"];
        self.memberid             = [aDecoder decodeObjectForKey:@"memberid"];
        self.userid               = [aDecoder decodeObjectForKey:@"userid"];
        self.dealername           = [aDecoder decodeObjectForKey:@"dealername"];
        self.isnewcar             = [aDecoder decodeObjectForKey:@"isnewcar"];
        self.extendedrepair       = [aDecoder decodeObjectForKey:@"extendedrepair"];
        self.certificatetype      = [aDecoder decodeObjectForKey:@"certificatetype"];
        self.qualityassdate       = [aDecoder decodeObjectForKey:@"qualityassdate"];
        self.qualityassmile       = [aDecoder decodeObjectForKey:@"qualityassmile"];
        self.dctionimg            = [aDecoder decodeObjectForKey:@"dctionimg"];
        self.dctionthumbimg       = [aDecoder decodeObjectForKey:@"dctionthumbimg"];
        self.haswarranty          = [aDecoder decodeObjectForKey:@"haswarranty"];
        self.creditid             = [aDecoder decodeObjectForKey:@"creditid"];
        self.hasDeposit           = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.bailmoney            = [aDecoder decodeObjectForKey:@"bailmoney"];
        
        self.state = [aDecoder decodeObjectForKey:@"state"];
        self.carsourceid = [aDecoder decodeObjectForKey:@"carsourceid"];
        self.carsourcename = [aDecoder decodeObjectForKey:@"carsourcename"];
        self.carsourceurl = [aDecoder decodeObjectForKey:@"carsourceurl"];
        self.selldate = [aDecoder decodeObjectForKey:@"selldate"];
        
        self.pdateText = [aDecoder decodeObjectForKey:@"pdateText"];
        self.publicdateText = [aDecoder decodeObjectForKey:@"publicdateText"];
        self.priceText = [aDecoder decodeObjectForKey:@"priceText"];
        self.registrationdateText = [aDecoder decodeObjectForKey:@"registrationdateText"];
        self.carnameText = [aDecoder decodeObjectForKey:@"carnameText"];
        self.drivemileageText = [aDecoder decodeObjectForKey:@"drivemileageText"];
        self.caridText = [aDecoder decodeObjectForKey:@"caridText"];
        self.sourceidText = [aDecoder decodeObjectForKey:@"sourceidText"];
        self.levelidText = [aDecoder decodeObjectForKey:@"levelidText"];
        self.viewsText = [aDecoder decodeObjectForKey:@"viewsText"];
        self.bookpriceText = [aDecoder decodeObjectForKey:@"bookpriceText"];
        self.isincludetransferfeeText = [aDecoder decodeObjectForKey:@"isincludetransferfeeText"];
        self.provinceidText = [aDecoder decodeObjectForKey:@"provinceidText"];
        self.cityidText = [aDecoder decodeObjectForKey:@"cityidText"];
        self.purposeidText = [aDecoder decodeObjectForKey:@"purposeidText"];
        self.coloridText = [aDecoder decodeObjectForKey:@"coloridText"];
        self.firstregtimeText = [aDecoder decodeObjectForKey:@"firstregtimeText"];
        self.verifytimeText = [aDecoder decodeObjectForKey:@"verifytimeText"];
        self.insurancedateText = [aDecoder decodeObjectForKey:@"insurancedateText"];
        self.veticaltaxtimeText = [aDecoder decodeObjectForKey:@"veticaltaxtimeText"];
        self.drivingpermitText = [aDecoder decodeObjectForKey:@"drivingpermitText"];
        self.registrationText = [aDecoder decodeObjectForKey:@"registrationText"];
        self.invoiceText = [aDecoder decodeObjectForKey:@"invoiceText"];
        self.usercommentText = [aDecoder decodeObjectForKey:@"usercommentText"];
        self.configsText = [aDecoder decodeObjectForKey:@"configsText"];
        self.gearboxText = [aDecoder decodeObjectForKey:@"gearboxText"];
        self.displacementText = [aDecoder decodeObjectForKey:@"displacementText"];
        self.seriesidText = [aDecoder decodeObjectForKey:@"seriesidText"];
        self.productidText = [aDecoder decodeObjectForKey:@"productidText"];
        self.thumbimgurlsText = [aDecoder decodeObjectForKey:@"thumbimgurlsText"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"pdate : %@\n", self.pdate];
    result = [result stringByAppendingFormat:@"publicdate : %@\n", self.publicdate];
    result = [result stringByAppendingFormat:@"price : %@\n", self.price];
    result = [result stringByAppendingFormat:@"imgurls : %@\n", self.imgurls];
    result = [result stringByAppendingFormat:@"registrationdate : %@\n", self.registrationdate];
    result = [result stringByAppendingFormat:@"carname : %@\n", self.carname];
    result = [result stringByAppendingFormat:@"drivemileage : %@\n", self.drivemileage];
    result = [result stringByAppendingFormat:@"carid : %@\n", self.carid];
    result = [result stringByAppendingFormat:@"sourceid : %@\n", self.sourceid];
    result = [result stringByAppendingFormat:@"levelid : %@\n", self.levelid];
    result = [result stringByAppendingFormat:@"views : %@\n", self.views];
    result = [result stringByAppendingFormat:@"bookprice : %@\n", self.bookprice];
    result = [result stringByAppendingFormat:@"isincludetransferfee : %@\n", self.isincludetransferfee];
    result = [result stringByAppendingFormat:@"provinceid : %@\n", self.provinceid];
    result = [result stringByAppendingFormat:@"cityid : %@\n", self.cityid];
    result = [result stringByAppendingFormat:@"purposeid : %@\n", self.purposeid];
    result = [result stringByAppendingFormat:@"colorid : %@\n", self.colorid];
    result = [result stringByAppendingFormat:@"firstregtime : %@\n", self.firstregtime];
    result = [result stringByAppendingFormat:@"verifytime : %@\n", self.verifytime];
    result = [result stringByAppendingFormat:@"insurancedate : %@\n", self.insurancedate];
    result = [result stringByAppendingFormat:@"veticaltaxtime : %@\n", self.veticaltaxtime];
    result = [result stringByAppendingFormat:@"drivingpermit : %@\n", self.drivingpermit];
    result = [result stringByAppendingFormat:@"registration : %@\n", self.registration];
    result = [result stringByAppendingFormat:@"invoice : %@\n", self.invoice];
    result = [result stringByAppendingFormat:@"usercomment : %@\n", self.usercomment];
    result = [result stringByAppendingFormat:@"configs : %@\n", self.configs];
    result = [result stringByAppendingFormat:@"gearbox : %@\n", self.gearbox];
    result = [result stringByAppendingFormat:@"displacement : %@\n", self.displacement];
    result = [result stringByAppendingFormat:@"brandid : %@\n", self.brandid];
    result = [result stringByAppendingFormat:@"seriesid : %@\n", self.seriesid];
    result = [result stringByAppendingFormat:@"productid : %@\n", self.productid];
    result = [result stringByAppendingFormat:@"thumbimgurls : %@\n", self.thumbimgurls];
    result = [result stringByAppendingFormat:@"salesPerson : %@\n", self.salesPerson];
    result = [result stringByAppendingFormat:@"dealer : %@\n", self.dealer];
    result = [result stringByAppendingFormat:@"userid : %@\n", self.userid];
    result = [result stringByAppendingFormat:@"memberid : %@\n", self.memberid];
    result = [result stringByAppendingFormat:@"dealername : %@\n", self.dealername];
    result = [result stringByAppendingFormat:@"isnewcar : %@\n", self.isnewcar];
    result = [result stringByAppendingFormat:@"extendedrepair : %@\n", self.extendedrepair];
    result = [result stringByAppendingFormat:@"certificatetype : %@\n", self.certificatetype];
    result = [result stringByAppendingFormat:@"qualityassdate : %@\n", self.qualityassdate];
    result = [result stringByAppendingFormat:@"qualityassmile : %@\n", self.qualityassmile];
    result = [result stringByAppendingFormat:@"dctionimg : %@\n", self.dctionimg];
    result = [result stringByAppendingFormat:@"dctionthumbimg : %@\n", self.dctionthumbimg];
    result = [result stringByAppendingFormat:@"haswarranty : %@\n", self.haswarranty];
    result = [result stringByAppendingFormat:@"creditid : %@\n", self.creditid];
    result = [result stringByAppendingFormat:@"hasDeposit  : %@\n", self.hasDeposit];
    result = [result stringByAppendingFormat:@"bailmoney  : %@\n", self.bailmoney];
    
    result = [result stringByAppendingFormat:@"state : %@\n", self.state];
    result = [result stringByAppendingFormat:@"carsourceid : %@\n", self.carsourceid];
    result = [result stringByAppendingFormat:@"carsourcename : %@\n", self.carsourcename];
    result = [result stringByAppendingFormat:@"carsourceurl : %@\n", self.carsourceurl];
    result = [result stringByAppendingFormat:@"selldate : %@\n", self.selldate];
    
    result = [result stringByAppendingFormat:@"pdateText : %@\n", self.pdateText];
    result = [result stringByAppendingFormat:@"publicdateText : %@\n", self.publicdateText];
    result = [result stringByAppendingFormat:@"priceText : %@\n", self.priceText];
    result = [result stringByAppendingFormat:@"registrationdateText : %@\n", self.registrationdateText];
    result = [result stringByAppendingFormat:@"carnameText : %@\n", self.carnameText];
    result = [result stringByAppendingFormat:@"drivemileageText : %@\n", self.drivemileageText];
    result = [result stringByAppendingFormat:@"caridText : %@\n", self.caridText];
    result = [result stringByAppendingFormat:@"sourceidText : %@\n", self.sourceidText];
    result = [result stringByAppendingFormat:@"levelidText : %@\n", self.levelidText];
    result = [result stringByAppendingFormat:@"viewsText : %@\n", self.viewsText];
    result = [result stringByAppendingFormat:@"bookpriceText : %@\n", self.bookpriceText];
    result = [result stringByAppendingFormat:@"isincludetransferfeeText : %@\n", self.isincludetransferfeeText];
    result = [result stringByAppendingFormat:@"provinceidText : %@\n", self.provinceidText];
    result = [result stringByAppendingFormat:@"cityidText : %@\n", self.cityidText];
    result = [result stringByAppendingFormat:@"purposeidText : %@\n", self.purposeidText];
    result = [result stringByAppendingFormat:@"coloridText : %@\n", self.coloridText];
    result = [result stringByAppendingFormat:@"firstregtimeText : %@\n", self.firstregtimeText];
    result = [result stringByAppendingFormat:@"verifytimeText : %@\n", self.verifytimeText];
    result = [result stringByAppendingFormat:@"insurancedateText : %@\n", self.insurancedateText];
    result = [result stringByAppendingFormat:@"veticaltaxtimeText : %@\n", self.veticaltaxtimeText];
    result = [result stringByAppendingFormat:@"drivingpermitText : %@\n", self.drivingpermitText];
    result = [result stringByAppendingFormat:@"registrationText : %@\n", self.registrationText];
    result = [result stringByAppendingFormat:@"invoiceText : %@\n", self.invoiceText];
    result = [result stringByAppendingFormat:@"usercommentText : %@\n", self.usercommentText];
    result = [result stringByAppendingFormat:@"configsText : %@\n", self.configsText];
    result = [result stringByAppendingFormat:@"gearboxText : %@\n", self.gearboxText];
    result = [result stringByAppendingFormat:@"displacementText : %@\n", self.displacementText];
    result = [result stringByAppendingFormat:@"seriesidText : %@\n", self.seriesidText];
    result = [result stringByAppendingFormat:@"productidText : %@\n", self.productidText];
    result = [result stringByAppendingFormat:@"thumbimgurlsText : %@\n", self.thumbimgurlsText];
    
    return result;
}

- (id)initWithCarInfoEditModel:(UCCarInfoEditModel *)mCarinfoEdit
{
    // 车辆信息
    NSMutableDictionary *dicCarInfo = [NSMutableDictionary dictionary];
    [dicCarInfo setValue:mCarinfoEdit.bookprice forKey:@"bookprice"];
    [dicCarInfo setValue:mCarinfoEdit.brandid forKey:@"brandid"];
    [dicCarInfo setValue:mCarinfoEdit.brandname forKey:@"brandname"];
    [dicCarInfo setValue:mCarinfoEdit.carid.integerValue < 0 ? [NSNumber numberWithInt:0] : mCarinfoEdit.carid forKey:@"carid"];
    [dicCarInfo setValue:mCarinfoEdit.carname forKey:@"carname"];
    [dicCarInfo setValue:mCarinfoEdit.cityid forKey:@"cityid"];
    [dicCarInfo setValue:mCarinfoEdit.colorid forKey:@"colorid"];
    [dicCarInfo setValue:nil forKey:@"configs"];
    [dicCarInfo setValue:mCarinfoEdit.displacement forKey:@"displacement"];
    [dicCarInfo setValue:mCarinfoEdit.drivemileage forKey:@"drivemileage"];
    [dicCarInfo setValue:mCarinfoEdit.drivingpermit forKey:@"drivingpermit"];
    [dicCarInfo setValue:mCarinfoEdit.firstregtime forKey:@"firstregtime"];
    [dicCarInfo setValue:mCarinfoEdit.gearbox forKey:@"gearbox"];
    [dicCarInfo setValue:mCarinfoEdit.imgurls forKey:@"imgurls"];
    [dicCarInfo setValue:mCarinfoEdit.insurancedate forKey:@"insurancedate"];
    [dicCarInfo setValue:mCarinfoEdit.invoice forKey:@"invoice"];
    [dicCarInfo setValue:mCarinfoEdit.isfixprice forKey:@"isfixprice"];
    [dicCarInfo setValue:mCarinfoEdit.isincludetransferfee forKey:@"isincludetransferfee"];
    [dicCarInfo setValue:nil forKey:@"levelid"];
    [dicCarInfo setValue:mCarinfoEdit.productid forKey:@"productid"];
    [dicCarInfo setValue:mCarinfoEdit.productname forKey:@"productname"];
    [dicCarInfo setValue:mCarinfoEdit.provinceid forKey:@"provinceid"];
    [dicCarInfo setValue:nil forKey:@"publicdate"];
    [dicCarInfo setValue:mCarinfoEdit.purposeid forKey:@"purposeid"];
    [dicCarInfo setValue:nil forKey:@"qualityassdate"];
    [dicCarInfo setValue:nil forKey:@"qualityassmile"];
    [dicCarInfo setValue:mCarinfoEdit.registration forKey:@"registration"];
    //TODO: baozhengjin
    //    [dicCarInfo setValue:mCarinfoEdit.registration forKey:@"registration"];
    //    [dicCarInfo setValue:mCarinfoEdit.bailmoney forKey:@"bailmoney"];
    // 销售代表
    NSMutableDictionary *dicSalesPerson = [NSMutableDictionary dictionary];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.salesid forKey:@"salesid"];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.saleslinktime forKey:@"saleslinktime"];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.salesname forKey:@"salesname"];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.salesphone forKey:@"salesphone"];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.salesqq forKey:@"salesqq"];
    [dicSalesPerson setValue:mCarinfoEdit.salesPerson.salestype forKey:@"salestype"];
    [dicCarInfo setValue:dicSalesPerson forKey:@"salesperson"];
    
//    NSMutableDictionary *dicDealer = [NSMutableDictionary dictionary];
//    [dicDealer setValue: forKey:mCarinfoEdit];
    
    [dicCarInfo setValue:mCarinfoEdit.seriesid forKey:@"seriesid"];
    [dicCarInfo setValue:mCarinfoEdit.seriesname forKey:@"seriesname"];
    [dicCarInfo setValue:mCarinfoEdit.state forKey:@"state"];
    [dicCarInfo setValue:mCarinfoEdit.thumbimgurls forKey:@"thumbimgurls"];
    [dicCarInfo setValue:mCarinfoEdit.usercomment forKey:@"usercomment"];
    [dicCarInfo setValue:nil forKey:@"userid"];
    [dicCarInfo setValue:mCarinfoEdit.verifytime forKey:@"verifytime"];
    [dicCarInfo setValue:mCarinfoEdit.veticaltaxtime forKey:@"veticaltaxtime"];
    [dicCarInfo setValue:mCarinfoEdit.views forKey:@"views"];
    [dicCarInfo setValue:mCarinfoEdit.isnewcar forKey:@"isnewcar"];
    [dicCarInfo setValue:mCarinfoEdit.extendedrepair forKey:@"extendedrepair"];
    
    [dicCarInfo setValue:mCarinfoEdit.certificatetype forKey:@"certificatetype"];
    [dicCarInfo setValue:mCarinfoEdit.qualityassdate forKey:@"qualityassdate"];
    [dicCarInfo setValue:mCarinfoEdit.qualityassmile forKey:@"qualityassmile"];
    [dicCarInfo setValue:mCarinfoEdit.dctionimg forKey:@"dctionimg"];
    [dicCarInfo setValue:mCarinfoEdit.dctionthumbimg forKey:@"dctionthumbimg"];
    
    UCCarDetailInfoModel *mCarDetailInfo = [[UCCarDetailInfoModel alloc] initWithJson:dicCarInfo];
    
    return mCarDetailInfo;
}

- (NSString *)jsonString
{
    //    // 车辆信息
    NSMutableDictionary *dicCarInfo = [[NSMutableDictionary alloc] init];
    [dicCarInfo setValue:self.userid forKey:@"userid"];
    
    // 销售代表
    NSMutableDictionary *dicSalesPerson = [NSMutableDictionary dictionary];
    [dicSalesPerson setValue:self.salesPerson.salesid forKey:@"salesid"];
    [dicSalesPerson setValue:self.salesPerson.salesname forKey:@"salesname"];
    [dicSalesPerson setValue:self.salesPerson.salesphone forKey:@"salesphone"];
    
    [dicCarInfo setValue:dicSalesPerson forKey:@"salesperson"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicCarInfo options:kNilOptions error:NULL];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
