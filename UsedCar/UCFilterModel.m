//
//  JsonToModel
//
//  Created by Alan on 13-7-18.
//  Copyright (c) 2013年 Ancool. All rights reserved.
//

#import "UCFilterModel.h"
#import "UCCarAttenModel.h"
#import "AMCacheManage.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"

@implementation UCFilterModel

- (id)initWithJson:(NSDictionary *)json;
{
    self = [super init];

    if (self) {
        if (json != nil) {
            self.brandid = [json objectForKey:@"brandid"];
            self.seriesid = [json objectForKey:@"seriesid"];
            self.specid = [json objectForKey:@"specid"];
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
            
            // 筛选条件
            NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
            NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
            NSArray *registeageregionValues = values[@"Registeageregions"];
            NSArray *levelValues = values[@"Levels"];
            NSArray *sourceValues = values[@"Sources"];
            NSArray *gearboxValues = values[@"Gearbox"];
            NSArray *prices = values[@"Prices"];
            NSArray *mileages = values[@"Mileages"];
            NSArray *state = values[@"state"];
            
            self.priceregionText = [prices objectAtIndex:[self.priceregion integerValue]];
            self.mileageregionText = [mileages objectAtIndex:[self.mileageregion integerValue]];
            self.registeageregionText = [registeageregionValues objectAtIndex:[self.registeageregion integerValue]];
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

            self.sourceidText = [sourceValues objectAtIndex:[self.sourceid integerValue]];
            self.gearboxidText = [gearboxValues objectAtIndex:[self.gearboxid integerValue]];
            self.dealertypeText = [state objectAtIndex:[self.dealertype integerValue]];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
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


- (id)copyWithZone:(NSZone *)zone
{
    UCFilterModel *result = [[[self class] allocWithZone:zone] init];
    
    result->_brandid = [self->_brandid copy];
    result->_seriesid = [self->_seriesid copy];
    result->_specid = [self->_specid copy];
    result->_priceregion = [self->_priceregion copy];
    result->_mileageregion = [self->_mileageregion copy];
    result->_registeageregion = [self->_registeageregion copy];
    result->_levelid = [self->_levelid copy];
    result->_gearboxid = [self->_gearboxid copy];
    result->_color = [self->_color copy];
    result->_displacement = [self->_displacement copy];
    result->_countryid = [self->_countryid copy];
    result->_countrytype = [self->_countrytype copy];
    result->_powertrain = [self->_powertrain copy];
    result->_structure = [self->_structure copy];
    result->_sourceid = [self->_sourceid copy];
    result->_haswarranty = [self->_haswarranty copy];
    result->_extrepair = [self->_extrepair copy];
    result->_isnewcar = [self->_isnewcar copy];
    result->_dealertype = [self->_dealertype copy];
    result->_ispic = [self->_ispic copy];
    
    result->_brandidText = [self->_brandidText copy];
    result->_seriesidText = [self->_seriesidText copy];
    result->_specidText = [self->_specidText copy];
    result->_priceregionText = [self->_priceregionText copy];
    result->_mileageregionText = [self->_mileageregionText copy];
    result->_registeageregionText = [self->_registeageregionText copy];
    result->_levelidText = [self->_levelidText copy];
    result->_gearboxidText = [self->_gearboxidText copy];
    result->_colorText = [self->_colorText copy];
    result->_displacementText = [self->_displacementText copy];
    result->_countryidText = [self->_countryidText copy];
    result->_countrytypeText = [self->_countrytypeText copy];
    result->_powertrainText = [self->_powertrainText copy];
    result->_structureText = [self->_structureText copy];
    result->_sourceidText = [self->_sourceidText copy];
    result->_haswarrantyText = [self->_haswarrantyText copy];
    result->_extrepairText = [self->_extrepairText copy];
    result->_isnewcarText = [self->_isnewcarText copy];
    result->_dealertypeText = [self->_dealertypeText copy];
    result->_ispicText = [self->_ispicText copy];
    
    
    
    return result;
}


- (BOOL)isNull
{
    if (self.brandid.length == 0
        &&self.seriesid.length == 0
        &&self.specid.length == 0
        &&self.priceregion.length == 0
        &&self.mileageregion.length == 0
        &&self.registeageregion.length == 0
        &&self.levelid == nil
        &&self.gearboxid == nil
        &&self.color == nil
        &&self.displacement.length == 0
        &&self.countryid.length == 0
        &&self.countrytype == nil
        &&self.powertrain == nil
        &&self.structure == nil
        &&self.sourceid == nil
        &&self.haswarranty == nil
        &&self.extrepair == nil
        &&self.isnewcar.length == 0
        &&self.dealertype == nil
        &&self.ispic.length == 0)
        return YES;
    else
        return NO;
}

- (BOOL)isEqualToFilter:(UCFilterModel *)mFilter
{
    NSInteger levelid1, levelid2, gearboxid1, gearboxid2, color1, color2, countrytype1, countrytype2, powertrain1, powertrain2, structure1, structure2, sourceid1, sourceid2, haswarranty1, haswarranty2, extrepair1, extrepair2,
    dealertype1, dealertype2;
    
    levelid1 = self.levelid ? [self.levelid integerValue] : -1;
    levelid2 = mFilter.levelid ? [mFilter.levelid integerValue] : -1;
    gearboxid1 = self.gearboxid ? [self.gearboxid integerValue] : -1;
    gearboxid2 = mFilter.gearboxid ? [mFilter.gearboxid integerValue] : -1;
    color1 = self.color ? [self.color integerValue] : -1;
    color2 = mFilter.color ? [mFilter.color integerValue] : -1;
    countrytype1 = self.countrytype ? [self.countrytype integerValue] : -1;
    countrytype2 = mFilter.countrytype ? [mFilter.countrytype integerValue] : -1;
    powertrain1 = self.powertrain ? [self.powertrain integerValue] : -1;
    powertrain2 = mFilter.powertrain ? [mFilter.powertrain integerValue] : -1;
    structure1 = self.structure ? [self.structure integerValue] : -1;
    structure2 = mFilter.structure ? [mFilter.structure integerValue] : -1;
    sourceid1 = self.sourceid ? [self.sourceid integerValue] : -1;
    sourceid2 = mFilter.sourceid ? [mFilter.sourceid integerValue] : -1;
    haswarranty1 = self.haswarranty ? [self.haswarranty integerValue] : -1;
    haswarranty2 = mFilter.haswarranty ? [mFilter.haswarranty integerValue] : -1;
    extrepair1 = self.extrepair ? [self.extrepair integerValue] : -1;
    extrepair2 = mFilter.extrepair ? [mFilter.extrepair integerValue] : -1;
    dealertype1 = self.dealertype ? [self.dealertype integerValue] : -1;
    dealertype2 = mFilter.dealertype ? [mFilter.dealertype integerValue] : -1;
    
    if ((self.brandid == mFilter.brandid || [self.brandid isEqualToString:mFilter.brandid])
        &&(self.seriesid == mFilter.seriesid || [self.seriesid isEqualToString:mFilter.seriesid])
        &&(self.specid == mFilter.specid || [self.specid isEqualToString:mFilter.specid])
        &&(self.priceregion == mFilter.priceregion || [self.priceregion isEqualToString:mFilter.priceregion])
        &&(self.mileageregion == mFilter.mileageregion || [self.mileageregion isEqualToString:mFilter.mileageregion])
        &&(self.registeageregion == mFilter.registeageregion || [self.registeageregion isEqualToString:mFilter.registeageregion])
        &&(self.levelid == mFilter.levelid || levelid1 == levelid2)
        &&(self.gearboxid == mFilter.gearboxid || gearboxid1 == gearboxid2)
        &&(self.color == mFilter.color || color1 == color2)
        &&(self.displacement == mFilter.displacement || [self.displacement isEqualToString:mFilter.displacement])
        &&(self.countryid == mFilter.countryid || [self.countryid isEqualToString:mFilter.countryid])
        &&(self.countrytype == mFilter.countrytype || countrytype1 == countrytype2)
        &&(self.powertrain == mFilter.powertrain || powertrain1 == powertrain2)
        &&(self.structure == mFilter.structure || structure1 == structure2)
        &&(self.sourceid == mFilter.sourceid || sourceid1 == sourceid2)
        &&(self.haswarranty == mFilter.haswarranty || haswarranty1 == haswarranty2)
        &&(self.extrepair == mFilter.extrepair || extrepair1 == extrepair2)
        &&(self.isnewcar == mFilter.isnewcar || [self.isnewcar isEqualToString:mFilter.isnewcar])
        &&(self.dealertype == mFilter.dealertype || dealertype1 == dealertype2)
        &&(self.ispic == mFilter.ispic || [self.ispic isEqualToString:mFilter.ispic])
        )
        return YES;
    else
        return NO;
}

- (NSInteger)conditionCount
{
    NSInteger count = 0;
    if (self.brandid.length > 0 || self.seriesid.length > 0 || self.specid.length > 0) count++;
    if (self.priceregion.length > 0) count++;
    if (self.mileageregion.length > 0) count++;
    if (self.registeageregion.length > 0) count++;
    if (self.levelid) count++;
    if (self.gearboxid) count++;
    if (self.color) count++;
    if (self.displacement.length > 0) count++;
    if (self.countryid.length > 0) count++;
    if (self.countrytype) count++;
    if (self.powertrain) count++;
    if (self.structure) count++;
    if (self.sourceid) count++;
    if (self.haswarranty) count++;
    if (self.extrepair) count++;
    if (self.isnewcar.length > 0) count++;
    if (self.dealertype) count++;
    if (self.ispic.length > 0) count++;
    
    return count;
}

- (void)convertFromAttentionModel:(UCCarAttenModel *)mAtten
{
    // 品牌
    if (mAtten.brandid && mAtten.brandid.integerValue > 0) {
        self.brandid = [NSString stringWithFormat:@"%@", mAtten.brandid];
        
        NSArray *brand = [AMCacheManage selectFrome:@"CarBrand" where:@"BrandId" equalValue:[NSString stringWithFormat:@"%@", mAtten.brandid]];
        if (brand.count > 0)
            self.brandidText = ([[UCCarBrandModel alloc] initWithJson:[brand objectAtIndex:0]]).name;
    }
    // 车系
    if (mAtten.seriesid && mAtten.seriesid.integerValue > 0) {
        self.seriesid = [NSString stringWithFormat:@"%@", mAtten.seriesid];
        
        NSArray *series = [AMCacheManage selectFrome:@"CarSeries" where:@"SeriesId" equalValue:[NSString stringWithFormat:@"%@", mAtten.seriesid]];
        if (series.count > 0)
            self.seriesidText = ([[UCCarSeriesModel alloc] initWithJson:[series objectAtIndex:0]]).name;
    }
    // 车型
    if (mAtten.specid && mAtten.specid.integerValue > 0) {
        self.specid = [NSString stringWithFormat:@"%@", mAtten.specid];
        
        NSArray *spec = [AMCacheManage selectFrome:@"CarSpec" where:@"SpecId" equalValue:[NSString stringWithFormat:@"%@", mAtten.specid]];
        if (spec.count > 0)
            self.specidText = ([[UCCarSpecModel alloc] initWithJson:[spec objectAtIndex:0]]).name;
    }
    if (mAtten.priceregion && mAtten.priceregion.length > 0)
        self.priceregion = [NSString stringWithFormat:@"%@", mAtten.priceregion];
    if (mAtten.mileageregion && mAtten.mileageregion.length > 0) {
        self.mileageregion = [NSString stringWithFormat:@"%@", mAtten.mileageregion];
        NSArray *items = [mAtten.mileageregion componentsSeparatedByString:@"-"];
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
                    str = [NSString stringWithFormat:@"%d-%d万", min, max];
                if (str.length > 0)
                    self.mileageregionText = [NSString stringWithString:str];
            }
        }
    }
    // 车龄
    if (mAtten.registeageregion && mAtten.registeageregion.length > 0) {
        self.registeageregion = [NSString stringWithFormat:@"%@", mAtten.registeageregion];
        
        NSArray *items = [mAtten.registeageregion componentsSeparatedByString:@"-"];
        if (items.count == 2) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            if (min > 0 || max > 0) {
                NSString *str = nil;
                if (min == 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d年以下", max];
                if (min > 0 && max == 0)
                    str = [NSString stringWithFormat:@"%d年以上", min];
                if (min > 0 && max > 0)
                    str = [NSString stringWithFormat:@"%d-%d年", min, max];
                if (str.length > 0)
                    self.registeageregionText = [NSString stringWithString:str];
            }
        }
    }
    if (mAtten.levelid && mAtten.levelid.integerValue > 0) {
        self.levelid = [NSNumber numberWithInteger:[mAtten.levelid integerValue]];
        self.levelidText = mAtten.levelidText;
    }
    if (mAtten.gearboxid && mAtten.gearboxid.integerValue > 0) {
        self.gearboxid = [NSNumber numberWithInteger:[mAtten.gearboxid integerValue]];
        self.gearboxidText = mAtten.gearboxidText;
    }
    if (mAtten.color && mAtten.color.integerValue > 0) {
        self.color = [NSNumber numberWithInteger:[mAtten.color integerValue]];
        self.colorText = mAtten.colorText;
    }
    if (mAtten.displacement && mAtten.displacement.length > 0) {
        self.displacement = [NSString stringWithFormat:@"%@", mAtten.displacement];
        self.displacementText = mAtten.displacementText;
    }
    if (mAtten.countryid && mAtten.countryid.integerValue > 0) {
        self.countryid = [NSString stringWithFormat:@"%@", mAtten.countryid];
        self.countryidText = mAtten.countryidText;
    }
    if (mAtten.countrytype && mAtten.countrytype.integerValue > 0) {
        self.countrytype = [NSNumber numberWithInteger:[mAtten.countrytype integerValue]];
        self.countrytypeText = mAtten.countrytypeText;
    }
    if (mAtten.powertrain && mAtten.powertrain.integerValue > 0) {
        self.powertrain = [NSNumber numberWithInteger:[mAtten.powertrain integerValue]];
        self.powertrainText = mAtten.powertrainText;
    }
    if (mAtten.structure && mAtten.structure.integerValue > 0) {
        self.structure = [NSNumber numberWithInteger:[mAtten.structure integerValue]];
        self.structureText = mAtten.structureText;
    }
    if (mAtten.sourceid && mAtten.sourceid.integerValue > 0) {
        self.sourceid = [NSNumber numberWithInteger:[mAtten.sourceid integerValue]];
        self.sourceidText = mAtten.sourceidText;
    }
    if (mAtten.haswarranty && mAtten.haswarranty.integerValue > 0) {
        self.haswarranty = [NSNumber numberWithInteger:[mAtten.haswarranty integerValue]];
        self.haswarrantyText = mAtten.haswarrantyText;
    }
    if (mAtten.extrepair && mAtten.extrepair.integerValue > 0) {
        self.extrepair = [NSNumber numberWithInteger:[mAtten.extrepair integerValue]];
        self.extrepairText = mAtten.extrepairText;
    }
    if (mAtten.isnewcar && mAtten.isnewcar.integerValue > 0) {
        self.isnewcar = [NSString stringWithFormat:@"%@", mAtten.isnewcar];
        self.isnewcarText = mAtten.isnewcarText;
    }
    if (mAtten.dealertype && mAtten.dealertype > 0) {
        self.dealertype = [NSNumber numberWithInteger:[mAtten.dealertype integerValue]];
        self.dealertypeText = mAtten.dealertypeText;
    }
    if (mAtten.ispic && mAtten.ispic.integerValue > 0) {
        self.ispic = [NSString stringWithFormat:@"%@", mAtten.ispic];
        self.ispicText = mAtten.ispicText;
    }
}

@end