//
//  UCCarCompareDetailView.m
//  UsedCar
//
//  Created by wangfaquan on 14-1-28.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCompareDetailView.h"
#import "UCTopBar.h"
#import "UCCarDetailInfoModel.h"
#import "UIImageView+WebCache.h"

@interface UCCarCompareDetailView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) NSArray *twoCompareModels;
@property (nonatomic, strong) NSArray *viewDatas;
@property (nonatomic, strong) UIButton *btnSelectAll;
@property (nonatomic, strong) UIButton *btnSelectPart;
@property (nonatomic, strong) UIView *vCarPicCompare;
@property (nonatomic, strong) UIScrollView *svCompare;
@property (nonatomic, strong) UIView *vList;
@property (nonatomic) BOOL isTitleView;

@end

@implementation UCCarCompareDetailView

- (id)initWithFrame:(CGRect)frame twoCar:(NSArray *)twoCompareModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _twoCompareModels = twoCompareModel;
        _viewDatas = [self buildeViewDatas:twoCompareModel];
        [UMSAgent postEvent:comparedetail_pv page_name:NSStringFromClass(self.class)];
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
/** 初始化视图 */
- (void)initView
{
    self.backgroundColor = kColorWhite;
    
    // 处理头部
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"比一比" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:
     UIControlEventTouchUpInside];
    [self addSubview:_tbTop];
    
    // 生成第一个模块
    [self initCarPicCompare];
    
    // 初始化比对列表
    _vList = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarPicCompare.height, self.width, kUnkown)];
    [_svCompare addSubview:_vList];
    [self onClickPartDataBtn:_btnSelectAll];
}

/** 创建第一大模块车辆信息 */
- (void)initCarPicCompare
{
    UCCarDetailInfoModel *mCarDetailInfo1 = [_twoCompareModels objectAtIndex:0];
    UCCarDetailInfoModel *mCarDetailInfo2 = [_twoCompareModels objectAtIndex:1];
    
    // 创建一个UIScrollView
    _svCompare = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
    
    // 垂直方向的滚动指示
    _svCompare.showsVerticalScrollIndicator =YES;
    _svCompare.showsHorizontalScrollIndicator = NO;
    _svCompare.scrollEnabled = YES;
    _svCompare.delegate = self;
    _svCompare.backgroundColor = kColorWhite;
    
    // 创建车图片对比视图
    _vCarPicCompare = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kUnkown) color:[UIColor whiteColor]];
    
    // 创建Pk图片
    UIImageView *ivPk = [[UIImageView alloc] initLineWithFrame:CGRectMake(24, 40, 38, 22) color:[UIColor clearColor]];
    [ivPk setImage:[UIImage imageNamed:@"contrast_pk_icon"]];
    
    // 全部数据
    UIImage *iSelect = [UIImage imageNamed:@"contrast_all_icon"];
    _btnSelectAll = [[UIButton alloc] initLineWithFrame:CGRectMake(8, 90, 70, 20) color:[UIColor clearColor]];
    _btnSelectAll.titleLabel.font = [UIFont systemFontOfSize:10];
    _btnSelectAll.tintColor = kColorBlue1;
    _btnSelectAll.titleLabel.textColor = kColorBlue1;
    [_btnSelectAll setImage:iSelect forState:UIControlStateNormal];
    [_btnSelectAll setImage:[UIImage imageNamed:@"contrast_choose_btn_h"] forState:UIControlStateSelected];
    [_btnSelectAll setTitle:@"全部数据" forState:UIControlStateNormal];
    [_btnSelectAll addTarget:self action:@selector(onClickPartDataBtn:) forControlEvents:UIControlEventTouchUpInside];
    _btnSelectAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnSelectAll.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _btnSelectAll.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0); //{top, left, bottom, right}
    [_btnSelectAll setTitleColor:kColorGray1 forState:UIControlStateNormal];
    
    // 隐藏相同
    _btnSelectPart = [[UIButton alloc] initLineWithFrame:CGRectMake(8, 131, 75, 20) color:[UIColor clearColor]];
    [_btnSelectPart setImage:iSelect forState:UIControlStateNormal];
    [_btnSelectPart setImage:[UIImage imageNamed:@"contrast_choose_btn_h"] forState:UIControlStateSelected];
    [_btnSelectPart setTitleColor:kColorGray1 forState:UIControlStateNormal];
    _btnSelectPart.titleLabel.textColor = kColorBlue1;
    [_btnSelectPart setTitle:@"隐藏相同项" forState:UIControlStateNormal];
    _btnSelectPart.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_btnSelectPart addTarget:self action:@selector(onClickPartDataBtn:) forControlEvents:UIControlEventTouchUpInside];
    _btnSelectPart.titleLabel.font = [UIFont systemFontOfSize:10];
    _btnSelectPart.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0); //{top, left, bottom, right}
    _btnSelectPart.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 汽车图片视图
    UIImageView *ivCarPicsOne = [[UIImageView alloc] initLineWithFrame:CGRectMake(99, 13, 90, 65) color:kColorWhite];
    NSArray *thumbimgurlsOne = [mCarDetailInfo1.thumbimgurls componentsSeparatedByString:@","];
    if (thumbimgurlsOne.count > 0)
        [ivCarPicsOne sd_setImageWithURL:[NSURL URLWithString:[thumbimgurlsOne objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"home_default"]];
    else
        [ivCarPicsOne setImage:[UIImage imageNamed:@"details_nopictures_picture"]];
    UIImageView *ivCarPicsTwo = [[UIImageView alloc] initLineWithFrame:CGRectMake((self.width - 86) / 2 + 86 + 13, 13, 90, 65) color:kColorWhite];
    NSArray *thumbimgurlsTwo = [mCarDetailInfo2.thumbimgurls componentsSeparatedByString:@","];
    if (thumbimgurlsTwo.count > 0)
        [ivCarPicsTwo sd_setImageWithURL:[NSURL URLWithString:[thumbimgurlsTwo objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"home_default"]];
    else {
        [ivCarPicsTwo setImage:[UIImage imageNamed:@"details_nopictures_picture"]];
    }
    
    // 创建了车的名字
    UILabel *labCarNameOne = [[UILabel alloc] initWithFrame:CGRectMake(98, 86, (self.width - 88 - 13 * 2) / 2, 90)];
    labCarNameOne.backgroundColor = kColorWhite;
    
    // 判断是不是自定义车辆
    if ([mCarDetailInfo1.productidText  isEqual: @""] && [mCarDetailInfo1.seriesidText  isEqual: @""])
        labCarNameOne.text = [NSString stringWithFormat:@"%@\n%@ %@", mCarDetailInfo1.carnameText,[NSString stringWithFormat:@"%@L",mCarDetailInfo1.displacementText], mCarDetailInfo1.gearboxText];
    else
        labCarNameOne.text = [NSString stringWithFormat:@"%@%@", mCarDetailInfo1.productidText, mCarDetailInfo1.seriesidText];
    labCarNameOne.font = [UIFont systemFontOfSize:15];
    labCarNameOne.numberOfLines = 0;
    [labCarNameOne sizeToFit];
    
    // 计算出label的高度
    CGFloat hight = labCarNameOne.size.height;
    UILabel *labCarNameTwo = [[UILabel alloc] initWithFrame:CGRectMake((self.width - 86) / 2 + 86 + 13, 86, (self.width - 88 - 13 * 2) / 2, 90)];
    labCarNameTwo.backgroundColor = kColorWhite;
    
    // 判断是不是自定义车辆
    if ([mCarDetailInfo2.productidText  isEqual: @""] && [mCarDetailInfo2.seriesidText  isEqual: @""])
        labCarNameTwo.text = [NSString stringWithFormat:@"%@\n%@ %@", mCarDetailInfo2.carnameText, [NSString stringWithFormat:@"%@L", mCarDetailInfo2.displacementText], mCarDetailInfo2.gearboxText];
    else
        labCarNameTwo.text = [NSString stringWithFormat:@"%@%@", mCarDetailInfo2.productidText, mCarDetailInfo2.seriesidText];

    labCarNameTwo.font = labCarNameOne.font;
    labCarNameTwo.numberOfLines = 0;
    [labCarNameTwo sizeToFit];
    CGFloat hights = labCarNameTwo.size.height;
    
    // 特殊处理线的高度
    UIView *vLineOne = [[UIView alloc] initLineWithFrame:CGRectMake(86, 0, kLinePixel, kUnkown) color:kColorNewLine];
    UIView *vLineTwo = [[UIView alloc] initLineWithFrame:CGRectMake((self.width - 86) / 2 + 86, 0, kLinePixel, kUnkown) color:kColorNewLine];
    if (hight > hights) {
        
        // 判断是不是满足最小高度
        if ((26 + ivCarPicsOne.height + hight) < 164) {
            _vCarPicCompare.size = CGSizeMake(self.height, 164);
            vLineOne.size = CGSizeMake(kLinePixel, 164);
            vLineTwo.size = CGSizeMake(kLinePixel, 164);
        } else {
            _vCarPicCompare.size = CGSizeMake(self.width, 26 + ivCarPicsOne.height + hight);
            vLineOne.size = CGSizeMake(kLinePixel, 26 + ivCarPicsOne.height + hight);
            vLineTwo.size = CGSizeMake(kLinePixel, 26 + ivCarPicsOne.height + hight);
        }
    } else {
        if ((26 + ivCarPicsOne.height + hights) < 164) {
            _vCarPicCompare.size = CGSizeMake(self.height, 164);
            vLineOne.size = CGSizeMake(kLinePixel, 164);
            vLineTwo.size = CGSizeMake(kLinePixel, 164);
        } else {
            _vCarPicCompare.size = CGSizeMake(self.width, 26 + ivCarPicsOne.height + hights);
            vLineOne.size = CGSizeMake(kLinePixel, 26 + ivCarPicsOne.height + hights);
            vLineTwo.size = CGSizeMake(kLinePixel, 26 + ivCarPicsOne.height + hights);
        }
    }
    
    [self addSubview:_svCompare];
    [_vCarPicCompare addSubview:vLineOne];
    [_vCarPicCompare addSubview:vLineTwo];
    [_vCarPicCompare addSubview:ivCarPicsOne];
    [_vCarPicCompare addSubview:ivCarPicsTwo];
    [_vCarPicCompare addSubview:labCarNameOne];
    [_vCarPicCompare addSubview:labCarNameTwo];
    [_vCarPicCompare addSubview:_btnSelectAll];
    [_vCarPicCompare addSubview:_btnSelectPart];
    [_vCarPicCompare addSubview:ivPk];
    [_svCompare addSubview:_vCarPicCompare];
}

/** 初始化行视图 */
- (UIView *)makeRowView:(id)rowdata isLast:(BOOL)isLast
{
    // 获取每一块的大标题
    if ([rowdata isKindOfClass:[NSString class]]) {
        UIView *vTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
        UILabel *labInformation = [[UILabel alloc] initLineWithFrame:CGRectMake(10, 0, self.width, 30) color:[UIColor clearColor]];
        labInformation.text = rowdata;
        labInformation.textColor = kColorBlue1;
        vTitle.backgroundColor = kColorGrey5;
        [vTitle addSubview:labInformation];
        _isTitleView = YES;
        return vTitle;
    } else {
        NSArray *values = rowdata;
        if (_btnSelectPart.isSelected) {
            if ([rowdata[1] isEqualToString:rowdata[2]])
                return nil;
        }
        UIView *vRow = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, 50) color:kColorWhite];
        
        // 名称
        UILabel *labName = [[UILabel alloc] initWithClearFrame:CGRectMake(10, 0, 64, 50)];
        labName.textColor = kColorGrey3;
        labName.text = [values objectAtIndex:0];
        labName.font = [UIFont systemFontOfSize:15];
        
        // 单独处理字体大小
        if ([[values objectAtIndex:0]isEqualToString:@"首次上牌时间"] || [[values objectAtIndex:0]isEqualToString:@"车辆年审时间"]|| [[values objectAtIndex:0]isEqualToString:@"车船使用税有效时间"] || [[values objectAtIndex:0]isEqualToString:@"交强险截止日期"])
        {
            labName.font = [UIFont systemFontOfSize:13];
            labName.numberOfLines = 0;
        }
        
        // 值1
        UILabel *labValue1 = [[UILabel alloc] initLineWithFrame:CGRectMake(94, 0, 104, 50) color:kColorWhite];
        labValue1.text = [values objectAtIndex:1];
        if ([[values objectAtIndex:1] isEqualToString:@""])
            labValue1.text = @"-";
        
        labValue1.font = [UIFont systemFontOfSize:15];
        
        // 值2
        UILabel *labValue2 = [[UILabel alloc] initLineWithFrame:CGRectMake(112 + (self.width - 112) / 2, 0, 104, 50) color:kColorWhite];
        labValue2.text = [values objectAtIndex:2];
        if ([[values objectAtIndex:2]isEqualToString:@""])
            labValue2.text = @"-";
        
        labValue2.font = labValue1.font;
        
        // 特殊处理显示的数据
        if ([[values objectAtIndex:0]isEqualToString:@"预售价格"] || [[values objectAtIndex:0]isEqualToString:@"行驶里程"]) {
            labValue1.frame = CGRectMake(94, 15, kUnkown, 50);
            labValue2.frame = CGRectMake(112 + (self.width - 112) / 2, 15, kUnkown, 50);
            labValue1.textColor = kColorOrange;
            labValue2.textColor = kColorOrange;
            [labValue1 sizeToFit];
            [labValue2 sizeToFit];
            
            // 单独用了两个Label特殊处理价格和公里
            UILabel *labPrice = [[UILabel alloc] initLineWithFrame:CGRectMake(94 + labValue1.width , 0, 50, 50) color:kColorWhite];
            UILabel *labPriceT = [[UILabel alloc] initLineWithFrame:CGRectMake(112 + (self.width - 112) / 2 + labValue2.width , 0, 50, 50) color:kColorWhite];
            
            if ([[values objectAtIndex:0]isEqualToString:@"预售价格"]) {
                labPrice.text = @" 万元";
                labPriceT.text = @" 万元";
            } else {
                labPrice.text = @" 万公里";
                labPriceT.text = @" 万公里";
            }
            labPrice.textColor = kColorGrey3;
            labPriceT.textColor = kColorGrey3;
            labPrice.font = [UIFont systemFontOfSize:15];
            labPriceT.font = labPrice.font;
            labValue1.text = [NSString stringWithFormat:@"%@",[values objectAtIndex:1]];
            labValue2.text = [NSString stringWithFormat:@"%@",[values objectAtIndex:2]];
            [vRow addSubview:labPrice];
            [vRow addSubview:labPriceT];
        }
        
        // 特殊处理车辆其他信息
        if ([[values objectAtIndex:0]isEqualToString:@"车辆配置"]||[[values objectAtIndex:0]isEqualToString:@"卖家描述"]) {
            labValue1.frame = CGRectMake(94, 10, (self.width - 112) / 2, 50);
            labValue2.frame = CGRectMake(108 + (self.width - 112) / 2, 10, (self.width - 112) / 2, 50);
            labValue1.numberOfLines = 0;
            labValue2.numberOfLines = 0;
            [labValue1 sizeToFit];
            [labValue2 sizeToFit];
            CGFloat height1 = labValue1.size.height;
            CGFloat height2 = labValue2.size.height;
            
            // 自适应高度
            vRow.size = CGSizeMake(self.width, (height1 > height2 ? labValue1.height + 20 : labValue2.height + 20));
            
            // 标题居中
            labName.minY = (vRow.height - labName.height) / 2;
        }
        
        // 纵向分割线
        UIView *vLineOne = [[UIView alloc] initLineWithFrame:CGRectMake(86, 0, kLinePixel, vRow.height) color:kColorNewLine];
        UIView *vLineTwo = [[UIView alloc] initLineWithFrame:CGRectMake(112 + (self.width - 112) / 2 - 11, 0, kLinePixel, vRow.height) color:kColorNewLine];
        [vRow addSubview:labName];
        [vRow addSubview:labValue1];
        [vRow addSubview:labValue2];
        [vRow addSubview:vLineOne];
        [vRow addSubview:vLineTwo];
        
        // 横向分割线
        if (!_isTitleView) {
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vRow.width, kLinePixel) color:kColorNewLine];
            [vRow addSubview:vLine];
        }
        
        // 处理最后一根线
        if (isLast) {
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vRow.height - kLinePixel, vRow.width, kLinePixel) color:kColorNewLine];
            [vRow addSubview:vLine];
        }
        _isTitleView = NO;
        return vRow;
    }
}

#pragma mark - private Method
/** 获取数据 */
- (NSArray *)buildeViewDatas:(NSArray *)compareModels
{
    UCCarDetailInfoModel *carmodel = [compareModels objectAtIndex:0];
    UCCarDetailInfoModel *carmodel1 = [compareModels objectAtIndex:1];
    NSMutableArray *viewDatas = [[NSMutableArray alloc] init];
    [NSString stringWithFormat:@"%@ 万元",carmodel.bookpriceText];
    
    // 第一大模块数据处理
    [viewDatas addObject:@"车辆基础信息"];
    [viewDatas addObject:@[@"预售价格", carmodel.bookpriceText, carmodel1.bookpriceText]];
    [viewDatas addObject:@[@"行驶里程", carmodel.drivemileageText, carmodel1.drivemileageText]];
    [viewDatas addObject:@[@"过户费", carmodel.isincludetransferfeeText, carmodel1.isincludetransferfeeText]];
    [viewDatas addObject:@[@"信息来源", [carmodel.sourceid integerValue] == 1 ? @"个人" : @"商家", [carmodel1.sourceid integerValue] == 1 ? @"个人" : @"商家"]];
    
    NSString *cityProvices = nil;
    NSString *citys = nil;
    
    // 获取省份与城市看是否为直辖市
    if ([carmodel.provinceidText isEqualToString:carmodel.cityidText])
        cityProvices = carmodel.cityidText;
    else
        cityProvices = [NSString stringWithFormat:@"%@ %@",carmodel.provinceidText,carmodel.cityidText];

    if ([carmodel1.provinceidText isEqualToString:carmodel1.cityidText])
        citys = carmodel1.cityidText;
    else
        citys = [NSString stringWithFormat:@"%@ %@",carmodel1.provinceidText,carmodel1.cityidText];
    
    [viewDatas addObject:@[@"所在地", cityProvices, citys]];
    [viewDatas addObject:@[@"车辆用途", carmodel.purposeidText, carmodel1.purposeidText]];
    [viewDatas addObject:@[@"车辆颜色", carmodel.coloridText, carmodel1.coloridText]];
    
    // 第二大模块数据处理
    [viewDatas addObject:@"车辆牌照信息"];
    
    // 定义字符串
    NSString *strData1 = nil;
    NSString *strData2 = nil;
    NSString *strData3 = nil;
    NSString *strData4 = nil;
    NSString *strData5 = nil;
    NSString *strData6 = nil;
    NSString *strData7 = nil;
    NSString *strData8 = nil;
    
    // 首次上牌时间
    if ( carmodel.firstregtimeText.length < 4)
        strData1 = @"-";
    else
        strData1 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel.firstregtimeText]];
    if (carmodel1.firstregtimeText.length < 4)
        strData2 = @"-";
    else
        strData2 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel1.firstregtimeText]];
    
    // 车辆年审时间
    if (carmodel.verifytimeText.length < 4)
        strData3 = @"-";
    else
        strData3 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel.verifytimeText]];
    if (carmodel1.verifytimeText.length < 4)
        strData4 = @"-";
    else
        strData4 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel1.verifytimeText]];
    
    // 车船使用税有效时间
    if ([carmodel.veticaltaxtimeText isEqualToString:@"已过期"])
        strData5 = @"已过期";
    else if (carmodel.veticaltaxtimeText.length > 3)
        strData5 = [NSString stringWithFormat:@"%@年",[carmodel.veticaltaxtimeText substringToIndex:4]];
    else
        strData5 = @"-";
    
    if ([carmodel1.veticaltaxtimeText isEqualToString:@"已过期"])
        strData6 = @"已过期";
    else if (carmodel1.veticaltaxtimeText.length > 3)
        strData6 = [NSString stringWithFormat:@"%@年",[carmodel1.veticaltaxtimeText substringToIndex:4]];
    else
        strData6 = @"-";
    
    // 交强险截止日期
    if (carmodel.insurancedateText.length < 4)
        strData7 = @"-";
    else
        strData7 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel.insurancedateText]];
    if (carmodel1.insurancedateText.length < 4)
        strData8 = @"-";
    else
        strData8 = [OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:carmodel1.insurancedateText]];
    
    [viewDatas addObject:@[@"首次上牌时间", strData1, strData2]];
    [viewDatas addObject:@[@"车辆年审时间", strData3, strData4]];
    [viewDatas addObject:@[@"车船使用税有效时间", strData5, strData6]];
    [viewDatas addObject:@[@"交强险截止日期", strData7, strData8]];
    [viewDatas addObject:@[@"行驶证", carmodel.drivingpermitText, carmodel1.drivingpermitText]];
    [viewDatas addObject:@[@"登记证", carmodel.registrationText, carmodel1.registrationText]];
    [viewDatas addObject:@[@"购车发票", carmodel.invoiceText, carmodel1.invoiceText]];
    
    // 第三大模块数据处理
    [viewDatas addObject:@"其他信息"];
    [viewDatas addObject:@[@"卖家描述", carmodel.usercommentText, carmodel1.usercommentText]];
    [viewDatas addObject:@[@"车辆配置", carmodel.configsText, carmodel1.configsText]];
    
    return viewDatas;
}

/** 数据处理 */
- (void)makeListViewWithDatas:(NSArray *)datas
{
    [_vList removeAllSubviews];
    CGFloat rowViewMinY = 0;
    for (NSInteger i = 0; i < datas.count; i++) {
        // 单行视图
        id rowdata = datas[i];
        
        UIView *vRow = [self makeRowView:rowdata isLast:i == datas.count - 1];
        if (vRow) {
            vRow.minY = rowViewMinY;
            [_vList addSubview:vRow];
            rowViewMinY += vRow.height;
        }
    }
    _vList.height = ((UIView *)_vList.subviews.lastObject).maxY;
    _svCompare.contentSize = CGSizeMake(_svCompare.contentSize.width, _vList.maxY);
}

#pragma mark - onClickButton
/** 部分数据 */
- (void)onClickPartDataBtn:(UIButton *)btn
{
    if (btn == _btnSelectPart) {
        _btnSelectPart.selected = YES;
        _btnSelectAll.selected = NO;
    } else {
        _btnSelectPart.selected = NO;
        _btnSelectAll.selected = YES;
    }
    [self makeListViewWithDatas:_viewDatas];
    
    return;
}

/** 返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

@end
