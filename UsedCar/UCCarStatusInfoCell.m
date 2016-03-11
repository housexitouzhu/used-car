//
//  UCCarStatusInfoCell.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCCarStatusInfoCell.h"
#import "UCCarInfoEditModel.h"
#import "UIImage+Util.h"
#import "UIImageView+WebCache.h"
#import "AreaProvinceItem.h"

@interface UCCarStatusInfoCell ()

@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labPrice;
@property (nonatomic, strong) UILabel *labArea;
@property (nonatomic, strong) UILabel *labViewCount;
@property (nonatomic, strong) UIImageView *ivBtnBg;
@property (nonatomic, strong) UIImageView *vHighlighted;

@end

@implementation UCCarStatusInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.width = self.contentView.width = cellWidth;
        
        //车信息View
        _vCarInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, UCCarStatusInfoCellHeight)];
        _vCarInfo.backgroundColor = kColorWhite;
        
        // 图片
        _ivCarPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 90, 67.5)];

        //高亮背景
        _vHighlighted = [[UIImageView alloc] initWithFrame:CGRectZero];
        _vHighlighted.backgroundColor = kColorWhite;
        
        // 标题
        _labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, 12, self.width - 110, 14)];
        _labTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        _labTitle.numberOfLines = 1;
        _labTitle.font = [UIFont systemFontOfSize:_labTitle.height];
        
        // 价格
        _labPrice = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 7, _labTitle.maxY + 10, self.width - 150, 16)];
        _labPrice.font = [UIFont boldSystemFontOfSize:_labPrice.height];
        _labPrice.textColor = kColorOrange;
        
        // 城市
        _labArea = [[UILabel alloc] initWithClearFrame:CGRectMake(_ivCarPhoto.maxX + 10, _labPrice.maxY + 10, 110, 11)];
        _labArea.font = [UIFont systemFontOfSize:_labArea.height];
        _labArea.textColor = kColorGrey3;
        
        // 浏览数
        _labViewCount = [[UILabel alloc] initWithClearFrame:CGRectMake(221, _labPrice.maxY + 10, 90, 11)];
        _labViewCount.font = [UIFont systemFontOfSize:_labViewCount.height];
        _labViewCount.textAlignment = NSTextAlignmentRight;
        _labViewCount.textColor = kColorGrey3;
        
        // 近似新车
        _ivNewCar = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 50, _labTitle.maxY + 10, 14.5, 14.5)];
        _ivNewCar.image = [UIImage imageNamed:@"new_car"];
        // 延长质保
        _ivWarrantly = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 70, _labTitle.maxY + 10, 14.5, 14.5)];
        _ivWarrantly.image = [UIImage imageNamed:@"ext_warrant"];

        //添加+号按钮的背景
        _ivBtnBg = [[UIImageView alloc] initWithFrame:CGRectMake(_vCarInfo.width - 25, 0, 27, UCCarStatusInfoCellHeight)];
        _ivBtnBg.userInteractionEnabled = YES;
        
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kLinePixel, UCCarStatusInfoCellHeight) color:kColorNewLine];
        
        //+号按钮
        _btnMoveCell = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, _ivBtnBg.height)];
        [_btnMoveCell setImage:[UIImage imageWithColor:kColorGrey5 size:_btnMoveCell.size] forState:UIControlStateHighlighted];
        [_btnMoveCell addTarget:self action:@selector(onClickMoveCellBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        //右分割线
        UIView *vRightLint = [[UIView alloc] initLineWithFrame:CGRectMake(_btnMoveCell.maxX, 0, kLinePixel, _btnMoveCell.height) color:kColorNewLine];
        [_ivBtnBg addSubview:vRightLint];
        
        _ivBtnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"person al_add_btn"]];
        _ivBtnImage.frame = CGRectMake((_ivBtnBg.width - _ivBtnImage.width)/2, (_ivBtnBg.height - _ivBtnImage.height)/2, _ivBtnImage.width, _ivBtnImage.height);
        _ivBtnImage.tag = 23766322;
        _ivBtnImage.userInteractionEnabled = NO;
        
        [_vCarInfo addSubview:_vHighlighted];
        [_ivBtnBg addSubview:_btnMoveCell];
        [_ivBtnBg addSubview:_ivBtnImage];
        [_vCarInfo addSubview:_ivBtnBg];
        [_ivBtnBg addSubview:vLine];
        
        // 分割线
        UIView *vCellLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, UCCarStatusInfoCellHeight - kLinePixel, self.contentView.width, kLinePixel) color:kColorNewLine];
        
        [_vCarInfo addSubview:_ivCarPhoto];
        [_vCarInfo addSubview:_labTitle];
        [_vCarInfo addSubview:_labPrice];
        [_vCarInfo addSubview:_labArea];
        [_vCarInfo addSubview:_labViewCount];
        
        [_vCarInfo addSubview:_ivNewCar];
        [_vCarInfo addSubview:_ivWarrantly];
        [self.contentView addSubview:_vCarInfo];
        [self.contentView addSubview:vCellLine];
    }
    return self;
}

//设置cell内容
- (void)makeView:(UCCarInfoEditModel *)carInfoModel carListState:(UCCarStatusListViewStyle)carListState cellRow:(NSInteger)row
{
    _labTitle.text = nil;
    _labPrice.text = nil;
    _labArea.text = nil;
    _labViewCount.text = nil;
    
    _mCarInfoEdit = carInfoModel;
    
    //车名
    NSString *strName = nil;
    NSString *strGearbox = nil;
    NSString *strDisplacement = nil;
    if (_mCarInfoEdit.productname.length > 0 && _mCarInfoEdit.seriesname.length > 0)
        strName = [NSString stringWithFormat:@"%@%@", (_mCarInfoEdit.seriesname.length > 0 ? _mCarInfoEdit.seriesname : @""), (_mCarInfoEdit.productname.length > 0 ? [NSString stringWithFormat:@" %@",_mCarInfoEdit.productname] : @"")];
    else
        strName = _mCarInfoEdit.carname.length > 0 ? _mCarInfoEdit.carname : @"";
    
    strGearbox = _mCarInfoEdit.gearbox.length > 0 ? [NSString stringWithFormat:@" %@",_mCarInfoEdit.gearbox] : @"";
    
    strDisplacement = _mCarInfoEdit.displacement.length > 0 ? [NSString stringWithFormat:@" %@L",_mCarInfoEdit.displacement] : @"";
    
    _labTitle.text = [NSString stringWithFormat:@"%@%@%@", strName, strGearbox, strDisplacement];
    
    // 未填完无标题
    if (carListState == UCCarStatusListViewStyleNotfilled && [_labTitle.text isEqualToString:@""])
        _labTitle.text = @"暂无车辆信息";
    
    // 价格
    _labPrice.text = [NSString stringWithFormat:@"￥%@万",carInfoModel.bookpriceText.length > 0 ? carInfoModel.bookpriceText : @"--"];
    
    if ([carInfoModel.cityid stringValue].length > 0) {
        //获得城市
        NSString *strCity = nil;
        
        NSArray *areProvinces = [OMG areaProvinces];
        for (AreaProvinceItem *apItem in areProvinces) {
            if ([apItem.PI isEqualToNumber: carInfoModel.provinceid]) {
                //设置省
                for (AreaCityItem *acItem in apItem.CL) {
                    if ([acItem.CI isEqualToNumber: carInfoModel.cityid]) {
                        //设置市
                        strCity = [acItem.CN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        break;
                    }
                }
                break;
            }
        }
        strCity = strCity ? strCity : @"--";
        _labArea.text = strCity;
    }
    else {
        _labArea.text = @"--";
    }
    
    // 浏览数
    if (carInfoModel.views.integerValue > 0) {
        _labViewCount.text = [NSString stringWithFormat:@"浏览：%d", carInfoModel.views.integerValue];
    }
    else{
        _labViewCount.text = nil;
    }
    
    //设置图片
    NSArray *thumbImgurls = [carInfoModel.thumbimgurls componentsSeparatedByString:@","];
    
    if ([thumbImgurls count] > 0) {
        [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:[thumbImgurls objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"home_default"]];
    }
    // 无缩略图使用大图
    else {
        thumbImgurls = [carInfoModel.imgurls componentsSeparatedByString:@","];
        if ([thumbImgurls count] > 0 && ((NSString *)[thumbImgurls objectAtIndex:0]).length > 3) {
            [_ivCarPhoto sd_setImageWithURL:[NSURL URLWithString:[thumbImgurls objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"home_default"]];

        }
        // 无图片
        else {
            [_ivCarPhoto setImage:[UIImage imageNamed:(carListState == UCCarStatusListViewStyleNotfilled ? @"carphoto_nophoto" : @"home_default")]];
        }
    }
    
    // 是否显示操作项
    if (carListState == UCCarStatusListViewStyleSaled) {
        _ivBtnBg.hidden = YES;
        _labTitle.width = self.width - 110;
        _labViewCount.minX = self.width - 100;
        
    } else {
        _ivBtnBg.hidden = NO;
        _labTitle.width = self.width - 110 - _ivBtnBg.width;
        _labViewCount.minX = self.width - 100 - _ivBtnBg.width;
    }
    CGFloat range = carListState == UCCarStatusListViewStyleSaled ?
    range = 25 : 0;
    // 近似新车和延长质保图片显示
    _ivNewCar.hidden = ([_mCarInfoEdit.isnewcar integerValue] == 0);
    _ivNewCar.frame = CGRectMake(self.width - 50 + range, _labTitle.maxY + 10, 14.5, 14.5);

    _ivWarrantly.hidden = ([_mCarInfoEdit.extendedrepair integerValue] == 0);
    _ivWarrantly.minX = _ivNewCar.hidden ? _ivNewCar.minX : self.width - 75 + range;
}

/** 移动cell */
-(void)onClickMoveCellBtn:(UIButton *)btn
{
    [self.delegateView onClickMoveBtn:self];
}

//开启或关闭
-(void)openCell:(BOOL)isOpenCell btnBackgroundView:(UIView *)vBtnBackground
{
    CGFloat marginLeft = -(self.width - 24);
    
    _btnMoveCell.selected = isOpenCell;
    
    //移动 旋转
    [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
        
        CGFloat vCarInfoMinX = _vCarInfo.minX == 0 ? marginLeft : 0;
        _vCarInfo.minX = vCarInfoMinX;
        _ivBtnImage.transform = CGAffineTransformMakeRotation([OMG degreesToRadians:(_btnMoveCell.isSelected ? 45 : 0)]);
        
    } completion:^(BOOL finished) {
        if (_vCarInfo.minX == 0)
            [vBtnBackground removeAllSubviews];
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
