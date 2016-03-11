//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCCarInfoModel.h"
#import "NSString+Util.h"
#import "UCFavoritesModel.h"
#import "UCFavoritesCloudModel.h"
#import "UCCarInfoEditModel.h"

@implementation UCCarInfoModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {            
            self.carid            = [json objectForKey:@"carid"];
            self.carname          = [json objectForKey:@"carname"];
            self.cid              = [json objectForKey:@"cid"];
            self.cname            = [json objectForKey:@"cname"];
            self.creditid         = [json objectForKey:@"creditid"];
            self.dealertype       = [json objectForKey:@"dealertype"];
            self.goodcarofpic     = [json objectForKey:@"goodcarofpic"];
            self.haswarranty      = [json objectForKey:@"haswarranty"];
            self.haswarrantydate  = [json objectForKey:@"haswarrantydate"];
            self.image            = [json objectForKey:@"image"];
            self.isNew            = [json objectForKey:@"isnew"];
            self.isnewcar         = [json objectForKey:@"isnewcar"];
            self.isoutsite        = [json objectForKey:@"isoutsite"];
            self.mileage          = [json objectForKey:@"mileage"];
            self.pdate            = [json objectForKey:@"pdate"];
            self.pid              = [json objectForKey:@"pid"];
            self.pname            = [json objectForKey:@"pname"];
            self.price            = [json objectForKey:@"price"];
            self.publishdate      = [json objectForKey:@"publishdate"];
            self.registrationdate = [json objectForKey:@"registrationdate"];
            self.sourceid         = [json objectForKey:@"sourceid"];
            self.specid           = [json objectForKey:@"specid"];
            self.state            = [json objectForKey:@"state"];
            self.hasDeposit       = [json objectForKey:@"isbailcar"];
            self.sharetimes       = [json objectForKey:@"sharetimes"];
            
            // 延长质保特殊处理
            if ([json objectForKey:@"invoice"])
                self.invoice = [json objectForKey:@"invoice"];
            else
                self.invoice = [json objectForKey:@"extendedrepair"];
            
            if (self.price.length > 0)
                self.price = [NSString stringWithFormat:@"%.2f", self.price.doubleValue];
            
            if (self.carname.length > 0)
                self.carname = self.carname.trim;
            
            if (self.mileage.length > 0)
                self.mileage = [NSString stringWithFormat:@"%.2f", self.mileage.doubleValue];
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.carid forKey:@"carid"];
    [aCoder encodeObject:self.carname forKey:@"carname"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeObject:self.cname forKey:@"cname"];
    [aCoder encodeObject:self.creditid forKey:@"creditid"];
    [aCoder encodeObject:self.dealertype forKey:@"dealertype"];
    [aCoder encodeObject:self.goodcarofpic forKey:@"goodcarofpic"];
    [aCoder encodeObject:self.haswarranty forKey:@"haswarranty"];
    [aCoder encodeObject:self.haswarrantydate forKey:@"haswarrantydate"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.isNew forKey:@"isNew"];
    [aCoder encodeObject:self.isnewcar forKey:@"isnewcar"];
    [aCoder encodeObject:self.isoutsite forKey:@"isoutsite"];
    [aCoder encodeObject:self.mileage forKey:@"mileage"];
    [aCoder encodeObject:self.pdate forKey:@"pdate"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.pname forKey:@"pname"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.publishdate forKey:@"publishdate"];
    [aCoder encodeObject:self.registrationdate forKey:@"registrationdate"];
    [aCoder encodeObject:self.sourceid forKey:@"sourceid"];
    [aCoder encodeObject:self.specid forKey:@"specid"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.invoice forKey:@"invoice"];
    [aCoder encodeObject:self.hasDeposit forKey:@"isbailcar"];
    [aCoder encodeObject:self.sharetimes forKey:@"sharetimes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.carid            = [aDecoder decodeObjectForKey:@"carid"];
        self.carname          = [aDecoder decodeObjectForKey:@"carname"];
        self.cid              = [aDecoder decodeObjectForKey:@"cid"];
        self.cname            = [aDecoder decodeObjectForKey:@"cname"];
        self.creditid         = [aDecoder decodeObjectForKey:@"creditid"];
        self.dealertype       = [aDecoder decodeObjectForKey:@"dealertype"];
        self.goodcarofpic     = [aDecoder decodeObjectForKey:@"goodcarofpic"];
        self.haswarranty      = [aDecoder decodeObjectForKey:@"haswarranty"];
        self.haswarrantydate  = [aDecoder decodeObjectForKey:@"haswarrantydate"];
        self.image            = [aDecoder decodeObjectForKey:@"image"];
        self.isNew            = [aDecoder decodeObjectForKey:@"isNew"];
        self.isnewcar         = [aDecoder decodeObjectForKey:@"isnewcar"];
        self.isoutsite        = [aDecoder decodeObjectForKey:@"isoutsite"];
        self.mileage          = [aDecoder decodeObjectForKey:@"mileage"];
        self.pdate            = [aDecoder decodeObjectForKey:@"pdate"];
        self.pid              = [aDecoder decodeObjectForKey:@"pid"];
        self.pname            = [aDecoder decodeObjectForKey:@"pname"];
        self.price            = [aDecoder decodeObjectForKey:@"price"];
        self.publishdate      = [aDecoder decodeObjectForKey:@"publishdate"];
        self.registrationdate = [aDecoder decodeObjectForKey:@"registrationdate"];
        self.sourceid         = [aDecoder decodeObjectForKey:@"sourceid"];
        self.specid           = [aDecoder decodeObjectForKey:@"specid"];
        self.state            = [aDecoder decodeObjectForKey:@"state"];
        self.invoice          = [aDecoder decodeObjectForKey:@"invoice"];
        self.hasDeposit       = [aDecoder decodeObjectForKey:@"isbailcar"];
        self.sharetimes       = [aDecoder decodeObjectForKey:@"sharetimes"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"carid : %@\n", self.carid];
    result = [result stringByAppendingFormat:@"carname : %@\n", self.carname];
    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
    result = [result stringByAppendingFormat:@"cname : %@\n", self.cname];
    result = [result stringByAppendingFormat:@"creditid : %@\n", self.creditid];
    result = [result stringByAppendingFormat:@"dealertype : %@\n", self.dealertype];
    result = [result stringByAppendingFormat:@"goodcarofpic : %@\n", self.goodcarofpic];
    result = [result stringByAppendingFormat:@"haswarranty : %@\n", self.haswarranty];
    result = [result stringByAppendingFormat:@"haswarrantydate : %@\n", self.haswarrantydate];
    result = [result stringByAppendingFormat:@"image : %@\n", self.image];
    result = [result stringByAppendingFormat:@"isNew : %@\n", self.isNew];
    result = [result stringByAppendingFormat:@"isnewcar : %@\n", self.isnewcar];
    result = [result stringByAppendingFormat:@"isoutsite : %@\n", self.isoutsite];
    result = [result stringByAppendingFormat:@"mileage : %@\n", self.mileage];
    result = [result stringByAppendingFormat:@"pdate : %@\n", self.pdate]; // 首页列表时间
    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
    result = [result stringByAppendingFormat:@"pname : %@\n", self.pname];
    result = [result stringByAppendingFormat:@"price : %@\n", self.price];
    result = [result stringByAppendingFormat:@"publishdate : %@\n", self.publishdate];
    result = [result stringByAppendingFormat:@"registrationdate : %@\n", self.registrationdate];
    result = [result stringByAppendingFormat:@"sourceid : %@\n", self.sourceid];
    result = [result stringByAppendingFormat:@"specid : %@\n", self.specid];
    result = [result stringByAppendingFormat:@"state  : %@\n", self.state]; // 销售线索车源状态
    result = [result stringByAppendingFormat:@"invoice  : %@\n", self.invoice];
    result = [result stringByAppendingFormat:@"hasDeposit  : %@\n", self.hasDeposit];
    result = [result stringByAppendingFormat:@"sharetimes  : %@\n", self.sharetimes];
    return result;
}

- (UCCarInfoModel *)initWithFavoriteModel:(UCFavoritesModel *)mFavorite
{
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] init];
    mCarInfo.publishdate = mFavorite.publishDate;
    mCarInfo.price = [NSString stringWithFormat:@"%@", mFavorite.price];
    mCarInfo.image = [NSString stringWithFormat:@"%@", mFavorite.image];
    mCarInfo.registrationdate = [NSString stringWithFormat:@"%@", mFavorite.registrationDate];
    mCarInfo.carname = [NSString stringWithFormat:@"%@", mFavorite.name];
    mCarInfo.mileage = [NSString stringWithFormat:@"%@", mFavorite.mileage];
    mCarInfo.carid = [NSNumber numberWithInteger:[mFavorite.quoteID integerValue]];
    mCarInfo.sourceid = [NSNumber numberWithInteger:[mFavorite.isDealer integerValue]];
    mCarInfo.isnewcar = [NSNumber numberWithInteger:[mFavorite.isnewcar integerValue]];
    mCarInfo.invoice = [NSNumber numberWithInteger:[mFavorite.invoice integerValue]];
//#warning 待完善 和收藏有关，需要优化处理
//    // 9,在售 5,已售
//    mCarInfo.dealertype
//    //0,表示无图 1,表示有图
//    mCarInfo.goodcarofpic
    
    return mCarInfo;
}

- (UCCarInfoModel *)initWithFavoriteCloudModel:(UCFavoritesCloudModel *)mFavorite{
    
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] init];
    mCarInfo.publishdate = mFavorite.publishdate;
    mCarInfo.price = mFavorite.price;
    mCarInfo.image = mFavorite.image;
    mCarInfo.registrationdate = mFavorite.registrationdate;
    mCarInfo.carname = mFavorite.carname;
    mCarInfo.mileage = mFavorite.mileage;
    mCarInfo.carid = mFavorite.carid;
    mCarInfo.sourceid = mFavorite.sourceid;
    mCarInfo.isnewcar = mFavorite.isnewcar;
    mCarInfo.state = mFavorite.state;
    mCarInfo.specid = mFavorite.specid;
    
//    mCarInfo.invoice = [NSNumber numberWithInteger:[mFavorite.invoice integerValue]];
    //#warning 待完善 和收藏有关，需要优化处理
    //    // 9,在售 5,已售
    //    mCarInfo.dealertype
    //    //0,表示无图 1,表示有图
    //    mCarInfo.goodcarofpic
    
    return mCarInfo;
}

- (UCCarInfoModel *)initWithCarInfoEditModelModel:(UCCarInfoEditModel *)mCarInfoEdit{
    
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] init];
    mCarInfo.carid = mCarInfoEdit.carid;
    mCarInfo.carname = mCarInfoEdit.carname;
    mCarInfo.cid = mCarInfoEdit.cityid;
    mCarInfo.cname = mCarInfoEdit.cityidText;
    mCarInfo.pid = mCarInfoEdit.provinceid;
    mCarInfo.pname = mCarInfoEdit.provinceidText;
    mCarInfo.specid = mCarInfoEdit.productid;
    mCarInfo.price = mCarInfoEdit.bookprice.stringValue;
    NSArray *arrThumbs = [mCarInfoEdit.thumbimgurls componentsSeparatedByString:@","];
    if (arrThumbs.count>0) {
        mCarInfo.image = [arrThumbs firstObject];
    }
    else{
        mCarInfo.image = nil;
    }
    mCarInfo.imageLargeURLs = mCarInfoEdit.imgurls;
    mCarInfo.registrationdate = [mCarInfoEdit.firstregtime substringWithRange:NSMakeRange(0, 4)];
    mCarInfo.mileage = mCarInfoEdit.drivemileage.stringValue;
    mCarInfo.sourceid = mCarInfoEdit.carsourceid;
    mCarInfo.isnewcar = mCarInfoEdit.isnewcar;
    mCarInfo.invoice = mCarInfoEdit.extendedrepair;
//    mCarInfo.haswarranty = mCarInfoEdit.
//    mCarInfo.haswarrantydate = mCarInfoEdit
//    mCarInfo.creditid = mCarInfoEdit.
    mCarInfo.state = mCarInfoEdit.state;
    mCarInfo.dealertype = mCarInfoEdit.state;
//    mCarInfo.goodcarofpic = mCarInfoEdit.
//    mCarInfo.isNew = mCarInfoEdit
    mCarInfo.hasDeposit = mCarInfoEdit.isbailcar;
    mCarInfo.sharetimes = mCarInfoEdit.sharetimes;
    
    return mCarInfo;
}






@end