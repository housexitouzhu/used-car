//
//  UCCarAttentionCell.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionCell.h"
#import "UIImageView+WebCache.h"
#import "UCCarAttenModel.h"
#import "JSBadgeView.h"
#import "NSString+Util.h"

@interface UCAttentionCell ()

@property (nonatomic, strong) UILabel *labLocation;
@property (nonatomic, strong) UILabel *labFilter;
@property (nonatomic, strong) UILabel *labBrand;
@property (nonatomic, strong) JSBadgeView *jsbCount;
@property (nonatomic, strong) UILabel *labTotalCount;
@property (nonatomic, strong) UIView *vLine;

@end

@implementation UCAttentionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.width = self.contentView.width = cellWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 图标
        UIImage *iIcon = [UIImage imageNamed:@"attention_icon"];
        UIImageView *ivIcon = [[UIImageView alloc] initWithImage:iIcon];
        ivIcon.origin = CGPointMake(10, 14);
        
        // 地点
        _labLocation = [[UILabel alloc] init];
        _labLocation.font = kFontNormal;
        _labLocation.textColor = kColorNewGray1;
        _labLocation.backgroundColor = kColorClear;

        // 数
        _jsbCount = [[JSBadgeView alloc] initWithParentView:self.contentView alignment:JSBadgeViewAlignmentCenterRight];
        _jsbCount.userInteractionEnabled = NO;
        _jsbCount.badgePositionAdjustment = CGPointMake(-29, -10);
        
        // 品牌
        _labBrand = [[UILabel alloc] initWithFrame:CGRectMake(9, 33, self.contentView.width - 60, 15)];
        _labBrand.font = kFontSmall;
        _labBrand.textColor = kColorNewGray2;
        _labBrand.backgroundColor = kColorClear;
        
        // 筛选文本
        _labFilter = [[UILabel alloc] initWithFrame:CGRectMake(9, 52, _labBrand.width, 15)];
        _labFilter.font = kFontSmall;
        _labFilter.textColor = kColorNewGray2;
        _labFilter.backgroundColor = kColorClear;
        
        // 共多少项
        _labTotalCount = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 45, 55, 80, 15)];
        _labTotalCount.textColor = _labFilter.textColor;
        _labTotalCount.font = _labFilter.font;
        _labTotalCount.backgroundColor = kColorClear;
        
        // 分割线
        _vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
        
        [self.contentView addSubview:ivIcon];
        [self.contentView addSubview:_jsbCount];
        [self.contentView addSubview:_labBrand];
        [self.contentView addSubview:_labLocation];
        [self.contentView addSubview:_labFilter];
        [self.contentView addSubview:_labTotalCount];
        [self.contentView addSubview:_vLine];
        
    }
    return self;
}

- (void)makeView:(UCCarAttenModel *)mCarInfo isShowSelect:(BOOL)isShowSelect
{
    // 地点
    NSString *strLocation = @"全国";
    if (mCarInfo.areaname.length > 0 || mCarInfo.province.length > 0 || mCarInfo.city.length > 0) {
        // 广深不显示省
        if (mCarInfo.areaid.integerValue == 300000) {
            strLocation = [NSString stringWithFormat:@"%@%@", mCarInfo.areaname.length > 0 ? [NSString stringWithFormat:@"%@ ", mCarInfo.areaname] : @"", mCarInfo.city.length > 0 ? [NSString stringWithFormat:@"%@ ", mCarInfo.city] : @""];
        } else {
            strLocation = [NSString stringWithFormat:@"%@%@%@", mCarInfo.areaname.length > 0 ? [NSString stringWithFormat:@"%@ ", mCarInfo.areaname] : @"", mCarInfo.province.length > 0 ? [NSString stringWithFormat:@"%@ ", mCarInfo.province] : @"", mCarInfo.city.length > 0 ? [NSString stringWithFormat:@"%@ ", mCarInfo.city] : @""];
        }
    }
    _labLocation.text = strLocation;
    [_labLocation sizeToFit];
    _labLocation.origin = CGPointMake(27, 12);
    
    // 个数
    NSString *strCount = nil;
    
    if (mCarInfo.count.integerValue > 0) {
        strCount = mCarInfo.count.integerValue > 99 ? @"N" : [NSString stringWithFormat:@"%d", mCarInfo.count.integerValue];
    }
    _jsbCount.badgeText = strCount;

    // 品牌
    _labBrand.text = mCarInfo.Name.length > 0 ? mCarInfo.Name : @"";
    
    // 筛选文字
    _labFilter.text = [self assembleTitleStringWithModel:mCarInfo];
    _labFilter.minY = _labBrand.text.length == 0 ? 33 : 52;
    
    // 共多少项目
    _labTotalCount.text = [NSString stringWithFormat:@"共%d项", [mCarInfo conditionsCount] + 1];
    _labTotalCount.minY = (_labBrand.text.length > 0 && _labFilter.text.length > 0) ? 52 : 33;
    
    _vLine.minY = (_labBrand.text.length > 0 && _labFilter.text.length > 0) ? 75 - kLinePixel : 60 - kLinePixel;

}

- (NSString *)assembleTitleStringWithModel:(UCCarAttenModel*)model {
    
    NSMutableString *title = [NSMutableString new];
    
    if (model.priceregionText) {
        [title appendString:@" "];
        [title appendString:model.priceregionText];
    }
    if (model.mileageregionText) {
        [title appendString:@" "];
        [title appendString:model.mileageregionText];
    }
    if (model.registeageregionText) {
        [title appendString:@" "];
        [title appendString:model.registeageregionText];
    }
    if (model.levelidText) {
        [title appendString:@" "];
        [title appendString:model.levelidText];
    }
    if (model.gearboxidText) {
        [title appendString:@" "];
        [title appendString:model.gearboxidText];
    }
    if (model.colorText) {
        [title appendString:@" "];
        [title appendString:model.colorText];
    }
    if (model.displacementText) {
        [title appendString:@" "];
        [title appendString:model.displacementText];
    }
    if (model.countryidText) {
        [title appendString:@" "];
        [title appendString:model.countryidText];
    }
    if (model.countrytypeText) {
        [title appendString:@" "];
        [title appendString:model.countrytypeText];
    }
    if (model.powertrainText) {
        [title appendString:@" "];
        [title appendString:model.powertrainText];
    }
    if (model.structureText) {
        [title appendString:@" "];
        [title appendString:model.structureText];
    }
    if (model.sourceidText) {
        [title appendString:@" "];
        [title appendString:model.sourceidText];
    }
    if (model.haswarrantyText) {
        [title appendString:@" "];
        [title appendString:model.haswarrantyText];
    }
    if (model.extrepairText) {
        [title appendString:@" "];
        [title appendString:model.extrepairText];
    }
    if (model.isnewcarText) {
        [title appendString:@" "];
        [title appendString:model.isnewcarText];
    }
    if (model.dealertypeText) {
        [title appendString:@" "];
        [title appendString:model.dealertypeText];
    }
    if (model.ispicText) {
        [title appendString:@" "];
        [title appendString:model.ispicText];
    }
    // 去首顿号
    if (title.length > 0)
        [title deleteCharactersInRange:NSMakeRange(0, 1)];
    
    return [title copy];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.contentView.backgroundColor = kColorGrey5;
    else
        self.contentView.backgroundColor = kColorWhite;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
