//
//  UCUserCarDetailView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-11.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCUserCarDetailView.h"
#import "UIIndexControl.h"
#import "UCTopBar.h"
#import "UCImageBrowseView.h"
#import "UIImage+Util.h"
#import "AMCacheManage.h"
#import "UIImageView+WebCache.h"
#import "UCLoginDealerView.h"
#import "UCLoginClientView.h"

#define KColorBackground        [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05]

#define KOptionsBarHeight       45
#define KMarginLefTitle         20
#define KMarginLefLine          12
#define KMarginLefContent       93
#define KContentHeight          50

#define kBasicHeadBgTag         34872637

#define KlabCarBasicInfoTag     37487563
#define KlabLicenseTitleTag     19332338
#define KlabLicenseContenTag    22239846
#define KCarPhotoTag            93848848

#define zero 0

@interface UCUserCarDetailView ()
@property (nonatomic) UserStyle userStyle;
@property (nonatomic) UCCarStatusListViewStyle statusStyle;
@property (nonatomic, strong) APIHelper *apiCarAction;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UILabel *labPrice;
@property (nonatomic, strong) UILabel *labDescriptionContent;
@property (nonatomic, strong) UILabel *labCarName;
@property (nonatomic, strong) UILabel *labCarModel;
@property (nonatomic, strong) UILabel *labGearbox;
@property (nonatomic, strong) UILabel *labPriceUnit;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit;
@property (nonatomic, strong) UIView *vLicense;
@property (nonatomic, strong) UIView *vDescription;
@property (nonatomic, strong) UIView *vPriceAndOther;
@property (nonatomic, strong) UIView *vCarBasicInfo;
@property (nonatomic, strong) UIScrollView *svPhoto;
@property (nonatomic, strong) UIScrollView *svCarInfo;
@property (nonatomic, strong) UIIndexControl *pcPhoto;
@property (nonatomic, strong) UILabel *labSalesPerson;
@property (nonatomic, strong) UILabel *labPhone;
@property (nonatomic, strong) UILabel *labPhoneTitle;
@property (nonatomic, strong) UILabel *labSalesPersonTitle;
@property (nonatomic) NSInteger carId;
@property (nonatomic, strong) UCThumbnailsView *vCarTestReportlPhoto;   // 检测报告

@end

@implementation UCUserCarDetailView

- (id)initWithFrame:(CGRect)frame userStyle:(UserStyle)userStyle statusStyle:(UCCarStatusListViewStyle)statusStyle carInfoEdeiModel:(UCCarInfoEditModel *)mCarInfo;
{
    self = [super initWithFrame:frame];
    if (self) {
        _userStyle = userStyle;
        _statusStyle = statusStyle;
        // 获取数据
        _mCarInfoEdit = mCarInfo;
        [_mCarInfoEdit setTextValue];
        _carId = [_mCarInfoEdit.carid integerValue];
        // 统计事件
        [self recordEvent];
        // 初始化
        [self initTitleView];
        [self initView];
        [self reloadView];
    }
    return self;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView
{
    self.backgroundColor = kColorWhite;
    
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnTitle setTitle:@"车辆详情" forState:UIControlStateNormal];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
}

/** 初始化View */
- (void)initView
{
    // 信息视图
    _svCarInfo = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.height, self.width, self.height - (_statusStyle != UCCarStatusListViewStyleSaled ? KOptionsBarHeight : 0) - _tbTop.height)];
    
    // 时间 & 图片 视图
    UIView *vTimeAndPhotos = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 101)];
    vTimeAndPhotos.backgroundColor = kColorGrey5;
    
    UIView *vTime = nil;
    
    // 图片view
    UIView *vPhoto = [[UIView alloc] initWithFrame:CGRectMake(0, vTime.maxY, vTimeAndPhotos.width, vTimeAndPhotos.height - vTime.height)];
    
    // 图片滚动视图
    _svPhoto = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, vPhoto.width, 80)];
    _svPhoto.delegate = self;
    _svPhoto.showsHorizontalScrollIndicator = NO;
    _svPhoto.tag = 98765648;
    _svPhoto.delegate = self;
    _svPhoto.pagingEnabled = YES;
    
    // 索引
    _pcPhoto = [[UIIndexControl alloc] initWithFrame:CGRectMake(0, vPhoto.height - 18, vPhoto.width, 13) currentImageName:@"individual_points_h" commonImageName:@"individual_points"];
    _pcPhoto.tag = 32141876;
    _pcPhoto.hidesForSinglePage = YES;
    _pcPhoto.userInteractionEnabled = NO;
    
    UIView *vImageViewLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vPhoto.height - kLinePixel, vPhoto.width, kLinePixel) color:kColorNewLine];
    
    [_svCarInfo addSubview:vTimeAndPhotos];
    
    // 车辆基础信息
    _vCarBasicInfo = [[UIView alloc] initWithFrame:CGRectMake(0, vTimeAndPhotos.maxY, self.width, 0)];
    
    // 车辆信息标题背景
    UIView *vBasicHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vCarBasicInfo.width, 30)];
    vBasicHeadBg.tag = kBasicHeadBgTag;
    vBasicHeadBg.backgroundColor = KColorBackground;
    
    // 车辆基础信息
    UILabel *labBasicTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vBasicHeadBg.width - KMarginLefTitle, vBasicHeadBg.height)];
    labBasicTitle.text = @"车辆基础信息";
    labBasicTitle.textColor = kColorBlue1;
    labBasicTitle.font = [UIFont systemFontOfSize:16];
    [_vCarBasicInfo addSubview:labBasicTitle];
    
    // 车辆信息标题
    UILabel *labNameTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, labBasicTitle.maxY, _vCarBasicInfo.width - KMarginLefTitle, KContentHeight)];
    labNameTitle.text = @"车辆信息：";
    labNameTitle.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:labNameTitle];
    
    // 车系
    _labCarName = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, 46, _vCarBasicInfo.width - KMarginLefContent - 10, 0)];
    _labCarName.textColor = kColorGrey2;
    _labCarName.numberOfLines = 0;
    _labCarName.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labCarName];
    
    // 车型
    _labCarModel = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefContent, 0, 0, 0)];
    _labCarModel.textColor = kColorGrey2;
    _labCarModel.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labCarModel];
    
    // 变速箱 排量
    _labGearbox = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, 100, 0, 0)];
    _labGearbox.textColor = kColorGrey2;
    _labGearbox.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labGearbox];
    
    // 销售代表
    _labSalesPersonTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _labGearbox.maxY + 15, _vCarBasicInfo.width - KMarginLefTitle, 15)];
    _labSalesPersonTitle.text = _userStyle == UserStyleBusiness ? @"销售代表：" : @"卖家姓名：";
    _labSalesPersonTitle.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labSalesPersonTitle];
    
    _labSalesPerson = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, _labSalesPersonTitle.minY, _vCarBasicInfo.width - KMarginLefContent, 15)];
    _labSalesPerson.textColor = kColorGrey2;
    _labSalesPerson.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labSalesPerson];
    
    // 联系方式
    _labPhoneTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _labSalesPersonTitle.maxY + 15, _vCarBasicInfo.width - KMarginLefTitle, 15)];
    _labPhoneTitle.text = @"联系方式：";
    _labPhoneTitle.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labPhoneTitle];
    
    _labPhone = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, _labSalesPersonTitle.minY, _vCarBasicInfo.width - KMarginLefContent, 15)];
    _labPhone.textColor = kColorGrey2;
    _labPhone.font = [UIFont systemFontOfSize:15];
    [_vCarBasicInfo addSubview:_labPhone];
    
    // 预售价格 & 其他基本信息
    _vPriceAndOther = [[UIView alloc] initWithFrame:CGRectMake(0, _labPhone.maxY, _vCarBasicInfo.width, zero)];
    [_vCarBasicInfo addSubview:_vPriceAndOther];
    
    // 预售价格标题
    UILabel *labPriceTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 3, _vCarBasicInfo.width - KMarginLefContent, KContentHeight - 15)];
    labPriceTitle.text = @"预售价格：";
    labPriceTitle.font = [UIFont systemFontOfSize:15];
    [_vPriceAndOther addSubview:labPriceTitle];
    
    // 价格
    _labPrice = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, DEVICE_IS_IPHONE5 ? 11 : 10, zero, zero)];
    _labPrice.textColor = kColorOrange;
    _labPrice.font = [UIFont boldSystemFontOfSize:17];
    [_vPriceAndOther addSubview:_labPrice];
    
    // 单位
    _labPriceUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(zero, 3, _vCarBasicInfo.width - KMarginLefContent, KContentHeight - 15)];
    _labPriceUnit.text = @"万元";
    _labPriceUnit.textColor = kColorGrey2;
    _labPriceUnit.font = [UIFont systemFontOfSize:15];
    [_vPriceAndOther addSubview:_labPriceUnit];
    
    // 过户费用、所在城市、行驶里程、车辆用途、车辆颜色
    NSArray *basicTitles = nil;
    basicTitles = _userStyle == UserStyleBusiness ? @[@"过户费用：", @"所在城市：", @"行驶里程：", @"车辆用途：", @"车辆颜色："] : @[@"过户费用：", @"所在城市：", @"行驶里程：", @"车辆颜色："];
    for (int i = 0 ; i < [basicTitles count]; i++) {
        UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefTitle, labBasicTitle.maxY + 33 * i + 18, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labTitle.text = [basicTitles objectAtIndex:i];
        labTitle.font = [UIFont systemFontOfSize:15];
        [_vPriceAndOther addSubview:labTitle];
        
        UILabel *labContent = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefContent, labBasicTitle.maxY + 33 * i + 18, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labContent.font = [UIFont systemFontOfSize:15];
        labContent.tag = KlabCarBasicInfoTag + i;
        _labCarName.textColor = kColorGrey2;
        [_vPriceAndOther addSubview:labContent];
        
        _vPriceAndOther.height = labTitle.maxY + 7;
        
    }
    
    // 车辆牌照信息
    _vLicense = [[UIView alloc]initWithFrame:CGRectMake(0, _vCarBasicInfo.maxY, _svCarInfo.width, 999)];
    _vLicense.backgroundColor = [UIColor clearColor];
    [_svCarInfo addSubview:_vLicense];
    
    // 车辆牌照信息背景
    UIView *vLicenseHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vCarBasicInfo.width, 30)];
    vLicenseHeadBg.backgroundColor = KColorBackground;
    [_vLicense addSubview:vLicenseHeadBg];
    
    // 车辆牌照信息
    UILabel *labLicenseTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vLicenseHeadBg.width - KMarginLefTitle, vLicenseHeadBg.height)];
    labLicenseTitle.text = @"车辆牌照信息";
    labLicenseTitle.textColor = kColorBlue1;
    labLicenseTitle.font = [UIFont systemFontOfSize:16];
    [_vLicense addSubview:labLicenseTitle];
    
    NSArray *licenseTitles = nil;
    if (_userStyle == UserStylePersonal) {
        licenseTitles = @[@"首次上牌时间：",@"车辆年审时间：",@"交强险截止日期：",@"车船使用税有效时间：",@"行驶证：",@"登记证：",@"购车发票："];
    }else{
        licenseTitles = @[@"首次上牌时间：",@"车辆年审时间：",@"交强险截止日期：",@"车船使用税有效时间："];
    }
    
    for (int i = 0; i < [licenseTitles count]; i++) {
        
        UILabel *labTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, vLicenseHeadBg.maxY + 33 * i + 8, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labTitle.text = [licenseTitles objectAtIndex:i];
        labTitle.font = [UIFont systemFontOfSize:15];
        labTitle.tag = KlabLicenseTitleTag + i;
        [_vLicense addSubview:labTitle];
        
        CGSize labTitleSize = [labTitle.text sizeWithFont:labTitle.font constrainedToSize:CGSizeMake(_vLicense.width, 400) lineBreakMode:labTitle.lineBreakMode];
        
        UILabel *labContent = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle + labTitleSize.width, vLicenseHeadBg.maxY + 33 * i + 8, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labContent.tag = KlabLicenseContenTag + i;
        labContent.font = [UIFont systemFontOfSize:15];
        labContent.textColor = kColorGrey2;
        [_vLicense addSubview:labContent];
        
        _vLicense.height = labTitle.maxY + 7;
        
    }
    
    // 卖家描述
    _vDescription = [[UIView alloc]initWithFrame:CGRectMake(0, _vLicense.maxY, _svCarInfo.width, 0)];
    _vDescription.layer.masksToBounds = YES;
    [_svCarInfo addSubview:_vDescription];
    
    // 卖家描述背景
    UIView *vDescriptionHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vDescription.width, 30)];
    vDescriptionHeadBg.backgroundColor = KColorBackground;
    [_vDescription addSubview:vDescriptionHeadBg];
    
    // 卖家描述标题
    UILabel *labDescriptionTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vDescriptionHeadBg.width - KMarginLefTitle, vDescriptionHeadBg.height)];
    labDescriptionTitle.text = @"卖家描述";
    labDescriptionTitle.textColor = kColorBlue1;
    labDescriptionTitle.font = [UIFont systemFontOfSize:16];
    [_vDescription addSubview:labDescriptionTitle];
    
    // 卖家描述内容
    _labDescriptionContent = [[UILabel alloc] init];
    _labDescriptionContent.backgroundColor = [UIColor clearColor];
    _labDescriptionContent.numberOfLines = 0;
    _labDescriptionContent.textColor = kColorGrey2;
    _labDescriptionContent.font = [UIFont systemFontOfSize:15];
    CGSize labDescriptionContentSize = [_labDescriptionContent.text sizeWithFont:_labDescriptionContent.font constrainedToSize:CGSizeMake(_vDescription.width - 40, 400) lineBreakMode:_labDescriptionContent.lineBreakMode];
    _labDescriptionContent.frame = CGRectMake(KMarginLefTitle, vDescriptionHeadBg.height, labDescriptionContentSize.width, labDescriptionContentSize.height + 16 *2);
    [_vDescription addSubview:_labDescriptionContent];
    
    _vDescription.height = _labDescriptionContent.maxY;
    
    _svCarInfo.contentSize = CGSizeMake(_svCarInfo.width, _vDescription.maxY);
    
    // 添加图片视图
    [vPhoto addSubview:_svPhoto];
    [vPhoto addSubview:_pcPhoto];
    [vPhoto addSubview:vImageViewLine];
    
    // 添加到时间 & 图片 视图
    [vTimeAndPhotos addSubview:vPhoto];
    
    // 基本信息视图
    [_vCarBasicInfo addSubview:vBasicHeadBg];
    [_svCarInfo addSubview:_vCarBasicInfo];
    
    // 添加到主视图
    [self addSubview:_svCarInfo];
    
    if (_statusStyle == UCCarStatusListViewStyleSaled) {
        return;
    }
    
    UIView *vActionBg = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 45, self.width, 45)];
    vActionBg.backgroundColor = kColorGrey5;
    [self addSubview:vActionBg];
    
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, vActionBg.width, kLinePixel) color:kColorNewLine];
    [vActionBg addSubview:vLine];
    
    NSArray *btnTittles = nil;
    NSArray *btnActionTags = nil;
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            if (_userStyle == UserStyleBusiness) {
                btnTittles = @[@"标为已售",@"修改"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionMarkSold], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
            } else {
                btnTittles = @[@"标为已售",@"修改"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionMarkSold], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
            }
            
            break;
        case UCCarStatusListViewStyleSaled:
            btnTittles = nil;
            btnActionTags = nil;
            break;
        case UCCarStatusListViewStyleChecking:
            btnTittles = @[@"删除",@"修改"];
            btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
            break;
        case UCCarStatusListViewStyleNotpassed:
            btnTittles = @[@"删除",@"修改",@"查看原因"];
            btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionReasons]];
            break;
        case UCCarStatusListViewStyleNotfilled:
            btnTittles = @[@"删除",@"继续填写"];
            btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionContinueFill]];
            break;
        case UCCarStatusListViewStyleInvalid:
            if (_userStyle == UserStyleBusiness) {
                btnTittles = @[@"重新发布",@"修改"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionRepublish], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
            } else {
                btnTittles = @[@"修改"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
            }
            
            break;
            
        default:
            break;
    }
    
    CGFloat actionbtnWidth = vActionBg.width / [btnTittles count];
    for (int i = 0; i < [btnTittles count]; i++) {
        // 按钮
        UIButton *btnAction = [[UIButton alloc] initWithFrame:CGRectMake(i * actionbtnWidth, 0, actionbtnWidth , 45)];
        btnAction.tag = (UCCarStatusListViewButtonAction)[[btnActionTags objectAtIndex:i] integerValue];
        [btnAction setTitle:[btnTittles objectAtIndex:i] forState:UIControlStateNormal];
        [btnAction setTitleColor:kColorBlue1 forState:UIControlStateNormal];
        btnAction.titleLabel.font = [UIFont systemFontOfSize:15];
        [btnAction setBackgroundImage:[UIImage imageWithColor:kColorGrey4 size:btnAction.size] forState:UIControlStateHighlighted];
        [btnAction addTarget:self action:@selector(onClickActionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [vActionBg addSubview:btnAction];
        
        // 分割线
        if (i != 0) {
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(i * actionbtnWidth, (45 - 23) / 2, 1, 23) color:kColorNewLine];
            [vActionBg addSubview:vLine];
        }
        
    }
    
}

#pragma mark - private Method
/** 加载数据 */
- (void)reloadView
{
    // 图片urls
    NSArray *thumbimgurls = [_mCarInfoEdit.thumbimgurls componentsSeparatedByString:@","];
    
    if (thumbimgurls.count == 0)
        thumbimgurls = [_mCarInfoEdit.imgurls componentsSeparatedByString:@","];
    
    //无图片提示文字
    if ([thumbimgurls count] == 0) {
        UILabel *labNoImage = [[UILabel alloc] initWithClearFrame:CGRectZero];
        labNoImage.minY = 26;
        labNoImage.text = @"暂无图片";
        [labNoImage sizeToFit];
        labNoImage.frame = CGRectMake((_svPhoto.width - labNoImage.width) / 2, 40, labNoImage.width, labNoImage.height);
        labNoImage.textAlignment = NSTextAlignmentCenter;
        labNoImage.textColor = kColorGrey2;
        [_svPhoto addSubview:labNoImage];
    }
    else{
        CGFloat minX = 0.0f;
        for (int i = 0; i<[thumbimgurls count]; i++) {
            
            if (i%3 == 0) {
                minX += (_svPhoto.width - 3*90) / 4;
            }
            // 图片按钮
            UIImageView *amImgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(minX, 10, 90, 67.5)];
            amImgPhoto.frame = CGRectMake(minX, 10, 90, 67.5);
            amImgPhoto.tag = KCarPhotoTag + i;
            [_svPhoto addSubview:amImgPhoto];
            [amImgPhoto sd_setImageWithURL:[NSURL URLWithString:[thumbimgurls objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"home_default"]];
            
            // 查看大图
            UIButton *photoBtn = [[UIButton alloc] init];
            photoBtn.frame = CGRectMake(minX, 10, 90, 67.5);
            photoBtn.tag = i;
            [photoBtn addTarget:self action:@selector(onClickPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
            photoBtn.backgroundColor = [UIColor clearColor];
            [_svPhoto addSubview:photoBtn];
            
            minX = amImgPhoto.maxX + (_svPhoto.width - 3*90) / 4;
        }
    }
    
    _svPhoto.contentSize = CGSizeMake(([thumbimgurls count] % 3 == 0 ? [thumbimgurls count] / 3 * _svPhoto.width : (([thumbimgurls count] / 3 + 1) * _svPhoto.width)), _svPhoto.height);
    
    _pcPhoto.numberOfPages = [thumbimgurls count] % 3 == 0 ? [thumbimgurls count] / 3 : ([thumbimgurls count] / 3 + 1);
    [_pcPhoto setCurrentPage:0];
    
    CGFloat marginLift = 130;
    UIView *vBasicHeadBg = (UIView *)[self viewWithTag:kBasicHeadBgTag];
    
    // 新车
    if ([_mCarInfoEdit.isnewcar integerValue] == 1) {
        UIButton *btnNewCar = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, 35, vBasicHeadBg.height)];
        btnNewCar.tag = UCUserCarDetailViewPromptNewCar;
        [btnNewCar addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnNewCar setImage:[UIImage imageNamed:@"new_car"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnNewCar];
        
        marginLift = btnNewCar.maxX;
    }
    // 延保
    if ([_mCarInfoEdit.extendedrepair integerValue] == 1) {
        UIButton *btnExtended = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, 35, vBasicHeadBg.height)];
        btnExtended.tag = UCUserCarDetailViewPromptExtended;
        [btnExtended addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnExtended setImage:[UIImage imageNamed:@"ext_warrant"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnExtended];
    }
    // 名称
    _labCarName.text = _mCarInfoEdit.carnameText;
    CGSize labCarNameSize = [_labCarName.text sizeWithFont:_labCarName.font constrainedToSize:CGSizeMake(_labCarName.width, CGFLOAT_MAX) lineBreakMode:_labCarName.lineBreakMode];
    _labCarName.size = CGSizeMake(labCarNameSize.width, labCarNameSize.height > 13.8 ? labCarNameSize.height : 13.8);
    _labCarModel.text = _mCarInfoEdit.productnameText;
    [_labCarModel sizeToFit];
    _labCarModel.minY = _labCarName.maxY + 2;
    
    NSString *strDisplacement = _mCarInfoEdit.displacementText;
    NSString *strGearboxText = [NSString stringWithFormat:@"%@ %@",_mCarInfoEdit.gearboxText, (strDisplacement.length > 0 ? [NSString stringWithFormat:@"%@L",strDisplacement] : @"")];
    _labGearbox.text = [strGearboxText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [_labGearbox sizeToFit];
    _labGearbox.minY = _labCarModel.maxY + 2;
    
    _labSalesPersonTitle.minY = _labGearbox.maxY + 14;
    _labSalesPerson.minY = _labSalesPersonTitle.minY;
    _labPhoneTitle.minY = _labSalesPerson.maxY + 15;
    _labPhone.minY = _labPhoneTitle.minY;
    
    _labSalesPerson.text = (_mCarInfoEdit.salesPerson.salesname.length > 0 ? _mCarInfoEdit.salesPerson.salesname : @"");
    _labPhone.text = _mCarInfoEdit.salesPerson.salesphone.length > 0 ? _mCarInfoEdit.salesPerson.salesphone : @"";
    
    for (int i = 0; i < 2; i++) {
        UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(KMarginLefLine, _labPhone.maxY + (i == 0 ? 12 : 56), _vPriceAndOther.width - KMarginLefLine, kLinePixel) color:kColorNewLine];
        [_vCarBasicInfo addSubview:vLine1];
    }
    
    // 价格和其他
    _vPriceAndOther.minY = _labPhone.maxY + 12;
    
    // 预售价格额
    _labPrice.text = _mCarInfoEdit.bookpriceText;
    [_labPrice sizeToFit];
    _labPriceUnit.minX = _labPrice.maxX + 2;
    
    if (_labPrice.text.length == 0)
        _labPriceUnit.hidden = YES;
    else
        _labPriceUnit.hidden = NO;
    
    // 过户费用、所在城市、行驶里程、车辆用途、车辆颜色
    NSString *strIsincludetransferfee = _mCarInfoEdit.isincludetransferfeeText;
    NSString *strArea = [NSString stringWithFormat:@"%@ %@",_mCarInfoEdit.provinceidText, _mCarInfoEdit.cityidText];
    NSString *strDrivemileage = _mCarInfoEdit.drivemileageText;
    NSString *strPurpose = _userStyle == UserStyleBusiness ? _mCarInfoEdit.purposeidText : nil;
    NSString *strColor = _mCarInfoEdit.coloridText;
    
    NSArray *labBasicInfos = _userStyle == UserStyleBusiness ? [NSArray arrayWithObjects:strIsincludetransferfee, strArea, strDrivemileage, strPurpose, strColor, nil] : [NSArray arrayWithObjects:strIsincludetransferfee, strArea, strDrivemileage, strColor, nil];
    
    CGFloat licenseHeight = 0.f;
    
    for (int i = 0; i < [labBasicInfos count]; i ++) {
        UILabel *tempLabel = (UILabel *)[self viewWithTag:KlabCarBasicInfoTag + i];
        tempLabel.text = [NSString stringWithFormat:@"%@",[labBasicInfos objectAtIndex:i]];
        tempLabel.textColor = kColorGrey2;
        
        if (i == 2 && [tempLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
            tempLabel.font = [UIFont boldSystemFontOfSize:17];
            tempLabel.textColor = kColorOrange;
            
            // 万公里单位
            CGSize labSize = [tempLabel.text sizeWithFont:tempLabel.font forWidth:200 lineBreakMode:tempLabel.lineBreakMode];
            UILabel *labMileageUnit = [[UILabel alloc] initWithClearFrame:CGRectMake(tempLabel.minX + labSize.width + 2, tempLabel.minY, 100, tempLabel.height)];
            labMileageUnit.textColor = kColorOrange;
            labMileageUnit.text = @"万公里";
            labMileageUnit.font = [UIFont systemFontOfSize:15];
            labMileageUnit.textColor = kColorGrey2;
            [tempLabel.superview addSubview:labMileageUnit];
            
            if (DEVICE_IS_IPHONE5)
                tempLabel.minY += 1;
        }
        licenseHeight = tempLabel.maxY;
        
    }
    _vCarBasicInfo.height = _vPriceAndOther.maxY;
    // 牌照信息
    _vLicense.minY = _vCarBasicInfo.maxY;
    
    NSMutableArray *licenseInfos = [[NSMutableArray alloc] init];
    
    //首次上牌时间
    [licenseInfos addObject:_mCarInfoEdit.firstregtimeText];
    [licenseInfos addObject:_mCarInfoEdit.verifytimeText];
    [licenseInfos addObject:_mCarInfoEdit.insurancedateText];
    [licenseInfos addObject:_mCarInfoEdit.veticaltaxtimeText];
    // 个人
    if (_userStyle == UserStylePersonal) {
        [licenseInfos addObject:_mCarInfoEdit.drivingpermitText];
        [licenseInfos addObject:_mCarInfoEdit.registrationText];
        [licenseInfos addObject:_mCarInfoEdit.invoiceText];
    }
    // 商家
    else{
        _vDescription.minY = _vLicense.maxY;
    }
    for (int i = 0; i < [licenseInfos count]; i++) {
        UILabel * labContent = (UILabel *)[self viewWithTag:KlabLicenseContenTag + i];
        labContent.text = [NSString stringWithFormat:@"%@", [licenseInfos objectAtIndex:i]];
    }
    if (_userStyle == UserStyleBusiness) {
        // 延长质保
        if (([_mCarInfoEdit.qualityassdate integerValue] > 0 && [_mCarInfoEdit.qualityassmile floatValue] > 0 && [_mCarInfoEdit.extendedrepair integerValue] == 1) || (_statusStyle == UCCarStatusListViewStyleNotfilled && [_mCarInfoEdit.isExtendedrepair integerValue] == 1)) {
            
            NSString *date = _mCarInfoEdit.qualityassdate ? [_mCarInfoEdit.qualityassdate stringValue] : @"-";
            NSString *mileage = _mCarInfoEdit.qualityassmile ? [_mCarInfoEdit.qualityassmile stringValue] : @"-";
            
            UILabel *labWarranty = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _vLicense.height - 7, (_vLicense.width - KMarginLefTitle * 2), 33)];
            labWarranty.font = [UIFont systemFontOfSize:15];
            labWarranty.text = [NSString stringWithFormat:@"延长质保：%@个月 / %@万公里", date, mileage];
            [_vLicense addSubview:labWarranty];
            _vLicense.height = labWarranty.maxY;
        }
        NSArray *thumbTestReportPhotos = [(_mCarInfoEdit.dctionthumbimg.length > 0 ? _mCarInfoEdit.dctionthumbimg : _mCarInfoEdit.dctionimg) componentsSeparatedByString:@","];
        if ((_mCarInfoEdit.certificatetype.integerValue == 10 || _mCarInfoEdit.certificatetype.integerValue == 30) && thumbTestReportPhotos.count > 0) {
            UILabel *labTestReport = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _vLicense.height, (_vLicense.width - KMarginLefTitle * 2), 30)];
            labTestReport.font = [UIFont systemFontOfSize:15];
            labTestReport.text = @"检测报告：";
            [_vLicense addSubview:labTestReport];
            _vLicense.height = labTestReport.maxY;
            
            // 检测报告图片
            _vCarTestReportlPhoto = [[UCThumbnailsView alloc] initWithFrame:CGRectMake(0, labTestReport.maxY, _vLicense.width, 90)];
            _vCarTestReportlPhoto.tag = UCUserCarDetailViewThumbnailsTestReport;
            _vCarTestReportlPhoto.backgroundColor = [UIColor whiteColor];
            _vCarTestReportlPhoto.delegate = self;
            [_vLicense addSubview:_vCarTestReportlPhoto];
            
            // 加载数据
            _vCarTestReportlPhoto.thumbimgurls = thumbTestReportPhotos;
            [_vCarTestReportlPhoto reloadPhoto];
            
            _vLicense.height = _vCarTestReportlPhoto.maxY;
        }
    }

    // 卖家描述
    _vDescription.minY = _vLicense.maxY;
    if (_mCarInfoEdit.usercomment.length > 0) {
        _labDescriptionContent.text = _mCarInfoEdit.usercomment;
        CGSize labDescriptionContentSize = [_labDescriptionContent.text sizeWithFont:_labDescriptionContent.font constrainedToSize:CGSizeMake(_vDescription.width - 40, CGFLOAT_MAX) lineBreakMode:_labDescriptionContent.lineBreakMode];
        _labDescriptionContent.frame = CGRectMake(KMarginLefTitle, 30, labDescriptionContentSize.width, labDescriptionContentSize.height + 16 * 2);
        _vDescription.height = _labDescriptionContent.maxY;
    }else{
        _vDescription.height = 0;
    }
    
    _svCarInfo.contentSize = CGSizeMake(_svCarInfo.width, _vDescription.maxY);
    
}

/** 记录统计时间 */
- (void)recordEvent
{
    UserInfoModel *mUserInfo = nil;
    NSMutableDictionary *dic = nil;
    if (_userStyle == UserStyleBusiness) {
        mUserInfo = [AMCacheManage currentUserInfo];
        // 未填完
        dic = _statusStyle == UCCarStatusListViewStyleNotfilled ? [NSMutableDictionary dictionaryWithObjectsAndKeys:mUserInfo.userid, @"userid#4", nil] : [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarInfoEdit.carid, @"objectid#1", mUserInfo.userid, @"userid#4", nil];
    } else {
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarInfoEdit.carid, @"objectid#1", nil];
    }
    
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing: // 在售车
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessreadydetailsource : pv_3_1_personreadydetailsource];
            [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsellingdetail_pv : usercarsellingdetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            break;
        case UCCarStatusListViewStyleSaled: // 已售车
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesssolddetailsource : pv_3_1_personsolddetailsource];
            [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsolddetail_pv : usercarsolddetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            break;
        case UCCarStatusListViewStyleChecking: // 审核中
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessreviewdetailsource : pv_3_1_personreviewdetailsource];
            [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarreviewdetail_pv : usercarreviewdetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            break;
        case UCCarStatusListViewStyleNotpassed: // 未通过
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessnotdetailsource : pv_3_1_personnotdetailsource];
            [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotthroughdetail_pv : usercarnotthroughdetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            break;
        case UCCarStatusListViewStyleNotfilled: // 未填完
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesswithoutdetailsource : pv_3_1_personwithoutdetailsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:dealercarnotfinishdetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:usercarnotfinishdetail_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleInvalid: // 已过期
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesshasexpiredsource : pv_3_1_ersonhasexpiredsource];
            [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarexpireddetail_pv : usercarexpireddetail_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            break;
    }
}

/** 删除cell */
-(void)removeCarStatusListCell
{
    //执行删除行代理
    if (self.delegate) {
        if (_carId) {
            if ([self.delegate respondsToSelector:@selector(removeCarFromList:carOperate:)]) {
                //删除行
                [self.delegate removeCarFromList:_mCarInfoEdit carOperate:CarOperateDeleted];
                
            }
        }
    }
}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 查看大图 */
- (void)onClickPhotoBtn:(UIButton *)btn
{
    NSArray *images = [[NSArray alloc] initWithArray:[_mCarInfoEdit.imgurls componentsSeparatedByString:@","]];
    NSArray *thumbimgurls = [[NSArray alloc] initWithArray:[_mCarInfoEdit.thumbimgurls componentsSeparatedByString:@","]];
    
    UCImageBrowseView *vImageBrowse = [[UCImageBrowseView alloc] initWithFrame:self.bounds index:btn.tag thumbimgurls:thumbimgurls imageUrls:images];
    
    [[MainViewController sharedVCMain] openView:vImageBrowse animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    
    if (_userStyle == UserStyleBusiness) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarInfoEdit.carid.stringValue, @"objectid#1", mUserInfo.userid, @"dealerid#5", mUserInfo.userid, @"userid#4", nil];
        [UMSAgent postEvent:dealerbigpicture_pv page_name:NSStringFromClass(vImageBrowse.class) eventargvs:dic];
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarInfoEdit.carid.stringValue, @"objectid#1", nil];
        [UMSAgent postEvent:userbigpicture_pv page_name:NSStringFromClass(vImageBrowse.class) eventargvs:dic];
    }
}

/** 操作车辆 */
- (void)onClickActionBtn:(UIButton *)btn
{
    // 修改 & 继续修改
    if (btn.tag == UCCarStatusListViewButtonActionContinueFill || btn.tag == UCCarStatusListViewButtonActionModify) {
        
        UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:_mCarInfoEdit];
        vSaleCar.delegate = self.delegate;
        [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
        
        return;
    }
    
    switch (btn.tag) {
            
        case UCCarStatusListViewButtonActionMarkSold:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否标为已售" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            alert.tag = UCCarStatusListViewButtonActionMarkSold;
            [alert show];
        }
            break;
            
        case UCCarStatusListViewButtonActionDelete:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确认删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            alert.tag = UCCarStatusListViewButtonActionDelete;
            [alert show];
        }
            break;
            
        case UCCarStatusListViewButtonActionReasons:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:(_mCarInfoEdit.errortext.length > 0 ? _mCarInfoEdit.errortext : @"无被退回原因")
                                                           message:nil
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
            break;
            
        case UCCarStatusListViewButtonActionRefresh:
            [self carOperate:CarOperateUpdate mCarInfo:_mCarInfoEdit salePrice:nil];
            break;
            
        case UCCarStatusListViewButtonActionRepublish:
            [self carOperate:CarOperateRelease mCarInfo:_mCarInfoEdit salePrice:nil];
            break;
            
        default:
            break;
    }
    
}

/** 点击提示按钮 */
- (void)onClickPromptBtn:(UIButton *)btn
{
    if (btn.tag == UCUserCarDetailViewPromptNewCar)
        [[AMToastView toastView] showMessage:@"本车车况近似新车" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCUserCarDetailViewPromptExtended)
        [[AMToastView toastView] showMessage:@"提供延长质保服务，可获得质保图标" icon:nil duration:AMToastDurationNormal];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        // 标为已售
        if (alertView.tag == UCCarStatusListViewButtonActionMarkSold) {
            
            [self carOperate:CarOperateSaled mCarInfo:_mCarInfoEdit salePrice:nil];
            
        }
        // 删除
        else if (alertView.tag == UCCarStatusListViewButtonActionDelete) {
            
            if (_statusStyle == UCCarStatusListViewStyleNotfilled) {
                // 删除未填完缓存
                NSMutableArray *mCarInfoDrafts = [NSMutableArray arrayWithArray:[AMCacheManage currentCarInfoEditDrafts]];
                NSInteger index = NSNotFound;
                for (int i = 0; i < mCarInfoDrafts.count; i++) {
                    UCCarInfoEditModel *mCarInfoDraft = [mCarInfoDrafts objectAtIndex:i];
                    // 找到对应的下标
                    if ([mCarInfoDraft.carid isEqualToNumber:_mCarInfoEdit.carid]) {
                        index = i;
                        break;
                    }
                }
                if (index != NSNotFound) {
                    // 移除对应的未填完车辆信息
                    [mCarInfoDrafts removeObjectAtIndex:index];
                    // 写入缓存
                    if (mCarInfoDrafts.count > 0)
                        [AMCacheManage setCurrentCarInfoEditDrafts:mCarInfoDrafts];
                    else
                        [AMCacheManage setCurrentCarInfoEditDrafts:nil];
                }
                
                [self removeCarStatusListCell];
                [self onClickBackBtn:nil];
            }else{
                [self carOperate:CarOperateDeleted mCarInfo:_mCarInfoEdit salePrice:nil];
            }
        }
    }
    
}

#pragma mark - UCThumbnailsViewDelegate
- (void)UCThumbnailsView:(UCThumbnailsView *)vThumbnails onClickPhotoBtn:(UIButton *)btn
{
    NSArray *thumbimgurls = nil;
    NSArray *images = nil;
    if (vThumbnails.tag == UCUserCarDetailViewThumbnailsTestReport) {
        thumbimgurls = [_mCarInfoEdit.dctionthumbimg componentsSeparatedByString:@","];
        images = [_mCarInfoEdit.dctionimg componentsSeparatedByString:@","];
        if ([thumbimgurls count] == 0)
            thumbimgurls = images;
    }
    
    if (images.count > 0) {
        [[MainViewController sharedVCMain] openView:[[UCImageBrowseView alloc] initWithFrame:self.bounds index:btn.tag thumbimgurls:thumbimgurls imageUrls:images] animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    } else {
        [[AMToastView toastView] showMessage:@"数据出错啦，请重试" icon:kImageRequestError duration:AMToastDurationNormal];
    }
    
}

#pragma  mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    CGPoint offsetofScrollView = scrollView1.contentOffset;
    UIPageControl *pcPhotot = (UIPageControl *)[self viewWithTag:32141876];
    [pcPhotot setCurrentPage:offsetofScrollView.x / scrollView1.frame.size.width];
}

#pragma mark - APIHelper
/** 车辆操作 */
- (void)carOperate:(CarOperate)operate mCarInfo:(UCCarInfoEditModel *)mCarInfo salePrice:(NSNumber *)salePrice
{
    // 记录统计事件
    [self recordEvent];
    
    if (!_apiCarAction)
        _apiCarAction = [[APIHelper alloc] init];
    [_apiCarAction cancel];
    
    __weak UCUserCarDetailView *vUserCarDetail = self;
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
        [_apiCarAction cancel];
        [[AMToastView toastView] hide];
    }];
    [_apiCarAction setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                // 处理成功
                if (mBase.returncode == 0) {
                    //删除,标为已售,重新发布
                    if (operate == CarOperateDeleted || operate == CarOperateSaled || operate == CarOperateRelease){
                        [vUserCarDetail removeCarStatusListCell];
                        [vUserCarDetail onClickBackBtn:nil];
                    }
                }
                else if (mBase.returncode == 2049005){
                    
                    message = @"身份验证失效，请重新登录";
                    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                        UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
                        [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    else{
                        UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
                        [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    [AMCacheManage setCurrentUserInfo:nil];
                }
                
                else if (mBase.returncode == 2049010)
                    message = @"操作失败，请稍后尝试";
                else if (mBase.returncode == 2049011)
                    message = @"该信息已删除，无法操作";
                else if ((mBase.returncode == 2049013 && operate == CarOperateSaled) || mBase.returncode == 2049012)
                    message = @"该车为已售车源，无法操作";
                else if (mBase.returncode == 2049013 && operate == CarOperateDeleted)
                    message = @"该信息已删除，无法操作";
                else if (mBase.returncode == 2049014)
                    message = @"该车为审核中车源，无法操作";
                else if (mBase.returncode == 2049015)
                    message = @"该车为审核未通过车源，无法操作";
                else if (mBase.returncode == 2049020)
                    message = @"没有操作权限或信息已删除，无法操作";
                else
                    message = @"网络不给力，请稍后尝试";
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            }
        }
    }];
    
    [_apiCarAction carOperate:operate mCarInfo:mCarInfo];

}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiCarAction cancel];
}

@end
