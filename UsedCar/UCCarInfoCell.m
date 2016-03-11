//
//  UCCarInfoCell.m
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCCarInfoCell.h"
#import "UCCarInfoModel.h"

@implementation UCCarInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.width = self.contentView.width = cellWidth;
        _vCellMain = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _vCellMain.backgroundColor = kColorClear;
        
        // 选中图片
        _ivSelect = [[UIImageView alloc] initLineWithFrame:CGRectMake(0, 0, 90, 67.5) color:[UIColor blueColor]];
        _ivSelect.backgroundColor = [UIColor clearColor];
        
        // 图片
        _ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 90, 67.5)];
        
        // 新旧关注 NEW 标识
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 8, 20, 10)];
        [_statusLabel setTextColor:[UIColor whiteColor]];
        [_statusLabel setBackgroundColor:kColorNewOrange];
        [_statusLabel setText:@"NEW"];
        [_statusLabel setTextAlignment:NSTextAlignmentCenter];
        [_statusLabel setFont:[UIFont systemFontOfSize:8.0]];
        [_statusLabel setHidden:YES];
        
        // 主列表车源状态
        _labCarStatus1 = [[UILabel alloc] initWithFrame:_ivCarPhoto.bounds];
        _labCarStatus1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _labCarStatus1.textColor = kColorWhite;
        _labCarStatus1.font = kFontNormal;
        _labCarStatus1.text = @"已售";
        _labCarStatus1.textAlignment = NSTextAlignmentCenter;
        
        
        // 销售线索车源状态
        _labCarStatus2 = [[UILabel alloc] initWithFrame:CGRectMake(_ivCarPhoto.width - 33, _ivCarPhoto.height - 14, 33, 14)];
        _labCarStatus2.backgroundColor = [UIColor blackColor];
        _labCarStatus2.textColor = kColorWhite;
        _labCarStatus2.font = kFontTiny;
        
        // 标题
        _labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, 8, self.contentView.width - _ivCarPhoto.maxX - 20, 18)];
        _labTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labTitle.numberOfLines = 1;
        _labTitle.font = kFontLarge;
        _labTitle.textColor = kColorNewGray1;
        _labTitle.backgroundColor = [UIColor clearColor];
        
        // 来源图标
//        _ivSource = [[UIImageView alloc] initWithFrame:CGRectMake(_labTitle.minX, _labTitle.maxY + 10, 14.5, 14.5)];
        
        // 公里数/年份
        _labText = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, _labTitle.maxY + 10, 130, 15)];
        _labText.font = kFontNormal;
        _labText.textColor = kColorNewGray2;
        _labText.backgroundColor = [UIColor clearColor];
        
        // 价格
        _labPrice = [[UILabel alloc] initWithClearFrame:CGRectMake(self.width - 7.5 - 85, _labTitle.maxY + 10, 85, 15)];
        _labPrice.textAlignment = NSTextAlignmentRight;
        _labPrice.font = kFontLarge;
        _labPrice.textColor = kColorNewOrange;
        _labPrice.backgroundColor = [UIColor clearColor];
        
        // 来源/时间
        _labSourceTime = [[UILabel alloc] initWithClearFrame:CGRectMake(_labText.minX, _labText.maxY + 10, 140, 15)];
        _labSourceTime.font = kFontTiny;
        _labSourceTime.textAlignment = NSTextAlignmentLeft;
        _labSourceTime.textColor = kColorNewGray2;
        _labSourceTime.backgroundColor = [UIColor clearColor];
        
        // 近似新车
        _ivNewCar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_car"]];
        // 延长质保
        _ivWarrantly = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"factory_warrant"]];
        // 品牌认证
        _ivApprove = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"factory_approve"]];
        // 保证金 
        _ivDeposit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deposit_icon"]];
        
//        _ivNewCar = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 25, _labTitle.maxY + 10, 14.5, 14.5)];
//        _ivNewCar.image = [UIImage imageNamed:@"new_car"];
        
//        _ivWarrantly = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 45, _labTitle.maxY + 10, 14.5, 14.5)];
//        _ivWarrantly.image = [UIImage imageNamed:@"warrant"];
        
        // 分割线
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, UCCarInfoCellHeight - kLinePixel, self.contentView.width, kLinePixel) color:kColorNewLine];
        
        
        [_vCellMain addSubview:_ivSelect];
        [_ivCarPhoto addSubview:_ivSelect];
        [_ivCarPhoto addSubview:_labCarStatus1];
        [_ivCarPhoto addSubview:_labCarStatus2];
        [_vCellMain addSubview:_ivCarPhoto];
        [_vCellMain addSubview:_statusLabel];
        [_vCellMain addSubview:_labTitle];
//        [self.contentView addSubview:_ivSource];
        [_vCellMain addSubview:_labPrice];
        [_vCellMain addSubview:_labText];
        [_vCellMain addSubview:_labSourceTime];
        [_vCellMain addSubview:vLine];
        
        [_vCellMain addSubview:_ivNewCar];
        [_vCellMain addSubview:_ivWarrantly];
        [_vCellMain addSubview:_ivApprove];
        [_vCellMain addSubview:_ivDeposit];
        
        [self.contentView addSubview:_vCellMain];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.contentView.backgroundColor = kColorNewLine;
    else
        self.contentView.backgroundColor = kColorWhite;
}

- (void)makeView:(UCCarInfoModel *)mCarInfo isShowSelect:(BOOL)isShowSelect
{
//    AMLog(@"mCarInfo %@", mCarInfo);
    // 是否显示选择框
    if (isShowSelect == YES)
        _ivSelect.hidden = NO;
    else
        _ivSelect.hidden = YES;
    
    // 0,表示无图 1,表示有图 (接口状态有误, 老版本数据有图为0)
    if (mCarInfo.image.length == 0)
        _ivCarPhoto.image = [UIImage imageNamed:@"details_nopictures_picture"];
    else
      [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:mCarInfo.image]  placeholderImage:[UIImage imageNamed:@"home_default"] animate:YES];
    
    _labTitle.text = mCarInfo.carname;
    
    _labText.text = [NSString stringWithFormat:@"%@万公里/%@年", mCarInfo.mileage, mCarInfo.registrationdate]; //@"50.00万公里/2014年";//
    _labPrice.text = [NSString stringWithFormat:@"￥%@万", mCarInfo.price] ; //@"￥1500.00万";//
    
    
    // 1.个人，2.4s,3.商家，4。贩子，22.品牌车源，23.商家品牌车源
    NSString *source = @"";
    if (mCarInfo.sourceid.integerValue == 1){
        source = @"个人";
        //        _ivSource.image = [UIImage imageNamed:@"home_personage_btn"];
    }
    else{
        source = @"商家";
        //        _ivSource.image = [UIImage imageNamed:@"home_merchant_btn"];
    }
    
    if (mCarInfo.pdate) {
        _labSourceTime.text = [source stringByAppendingFormat:@" %@", mCarInfo.pdate];
    }
    else{
        _labSourceTime.text = source;
    }
    
    // 主列表车源状态 5,已售 9,在售
    _labCarStatus1.hidden = mCarInfo.dealertype.integerValue != 5;
    
    
    // 销售线索车源状态
    if ([mCarInfo.state integerValue] > 0) {
        _labCarStatus2.hidden = NO;
        switch ([mCarInfo.state integerValue]) {
            case 1:
                _labCarStatus2.text = @"在售车";
                break;
            case 2:
                _labCarStatus2.text = @"已售车";
                break;
            case 3:
                _labCarStatus2.text = @"审核中";
                break;
            case 4:
                _labCarStatus2.text = @"未通过";
                break;
            case 5:
                _labCarStatus2.text = @"已过期";
                break;
                
            default:
                _labCarStatus2.text = @"";
                break;
        }
    } else {
        _labCarStatus2.hidden = YES;
    }
    [self refreshPic:mCarInfo];
    
}

/** 近似新车和延长质保图片显示 */
- (void)refreshPic:(UCCarInfoModel*)mCarInfo
{
//    _ivNewCar.hidden = ([mCarInfo.isnewcar integerValue] == 0);
//    _ivWarrantly.hidden = ([mCarInfo.invoice integerValue] == 0);
//    _ivWarrantly.minX = _ivNewCar.hidden ? _ivNewCar.minX : self.width - 50;
    CGFloat rightGap = 10;
    CGRect rightItemFrame = CGRectMake(self.width - rightGap - 16, _labSourceTime.minY, 16, 16);
    // 新车
    if (mCarInfo.isnewcar.integerValue == 1) {
        [_ivNewCar setFrame:rightItemFrame];
    }
    else{
        [_ivNewCar setFrame:CGRectMake(self.width-rightGap, _labSourceTime.minY, 0, 0)];
    }
    
    // 延长质保
    if(mCarInfo.haswarranty.integerValue == 1){
        [_ivWarrantly setImage:[UIImage imageNamed:@"factory_warrant"]];
        [_ivWarrantly setFrame:CGRectMake(_ivNewCar.minX-16, _labSourceTime.minY, 16, 16)];
    }
    else if (mCarInfo.haswarranty.integerValue != 1 && mCarInfo.invoice.integerValue == 1) {
        [_ivWarrantly setImage:[UIImage imageNamed:@"ext_warrant"]];
        [_ivWarrantly setFrame:CGRectMake(_ivNewCar.minX-16, _labSourceTime.minY, 16, 16)];
    }
    else{
        [_ivWarrantly setFrame:CGRectMake(_ivNewCar.minX, _labSourceTime.minY, 0, 0)];
    }
    // 认证
    if (mCarInfo.creditid.integerValue > 0) {
        [_ivApprove setFrame:CGRectMake(_ivWarrantly.minX-16, _labSourceTime.minY, 16, 16)];
    }
    else{
        [_ivApprove setFrame:CGRectMake(_ivWarrantly.minX, _labSourceTime.minY, 0, 0)];
    }
    
    // 保证金
    if (mCarInfo.hasDeposit.integerValue > 0) {
        [_ivDeposit setFrame:CGRectMake(_ivApprove.minX-16, _labSourceTime.minY, 16, 16)];
    } else {
        [_ivDeposit setFrame:CGRectMake(_ivApprove.minX, _labSourceTime.minY, 0, 0)];
    }
    
}

/** 处理图片的状态 */
- (void)setImageWithSelectedState:(NSNumber *)isShowSelect
{
    // 设置图片
    UIImage *iSelect = [UIImage imageNamed:@"cariList_selected"];
    if ([isShowSelect isEqualToNumber:[NSNumber numberWithBool:NO]])
        [_ivSelect setImage:nil];
    else
        [_ivSelect setImage:iSelect];
}

@end