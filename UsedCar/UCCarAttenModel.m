//
//  UCCarAttenModel.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarAttenModel.h"
#import "UCAreaMode.h"
#import "UCFilterModel.h"
#import "AMCacheManage.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"
#import <objc/runtime.h>

@implementation UCCarAttenModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];
    
    if (self) {
        if (json != nil) {
            self.Name = [json objectForKey:@"Name"];
            self.areaname = [json objectForKey:@"areaname"];
            self.city = [json objectForKey:@"city"];
            self.province = [json objectForKey:@"province"];
            self.count = [json objectForKey:@"count"];
            self.attenID = [json objectForKey:@"id"];
            self.areaid = [json objectForKey:@"areaid"];
            self.pid = [json objectForKey:@"pid"];
            self.cid = [json objectForKey:@"cid"];
            self.brandid = [json objectForKey:@"brandId"];
            self.seriesid = [json objectForKey:@"seriesId"];
            self.specid = [json objectForKey:@"specId"];
            self.priceregion = [json objectForKey:@"priceregion"];
            self.mileageregion = [json objectForKey:@"mileageregion"];
            self.registeageregion = [json objectForKey:@"registeageregion"];
            self.levelid = [json objectForKey:@"levelid"];
            self.gearboxid = [json objectForKey:@"gearboxid"];
            self.color = [json objectForKey:@"color"];
            self.displacement = [json objectForKey:@"displacement"];
            self.countryid = [json objectForKey:@"countryid"];
            self.countrytype = [json objectForKey:@"countrytype"];
            self.powertrain = [json objectForKey:@"powertrain"];
            self.structure = [json objectForKey:@"structure"];
            self.sourceid = [json objectForKey:@"sourceid"];
            self.haswarranty = [json objectForKey:@"haswarranty"];
            self.extrepair = [json objectForKey:@"extrepair"];
            self.isnewcar = [json objectForKey:@"isnewcar"];
            self.dealertype = [json objectForKey:@"dealertype"];
            self.ispic = [json objectForKey:@"ispic"];
            self.lastdate = [json objectForKey:@"lastdate"];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Name forKey:@"Name"];
    [aCoder encodeObject:self.areaname forKey:@"areaname"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.province forKey:@"province"];
    [aCoder encodeObject:self.count forKey:@"count"];
    [aCoder encodeObject:self.attenID forKey:@"attenID"];
    [aCoder encodeObject:self.areaid forKey:@"areaid"];
    [aCoder encodeObject:self.pid forKey:@"pid"];
    [aCoder encodeObject:self.cid forKey:@"cid"];
    [aCoder encodeObject:self.brandid forKey:@"brandid"];
    [aCoder encodeObject:self.seriesid forKey:@"seriesid"];
    [aCoder encodeObject:self.specid forKey:@"specid"];
    [aCoder encodeObject:self.priceregion forKey:@"priceregion"];
    [aCoder encodeObject:self.mileageregion forKey:@"mileageregion"];
    [aCoder encodeObject:self.registeageregion forKey:@"registeageregion"];
    [aCoder encodeObject:self.levelid forKey:@"levelid"];
    [aCoder encodeObject:self.gearboxid forKey:@"gearboxid"];
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.displacement forKey:@"displacement"];
    [aCoder encodeObject:self.countryid forKey:@"countryid"];
    [aCoder encodeObject:self.countrytype forKey:@"countrytype"];
    [aCoder encodeObject:self.powertrain forKey:@"powertrain"];
    [aCoder encodeObject:self.structure forKey:@"structure"];
    [aCoder encodeObject:self.sourceid forKey:@"sourceid"];
    [aCoder encodeObject:self.haswarranty forKey:@"haswarranty"];
    [aCoder encodeObject:self.extrepair forKey:@"extrepair"];
    [aCoder encodeObject:self.isnewcar forKey:@"isnewcar"];
    [aCoder encodeObject:self.dealertype forKey:@"dealertype"];
    [aCoder encodeObject:self.ispic forKey:@"ispic"];
    [aCoder encodeObject:self.lastdate forKey:@"lastdate"];
    
    [aCoder encodeObject:self.brandidText forKey:@"brandidText"];
    [aCoder encodeObject:self.seriesidText forKey:@"seriesidText"];
    [aCoder encodeObject:self.specidText forKey:@"specidText"];
    [aCoder encodeObject:self.priceregionText forKey:@"priceregionText"];
    [aCoder encodeObject:self.mileageregionText forKey:@"mileageregionText"];
    [aCoder encodeObject:self.registeageregionText forKey:@"registeageregionText"];
    [aCoder encodeObject:self.levelidText forKey:@"levelidText"];
    [aCoder encodeObject:self.gearboxidText forKey:@"gearboxidText"];
    [aCoder encodeObject:self.colorText forKey:@"colorText"];
    [aCoder encodeObject:self.displacementText forKey:@"displacementText"];
    [aCoder encodeObject:self.countryidText forKey:@"countryidText"];
    [aCoder encodeObject:self.countrytypeText forKey:@"countrytypeText"];
    [aCoder encodeObject:self.powertrainText forKey:@"powertrainText"];
    [aCoder encodeObject:self.structureText forKey:@"structureText"];
    [aCoder encodeObject:self.sourceidText forKey:@"sourceidText"];
    [aCoder encodeObject:self.haswarrantyText forKey:@"haswarrantyText"];
    [aCoder encodeObject:self.extrepairText forKey:@"extrepairText"];
    [aCoder encodeObject:self.isnewcarText forKey:@"isnewcarText"];
    [aCoder encodeObject:self.dealertypeText forKey:@"dealertypeText"];
    [aCoder encodeObject:self.ispicText forKey:@"ispicText"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.Name = [aDecoder decodeObjectForKey:@"Name"];
        self.count = [aDecoder decodeObjectForKey:@"areaName"];
        self.attenID = [aDecoder decodeObjectForKey:@"city"];
        self.areaid = [aDecoder decodeObjectForKey:@"province"];
        self.count = [aDecoder decodeObjectForKey:@"count"];
        self.attenID = [aDecoder decodeObjectForKey:@"attenID"];
        self.areaid = [aDecoder decodeObjectForKey:@"areaid"];
        self.pid = [aDecoder decodeObjectForKey:@"pid"];
        self.cid = [aDecoder decodeObjectForKey:@"cid"];
        self.brandid = [aDecoder decodeObjectForKey:@"brandid"];
        self.seriesid = [aDecoder decodeObjectForKey:@"seriesid"];
        self.specid = [aDecoder decodeObjectForKey:@"specid"];
        self.priceregion = [aDecoder decodeObjectForKey:@"priceregion"];
        self.mileageregion = [aDecoder decodeObjectForKey:@"mileageregion"];
        self.registeageregion = [aDecoder decodeObjectForKey:@"registeageregion"];
        self.levelid = [aDecoder decodeObjectForKey:@"levelid"];
        self.gearboxid = [aDecoder decodeObjectForKey:@"gearboxid"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        self.displacement = [aDecoder decodeObjectForKey:@"displacement"];
        self.countryid = [aDecoder decodeObjectForKey:@"countryid"];
        self.countrytype = [aDecoder decodeObjectForKey:@"countrytype"];
        self.powertrain = [aDecoder decodeObjectForKey:@"powertrain"];
        self.structure = [aDecoder decodeObjectForKey:@"structure"];
        self.sourceid = [aDecoder decodeObjectForKey:@"sourceid"];
        self.haswarranty = [aDecoder decodeObjectForKey:@"haswarranty"];
        self.extrepair = [aDecoder decodeObjectForKey:@"extrepair"];
        self.isnewcar = [aDecoder decodeObjectForKey:@"isnewcar"];
        self.dealertype = [aDecoder decodeObjectForKey:@"dealertype"];
        self.ispic = [aDecoder decodeObjectForKey:@"ispic"];
        self.lastdate = [aDecoder decodeObjectForKey:@"lastdate"];
        
        self.brandidText = [aDecoder decodeObjectForKey:@"brandidText"];
        self.seriesidText = [aDecoder decodeObjectForKey:@"seriesidText"];
        self.specidText = [aDecoder decodeObjectForKey:@"specidText"];
        self.priceregionText = [aDecoder decodeObjectForKey:@"priceregionText"];
        self.mileageregionText = [aDecoder decodeObjectForKey:@"mileageregionText"];
        self.registeageregionText = [aDecoder decodeObjectForKey:@"registeageregionText"];
        self.levelidText = [aDecoder decodeObjectForKey:@"levelidText"];
        self.gearboxidText = [aDecoder decodeObjectForKey:@"gearboxidText"];
        self.colorText = [aDecoder decodeObjectForKey:@"colorText"];
        self.displacementText = [aDecoder decodeObjectForKey:@"displacementText"];
        self.countryidText = [aDecoder decodeObjectForKey:@"countryidText"];
        self.countrytypeText = [aDecoder decodeObjectForKey:@"countrytypeText"];
        self.powertrainText = [aDecoder decodeObjectForKey:@"powertrainText"];
        self.structureText = [aDecoder decodeObjectForKey:@"structureText"];
        self.sourceidText = [aDecoder decodeObjectForKey:@"sourceidText"];
        self.haswarrantyText = [aDecoder decodeObjectForKey:@"haswarrantyText"];
        self.extrepairText = [aDecoder decodeObjectForKey:@"extrepairText"];
        self.isnewcarText = [aDecoder decodeObjectForKey:@"isnewcarText"];
        self.dealertypeText = [aDecoder decodeObjectForKey:@"dealertypeText"];
        self.ispicText = [aDecoder decodeObjectForKey:@"ispicText"];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"Name : %@\n", self.Name];
    result = [result stringByAppendingFormat:@"areaname : %@\n", self.areaname];
    result = [result stringByAppendingFormat:@"city : %@\n", self.city];
    result = [result stringByAppendingFormat:@"province : %@\n", self.province];
    result = [result stringByAppendingFormat:@"count : %@\n", self.count];
    result = [result stringByAppendingFormat:@"attenID : %@\n", self.attenID];
    result = [result stringByAppendingFormat:@"areaid : %@\n", self.areaid];
    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
    result = [result stringByAppendingFormat:@"brandid : %@\n", self.brandid];
    result = [result stringByAppendingFormat:@"seriesid : %@\n", self.seriesid];
    result = [result stringByAppendingFormat:@"specid : %@\n", self.specid];
    result = [result stringByAppendingFormat:@"priceregion : %@\n", self.priceregion];
    result = [result stringByAppendingFormat:@"mileageregion : %@\n", self.mileageregion];
    result = [result stringByAppendingFormat:@"registeageregion : %@\n", self.registeageregion];
    result = [result stringByAppendingFormat:@"levelid : %@\n", self.levelid];
    result = [result stringByAppendingFormat:@"gearboxid : %@\n", self.gearboxid];
    result = [result stringByAppendingFormat:@"color : %@\n", self.color];
    result = [result stringByAppendingFormat:@"displacement : %@\n", self.displacement];
    result = [result stringByAppendingFormat:@"countryid : %@\n", self.countryid];
    result = [result stringByAppendingFormat:@"countrytype : %@\n", self.countrytype];
    result = [result stringByAppendingFormat:@"powertrain : %@\n", self.powertrain];
    result = [result stringByAppendingFormat:@"structure : %@\n", self.structure];
    result = [result stringByAppendingFormat:@"sourceid : %@\n", self.sourceid];
    result = [result stringByAppendingFormat:@"haswarranty : %@\n", self.haswarranty];
    result = [result stringByAppendingFormat:@"extrepair : %@\n", self.extrepair];
    result = [result stringByAppendingFormat:@"isnewcar : %@\n", self.isnewcar];
    result = [result stringByAppendingFormat:@"dealertype : %@\n", self.dealertype];
    result = [result stringByAppendingFormat:@"ispic : %@\n", self.ispic];
    result = [result stringByAppendingFormat:@"lastdate : %@\n", self.lastdate];
    
    result = [result stringByAppendingFormat:@"brandidText : %@\n", self.brandidText];
    result = [result stringByAppendingFormat:@"seriesidText : %@\n", self.seriesidText];
    result = [result stringByAppendingFormat:@"specidText : %@\n", self.specidText];
    result = [result stringByAppendingFormat:@"priceregionText : %@\n", self.priceregionText];
    result = [result stringByAppendingFormat:@"mileageregionText : %@\n", self.mileageregionText];
    result = [result stringByAppendingFormat:@"registeageregionText : %@\n", self.registeageregionText];
    result = [result stringByAppendingFormat:@"levelidText : %@\n", self.levelidText];
    result = [result stringByAppendingFormat:@"gearboxidText : %@\n", self.gearboxidText];
    result = [result stringByAppendingFormat:@"colorText : %@\n", self.colorText];
    result = [result stringByAppendingFormat:@"displacementText : %@\n", self.displacementText];
    result = [result stringByAppendingFormat:@"countryidText : %@\n", self.countryidText];
    result = [result stringByAppendingFormat:@"countrytypeText : %@\n", self.countrytypeText];
    result = [result stringByAppendingFormat:@"powertrainText : %@\n", self.powertrainText];
    result = [result stringByAppendingFormat:@"structureText : %@\n", self.structureText];
    result = [result stringByAppendingFormat:@"sourceidText : %@\n", self.sourceidText];
    result = [result stringByAppendingFormat:@"haswarrantyText : %@\n", self.haswarrantyText];
    result = [result stringByAppendingFormat:@"extrepairText : %@\n", self.extrepairText];
    result = [result stringByAppendingFormat:@"isnewcarText : %@\n", self.isnewcarText];
    result = [result stringByAppendingFormat:@"dealertypeText : %@\n", self.dealertypeText];
    result = [result stringByAppendingFormat:@"ispicText : %@\n", self.ispicText];
    
    return result;
}

- (void)setAreaValue:(UCAreaMode *)mArea
{
    self.areaid = mArea.areaid.length > 0 ? [NSNumber numberWithInteger:mArea.areaid.integerValue] : nil;
    self.areaname = mArea.areaName.length > 0 ? mArea.areaName : @"";
    self.pid = mArea.pid.length > 0 ? [NSNumber numberWithInteger:mArea.pid.integerValue] : nil;
    self.province = mArea.pName.length > 0 ? mArea.pName : @"";
    self.cid = mArea.cid.length > 0 ? [NSNumber numberWithInteger:mArea.cid.integerValue] : nil;
    self.city = mArea.cName.length > 0 ? mArea.cName : @"";
}

- (void)setFilterValue:(UCFilterModel *)mFilter
{
    self.brandid = mFilter.brandid;
    self.seriesid = mFilter.seriesid;
    self.specid = mFilter.specid;
    self.priceregion = mFilter.priceregion;
    self.mileageregion = mFilter.mileageregion;
    self.registeageregion = mFilter.registeageregion;
    self.levelid = mFilter.levelid;
    self.gearboxid = mFilter.gearboxid;
    self.color = mFilter.color;
    self.displacement = mFilter.displacement;
    self.countryid = mFilter.countryid;
    self.countrytype = mFilter.countrytype;
    self.powertrain = mFilter.powertrain;
    self.structure = mFilter.structure;
    self.sourceid = mFilter.sourceid;
    self.haswarranty = mFilter.haswarranty;
    self.extrepair = mFilter.extrepair;
    self.isnewcar = mFilter.isnewcar;
    self.dealertype = mFilter.dealertype;
    self.ispic = mFilter.ispic;
}

- (void)setTextValue
{
    // 筛选条件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *colors = values[@"FilterColors"];
    NSArray *county = values[@"County"];
    NSArray *countrytype = values[@"Property"];
    NSArray *displacement = values[@"Displacement"];
    NSArray *levels = values[@"FilterLevels"];
    NSArray *powertrain = values[@"FilterDrive"];
    NSArray *sources = values[@"Source"];
    NSArray *structures = values[@"Structure"];
    // 颜色
    if (self.color.intValue > 0)
        self.colorText = [[colors objectAtIndex:self.color.integerValue - 1] objectForKey:@"Name"];
    
    // 国别
    if (self.countryid.intValue > 0) {
        for (NSDictionary *dicTemp in county) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == [self.countryid integerValue]) {
                self.countryidText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 属性
    if (self.countrytype.integerValue > 0) {
        for (NSDictionary *dicTemp in countrytype) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == [self.countrytype integerValue]) {
                self.countrytypeText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 排量
    if (self.displacement.length > 0) {
        for (NSDictionary *dicTemp in displacement) {
            if ([[dicTemp objectForKey:@"Value"] isEqualToString:self.displacement]) {
                self.displacementText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 变速箱
    NSArray *titles = [NSArray arrayWithObjects:@"手动挡", @"自动挡", nil];
    if (self.gearboxid.integerValue > 0 && self.gearboxid.integerValue < 3) {
        self.gearboxidText = [titles objectAtIndex:self.gearboxid.integerValue - 1];
    }
    // 原厂质保
    if (self.haswarranty && self.haswarranty.integerValue == 1)
        self.haswarrantyText = @"原厂质保";
    // 延长质保
    if (self.extrepair && self.extrepair.integerValue == 1)
        self.extrepairText = @"延长质保";
    // 多选项
    NSArray *titles2 = [NSArray arrayWithObjects:@"准新车", @"只看在售", @"只看有图", nil];
    if (self.isnewcar && self.isnewcar.integerValue == 1)
        self.isnewcarText = [titles2 objectAtIndex:0];
    if (self.dealertype && self.dealertype.integerValue == 9)
        self.dealertypeText = [titles2 objectAtIndex:1];
    if (self.ispic && self.ispic.integerValue == 1)
        self.ispicText = [titles2 objectAtIndex:2];
    // 级别
    BOOL isSUVItem = NO;
    NSArray *suvItems = [[levels objectAtIndex:6] objectForKey:@"SUVItems"];
    for (int i = 0; i < suvItems.count; i++) {
        NSDictionary *dicTemp = [suvItems objectAtIndex:i];
        if ([[dicTemp objectForKey:@"Value"] integerValue] == self.levelid.integerValue) {
            self.levelidText = [dicTemp objectForKey:@"Name"];
            isSUVItem = YES;
            break;
        }
    }
    if (self.levelid.integerValue > 0 && !isSUVItem) {
        for (NSDictionary *dicTemp in levels) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == self.levelid.integerValue) {
                self.levelidText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 里程
    if (self.mileageregion.length > 0) {
        NSArray *items = [self.mileageregion componentsSeparatedByString:@"-"];
        if (items.count == 2) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            if (min > 0 || max > 0) {
                NSString *str = nil;
                if (min == 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d万以下", max];
                if (min > 0 && max == 0)
                    str = [NSString stringWithFormat:@"%d万以上", min];
                if (min > 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d-%d万公里", min, max];
                if (str.length > 0)
                    self.mileageregionText = [NSString stringWithString:str];
            }
        }
    }
    // 驱动
    if (self.powertrain.integerValue > 0) {
        for (NSDictionary *dicTemp in powertrain) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == self.powertrain.integerValue) {
                self.powertrainText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 价格
    if (self.priceregion.length > 0) {
        NSArray *items = [self.priceregion componentsSeparatedByString:@"-"];
        if (items.count == 2) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            if (min > 0 || max > 0) {
                NSString *str = nil;
                if (min == 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d万以下", max];
                if (min > 0 && max == 0)
                    str = [NSString stringWithFormat:@"%d万以上", min];
                if (min > 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d-%d万元", min, max];
                if (str.length > 0)
                    self.priceregionText = [NSString stringWithString:str];
            }
        }
    }
    // 车龄
    if (self.registeageregion.length > 0) {
        NSArray *items = [self.registeageregion componentsSeparatedByString:@"-"];
        if (items.count == 2) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            if (min > 0 || max > 0) {
                NSString *str = nil;
                if (min == 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d年以内", max];
                if (min > 0 && max == 0)
                    str = [NSString stringWithFormat:@"%d年以内", min];
                if (min > 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d-%d年", min, max];
                if (str.length > 0)
                    self.registeageregionText = [NSString stringWithString:str];
            }
        }
    }
    // 来源
    if (self.sourceid.integerValue > 0) {
        for (NSDictionary *dicTemp in sources) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == self.sourceid.integerValue) {
                self.sourceidText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
    // 结构
    if (self.structure.integerValue > 0) {
        for (NSDictionary *dicTemp in structures) {
            if ([[dicTemp objectForKey:@"Value"] integerValue] == self.structure.integerValue) {
                self.structureText = [dicTemp objectForKey:@"Name"];
                break;
            }
        }
    }
}

// 条件数量
- (NSInteger)conditionsCount
{
    NSInteger count = 0;
    if (self.brandid.integerValue >0 || self.seriesid.integerValue > 0 || self.specid.integerValue > 0)
        count++;
    if (self.priceregion.length > 0)
        count++;
    if (self.mileageregion.length > 0)
        count++;
    if (self.registeageregion.length > 0)
        count++;
    if (self.levelid.integerValue > 0)
        count++;
    if (self.gearboxid.integerValue > 0)
        count++;
    if (self.color.integerValue > 0)
        count++;
    if (self.displacement.length > 0)
        count++;
    if (self.countryid.integerValue > 0)
        count++;
    if (self.countrytype.integerValue > 0)
        count++;
    if (self.powertrain.integerValue > 0)
        count++;
    if (self.structure.integerValue > 0)
        count++;
    if (self.sourceid.integerValue > 0)
        count++;
    if (self.haswarranty.integerValue ==1 || self.extrepair.integerValue == 1)
        count++;
    if (self.isnewcar.integerValue == 1)
        count++;
    if (self.dealertype.integerValue == 9)
        count++;
    if (self.ispic.integerValue > 0)
        count++;
    return count;
}



//- (id)initWithJson:(NSDictionary *)json;
//{
//    self = [super init];
//
//    if (self) {
//        if (json != nil) {
//            self.attenId = [json objectForKey:@"id"];
//            self.carLogo = [json objectForKey:@"logo"];
//            self.carName = [json objectForKey:@"Name"];
//            self.seriesid = [json objectForKey:@"seriesId"];
//            self.specid = [json objectForKey:@"specId"];
//            self.brandid = [json objectForKey:@"brandId"];
//            self.count = [json objectForKey:@"count"];
//            self.pid = [json objectForKey:@"pid"];
//            self.cid = [json objectForKey:@"cid"];
//            self.areaid = [json objectForKey:@"areaid"];
//            self.city = [json objectForKey:@"city"];
//            self.province = [json objectForKey:@"province"];
//        }
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.attenId forKey:@"id"];
//    [aCoder encodeObject:self.carLogo forKey:@"logo"];
//    [aCoder encodeObject:self.carName forKey:@"Name"];
//    [aCoder encodeObject:self.seriesid forKey:@"seriesId"];
//    [aCoder encodeObject:self.specid forKey:@"specId"];
//    [aCoder encodeObject:self.brandid forKey:@"brandId"];
//    [aCoder encodeObject:self.count forKey:@"count"];
//    [aCoder encodeObject:self.pid forKey:@"pid"];
//    [aCoder encodeObject:self.cid forKey:@"cid"];
//    [aCoder encodeObject:self.areaid forKey:@"areaid"];
//    [aCoder encodeObject:self.city forKey:@"city"];
//    [aCoder encodeObject:self.province forKey:@"province"];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    
//    if (self) {
//        self.attenId = [aDecoder decodeObjectForKey:@"id"];
//        self.carLogo = [aDecoder decodeObjectForKey:@"logo"];
//        self.carName = [aDecoder decodeObjectForKey:@"carName"];
//        self.seriesid = [aDecoder decodeObjectForKey:@"seriesId"];
//        self.specid = [aDecoder decodeObjectForKey:@"specId"];
//        self.brandid = [aDecoder decodeObjectForKey:@"brandId"];
//        self.count = [aDecoder decodeObjectForKey:@"count"];
//        self.pid = [aDecoder decodeObjectForKey:@"pid"];
//        self.cid = [aDecoder decodeObjectForKey:@"cid"];
//        self.areaid = [aDecoder decodeObjectForKey:@"areaid"];
//        self.city = [aDecoder decodeObjectForKey:@"city"];
//        self.province = [aDecoder decodeObjectForKey:@"province"];
//    }
//    
//    return self;
//}
//
//- (NSString *)description
//{
//    NSString *result = @"";
//    result = [result stringByAppendingFormat:@"id : %@\n", self.attenId];
//    result = [result stringByAppendingFormat:@"logo : %@\n", self.carLogo];
//    result = [result stringByAppendingFormat:@"carName : %@\n", self.carName];
//    result = [result stringByAppendingFormat:@"seriesId : %@\n", self.seriesid];
//    result = [result stringByAppendingFormat:@"specid : %@\n", self.specid];
//    result = [result stringByAppendingFormat:@"count : %@\n", self.count];
//    result = [result stringByAppendingFormat:@"pid : %@\n", self.pid];
//    result = [result stringByAppendingFormat:@"cid : %@\n", self.cid];
//    result = [result stringByAppendingFormat:@"areaid : %@\n", self.areaid];
//    result = [result stringByAppendingFormat:@"city : %@\n", self.city];
//    result = [result stringByAppendingFormat:@"province : %@\n", self.province];
//    
//    return result;
//}

@end
