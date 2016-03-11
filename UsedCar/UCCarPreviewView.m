//
//  UCCarPreviewView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//
#import "UCCarPreviewView.h"
#import "APIHelper.h"
#import "UCTopBar.h"
#import "MainViewController.h"
#import "UCCarDetailInfoModel.h"
#import "UCReferencePriceModel.h"
#import "AMToastView.h"
#import "UCImageBrowseView.h"
#import "UCRecommendCarList.h"
#import "UIImage+Util.h"
#import "AMCacheManage.h"
#import "UCBusinessInfoView.h"
#import "UCMainView.h"
#import "UCTopBar.h"
#import "UCViewCarView.h"
#import "UCActivityView.h"
#import "NSString+Util.h"
#import "UCCarInfoModel.h"
#import "UCCarListView.h"
#import "UCPriceModel.h"

#define KColorBackground        [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05]

#define KOptionsBarHeight       45
#define KMarginLefTitle         20
#define KMarginLefLine          12
#define KMarginLefContent       93
#define KContentHeight          50

#define KlabCarBasicInfoTag     37487563
#define KlabLicenseTitleTag     19332338
#define KlabLicenseContenTag    22239846
#define kBasicTitleLabel        45748573
#define kBasicHeadBgTag         45938564

#define zero 0

@interface UCCarPreviewView ()

@property (nonatomic) BOOL isBusiness;
@property (nonatomic, strong) UIWebView *wvPrice;
@property (nonatomic, strong) APIHelper *apiHelperPrice;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarDetailInfoModel *mCarDetailInfo;
@property (nonatomic, strong) AMBlurView *bvOptions;
@property (nonatomic, strong) UILabel *labPrice;
@property (nonatomic, strong) UILabel *labDescriptionContent;
@property (nonatomic, strong) UILabel *labCarName;
@property (nonatomic, strong) UILabel *labCarModel;
@property (nonatomic, strong) UILabel *labGearbox;
@property (nonatomic, strong) UILabel *labPriceUnit;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UILabel *labKind;
@property (nonatomic, strong) UILabel *labTelephone;
@property (nonatomic, strong) UIView *vLicense;
@property (nonatomic, strong) UIView *vDescription;
@property (nonatomic, strong) UIView *vCarName;                         // 车辆名称视图
@property (nonatomic, strong) UIView *vCarBasicLine;
@property (nonatomic, strong) UIView *vPriceAndOther;
@property (nonatomic, strong) UIView *vPriceLine;
@property (nonatomic, strong) UIView *vCarBasicInfo;
@property (nonatomic, strong) UIScrollView *svCarInfo;
@property (nonatomic, strong) UCThumbnailsView *vCarThumbPhoto;         // 车缩略图片
@property (nonatomic, strong) UCThumbnailsView *vCarTestReportlPhoto;   // 检测报告
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UCReferencePriceModel *mReferencePrice; // 报价信息

@end

@implementation UCCarPreviewView

/** 发车预览 */
- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo isBusiness:(BOOL)isBusiness
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMStatistics event:isBusiness ? pv_3_1_buinesspreview : pv_3_1_personpreview];
        [UMSAgent postEvent:isBusiness ? dealerpreview_pv : userpreview_pv page_name:NSStringFromClass(self.class)];
        _isBusiness = isBusiness;
        // 初始化
        [self initTitleView:nil];
        // 获取数据
        self.mCarDetailInfo = [[UCCarDetailInfoModel alloc] init];
        self.mCarDetailInfo = mCarDetailInfo;
        [self initView:mCarDetailInfo.carid];
        [self reloadView];
    }
    return self;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView:(NSNumber *)carid
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    // 标题
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _tbTop.btnLeft.width, _tbTop.btnLeft.height)];
    [btnBack setImage:[UIImage imageNamed:@"topbar_backbtn"] forState:UIControlStateNormal];
    btnBack.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnBack.titleLabel.font = [UIFont systemFontOfSize:15];
    btnBack.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    btnBack.exclusiveTouch = YES;
    [btnBack setTitleColor:kColorGrey3 forState:UIControlStateHighlighted];
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [_tbTop.btnLeft addSubview:btnBack];
    
    [_tbTop.btnTitle setTitle:@"车辆详情预览" forState:UIControlStateNormal];
    _obFilter.hidden = YES;
    
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
}

/** 初始化View */
- (void)initView:(NSNumber *)carid
{
    CGFloat svCarInfoMinY = _tbTop.maxY;
    
    /* 信息视图 */
    _svCarInfo = [[UIScrollView alloc] initWithFrame:CGRectMake(0, svCarInfoMinY, self.width, self.height -  svCarInfoMinY - KOptionsBarHeight)];
    _svCarInfo.delegate = self;
    
    // 时间 & 图片 视图
    UIView *vPhotoTabTime = [[UIView alloc] initWithFrame:CGRectMake(0, _obFilter.maxY, self.width, 101)];
    vPhotoTabTime.backgroundColor = kColorWhite;
    
    // 车辆图片缩略图
    _vCarThumbPhoto = [[UCThumbnailsView alloc] initWithFrame:CGRectMake(0, 0, vPhotoTabTime.width, 101)];
    _vCarThumbPhoto.tag = UCCarPreviewViewThumbnailsCarPhoto;
    _vCarThumbPhoto.backgroundColor = kColorWhite;
    _vCarThumbPhoto.delegate = self;
    
    [_svCarInfo addSubview:vPhotoTabTime];
    
    // 车辆基础信息
    _vCarBasicInfo = [[UIView alloc] initWithFrame:CGRectMake(0, vPhotoTabTime.maxY, self.width, 0)];
    _vCarBasicInfo.backgroundColor = [UIColor clearColor];
    
    // 发布时间view
    UIView *vTime = nil;
    
    // 车辆信息标题背景
    UIView *vBasicHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, vTime ? vTime.maxY : 0, _vCarBasicInfo.width, 30)];
    vBasicHeadBg.tag = kBasicHeadBgTag;
    vBasicHeadBg.backgroundColor = KColorBackground;
    
    // 车辆基础信息 (问题1: labBasicTitle 与 vBasicHeadBg 坐标手动同步? 问题2: vBasicHeadBg 是盖在 labBasicTitle 上的?)
    UILabel *labBasicTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, vBasicHeadBg.minY, vBasicHeadBg.width - KMarginLefTitle, vBasicHeadBg.height)];
    labBasicTitle.tag = kBasicTitleLabel;
    labBasicTitle.text = @"车辆基础信息";
    labBasicTitle.textColor = kColorBlue1;
    labBasicTitle.font = [UIFont systemFontOfSize:16];
    [_vCarBasicInfo addSubview:labBasicTitle];
    
    // 车辆名车视图
    _vCarName = [[UIView alloc] initWithFrame:CGRectMake(0, labBasicTitle.maxY, self.width, 100)];
    _vCarName.backgroundColor = [UIColor clearColor];
    
    // 车辆信息标题
    UILabel *labNameTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, _vCarBasicInfo.width - KMarginLefTitle, KContentHeight)];
    labNameTitle.text = @"车辆信息：";
    labNameTitle.font = [UIFont systemFontOfSize:15];
    [_vCarName addSubview:labNameTitle];
    
    // 车系
    _labCarName = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, 16, _vCarBasicInfo.width - KMarginLefContent - 55, 0)];
    _labCarName.textColor = kColorGrey2;
    _labCarName.numberOfLines = 0;
    _labCarName.font = [UIFont systemFontOfSize:15];
    _labCarName.lineBreakMode = NSLineBreakByCharWrapping;
    [_vCarName addSubview:_labCarName];
    
    // 车型
    _labCarModel = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefContent, 0, 0, 0)];
    _labCarModel.textColor = kColorGrey2;
    _labCarModel.font = [UIFont systemFontOfSize:15];
    [_vCarName addSubview:_labCarModel];
    
    // 变速箱 排量
    _labGearbox = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefContent, 100, 0, 0)];
    _labGearbox.textColor = kColorGrey2;
    _labGearbox.font = [UIFont systemFontOfSize:15];
    [_vCarName addSubview:_labGearbox];
    
    [_vCarBasicInfo addSubview:_vCarName];
    
    // 车辆名称分割线
    _vCarBasicLine = [[UIView alloc] initLineWithFrame:CGRectMake(KMarginLefLine, _labGearbox.maxY, _svCarInfo.width - KMarginLefLine, kLinePixel) color:kColorNewLine];
    [_vCarBasicInfo addSubview:_vCarBasicLine];
    
    /* 预售价格 & 其他基本信息 */
    _vPriceAndOther = [[UIView alloc] initWithFrame:CGRectMake(0, _vCarBasicLine.maxY, _vCarBasicInfo.width, zero)];
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
    
    // 参考价
    _wvPrice = [[UIWebView alloc] initWithFrame:CGRectMake(KMarginLefTitle - 7, labPriceTitle.maxY - 7, _vPriceAndOther.width, 30)];
    _wvPrice.scrollView.scrollEnabled = NO;
    _wvPrice.scrollView.backgroundColor = [UIColor clearColor];
    _wvPrice.backgroundColor = [UIColor clearColor];
    [_vPriceAndOther addSubview:_wvPrice];
    
    // 预售价格分割线
    _vPriceLine = [[UIView alloc] initLineWithFrame:CGRectMake(KMarginLefLine, _wvPrice.maxY, _vPriceAndOther.width, kLinePixel) color:kColorNewLine];
    [_vPriceAndOther addSubview:_vPriceLine];
    
    // 过户费用、所在城市、行驶里程、车辆用途、车辆颜色
    NSArray *basicTitles = nil;
    basicTitles = !_isBusiness ? @[@"过户费用：", @"所在城市：", @"行驶里程：", @"车辆颜色："] : @[@"过户费用：", @"所在城市：", @"行驶里程：", @"车辆用途：", @"车辆颜色："];
    for (int i = 0 ; i < [basicTitles count]; i++) {
        UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefTitle, _vPriceLine.maxY + 33 * i + 8, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labTitle.text = [basicTitles objectAtIndex:i];
        labTitle.font = [UIFont systemFontOfSize:15];
        [_vPriceAndOther addSubview:labTitle];
        
        UILabel *labContent = [[UILabel alloc] initWithFrame:CGRectMake(KMarginLefContent, _vPriceLine.maxY + 33 * i + 8, _vPriceAndOther.width - KMarginLefTitle, 33)];
        labContent.font = [UIFont systemFontOfSize:15];
        labContent.tag = KlabCarBasicInfoTag + i;
        _labCarName.textColor = kColorGrey2;
        [_vPriceAndOther addSubview:labContent];
        
        _vPriceAndOther.height = labTitle.maxY + 7;
        
    }
    
    _vCarBasicInfo.height = _vPriceAndOther.maxY;
    
    /* 车辆牌照信息 */
    _vLicense = [[UIView alloc]initWithFrame:CGRectMake(0, _vCarBasicInfo.maxY, _svCarInfo.width, 999)];
    _vLicense.backgroundColor = kColorWhite;
    [_svCarInfo addSubview:_vLicense];
    
    // 车辆牌照信息标题
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
    if (!_isBusiness)
        licenseTitles = @[@"首次上牌时间：",@"车辆年审时间：",@"交强险截止日期：",@"车船使用税有效时间：",@"行驶证：",@"登记证：",@"购车发票："];
    else
        licenseTitles = @[@"首次上牌时间：",@"车辆年审时间：",@"交强险截止日期：",@"车船使用税有效时间："];
    
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
    
    // 卖家描述标题
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
    
    // 查看相关车辆信息
    
    // 操作项视图
    _bvOptions = [[AMBlurView alloc] initWithFrame:CGRectMake(0, self.height - KOptionsBarHeight, self.width, KOptionsBarHeight)];
    _bvOptions.blurTintColor = [UIColor colorWithWhite:0 alpha:IOS7_OR_LATER ? 0.7 : 0.8];
    _bvOptions.userInteractionEnabled = NO;
    
    _labName = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, 110, 22)];
    _labName.textColor = kColorWhite;
    _labName.backgroundColor = [UIColor clearColor];
    _labName.font = [UIFont systemFontOfSize:14];
    
    _labKind = [[UILabel alloc] initWithFrame:CGRectMake(50, 4, 150, 22)];
    _labKind.textColor = kColorWhite;
    _labKind.backgroundColor = [UIColor clearColor];
    _labKind.font = [UIFont systemFontOfSize:11];
    
    _labTelephone = [[UILabel alloc] initWithFrame:CGRectMake(12, 21, 150, 22)];
    _labTelephone.textColor = kColorWhite;
    _labTelephone.backgroundColor = [UIColor clearColor];
    _labTelephone.font = [UIFont systemFontOfSize:11];
    
    [_bvOptions addSubview:_labName];
    [_bvOptions addSubview:_labKind];
    [_bvOptions addSubview:_labTelephone];
    
    NSArray *titles = _isBusiness ? @[@"联系",@"商铺",@"预约看车"] : @[@"联系"];
    CGFloat marginLeft = _isBusiness ? _bvOptions.width / 2 : _bvOptions.width - 50;
    CGFloat widthBtn = (_bvOptions.width - marginLeft) / [titles count];
    
    for (int i = 0; i < [titles count]; i++) {
        UIButton *btnAction = [[UIButton alloc] init];
        if (i == 0 || i == 1)
            btnAction.frame = CGRectMake(marginLeft + i * widthBtn - 21, 0, widthBtn + 10, KOptionsBarHeight);
        else if (i == 2)
            btnAction.frame = CGRectMake(marginLeft + i * widthBtn - 10, 0, widthBtn + 10, KOptionsBarHeight);
        btnAction.backgroundColor = [UIColor clearColor];
        [btnAction setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        btnAction.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [btnAction setImageEdgeInsets:UIEdgeInsetsMake(-16, 0, 0, -btnAction.titleLabel.width)];
        [btnAction setBackgroundImage:[UIImage imageWithColor:kColorGrey2 size:btnAction.size] forState:UIControlStateSelected];
        [btnAction setBackgroundImage:[UIImage imageWithColor:kColorGrey2 size:btnAction.size] forState:UIControlStateHighlighted];
        
        [_bvOptions addSubview:btnAction];
    }
    
    // 添加到时间 & 图片 视图
    [vPhotoTabTime addSubview:_vCarThumbPhoto];
    
    // 车辆信息视图
    // 基本信息视图
    [_vCarBasicInfo addSubview:vBasicHeadBg];
    [_svCarInfo addSubview:_vCarBasicInfo];
    // 添加到主视图
    [self addSubview:_svCarInfo];
    // 添加商家爱信息
    [self addSubview:_bvOptions];
}

#pragma mark - private Method
/** 加载数据 */
- (void)reloadView
{
    // 加载图片
    _vCarThumbPhoto.thumbimgurls = [_mCarDetailInfo.thumbimgurlsText componentsSeparatedByString:@","];
    [_vCarThumbPhoto reloadPhoto];
    
    CGFloat marginLift = 125;
    CGFloat width = 32;
    UIView *vBasicHeadBg = (UIView *)[self viewWithTag:kBasicHeadBgTag];
    // 保证金
    if ([_mCarDetailInfo.hasDeposit integerValue] > 0) {
        UIButton *btnAuthentication = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnAuthentication.tag = UCCarPreviewViewPromptHasDeposit;
        [btnAuthentication addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnAuthentication setImage:[UIImage imageNamed:@"deposit_icon"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnAuthentication];
        
        marginLift = btnAuthentication.maxX;
    }
    // 厂家认证
    if ([_mCarDetailInfo.creditid integerValue] > 0) {
        UIButton *btnAuthentication = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnAuthentication.tag = UCCarPreviewViewPromptAuthentication;
        [btnAuthentication addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnAuthentication setImage:[UIImage imageNamed:@"factory_approve"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnAuthentication];
        
        marginLift = btnAuthentication.maxX;
    }
    // 延保
    if ([_mCarDetailInfo.extendedrepair integerValue] == 1) {
        UIButton *btnExtended = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnExtended.tag = UCCarPreviewViewPromptExtended;
        [btnExtended addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnExtended setImage:[UIImage imageNamed:@"ext_warrant"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnExtended];
        
        marginLift = btnExtended.maxX;
    }
    // 原厂质保
    else if ([_mCarDetailInfo.haswarranty integerValue] == 1) {
        UIButton *btnhaswarranty = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnhaswarranty.tag = UCCarPreviewViewPromptHaswarranty;
        [btnhaswarranty addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnhaswarranty setImage:[UIImage imageNamed:@"factory_warrant"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnhaswarranty];
        
        marginLift = btnhaswarranty.maxX;
    }
    // 新车
    if ([_mCarDetailInfo.isnewcar integerValue] == 1) {
        UIButton *btnNewCar = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnNewCar.tag = UCCarPreviewViewPromptNewCar;
        [btnNewCar addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnNewCar setImage:[UIImage imageNamed:@"new_car"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnNewCar];
        
        marginLift = btnNewCar.maxX;
    }
    
    // 名称
    _labCarName.text = _mCarDetailInfo.carnameText.length > 0 ? _mCarDetailInfo.carnameText : _mCarDetailInfo.seriesidText;
    CGSize labCarNameSize = [_labCarName.text sizeWithFont:_labCarName.font constrainedToSize:CGSizeMake(_labCarName.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    _labCarName.height = labCarNameSize.height;
    _labCarModel.text = _mCarDetailInfo.carnameText.length > 0 ? @"" : _mCarDetailInfo.productidText;
    [_labCarModel sizeToFit];
    _labCarModel.minY = _labCarName.maxY + 2;
    _labGearbox.text = [NSString stringWithFormat:@"%@%@",_mCarDetailInfo.gearboxText,(_mCarDetailInfo.displacementText.length > 0 && ![_mCarDetailInfo.displacementText isEqualToString:@"0"]) ? [NSString stringWithFormat:@" %@L",_mCarDetailInfo.displacementText] : @""];
    [_labGearbox sizeToFit];
    
    _labGearbox.minY = _labCarModel.maxY + 2;
    
    // 调整车辆名称视图位置
    _vCarName.height = _labGearbox.maxY + 8;
    
    // 价格和其他
    _vCarBasicLine.minY = _vCarName.maxY;
    _vPriceAndOther.minY = _vCarBasicLine.maxY;
    
    // 预售价格额
    _labPrice.text = _mCarDetailInfo.bookpriceText;
    [_labPrice sizeToFit];
    _labPriceUnit.minX = _labPrice.maxX + 2;
    
    // 过户费用、所在城市、行驶里程、车辆用途、车辆颜色
    NSString *strIsincludetransferfee = _mCarDetailInfo.isincludetransferfeeText;
    NSString *strArea = [NSString stringWithFormat:@"%@ %@", _mCarDetailInfo.provinceidText, _mCarDetailInfo.cityidText];
    NSString *strDrivemileage = _mCarDetailInfo.drivemileageText;
    NSString *strPurpose = !_isBusiness ? nil : _mCarDetailInfo.purposeidText;
    NSString *strColor = _mCarDetailInfo.coloridText;
    
    NSArray *labBasicInfos = !_isBusiness ? [NSArray arrayWithObjects:strIsincludetransferfee, strArea, strDrivemileage, strColor, nil] : [NSArray arrayWithObjects:strIsincludetransferfee, strArea, strDrivemileage, strPurpose, strColor, nil];
    
    CGFloat licenseHeight = 0.f;
    
    for (int i = 0; i < labBasicInfos.count; i ++) {
        UILabel *tempLabel = (UILabel *)[self viewWithTag:KlabCarBasicInfoTag + i];
        tempLabel.text = [NSString stringWithFormat:@"%@",[labBasicInfos objectAtIndex:i]];
        tempLabel.textColor = kColorGrey2;
        
        if (i == 2) {
            tempLabel.textColor = kColorOrange;
            tempLabel.font = [UIFont boldSystemFontOfSize:17];
            
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
    if (_mCarDetailInfo.firstregtimeText.length < 4)
        [licenseInfos addObject:@"无"];
    else
        [licenseInfos addObject:[OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:_mCarDetailInfo.firstregtimeText]]];
    
    if (_mCarDetailInfo.verifytimeText.length < 4)
        [licenseInfos addObject:@"无"];
    else
        [licenseInfos addObject:[OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:_mCarDetailInfo.verifytimeText]]];
    
    if (_mCarDetailInfo.insurancedateText.length < 4)
        [licenseInfos addObject:@"无"];
    else
        [licenseInfos addObject:[OMG stringFromDateWithFormat:@"yyyy年MM月" date:[OMG dateFromStringWithFormat:@"yyyy-MM" string:_mCarDetailInfo.insurancedateText]]];
    
    if ([_mCarDetailInfo.veticaltaxtimeText isEqualToString:@"已过期"])
        [licenseInfos addObject:_mCarDetailInfo.veticaltaxtimeText];
    else if (_mCarDetailInfo.veticaltaxtimeText.length > 3)
        [licenseInfos addObject:[NSString stringWithFormat:@"%@年",[_mCarDetailInfo.veticaltaxtimeText substringToIndex:4]]];
    else
        [licenseInfos addObject:@"无"];
    
    // 商家
    if (_isBusiness){
        _vDescription.minY = _vLicense.maxY;
    }
    // 个人
    else
    {
        [licenseInfos addObject:_mCarDetailInfo.drivingpermitText];
        [licenseInfos addObject:_mCarDetailInfo.registrationText];
        [licenseInfos addObject:_mCarDetailInfo.invoiceText];
    }
    // 车辆牌照信息赋值
    for (int i = 0; i < [licenseInfos count]; i++) {
        UILabel * labContent = (UILabel *)[self viewWithTag:KlabLicenseContenTag + i];
        labContent.text = [NSString stringWithFormat:@"%@",[licenseInfos objectAtIndex:i]];
    }
    
    // 延长质保
    if ([_mCarDetailInfo.qualityassdate integerValue] > 0 && [_mCarDetailInfo.qualityassmile floatValue] > 0) {
        UILabel *labWarranty = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _vLicense.height - 7, (_vLicense.width - KMarginLefTitle * 2), 33)];
        labWarranty.font = [UIFont systemFontOfSize:15];
        labWarranty.text = [NSString stringWithFormat:@"延长质保：%d个月 / %0.1f万公里", [_mCarDetailInfo.qualityassdate integerValue], [_mCarDetailInfo.qualityassmile floatValue]];
        [_vLicense addSubview:labWarranty];
        _vLicense.height = labWarranty.maxY;
    }
    NSArray *thumbTestReportPhotos = [_mCarDetailInfo.dctionimg componentsSeparatedByString:@","];
    
    if ((_mCarDetailInfo.certificatetype.integerValue == 10 || _mCarDetailInfo.certificatetype.integerValue == 30) && thumbTestReportPhotos.count > 0) {
        UILabel *labTestReport = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, _vLicense.height, (_vLicense.width - KMarginLefTitle * 2), 30)];
        labTestReport.font = [UIFont systemFontOfSize:15];
        labTestReport.text = @"检测报告：";
        [_vLicense addSubview:labTestReport];
        _vLicense.height = labTestReport.maxY;
        
        // 检测报告图片
        _vCarTestReportlPhoto = [[UCThumbnailsView alloc] initWithFrame:CGRectMake(0, labTestReport.maxY, _vLicense.width, 90)];
        _vCarTestReportlPhoto.backgroundColor = kColorWhite;
        _vCarTestReportlPhoto.delegate = self;
        _vCarTestReportlPhoto.tag = UCCarPreviewViewThumbnailsTestReport;
        [_vLicense addSubview:_vCarTestReportlPhoto];
        
        // 加载数据
        _vCarTestReportlPhoto.thumbimgurls = thumbTestReportPhotos;
        [_vCarTestReportlPhoto reloadPhoto];
        
        _vLicense.height = _vCarTestReportlPhoto.maxY;
    }
    
    // 检测报告
    
    // 卖家描述
    _vDescription.minY = _vLicense.maxY;
    if (_mCarDetailInfo.usercommentText.length > 0) {
        _labDescriptionContent.text = _mCarDetailInfo.usercommentText;
        CGSize labDescriptionContentSize = [_labDescriptionContent.text sizeWithFont:_labDescriptionContent.font constrainedToSize:CGSizeMake(_vDescription.width - 40, CGFLOAT_MAX) lineBreakMode:_labDescriptionContent.lineBreakMode];
        _labDescriptionContent.frame = CGRectMake(KMarginLefTitle, 30, labDescriptionContentSize.width, labDescriptionContentSize.height + 16 *2);
        _vDescription.height = _labDescriptionContent.maxY;
    } else {
        _vDescription.height = 0;
    }
    
    _svCarInfo.contentSize = CGSizeMake(self.width, _vDescription.maxY);
    
    // 卖家信息
    _labName.text = _mCarDetailInfo.salesPerson.txtsalesname;
    CGSize labNameSize = [_labName.text sizeWithFont:_labName.font constrainedToSize:CGSizeMake(_labName.width, 100) lineBreakMode:_labName.lineBreakMode];
    _labKind.minX = _labName.minX + labNameSize.width;
    _labKind.text = [NSString stringWithFormat:@"(%@)",_isBusiness ? @"商家" : @"个人"];
    _labTelephone.text = [NSString stringWithFormat:@"%@(%@)",_mCarDetailInfo.salesPerson.txtsalesphone,_mCarDetailInfo.cityidText];
    
    // 获取参考价
    // 参考价
    UCPriceModel *mPriceModel = [[UCPriceModel alloc] init];
    mPriceModel.specid = _mCarDetailInfo.productid;
    if (_mCarDetailInfo.firstregtime.length >=6 && _mCarDetailInfo.firstregtime.length <= 7 ) {
        mPriceModel.firstregtime = [_mCarDetailInfo.firstregtime stringByReplacingOccurrencesOfString:@"-" withString:@","];
    } else if (_mCarDetailInfo.firstregtime.length >= 4) {
        mPriceModel.firstregtime = [_mCarDetailInfo.firstregtime substringToIndex:4];
    }
    mPriceModel.pid = [_mCarDetailInfo.provinceid integerValue] > 0 ? _mCarDetailInfo.provinceid : nil;
    mPriceModel.cid = [_mCarDetailInfo.cityid integerValue] > 0 ? _mCarDetailInfo.cityid : nil;
    mPriceModel.mileage = _mCarDetailInfo.drivemileage;
    mPriceModel.price = _mCarDetailInfo.bookprice;
    
    // 获取参考价
    [self getReferencePrice:mPriceModel];
    
    // 调整层级关系
    [self sendSubviewToBack:_svCarInfo];
}

#pragma mark - method
/** 加载参考价 */
- (void)loadReferencePrice:(UCReferencePriceModel *)mReferencePrice
{
    _mReferencePrice = mReferencePrice;
    
    NSString *strHtml = @"<span style=\"font-size:10px;color:#4a6da2;font-family:Helvetica;\">买车参考价:%@ &nbsp;新车4S店最低价:%@</span>";
    NSString *strReferenceprice = @"<span style=\"color:#999999;\"> &nbsp 暂无数据</span>";
    NSString *strNewcarprice = @"<span style=\"color:#999999;\"> 暂无数据</span>";
    if (mReferencePrice) {
        if (mReferencePrice.referenceprice.length > 0)
            strReferenceprice = [NSString stringWithFormat:@"<span style=\"color:#ff9813;\">%@</span>万元", mReferencePrice.referenceprice];
        if (mReferencePrice.newcarprice.length > 0)
            strNewcarprice = [NSString stringWithFormat:@"<span style=\"color:#ff9813;\">%@</span>万元", mReferencePrice.newcarprice];
    }
    
    [_wvPrice loadHTMLString:[NSString stringWithFormat:strHtml, strReferenceprice, strNewcarprice] baseURL:nil];
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 查看相关车型 */
- (void)onClickRelatedBtn:(UIButton *)btn
{
    [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailrelevant : c_3_1_personsourcedetailrelevant];
    UCRecommendCarList *vRecommendCarList = [[UCRecommendCarList alloc] initWithFrame:self.bounds mCarDetailInfo:_mCarDetailInfo];
    [[MainViewController sharedVCMain] openView:vRecommendCarList animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 查看原车信息 */
- (void)onClickNewCarsBtn:(UIButton *)btn
{
    //    carPrice://PriceList?minp=10&maxp=25&ss=518&bid=11&sp=124&cid=10&pid=20
    
    NSString *minp = @"0";
    // 特殊控制 不能为空
    NSString *maxp = @"9998";
    NSInteger ss = _mCarDetailInfo.seriesid.integerValue;
    NSInteger bid = _mCarDetailInfo.brandid.integerValue;
    NSInteger sp = _mCarDetailInfo.productid.integerValue;
    NSInteger cid = _mCarDetailInfo.cityid.integerValue;
    NSInteger pid = _mCarDetailInfo.provinceid.integerValue;
    if (_mReferencePrice.referenceprice.length) {
        NSArray *arr = [_mReferencePrice.referenceprice componentsSeparatedByString:@"-"];
        if (arr.count == 2) {
            minp = arr[0];
            maxp = arr[1];
        }
    }
    
    // 特殊控制 间隔不小于5
    if ([maxp integerValue] - [minp integerValue] < 5) {
        maxp = [NSString stringWithFormat:@"%d", minp.integerValue + 5];
    }
    
    // 特殊控制 强转int
    minp = [NSString stringWithFormat:@"%d", [minp integerValue]];
    maxp = [NSString stringWithFormat:@"%d", [maxp integerValue] + 1];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"carPrice://PriceList?minp=%@&maxp=%@&ss=%d&bid=%d&sp=%d&cid=%d&pid=%d", minp, maxp, ss, bid, sp, cid, pid]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"您还未安装最新的\"汽车报价\"" delegate:self cancelButtonTitle:@"取消查看" otherButtonTitles:@"立即下载", nil];
        [vAlert show];
    }
}

/** 查看原车信息 */
- (void)onClickOriginalCarInfoBtn:(UIButton *)btn
{
    UCActivityView *vActivity = [[UCActivityView alloc] initWithFrame:self.bounds];
    [vActivity loadWebWithString:_mCarDetailInfo.carsourceurl];
    [[MainViewController sharedVCMain] openView:vActivity animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 点击提示按钮 */
- (void)onClickPromptBtn:(UIButton *)btn
{
    if (btn.tag == UCCarPreviewViewPromptHasDeposit && _mCarDetailInfo.bailmoney.integerValue > 0)
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"若与真实车况不符，赔%@", _mCarDetailInfo.bailmoney] icon:nil duration:AMToastDurationNormal];
    if (btn.tag == UCCarPreviewViewPromptNewCar)
        [[AMToastView toastView] showMessage:@"本车车况近似新车" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarPreviewViewPromptExtended)
        [[AMToastView toastView] showMessage:@"本车提供延长质保" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarPreviewViewPromptHaswarranty)
        [[AMToastView toastView] showMessage:@"本车提供原厂质保" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarPreviewViewPromptAuthentication)
        [[AMToastView toastView] showMessage:@"本车已通过品牌认证" icon:nil duration:AMToastDurationNormal];
}

#pragma mark - UCThumbnailsViewDelegate
- (void)UCThumbnailsView:(UCThumbnailsView *)vThumbnails onClickPhotoBtn:(UIButton *)btn
{
    NSArray *thumbimgurls = nil;
    NSArray *images = nil;
    // 车图片
    if (vThumbnails.tag == UCCarPreviewViewThumbnailsCarPhoto) {
        images = [_mCarDetailInfo.imgurls componentsSeparatedByString:@","];
        thumbimgurls = [_mCarDetailInfo.thumbimgurls componentsSeparatedByString:@","];
    } else if (vThumbnails.tag == UCCarPreviewViewThumbnailsTestReport) {
        thumbimgurls = [_mCarDetailInfo.dctionthumbimg componentsSeparatedByString:@","];
        images = [_mCarDetailInfo.dctionimg componentsSeparatedByString:@","];
    }
    
    if (thumbimgurls.count > 0 || images.count > 0) {
        UCImageBrowseView *vImageBrowse = [[UCImageBrowseView alloc] initWithFrame:self.bounds index:btn.tag thumbimgurls:thumbimgurls imageUrls:images];
        
        [[MainViewController sharedVCMain] openView:vImageBrowse animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        
        // 统计
        if (vThumbnails.tag == UCCarPreviewViewThumbnailsCarPhoto) {
            [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailphoto : c_3_1_personsourcedetailphoto];
            [UMStatistics event:_isBusiness ? pv_3_1_buinessviewlarge : pv_3_1_personviewlarge];
            if (_isBusiness) {
                UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                NSMutableDictionary *dic = nil;
                NSString *dealerid = mUserInfo.userid.stringValue;
                if ([AMCacheManage currentUserType] == UserStyleBusiness)
                    dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", dealerid, @"dealerid#5", mUserInfo.userid, @"userid#4", nil];
                else
                    dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", dealerid, @"dealerid#5", nil];
                [UMSAgent postEvent:dealerbigpicture_pv page_name:NSStringFromClass(vImageBrowse.class) eventargvs:dic];
            } else {
                [UMSAgent postEvent:userbigpicture_pv page_name:NSStringFromClass(vImageBrowse.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", nil]];
            }
        }
        
    } else {
        [[AMToastView toastView] hide];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    CGPoint offsetofScrollView = scrollView1.contentOffset;
    UIPageControl *pcPhotot = (UIPageControl *)[self viewWithTag:32141876];
    [pcPhotot setCurrentPage:offsetofScrollView.x / scrollView1.frame.size.width];
}

#pragma mark - APIHelper
/** 参考价 */
- (void)getReferencePrice:(UCPriceModel *)mPrice
{
    if (!self.apiHelperPrice)
        self.apiHelperPrice = [[APIHelper alloc] init];
    __weak UCCarPreviewView *vCarDetail = self;
    
    [self.apiHelperPrice setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error)
            return;
        if (apiHelper.data.length > 0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            UCReferencePriceModel *mReferencePrice = nil;
            if (mBase.returncode == 0 && mBase.result) {
                mReferencePrice = [[UCReferencePriceModel alloc] initWithJson: mBase.result];
            }
            [vCarDetail loadReferencePrice:mReferencePrice];
        }
    }];
    
    [self.apiHelperPrice getCarDetailPriceWithPriceModel:mPrice];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [[AMToastView toastView] hide];
    [_apiHelperPrice cancel];
}

@end
