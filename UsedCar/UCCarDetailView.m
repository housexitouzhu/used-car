//
//  UCCarDetailView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-15.
//  Copyright (c) 2013年 Alan. All rights reserved.
//
#import "UCCarDetailView.h"
#import "APIHelper.h"
#import "UCTopBar.h"
#import "MainViewController.h"
#import "UCCarDetailInfoModel.h"
#import "UCReferencePriceModel.h"
#import "AMToastView.h"
#import "UCImageBrowseView.h"
#import "UCRecommendCarList.h"
#import "UIImage+Util.h"
#import "UCFavoritesModel.h"
#import "AMCacheManage.h"
#import "UCBusinessInfoView.h"
#import "UCFavoritesList.h"
#import "UCCarCompareView.h"
#import "UCNewCarConfigView.h"
#import "UCMainView.h"
#import "UCOptionBar.h"
#import "UCTopBar.h"
#import "UCViewCarView.h"
#import "UCActivityView.h"
#import "NSString+Util.h"
#import "UCCarInfoModel.h"
#import "UCUserReputation.h"
#import "UCReportView.h"
#import "SHLActionSheet.h"
#import "UCPriceModel.h"
#import "AppDelegate.h"
#import "UCIMRootEntry.h"
#import "EMHint.h"

#define KColorBackground        [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05]

#define KOptionsBarHeight       45
#define KMarginLefTitle         20
#define KMarginLefLine          12
#define KMarginLefContent       93
#define KContentHeight          50
#define KTimeViewHeight         30

#define KlabCarBasicInfoTag     37487563
#define KlabLicenseTitleTag     19332338
#define KlabLicenseContenTag    22239846
#define kAddCompareImageViewTag 34859586
#define kAddCompareButtonTag    47564756
#define kCompareCountBagTag     48573848
#define kBasicTitleLabel        45748573
#define kBasicHeadBgTag         45938564

#define kBlackBgViewTag         12908765
#define kBtnPhoneTag            52849572
#define kBtnMessageTag          62549832
#define kBtnIMTag               83957563
#define kCarPriceAlertTag       37485938

#define KMoveCarNameAnimation     @"moveCarNameAnimation"
#define KChageCompareNumAnimation @"chageCompareNumAnimation"
#define kBtnSelect                200000
#define KAnimationTurningTime     0.4                        // 翻页动画时间

#define zero 0

@interface UCCarDetailView ()<SHLActionSheetDelegate, EMHintDelegate>
{
    CGRect _btnContactFrame;
}

@property (nonatomic) BOOL isCustomCar;
@property (nonatomic) BOOL isBusiness;
@property (nonatomic) BOOL isRecordCarInfo;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL isExistInCompareItems;
@property (nonatomic) BOOL isOpenTurning;                             // 开启翻页功能
@property (nonatomic) BOOL isForIM;
@property (nonatomic, strong) NSNumber *sourceid;
@property (nonatomic, strong) UIWebView *wvPrice;
@property (nonatomic, strong) NSMutableArray *compareItems;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) APIHelper *apiHelperPrice;
@property (nonatomic, strong) APIHelper *apiSetPV;
@property (nonatomic, strong) APIHelper *apiGetPV;
@property (nonatomic, strong) APIHelper *apiFavorite;
@property (nonatomic, strong) APIHelper *apiIsFavorite;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarDetailInfoModel *mCarDetailInfo;
@property (nonatomic, assign) UCCarCompareView *vCarCompare;
@property (nonatomic, strong) UCNewCarConfigView *vNewCarConfig;
@property (nonatomic, strong) AMBlurView *bvOptions;
@property (nonatomic, strong) UILabel *labHave;
@property (nonatomic, strong) UILabel *labView;
@property (nonatomic, strong) UILabel *labReleaseTime;
@property (nonatomic, strong) UILabel *labViewCount;
@property (nonatomic, strong) UILabel *labPrice;
@property (nonatomic, strong) UILabel *labDescriptionContent;
@property (nonatomic, strong) UILabel *labCarName;
@property (nonatomic, strong) UILabel *labCarModel;
@property (nonatomic, strong) UILabel *labGearbox;
@property (nonatomic, strong) UILabel *labPriceUnit;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UILabel *labKind;
@property (nonatomic, strong) UILabel *labTelephone;
@property (nonatomic, strong) UILabel *labConfigContent;
@property (nonatomic, strong) UILabel *labCompareCount;
@property (nonatomic, strong) UIView *vLicense;
@property (nonatomic, strong) UIView *vDescription;
@property (nonatomic, strong) UIView *vConfig;
@property (nonatomic, strong) UIView *vCarName;                       // 车辆名称视图
@property (nonatomic, strong) UIView *vCopyCarName;                   // 复制车辆名称视图
@property (nonatomic, strong) UIView *vCarBasicLine;
@property (nonatomic, strong) UIView *vPriceAndOther;
@property (nonatomic, strong) UIView *vPriceLine;
@property (nonatomic, strong) UIView *vCarBasicInfo;
@property (nonatomic, strong) UIView *vCompareBtn;
@property (nonatomic, strong) UIView *vChoosePhone;
@property (nonatomic, strong) UIView *vReportView;
@property (nonatomic, strong) UIButton *btnShare;
@property (nonatomic, strong) UIButton *btnFavorite;
@property (nonatomic, strong) UIButton *btnHome;
@property (nonatomic, strong) UIButton *btnLeftTab;                   // tab左按钮
@property (nonatomic, strong) UIButton *btnRithtTab;                  // tab右按钮
@property (nonatomic, strong) UIButton *btnAction;
@property (nonatomic, strong) UIControl *cBlackBg;
@property (nonatomic, strong) UILabel *labPhone;
@property (nonatomic, strong) UILabel *labSelldate;                   // 卖出时间
@property (nonatomic, strong) UIImageView *ivComparSlidingTips;
@property (nonatomic, strong) UIImageView *ivCountBackground;
@property (nonatomic, strong) UCChangeScrollView *svCarInfo;
@property (nonatomic, strong) UCThumbnailsView *vCarThumbPhoto;       // 车缩略图片
@property (nonatomic, strong) UCThumbnailsView *vCarTestReportlPhoto; // 检测报告
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic, strong) UCReferencePriceModel *mReferencePrice; // 报价信息
@property (nonatomic, strong) UIButton *btnReload;                    // 刷新按钮
@property (nonatomic, strong) UCUserReputation *userReputation;       // 用户口碑
@property (nonatomic, strong) NSURL *urlCarPrice;                     // 跳转到汽车报价Url
@property (nonatomic, strong) UCCarInfoModel *mCarInfo;                 // 当前搜索接口传过来的车源model
@property (nonatomic, weak) id vFirstDetail;                          // 前一个视图
@property (nonatomic) NSInteger carListAllCount;                      // 首页列表总个数
@property (nonatomic) CGFloat svHeights;
@property (nonatomic) NSInteger carPVCount;                           // 浏览数
@property (nonatomic, strong) UCIMRootEntry *imRootEntry;               // 聊天容器

@property (nonatomic, strong) UIView *descriptionBG;                  //卖家描述背景
@property (nonatomic, strong) UILabel *labConfigTitle;
@property (nonatomic, strong) UIView *configBG;                  //车辆配置描述背景

@property (nonatomic, strong) EMHint *vHint;

@end

@implementation UCCarDetailView

/** 车辆详情 */
- (id)initWithFrame:(CGRect)frame mCarInfo:(UCCarInfoModel *)mCarInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewWithCarInfoModel:mCarInfo];
    }
    return self;
}

/** 车辆详情可翻页 */
- (id)initTurningDetailViewWithFrame:(CGRect)frame mCarInfo:(UCCarInfoModel *)mCarInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        _isOpenTurning = YES;
        [self initViewWithCarInfoModel:mCarInfo];
    }
    return self;
}

/** IM查看车辆详情 */
- (id)initWithFrame:(CGRect)frame CarID:(NSNumber*)carID{
    self = [super initWithFrame:frame];
    if (self) {
        _isForIM = YES;
        [UMStatistics event:pv_4_3_buyCar_Detail_IM_Chat_ViewCar];
        [UMSAgent postEvent:buycar_chat_view_car_pv page_name:NSStringFromClass(self.class)];
        NSDictionary *mDic = @{@"carid":carID};
        UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithJson:mDic];
        [self initViewWithCarInfoModel:mCarInfo];
    }
    return self;
}


- (void)initViewWithCarInfoModel:(UCCarInfoModel *)mCarInfo
{
    // 浏览次数：未获取时为-1
    _carPVCount = -1;
    _mCarInfo = mCarInfo;
    _isRecordCarInfo = YES;
    _isBusiness = [mCarInfo.sourceid integerValue] == 1 ? NO : YES;
    // 对比数据
    _compareItems = [NSMutableArray arrayWithArray:[AMCacheManage currentCompareInfo]];
    
    _svHeights = 40;
    _sourceid = mCarInfo.sourceid;
    // 初始化
    [self initTitleView:mCarInfo.carid];
    // 获取数据
    [self getCarInfo:mCarInfo.carid];
    // 获取浏览数
    [self getPVWithCarID:mCarInfo.carid];
    if ([AMCacheManage currentUserType] == UserStylePersonal) {
        // 个人登录后判断是否是收藏车源
        [self isFavoriteCar:mCarInfo.carid];
    }
}

-(APIHelper *)apiIsFavorite
{
    if (!_apiIsFavorite) {
        _apiIsFavorite = [[APIHelper alloc] init];
    }
    return _apiIsFavorite;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView:(NSNumber *)carid
{
    self.backgroundColor = kColorNewBackground;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    // 标题
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _tbTop.btnLeft.width, _tbTop.btnLeft.height)];
    [btnBack setImage:[UIImage imageNamed:@"topbar_backbtn"] forState:UIControlStateNormal];
    btnBack.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnBack.titleLabel.font = _tbTop.btnLeft.titleLabel.font;
    btnBack.titleEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, 0, 0);
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(0, kBackButtonEdgeInsetsLeft, 0, 0);
    btnBack.exclusiveTouch = YES;
    [btnBack setTitleColor:[_tbTop.btnLeft titleColorForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    // 主页按钮
    _btnHome = [[UIButton alloc] initWithFrame:CGRectMake(_tbTop.btnLeft.width * 3 / 4, _tbTop.height - 44, _tbTop.btnLeft.width * 3 / 4, _tbTop.btnLeft.height)];
    [_btnHome setImage:[UIImage imageNamed:@"topbar_homebtn"] forState:UIControlStateNormal];
    [_btnHome addTarget:self action:@selector(onClickHomeBtn) forControlEvents:UIControlEventTouchUpInside];
    _btnHome.hidden = YES;
    [_tbTop.btnLeft addSubview:btnBack];
    [_tbTop addSubview:_btnHome];
    
    _obFilter.hidden = NO;
    [_tbTop.btnTitle setTitle:@"车辆详情" forState:UIControlStateNormal];
    
    // 分享按钮
    _btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _tbTop.btnRight.width / 2, _tbTop.btnRight.height)];
    _btnShare.enabled = NO;
    [_btnShare setImage:[UIImage imageNamed:@"detail_share_btn"] forState:UIControlStateNormal];
    [_btnShare setImage:[UIImage imageAutoNamed:@"detail_share_btn_d"] forState:UIControlStateDisabled];
    [_btnShare addTarget:self action:@selector(onClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 收藏按钮
    _btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(_btnShare.maxX, 0, _tbTop.btnRight.width / 2, _tbTop.btnRight.height)];
    _btnFavorite.enabled = NO;
    [_btnFavorite addTarget:self action:@selector(onClickFavoritesBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnRight addSubview:_btnShare];
    [_tbTop.btnRight addSubview:_btnFavorite];
    
    // 是否收藏
    if ([AMCacheManage existInFavourites:[carid stringValue]]) {
        [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
        [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
        _isFavorite = YES;
    }
    else {
        [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
        [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
        _isFavorite = NO;
    }
    
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
}

/** 初始化View */
- (void)initView:(NSNumber *)carid
{
    
    CGFloat svCarInfoMinY = _tbTop.maxY;
    
    /* 信息视图 */
    _svCarInfo = [[UCChangeScrollView alloc] initWithFrame:CGRectMake(0, svCarInfoMinY, self.width, self.height -  svCarInfoMinY) isOpenTurning:_isOpenTurning];
    if (!_isForIM) {
        _svCarInfo.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _svCarInfo.delegateChange = self;
    }
    
    // Tab切换View
    if (!_isCustomCar) {
        CGFloat barHeight = kTopOptionHeight;
        _svHeights = 0;
        NSArray *titles = @[@"二手车", @"新车配置", @"用户口碑"];
        // 选项
        UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight - 4, self.width / titles.count, 4)];
        vSlider.backgroundColor = kColorBlue;
        
        // 创建选项视图
        _obFilter = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, 0, self.width, barHeight) sliderView:vSlider];
        _obFilter.isAutoAdjustSlider = YES;
        _obFilter.isEnableBlur = NO;
        _obFilter.backgroundColor = [UIColor whiteColor];
        
        // 设置代理
        _obFilter.delegate = self;
        [_obFilter addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _obFilter.height - kLinePixel, _obFilter.width, kLinePixel) color:kColorNewLine]];
        NSMutableArray *items = [NSMutableArray array];
        
        // 设置选项的名字
        for (NSInteger i = 0; i < titles.count; i++) {
            UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
            item.titleFont = kFontLarge;
            item.titleColor = kColorNewGray1;
            item.titleColorSelected = kColorBlue;
            item.title = titles[i];
            [items addObject:item];
        }
        
        [_obFilter setItems:items];
        [_obFilter selectItemAtIndex:0];
        [_svCarInfo addSubview:_obFilter];
    }

    // 时间 & 图片 视图
    UIView *vPhotoTabTime = [[UIView alloc] initWithFrame:CGRectMake(0, _obFilter.maxY, self.width, 101)];
    vPhotoTabTime.backgroundColor = kColorWhite;

    // 车辆图片缩略图
    _vCarThumbPhoto = [[UCThumbnailsView alloc] initWithFrame:CGRectMake(0, 0, vPhotoTabTime.width, 101)];
    _vCarThumbPhoto.tag = UCCarDetailViewThumbnailsCarPhoto;
    _vCarThumbPhoto.backgroundColor = kColorWhite;
    _vCarThumbPhoto.delegate = self;
    
    // 已售时间
    _labSelldate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vCarThumbPhoto.width, 24)];
    _labSelldate.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _labSelldate.font = kFontNormal;
    _labSelldate.textColor = kColorWhite;
    _labSelldate.textAlignment = NSTextAlignmentCenter;
    _labSelldate.userInteractionEnabled = NO;
    
    [_vCarThumbPhoto addSubview:_labSelldate];
    [_svCarInfo addSubview:vPhotoTabTime];
    
    // 车辆基础信息
    _vCarBasicInfo = [[UIView alloc] initWithFrame:CGRectMake(0, vPhotoTabTime.maxY, self.width, 0)];
    _vCarBasicInfo.backgroundColor = [UIColor whiteColor];
    
    // 发布时间view
    UIView *vTime = nil;
    vTime = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vCarBasicInfo.width, KTimeViewHeight)];
    vTime.backgroundColor = kColorWhite;
    
    // 发布时间Title
    UILabel *labTimeTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(20, 0, 120, vTime.height)];
    labTimeTitle.text = @"发布时间：";
    labTimeTitle.font = [UIFont systemFontOfSize:12];
    
    // 发布时间
    _labReleaseTime = [[UILabel alloc] initWithClearFrame:CGRectMake(80, 0, 120, vTime.height)];
    _labReleaseTime.font = [UIFont systemFontOfSize:12];
    
    // 已有
    _labHave = [[UILabel alloc] init];
    _labHave.backgroundColor = kColorClear;
    _labHave.text = @"已有";
    _labHave.font = [UIFont systemFontOfSize:12];
    [_labHave sizeToFit];
    
    // 浏览数
    _labViewCount = [[UILabel alloc] init];
    _labViewCount.backgroundColor = kColorClear;
    _labViewCount.textColor = kColorBlue1;
    _labViewCount.font = [UIFont systemFontOfSize:12];
    _labViewCount.text = @"0";
    _labViewCount.textAlignment = NSTextAlignmentCenter;
    
    // 浏览
    _labView = [[UILabel alloc] init];
    _labView.backgroundColor = kColorClear;
    _labView.text = @"人浏览";
    _labView.font = [UIFont systemFontOfSize:12];
    [_labView sizeToFit];
    
    _labView.origin = CGPointMake(self.width - 20 - _labView.width, 8);
    _labViewCount.origin = CGPointMake(_labView.minX - _labViewCount.width, 8);
    _labHave.origin = CGPointMake(_labViewCount.minX - _labHave.width, 8);
    
    // 时间分割线
    UIView *vTimeLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vTime.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    
    // 添加时间视图
    [vTime addSubview:labTimeTitle];
    [vTime addSubview:_labReleaseTime];
    [vTime addSubview:vTimeLine];
    [vTime addSubview:_labHave];
    [vTime addSubview:_labViewCount];
    [vTime addSubview:_labView];
    
    [_vCarBasicInfo addSubview:vTime];

    // 车辆信息标题背景
    UIView *vBasicHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, vTime ? vTime.maxY : 0, _vCarBasicInfo.width, 30)];
    vBasicHeadBg.tag = kBasicHeadBgTag;
    vBasicHeadBg.backgroundColor = kColorNewLine;
    
    // 车辆基础信息 (问题1: labBasicTitle 与 vBasicHeadBg 坐标手动同步? 问题2: vBasicHeadBg 是盖在 labBasicTitle 上的?)
    UILabel *labBasicTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, vBasicHeadBg.minY, vBasicHeadBg.width - KMarginLefTitle, vBasicHeadBg.height)];
    labBasicTitle.tag = kBasicTitleLabel;
    labBasicTitle.text = @"车辆基础信息";
    labBasicTitle.textColor = kColorNewGray1;
    labBasicTitle.font = kFontLarge;
    [_vCarBasicInfo addSubview:vBasicHeadBg];
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
    
    // 对比按钮视图
    if (!_isForIM) {
        UIImage *iCompare = [UIImage imageNamed:@"detail_addpk_btn_bg"];
        _vCompareBtn = [[UIView alloc] initWithFrame:CGRectMake(self.width - iCompare.width, zero, iCompare.width, iCompare.height)];
        _vCompareBtn.layer.masksToBounds = NO;
        
        // 对比按钮
        UIButton *btnCompare = [[UIButton alloc] initWithFrame:_vCompareBtn.bounds];
        btnCompare.tag =  kAddCompareButtonTag;
        [btnCompare setBackgroundImage:iCompare forState:UIControlStateNormal];
        [btnCompare setBackgroundImage:[UIImage imageNamed:@"detail_addpk_btn_bg_h"] forState:UIControlStateHighlighted];
        [btnCompare setBackgroundImage:[UIImage imageNamed:@"detail_addpk_btn_bg_h"] forState:UIControlStateSelected];
        [btnCompare addTarget:self action:@selector(onClickCompareBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // “+”
        UIImage *iAddCompare = [UIImage imageNamed:@"detail_addpk_icon"];
        UIImageView *ivCompare = [[UIImageView alloc] init];
        ivCompare.image = iAddCompare;
        ivCompare.size = iAddCompare.size;
        ivCompare.tag = kAddCompareImageViewTag;
        ivCompare.origin = CGPointMake(12, 5);
        
        // “对比” 文字
        UILabel *labCompareText = [[UILabel alloc] init];
        labCompareText.textColor = kColorGrey3;
        labCompareText.userInteractionEnabled = NO;
        labCompareText.font = [UIFont systemFontOfSize:11];
        labCompareText.text = @"对比";
        labCompareText.backgroundColor = [UIColor clearColor];
        [labCompareText sizeToFit];
        labCompareText.origin = CGPointMake(9, 22);
        
        // 数量
        _ivCountBackground = [[UIImageView alloc] init];
        _ivCountBackground.origin = CGPointMake(-6, -6);
        _ivCountBackground.size = CGSizeMake(16, 16);
        _ivCountBackground.tag = kCompareCountBagTag;
        _ivCountBackground.backgroundColor = kColorOrange;
        _ivCountBackground.userInteractionEnabled = NO;
        _ivCountBackground.layer.masksToBounds = YES;
        _ivCountBackground.layer.cornerRadius = _ivCountBackground.size.width / 2;
        
        _labCompareCount = [[UILabel alloc] initWithClearFrame:_ivCountBackground.bounds];
        _labCompareCount.textColor = kColorWhite;
        _labCompareCount.userInteractionEnabled = NO;
        _labCompareCount.font = [UIFont systemFontOfSize:10];
        _labCompareCount.textAlignment = NSTextAlignmentCenter;
        if (_compareItems.count == 0)
            _ivCountBackground.hidden = YES;
        else
            _ivCountBackground.hidden = NO;
        _labCompareCount.text = [NSString stringWithFormat:@"%d",_compareItems.count];
        
        [_ivCountBackground addSubview:_labCompareCount];
        
        [_vCompareBtn addSubview:btnCompare];
        [_vCompareBtn addSubview:ivCompare];
        [_vCompareBtn addSubview:labCompareText];
        [_vCompareBtn addSubview:_ivCountBackground];
        [self addSubview:_vCompareBtn];
        
        // 对比按钮添加手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
        [_vCompareBtn addGestureRecognizer:pan];
        
    }
    
    
    
    
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
    vLicenseHeadBg.backgroundColor = kColorNewLine;
    [_vLicense addSubview:vLicenseHeadBg];
    
    // 车辆牌照信息
    UILabel *labLicenseTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vLicenseHeadBg.width - KMarginLefTitle, vLicenseHeadBg.height)];
    labLicenseTitle.text = @"车辆牌照信息";
    labLicenseTitle.textColor = kColorNewGray1;
    labLicenseTitle.font = kFontLarge;
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
    vDescriptionHeadBg.backgroundColor = kColorNewLine;
    [_vDescription addSubview:vDescriptionHeadBg];
    
    // 卖家描述标题
    UILabel *labDescriptionTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vDescriptionHeadBg.width - KMarginLefTitle, vDescriptionHeadBg.height)];
    labDescriptionTitle.text = @"卖家描述";
    labDescriptionTitle.textColor = kColorNewGray1;
    labDescriptionTitle.font = kFontLarge;
    [_vDescription addSubview:labDescriptionTitle];
    _descriptionBG = [[UIView alloc] initWithFrame:CGRectMake(0, labDescriptionTitle.height, _svCarInfo.width, _labDescriptionContent.height)];
    [_descriptionBG setBackgroundColor:[UIColor whiteColor]];
    [_vDescription addSubview:_descriptionBG];
    
    // 卖家描述内容
    _labDescriptionContent = [[UILabel alloc] init];
    _labDescriptionContent.numberOfLines = 0;
    _labDescriptionContent.textColor = kColorGrey2;
    _labDescriptionContent.font = [UIFont systemFontOfSize:15];
    CGSize labDescriptionContentSize = [_labDescriptionContent.text sizeWithFont:_labDescriptionContent.font constrainedToSize:CGSizeMake(_vDescription.width - 40, CGFLOAT_MAX) lineBreakMode:_labDescriptionContent.lineBreakMode];
    _labDescriptionContent.frame = CGRectMake(KMarginLefTitle, vDescriptionHeadBg.height, labDescriptionContentSize.width, labDescriptionContentSize.height + 16 * 2);
    _vDescription.height = _labDescriptionContent.maxY;
    [_vDescription addSubview:_labDescriptionContent];
    
    // 车辆配置
    _vConfig = [[UIView alloc]initWithFrame:CGRectMake(0, _vDescription.maxY, _svCarInfo.width, 999)];
    _vConfig.layer.masksToBounds = YES;
    [_svCarInfo addSubview:_vConfig];
    
    // 车辆配置标题
    // 车辆配置背景
    UIView *vConfigHeadBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vConfig.width, 30)];
    vConfigHeadBg.backgroundColor = kColorNewLine;
    [_vConfig addSubview:vConfigHeadBg];
    
    // 车辆配置标题
    _labConfigTitle = [[UILabel alloc] initWithClearFrame:CGRectMake(KMarginLefTitle, 0, vDescriptionHeadBg.width - KMarginLefTitle, vDescriptionHeadBg.height)];
    _labConfigTitle.text = @"车辆配置";
    _labConfigTitle.textColor = kColorNewGray1;
    _labConfigTitle.font = kFontLarge;
    [_vConfig addSubview:_labConfigTitle];

    // 车辆配置内容
    _labConfigContent = [[UILabel alloc] init];
    _labConfigContent.backgroundColor = [UIColor clearColor];
    _labConfigContent.numberOfLines = 0;
    _labConfigContent.textColor = kColorGrey2;
    _labConfigContent.font = [UIFont systemFontOfSize:15];
    CGSize labConfigContentSize = [_labConfigContent.text sizeWithFont:_labConfigContent.font constrainedToSize:CGSizeMake(_vConfig.width - 40, 400) lineBreakMode:_labConfigContent.lineBreakMode];
    _labConfigContent.frame = CGRectMake(KMarginLefTitle, vConfigHeadBg.height, labConfigContentSize.width, labConfigContentSize.height + 16 *2);
    [_vConfig addSubview:_labConfigContent];
    
    _configBG = [[UIView alloc] initWithFrame:CGRectMake(0, _labConfigTitle.maxY, _svCarInfo.width, _labConfigContent.height)];
    [_configBG setBackgroundColor:kColorWhite];
    [_vConfig insertSubview:_configBG belowSubview:_labConfigContent];
    
    
    // 操作项视图
    _bvOptions = [[AMBlurView alloc] initWithFrame:CGRectMake(0, _vConfig.maxY, self.width, KOptionsBarHeight)];
    _bvOptions.blurTintColor = [UIColor colorWithWhite:0 alpha:IOS7_OR_LATER ? 0.7 : 0.8];
    _bvOptions.userInteractionEnabled = YES;
    
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
        btnAction.tag = kBtnSelect +i;
        [btnAction addTarget:self action:@selector(onClickBottomOperationBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnAction setBackgroundImage:[UIImage imageWithColor:kColorGrey2 size:btnAction.size] forState:UIControlStateSelected];
        [btnAction setBackgroundImage:[UIImage imageWithColor:kColorGrey2 size:btnAction.size] forState:UIControlStateHighlighted];
        
        [_bvOptions addSubview:btnAction];
        
        if (i == 0) {
            _btnContactFrame = btnAction.frame;
        }
    }
    
    // 添加到时间 & 图片 视图
    [vPhotoTabTime addSubview:_vCarThumbPhoto];
    
    // 车辆信息视图
    // 基本信息视图
//    [_vCarBasicInfo addSubview:vBasicHeadBg];
    [_svCarInfo addSubview:_vCarBasicInfo];
    
    // 添加到主视图
    [self addSubview:_svCarInfo];
    
    // 创建对比列表视图
    if (!_isForIM){
        if (!_vCarCompare) {
            _vCarCompare = [UCCarCompareView shareCompare];
            _vCarCompare.frame = CGRectMake(self.maxX, self.minY, self.width, self.height);
            _vCarCompare.delegate = self;
            [self addSubview:_vCarCompare];
            [self bringSubviewToFront:_vCarCompare];
        }
        
        if ([AMCacheManage currentConfigStartIMGuideStatus] == 0) {
            [self createGuideView];
        }
    }
    
}

/** 创建按钮 */
- (UIView *)creatCarView:(CGRect)frame
{
    UIView *carRepotView = [[UIView alloc] initWithFrame:frame];
    [carRepotView setBackgroundColor:kColorWhite];
    NSMutableArray *arrText = [[NSMutableArray alloc] initWithArray:_mCarDetailInfo.state.integerValue == 1 ? @[@"车源举报",@"类似车源",@"同价新车"] : @[@"类似车源",@"同价新车"]];
    // 查看原车信息
    if ((_mCarDetailInfo.carsourceurl.length > 0))
        [arrText addObject:@"查看原车信息"];
    CGFloat minY = 0;
    
    for (int i = 0; i < arrText.count; i++) {
        // 分割线
        UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, minY, self.width, kLinePixel) color:kColorNewLine];
        UIButton *btnRepot = [[UIButton alloc] initWithFrame:CGRectMake(0, minY, self.width, 50)];
        [btnRepot setTitle:[arrText objectAtIndex:i] forState:UIControlStateNormal];
        [btnRepot setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        btnRepot.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0,0);
        btnRepot.titleLabel.font = [UIFont systemFontOfSize:15];
        [btnRepot setTitleColor:kColorGray1 forState:UIControlStateNormal];
        [btnRepot addTarget:self action:@selector(onClickCarsBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnRepot setBackgroundColor:kColorClear];
        [btnRepot setBackgroundImage:[UIImage imageWithColor:kColorNewLine size:btnRepot.size] forState:UIControlStateHighlighted];
        btnRepot.tag = _mCarDetailInfo.state.integerValue == 1 ? 10000 + i : 10000 + i + 1;

        UIImageView * arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 28, 16.5, 18, 18)];
        arrowImage.image = [UIImage imageNamed:@"set_arrow_right"];
        [btnRepot addSubview:arrowImage];
        [carRepotView addSubview:btnRepot];
        [carRepotView addSubview:vLines];
        minY += 50;
    }
    
    carRepotView.height = minY;
    
    return carRepotView;
}

- (UIView *)creatPhoneView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _cBlackBg.maxY, _cBlackBg.width, 150)];
    // 收藏按钮
//    UIButton *btnPhone = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
//    [btnPhone setTitle:@"拔打电话" forState:UIControlStateNormal];
//    [btnPhone setTitleColor:kColorBlue1 forState:UIControlStateNormal];
//    btnPhone.backgroundColor = kColorWhite;
//    btnPhone.titleLabel.font = [UIFont systemFontOfSize:15];
//    btnPhone.tag = kBtnPhoneTag;
//    
//    // 设置图片和标题位置
//    btnPhone.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0,0);
//    btnPhone.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
//    btnPhone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [btnPhone setImage:[UIImage imageNamed:@"individual_phone_btn1"] forState:UIControlStateNormal];
//    _labPhone = [[UILabel alloc] initLineWithFrame:CGRectMake(113, 15.5, 200, 20) color:[UIColor clearColor]];
//    _labPhone.text = _mCarDetailInfo.salesPerson.salesphone;
//    [_labPhone setTextColor:kColorBlue1];
//    
//    [btnPhone addSubview:_labPhone];
//    [btnPhone addTarget:self action:@selector(onClickbtnOpenPhone:) forControlEvents:UIControlEventTouchUpInside];
//    
//    // 分割线
//    UIView *vLines = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnPhone.maxY, self.width, kLinePixel) color:kColorNewLine];
//    [view addSubview:vLines];
//    
//    // 发短信
//    UIButton *btnMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, vLines.maxY, self.width, 50)];
//    [btnMessage setTitle:@"发送短信" forState:UIControlStateNormal];
//    [btnMessage setTitleColor:kColorBlue1 forState:UIControlStateNormal];
//    btnMessage.backgroundColor = kColorWhite;
//    btnMessage.titleLabel.font = [UIFont systemFontOfSize:15];
//    btnMessage.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0,0);
//    btnMessage.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
//    btnMessage.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [btnMessage setImage:[UIImage imageNamed:@"individual_message_btn1"] forState:UIControlStateNormal];
//    [btnMessage addTarget:self action:@selector(onClickbtnOpenPhone:) forControlEvents:UIControlEventTouchUpInside];
//    btnMessage.tag = kBtnMessageTag;
//    [view addSubview:btnMessage];
//    [view addSubview:btnPhone];
    
    NSArray *titles = @[@"拨打电话", @"在线咨询", @"发送短信"];
    NSArray *images = @[@"individual_phone_btn1", @"contact_consultation", @"individual_message_btn1"];
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 50 * i, self.width, 50)];
        [btnItem setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btnItem setTitleColor:kColorBlue1 forState:UIControlStateNormal];
        btnItem.backgroundColor = kColorWhite;
        btnItem.titleLabel.font = [UIFont systemFontOfSize:15];
        btnItem.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0,0);
        btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnItem setImage:[UIImage imageNamed:[images objectAtIndex:i]] forState:UIControlStateNormal];
        [btnItem addTarget:self action:@selector(onClickbtnOpenPhone:) forControlEvents:UIControlEventTouchUpInside];
        switch (i) {
            case 0:
                btnItem.tag = kBtnPhoneTag;
                break;
            case 1:
                btnItem.tag = kBtnIMTag;
                break;
            case 2:
                btnItem.tag = kBtnMessageTag;
                break;
                
            default:
                break;
        }
        
        if (i == 0) {
            _labPhone = [[UILabel alloc] initLineWithFrame:CGRectMake(113, 15.5, 200, 20) color:kColorClear];
            _labPhone.text = _mCarDetailInfo.salesPerson.salesphone;
            [_labPhone setTextColor:kColorBlue1];
            [btnItem addSubview:_labPhone];
        }
        
        UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, btnItem.height - kLinePixel, btnItem.width, kLinePixel) color:kColorNewLine];
        [btnItem addSubview:vLine];
        
        [view addSubview:btnItem];
    }
    
    return view;
}

#pragma mark - Private Method
/** 加载数据 */
- (void)reloadView
{
    // 统计代码
    if (_isBusiness) {
        UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            [UMSAgent postEvent:dealercardetail_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", _mCarDetailInfo.userid.stringValue, @"dealerid#5",_mCarDetailInfo.seriesid.stringValue, @"seriesid#2", _mCarDetailInfo.productid.stringValue, @"specid#3", mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:dealercardetail_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", _mCarDetailInfo.userid.stringValue, @"dealerid#5", _mCarDetailInfo.seriesid.stringValue, @"seriesid#2", _mCarDetailInfo.productid.stringValue, @"specid#3", nil]];
        }
    } else {
        [UMSAgent postEvent:usercardetail_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", _mCarDetailInfo.seriesid.stringValue, @"seriesid#2", _mCarDetailInfo.productid.stringValue, @"specid#3", nil]];
    }
    
    // 是否存在对比列表数据中
    _isExistInCompareItems = NO;
    for (int i = 0; i < _compareItems.count; i++) {
        UCCarDetailInfoModel * mCarDetail = [_compareItems objectAtIndex:i];
        if ([mCarDetail.carid integerValue] == [_mCarDetailInfo.carid integerValue]) {
            _isExistInCompareItems = YES;
            break;
        }
    }
    
    // 加载对比列表数据
    _vCarCompare.compareItems = _compareItems;
    [_vCarCompare reloadData];
    
    // 显示是否加入对比
    UIImageView *ivAddCompare = (UIImageView *)[self viewWithTag:kAddCompareImageViewTag];
    if (_isExistInCompareItems) {
        ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon_h"];
        ivAddCompare.transform = CGAffineTransformMakeRotation([OMG degreesToRadians:45]);
    } else {
        ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon"];
    }
    // 发布日期
    NSString *publicdate = nil;
    publicdate = _mCarDetailInfo.publicdateText;
    
    _labReleaseTime.text = publicdate;
    // 加载浏览数
    [self loadCarPVCount];
    
    // 加载图片
    _vCarThumbPhoto.thumbimgurls = [_mCarDetailInfo.thumbimgurlsText componentsSeparatedByString:@","];
    [_vCarThumbPhoto reloadPhoto];
    
    // 已售时间
    if (_mCarDetailInfo.state.integerValue == 2) {
        _labSelldate.hidden = NO;
        _labSelldate.text = [NSString stringWithFormat:@"此车于%@售出", _mCarDetailInfo.selldate];
    } else
        _labSelldate.hidden = YES;
    
    CGFloat marginLift = 125;
    CGFloat width = 32;
    UIView *vBasicHeadBg = (UIView *)[self viewWithTag:kBasicHeadBgTag];
    // 保证金
    if ([_mCarDetailInfo.hasDeposit integerValue] > 0) {
        UIButton *btnAuthentication = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnAuthentication.tag = UCCarDetailViewPromptHasDeposit;
        [btnAuthentication addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnAuthentication setImage:[UIImage imageNamed:@"deposit_icon"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnAuthentication];
        
        marginLift = btnAuthentication.maxX;
    }
    // 厂家认证
    if ([_mCarDetailInfo.creditid integerValue] > 0) {
        UIButton *btnAuthentication = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnAuthentication.tag = UCCarDetailViewPromptAuthentication;
        [btnAuthentication addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnAuthentication setImage:[UIImage imageNamed:@"factory_approve"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnAuthentication];
        
        marginLift = btnAuthentication.maxX;
    }
    // 延保
    if ([_mCarDetailInfo.extendedrepair integerValue] == 1) {
        UIButton *btnExtended = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnExtended.tag = UCCarDetailViewPromptExtended;
        [btnExtended addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnExtended setImage:[UIImage imageNamed:@"ext_warrant"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnExtended];
        
        marginLift = btnExtended.maxX;
    }
    // 原厂质保
    else if ([_mCarDetailInfo.haswarranty integerValue] == 1) {
        UIButton *btnhaswarranty = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnhaswarranty.tag = UCCarDetailViewPromptHaswarranty;
        [btnhaswarranty addTarget:self action:@selector(onClickPromptBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnhaswarranty setImage:[UIImage imageNamed:@"factory_warrant"] forState:UIControlStateNormal];
        [vBasicHeadBg addSubview:btnhaswarranty];
        
        marginLift = btnhaswarranty.maxX;
    }
    // 新车
    if ([_mCarDetailInfo.isnewcar integerValue] == 1) {
        UIButton *btnNewCar = [[UIButton alloc] initWithFrame:CGRectMake(marginLift, 0, width, vBasicHeadBg.height)];
        btnNewCar.tag = UCCarDetailViewPromptNewCar;
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
    // 调整对比按钮位置
    _vCompareBtn.minY = (_vCarName.height - _vCompareBtn.height) / 2 + (_isCustomCar ? 225 : 264);
    
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
    NSArray *thumbTestReportPhotos = [_mCarDetailInfo.dctionthumbimg componentsSeparatedByString:@","];
    
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
        _vCarTestReportlPhoto.tag = UCCarDetailViewThumbnailsTestReport;
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
        CGSize labDescriptionContentSize = [[_labDescriptionContent.text trim] sizeWithFont:_labDescriptionContent.font constrainedToSize:CGSizeMake(_vDescription.width - 40, CGFLOAT_MAX) lineBreakMode:_labDescriptionContent.lineBreakMode];
        _labDescriptionContent.frame = CGRectMake(KMarginLefTitle, 30, labDescriptionContentSize.width, labDescriptionContentSize.height + 16 *2);
        _vDescription.height = _labDescriptionContent.maxY;
    } else {
        _vDescription.height = 0;
    }
    
    [_descriptionBG setFrame:CGRectMake(0, _labDescriptionContent.minY, _svCarInfo.width, _labDescriptionContent.height)];
    
    // 车辆配置
    _vConfig.minY = _vDescription.maxY;
    
    if (_mCarDetailInfo.configsText.length > 0) {
        _labConfigContent.text = _mCarDetailInfo.configsText;
        CGSize labConfigContentSize = [_labConfigContent.text sizeWithFont:_labConfigContent.font constrainedToSize:CGSizeMake(_vConfig.width - 40, CGFLOAT_MAX) lineBreakMode:_labConfigContent.lineBreakMode];
        _labConfigContent.frame = CGRectMake(KMarginLefTitle, 27, labConfigContentSize.width, labConfigContentSize.height + 16 * 2 + 3);
        _vConfig.height = _labConfigContent.maxY;
    } else {
        _vConfig.height = 0;
    }
    [_configBG setFrame:CGRectMake(0, _labConfigTitle.maxY, _svCarInfo.width, _labConfigContent.height)];
    
    // 添加按钮区域
    _vReportView = [self creatCarView:CGRectMake(0, _vConfig.maxY, self.width, NSNotFound)];
    _vReportView.minY = _vConfig.maxY;
    
    [_svCarInfo addSubview:_vReportView];
    [_svCarInfo addSubview:_bvOptions];
    
    // 设置底栏的位置
    _bvOptions.minY = _svCarInfo.contentOffset.y + _svCarInfo.height - _bvOptions.height;
    // scrollview的contentsize
    _svCarInfo.contentSize = CGSizeMake(self.width, _vReportView.maxY + KOptionsBarHeight);
    
    // 卖家信息
    _labName.text = _mCarDetailInfo.salesPerson.txtsalesname;
    CGSize labNameSize = [_labName.text sizeWithFont:_labName.font constrainedToSize:CGSizeMake(_labName.width, 100) lineBreakMode:_labName.lineBreakMode];
    _labKind.minX = _labName.minX + labNameSize.width;
    _labKind.text = [NSString stringWithFormat:@"(%@)",_isBusiness ? @"商家" : @"个人"];
    _labTelephone.text = [NSString stringWithFormat:@"%@(%@)",_mCarDetailInfo.salesPerson.txtsalesphone,_mCarDetailInfo.cityidText];
    
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
    
    // 显示对比滑动引导
    [self showComparSlidingTips];
    
    // 检查是否存在多个详情页面
    int vDetailCount = 0;
    for (id vTemp in [[MainViewController sharedVCMain].vMain subviews]) {
        if ([vTemp isKindOfClass:[UCCarDetailView class]]) {
            vDetailCount ++;
            // 存储第一个详情页
            if (!_vFirstDetail)
                _vFirstDetail = vTemp;
            // 显示返回列表按钮
            if (vDetailCount > 1 && !_isForIM) {
                _btnHome.hidden = NO;
                break;
            }
        }
    }
    
    // 已售车源隐藏联系栏
    if (_mCarDetailInfo.state.integerValue == 2 || _isForIM) {
        [self hideOptionBar];
    }
    
    // 站外车源
    if (_mCarDetailInfo.carsourceid.integerValue >= 1000 && _mCarDetailInfo.carsourceid.integerValue <= 2000 ) {
        for (NSInteger i = 0; i < 3; i++) {
            UIView *btn = [_bvOptions viewWithTag:kBtnSelect + i];
            if (i == 0)
                btn.maxX = _bvOptions.maxX;
            else
                btn.hidden = YES;
        }
    }

    // 设置上拉下拉文字
    if (_isOpenTurning)
        [self setHeadterAndFooterText];
}


/** 更新是否收藏 */
- (void)setIsFavoriteWithBool:(BOOL)isFavorite
{
    if (isFavorite) {
        [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
        [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
        _isFavorite = YES;
    } else {
        [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
        [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
        _isFavorite = NO;
    }
}

/** 更新浏览数 */
- (void)loadCarPVCount
{
    if (_carPVCount >= 0) {
        // 浏览数
        _labViewCount.text = [NSString stringWithFormat:@"%d", _carPVCount];
        [_labViewCount sizeToFit];
        _labViewCount.origin = CGPointMake(_labView.minX - _labViewCount.width - 2, 8);
        _labHave.origin = CGPointMake(_labViewCount.minX - _labHave.width - 2, 8);
    }
}

/** 刷新页面 */
- (void)setReloadBtnHidden:(BOOL)isShow message:(NSString *)message enable:(BOOL)enable
{
    if (!_btnReload) {
        _btnReload = [[UIButton alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
        _btnReload.backgroundColor = [UIColor clearColor];
        _btnReload.titleLabel.numberOfLines = 2;
        _btnReload.titleLabel.font = kFontLarge;
        _btnReload.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnReload setTitleColor:kColorGrey2 forState:UIControlStateNormal];
        [_btnReload addTarget:self action:@selector(onClickReloadViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!isShow) {
        [self addSubview:_btnReload];
    } else {
        [_btnReload removeFromSuperview];
        _btnReload = nil;
    }
    
    [_btnReload setTitle:message forState:UIControlStateNormal];
    _btnReload.enabled = enable;
}

/** 设置列表页数据源和总数量 */
- (void)setCarInfoModels:(NSMutableArray *)mCarInfos carAllCount:(NSInteger)carAllCount
{
    _mCarLists = mCarInfos;
    _carListAllCount = carAllCount;
    
    // 设置上拉下拉文字
    [self setHeadterAndFooterText];
}

/** 设置上拉下拉文字 */
- (void)setHeadterAndFooterText
{
    NSUInteger index = [_mCarLists indexOfObject:_mCarInfo];
    if (index == NSNotFound)
        return;
    
    BOOL isTopHidden = YES;
    BOOL isBottomHidden = YES;
    
    NSString *strLastCar = [NSString stringWithFormat:@"%@", @"已经是第一辆车了"];
    NSString *strNextCar = [NSString stringWithFormat:@"%@", @"已经是最后一辆车了"];
    
    // 上一个
    if (index > 0) {
        strLastCar = [NSString stringWithFormat:@"上一辆：%@", ((UCCarInfoModel *)[_mCarLists objectAtIndex:index - 1]).carname];
        isTopHidden = NO;
    }
    
    // 下一个
    if (index < _mCarLists.count - 1) {
        strNextCar = [NSString stringWithFormat:@"下一辆：%@", ((UCCarInfoModel *)[_mCarLists objectAtIndex:index + 1]).carname];
        isBottomHidden = NO;
    }
    else if (_carListAllCount > _mCarLists.count)
        strNextCar = @"查看下一辆";
    
    // 设置 “头 & 底” 文字
    [_svCarInfo setHeaderText:strLastCar topCircleHidden:isTopHidden footerText:strNextCar topCircleHidden:isBottomHidden];
}

/** 隐藏联系栏 */
- (void)hideOptionBar
{
    _svCarInfo.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _svCarInfo.contentSize = CGSizeMake(_svCarInfo.contentSize.width, _isForIM ? _vConfig.maxY : _svCarInfo.contentSize.height - KOptionsBarHeight);
    _bvOptions.hidden = YES;
}

/** 显示对比滑动引导 */
- (void)showComparSlidingTips {
    if (!_ivComparSlidingTips && _compareItems.count > 0 && ![AMCacheManage currentIsShowComparSlidingTips]) {
        // 箭头
        _ivComparSlidingTips = [[UIImageView alloc] initLineWithFrame:CGRectMake(0,0, _vCompareBtn.width, _vCompareBtn.height) color:[UIColor redColor]];
        NSArray *images = [NSArray arrayWithObjects: [UIImage imageNamed:@"compare-1.png"],[UIImage imageNamed:@"compare-2.png"],[UIImage imageNamed:@"compare-3.png"], nil];
        _ivComparSlidingTips.animationImages = images;
        // 设置动画时间
        _ivComparSlidingTips.animationDuration = 0.8;
        //设置动画次数 0 表示无限
        _ivComparSlidingTips.animationRepeatCount = 0;
        //开始播放动画
        [_ivComparSlidingTips startAnimating];
        
        [_vCompareBtn insertSubview:_ivComparSlidingTips belowSubview:_ivCountBackground];
    }
}

/** 隐藏对比滑动引导 */
- (void)hideComparSlidingTips {
    [AMCacheManage setCurrentIsShowComparSlidingTips:YES];
    
    [_ivComparSlidingTips removeFromSuperview];
    _ivComparSlidingTips = nil;
}

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

/** 分享 */
- (void)shareCarImageUrl:(NSString *)imageUrl
{
    NSString *url = _isBusiness ? [NSString stringWithFormat:@"http://m.che168.com/dealer/%@/%@.html", _mCarDetailInfo.userid, _mCarDetailInfo.carid] : [NSString stringWithFormat:@"http://m.che168.com/personal/%@.html", _mCarDetailInfo.carid];
    /*
    // 上牌时间
    NSString *strRegistrationTime = ((UILabel *)[self viewWithTag:KlabLicenseContenTag]).text;
    // 行驶里程
    NSString *strDrivemileage = [NSString stringWithFormat:@"%@万公里",_mCarDetailInfo.drivemileageText];
     
     // 分享文字
     NSString *shareText = [NSString stringWithFormat:@"小伙伴们，别说有好东西不想着你们，这辆%@上牌的%@行驶了%@，售价%@确实不错，详情点击%@ #二手车之家#", strRegistrationTime, _labCarName.text, strDrivemileage, strPrice, url];
     */
    // 售价
    NSString *strPrice = [NSString stringWithFormat:@"%@万",_mCarDetailInfo.bookpriceText];
    // 分享文字
    NSString *shareText = [NSString stringWithFormat:@"%@，%@ #二手车之家# %@", strPrice, _labCarName.text, url];
    
    NSDictionary *wxsessionContent = [[NSDictionary alloc] initWithObjectsAndKeys:[_labCarName.text dNull:@"-"], @"title", [NSString stringWithFormat:@"价格：%@万\n上牌：%@\n里程：%@万公里", [_mCarDetailInfo.bookpriceText dNull:@"-"], [_mCarDetailInfo.firstregtimeText dNull:@"-"], [_mCarDetailInfo.drivemileageText dNull:@"-"]], @"shareText", nil];
    
    [[MainViewController sharedVCMain] showShareList:shareText imageUrl:imageUrl url:url wxsessionContent:wxsessionContent];
}

/**  动画 */
- (void)beginAnimation:(UIView *)vAnimation setValue:(NSString *)value
{
    // 抖动动画
    // 放大动画
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    zoomAnimation.toValue = [NSNumber numberWithFloat:1.3];
    zoomAnimation.beginTime = 0.0f;
    zoomAnimation.duration = 0.2f;
    zoomAnimation.removedOnCompletion = NO;
    zoomAnimation.fillMode = kCAFillModeForwards;
    zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // 缩小动画
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.fromValue = [NSNumber numberWithFloat:1.3];
    narrowAnimation.toValue = [NSNumber numberWithFloat:1.0];
    narrowAnimation.beginTime = 0.2f;
    narrowAnimation.duration = 0.2f;
    narrowAnimation.removedOnCompletion = NO;
    narrowAnimation.fillMode = kCAFillModeForwards;
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.duration = 0.4f;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    [animationGroup setAnimations:[NSArray arrayWithObjects:zoomAnimation, narrowAnimation, nil]];
    [animationGroup setValue:value forKey:@"animType"];
    //将上述两个动画编组
    [vAnimation.layer addAnimation:animationGroup forKey:value];
}

/** 平移手势 */
-(void)handelPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    // 拖住按钮显示高亮状态
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIButton *btnAddCompare = (UIButton *)[self viewWithTag:kAddCompareButtonTag];
        btnAddCompare.selected = YES;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UIButton *btnAddCompare = (UIButton *)[self viewWithTag:kAddCompareButtonTag];
        btnAddCompare.selected = NO;
    }
    
    // 得到按钮偏移量
    CGPoint point = [gestureRecognizer translationInView:_vCompareBtn];
    
    // 通过按钮偏移量,改变frame
    _vCompareBtn.minX = _vCompareBtn.minX + point.x;
    
    // 判断当前是否存在对比页面，没有重新添加（创建多个详情时会把对比页面加到其他视图上）
    BOOL isExitCarCompareView = NO;
    for (id vTepm in [self subviews]) {
        if ([vTepm isKindOfClass:[_vCarCompare class]]) {
            isExitCarCompareView = YES;
            break;
        }
    }
    if (!isExitCarCompareView) {
        // 刷新数据源
        _vCarCompare.compareItems = _compareItems;
        _vCarCompare.delegate = self;
        [_vCarCompare reloadData];
        // 添加视图
        [self addSubview:_vCarCompare];
    }
    
    _vCarCompare.minX = _vCarCompare.minX + point.x;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect frame = CGRectZero;
        CGFloat compareMinX = zero;
        // 显示对比页
        if (_vCarCompare.minX < self.width * 7/8) {
            // 添加对比页统计
            [UMStatistics event:pv_3_3_pk];
            [UMSAgent postEvent:comparelist_pv page_name:NSStringFromClass(_vCarCompare.class)];
            
            // 统计对比列表时长
            [UMSAgent startTracPage:NSStringFromClass(_vCarCompare.class)];
            [UMStatistics beginPageView:_vCarCompare];
            
            compareMinX = -_vCompareBtn.width;
            frame = CGRectMake(0, _vCarCompare.minY, _vCarCompare.width, _vCarCompare.height);
            
            // 对比拉开后, 隐藏对比滑动引导
            [self hideComparSlidingTips];
        }
        // 关闭对比页面
        else {
            compareMinX = self.width - _vCompareBtn.width;
            frame = CGRectMake(self.width, _vCarCompare.minY, _vCarCompare.width, _vCarCompare.height);
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            _vCompareBtn.minX = compareMinX;
            _vCarCompare.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
    
    // 重设偏移量
    [gestureRecognizer setTranslation:CGPointZero inView:_vCompareBtn];
    
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn
{
    //去掉所有动画
    UIImageView *ivCompareCountBag = (UIImageView *)[self viewWithTag:kCompareCountBagTag];
    [ivCompareCountBag.layer removeAllAnimations];
    [_vCopyCarName.layer removeAllAnimations];
    
    // 从收藏列表进入, 关闭时刷新下收藏
    if (_vFavoritesList)
        [_vFavoritesList refreshFavoritesList];
    
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 点击按钮区域 */
- (void)onClickCarsBtn:(UIButton *)btn
{
    // 车源举报
    if ([btn.titleLabel.text hasPrefix:@"车源举报"]) {
        // 添加友盟统计事件
        [UMStatistics event:pv_3_7_buycar_buinesssourcedetail_report];
        [UMSAgent postEvent:buycar_buinesssourcedetail_report_pv page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             _mCarDetailInfo.carid.stringValue, @"objectid#1",
                             _mCarDetailInfo.userid.stringValue, @"dealerid#5",
                             _mCarDetailInfo.seriesid.stringValue, @"seriesid#2",
                             _mCarDetailInfo.productid.stringValue, @"specid#3", nil]];
        
        UCReportView *report = [[UCReportView alloc] initWithFrame:self.bounds];
        report.carName =  _mCarDetailInfo.carnameText;
        report.carId = _mCarDetailInfo.carid;
        report.seriesid = _mCarDetailInfo.seriesid;
        report.brandid = _mCarDetailInfo.brandid;
        report.specid = _mCarDetailInfo.productid;
        
        [[MainViewController sharedVCMain] openView:report animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 类似车源
    else if ([btn.titleLabel.text hasPrefix:@"类似车源"]) {
        [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailrelevant : c_3_1_personsourcedetailrelevant];
        UCRecommendCarList *vRecommendCarList = [[UCRecommendCarList alloc] initWithFrame:self.bounds mCarDetailInfo:_mCarDetailInfo];
        [[MainViewController sharedVCMain] openView:vRecommendCarList animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 同价新车
    else if ([btn.titleLabel.text hasPrefix:@"同价新车"]) {
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
            _urlCarPrice = url;
            
            UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"确定打开\"汽车报价\"查看同价新车吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            vAlert.tag = kCarPriceAlertTag;
            [vAlert show];
        } else {
            UIAlertView *vAlert = [[UIAlertView alloc] initWithTitle:nil message:@"您还未安装最新的\"汽车报价\"" delegate:self cancelButtonTitle:@"取消查看" otherButtonTitles:@"立即下载", nil];
            [vAlert show];
        }
    }
    // 查看原车信息
    else if ([btn.titleLabel.text hasPrefix:@"查看原车信息"]) {
        UCActivityView *vActivity = [[UCActivityView alloc] initWithFrame:self.bounds];
        [vActivity loadWebWithString:_mCarDetailInfo.carsourceurl];
        [[MainViewController sharedVCMain] openView:vActivity animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
}

/** 回主页按钮 */
- (void)onClickHomeBtn
{
    [[MainViewController sharedVCMain] closeView:_vFirstDetail animateOption:AnimateOptionMoveLeft];
}

/** 刷新页面 */
- (void)onClickReloadViewBtn:(UIButton *)btn
{
    // 隐藏刷新按钮
    [self setReloadBtnHidden:YES message:@"加载车源失败\n点击屏幕重试" enable:YES];
    // 重新获取数据
    // 必须清空，为了不影响判断初始化后的代码
    _mCarDetailInfo = nil;
    _mReferencePrice = nil;
    [_apiHelper cancel];
    _cBlackBg = nil;
    [self getCarInfo:_mCarInfo.carid];
    if (_carPVCount < 0)
        [self getPVWithCarID:_mCarInfo.carid];
}

/** 点击收藏 */
- (void)onClickFavoritesBtn:(UIButton *)btn
{
    // 收藏
    if (_isFavorite == NO) {
        [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailfavorites : c_3_1_personsourcedetailfavorites];
        
        if ([AMCacheManage currentUserType] == UserStylePersonal) {
            [self addOrDeleteFavorite:_mCarDetailInfo.carid toType:1];
        } else {
            UCFavoritesModel * mFavorite = [[UCFavoritesModel alloc] init];
            mFavorite.quoteID=[NSString stringWithFormat:@"%i", [_mCarDetailInfo.carid intValue]];
            mFavorite.image = [[_mCarDetailInfo.thumbimgurls componentsSeparatedByString:@","] firstObject];
            mFavorite.seriesId = _mCarDetailInfo.seriesid;
            mFavorite.name = _mCarDetailInfo.carname;
            mFavorite.completeSale = nil;
            mFavorite.price = [_mCarDetailInfo.bookprice stringValue];
            mFavorite.mileage = [_mCarDetailInfo.drivemileage stringValue];
            mFavorite.registrationDate = _mCarDetailInfo.firstregtime;
            mFavorite.publishDate = _mCarDetailInfo.publicdate;
            mFavorite.isDealer = _sourceid;
            mFavorite.levelId = _mCarDetailInfo.levelid;
            mFavorite.isnewcar = _mCarDetailInfo.isnewcar;
            mFavorite.invoice = _mCarDetailInfo.extendedrepair;
            
            BOOL isSucess= [AMCacheManage saveCarToFavourite:mFavorite];
            NSString *message = nil;
            UIImage *icon = nil;
            if (isSucess) {
                [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
                [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
                _isFavorite = YES;
                message = @"收藏成功";
                icon = kImageRequestSuccess;
            } else {
                message = @"收藏失败";
                icon = kImageRequestError;
            }
            [[AMToastView toastView] showMessage:message icon:icon duration:AMToastDurationNormal];
        }
    } else {
        
        if (_isForIM) {
            [UMStatistics event:c_4_3_buyCar_Detail_IM_Chat_ViewCar_Collect];
        }
        
        [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailnofavorites : c_3_1_personsourcedetailnofavorites];
        
        if ([AMCacheManage currentUserType] == UserStylePersonal) {
            [self addOrDeleteFavorite:_mCarDetailInfo.carid toType:0];
        } else {
            BOOL isSuccess = [AMCacheManage deleteCarFromFavourite:[_mCarDetailInfo.carid stringValue]];
            NSString *message = nil;
            UIImage *icon = nil;
            if (isSuccess) {
                [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
                [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
                _isFavorite = NO;
                message = @"取消收藏成功";
                icon = kImageRequestSuccess;
            } else {
                message = @"取消收藏失败";
                icon = kImageRequestError;
            }
            [[AMToastView toastView] showMessage:message icon:icon duration:AMToastDurationNormal];
        }
    }
}

/** 底部按钮 */
- (void)onClickBottomOperationBtn:(UIButton *)btn
{
    // 屏蔽快速连续点击
    if (![OMG isValidClick:kAnimateSpeedFast])
        return;

    // 联系
    if (btn.tag == kBtnSelect) {
        
        UIButton *btnPhone = (UIButton *)[self viewWithTag:kBtnSelect];
        btnPhone.selected = YES;
        if (!self.cBlackBg) {
            // 背景视图
            _cBlackBg = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - _bvOptions.height)];
            _cBlackBg.layer.masksToBounds = YES;
            _cBlackBg.tag = kBlackBgViewTag;
            [_cBlackBg addTarget:self action:@selector(onClickCloseChooseViewControl:) forControlEvents:UIControlEventTouchUpInside];
            _cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
            [_cBlackBg addSubview:_vChoosePhone];
            [self addSubview:_cBlackBg];
            // 选图片视图
            if (!_vChoosePhone) {
                _vChoosePhone = [self creatPhoneView:CGRectMake(0, _cBlackBg.maxY, _cBlackBg.width, 150)];
                _vChoosePhone.layer.masksToBounds = YES;
                [_cBlackBg addSubview:_vChoosePhone];
            }
        }

        if (_vChoosePhone.minY == _cBlackBg.height - 150) {
            // 动画关闭
            UIButton *btnPhone = (UIButton *)[self viewWithTag:kBtnSelect];
            btnPhone.selected = NO;
            [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                _vChoosePhone.minY = _cBlackBg.maxY + 40;
                _cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
            }completion:^(BOOL finished) {
                _cBlackBg.hidden = YES;
                _svCarInfo.scrollEnabled = YES;
            }];
            return;
        }
        
        _cBlackBg.hidden = NO;
        _vChoosePhone.minY = _cBlackBg.height + 40;
        
        if ([AMCacheManage currentConfigStartIMGuideStatus] == 0) {
            [_vHint clearWithAnimation:YES duration:kAnimateSpeedFast completion:^(BOOL finish) {
                [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                    _svCarInfo.scrollEnabled = NO;
                    _cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
                    _vChoosePhone.minY = _cBlackBg.height - 150;
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
        else{
            [UIView animateWithDuration:kAnimateSpeedFast animations:^{
                _svCarInfo.scrollEnabled = NO;
                _cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
                _vChoosePhone.minY = _cBlackBg.height - 150;
            } completion:^(BOOL finished) {
                
            }];
        }
        
//        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
//            _svCarInfo.scrollEnabled = NO;
//            _cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
//            _vChoosePhone.minY = _cBlackBg.height - 150;
//        } completion:^(BOOL finished) {
//            if ([AMCacheManage currentConfigStartIMGuideStatus] == 0) {
//                [_vHint clearWithAnimation:YES duration:kAnimateSpeedFast completion:nil];
//            }
//        }];
        
    }
    // 商铺
    else if (btn.tag == kBtnSelect + 1) {
        [UMStatistics event:c_3_1_buinesssourcedetailmerchant];
        UCBusinessInfoView *vBusinessInfo = [[UCBusinessInfoView alloc] initWithFrame:self.bounds userid:_mCarDetailInfo.userid];
        [[MainViewController sharedVCMain] openView:vBusinessInfo animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    // 看车
    else if (btn.tag == kBtnSelect + 2) {
        
        [UMStatistics event:c_3_5_appointment];
        [UMSAgent postEvent:appointment_pv page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             _mCarDetailInfo.carid.stringValue, @"objectid#1",
                             _mCarDetailInfo.userid.stringValue, @"dealerid#5",
                             _mCarDetailInfo.seriesid.stringValue, @"seriesid#2",
                             _mCarDetailInfo.productid.stringValue, @"specid#3", nil]];
        
        UCViewCarView *vReserCar = [[UCViewCarView alloc] initWithFrame:self.bounds mCarDetailInfo: _mCarDetailInfo];
        
        [[MainViewController sharedVCMain] openView:vReserCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
}

- (void)onClickbtnOpenPhone:(UIButton *)btn
{
    if (btn.tag == kBtnPhoneTag) {
        [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailcall : c_3_1_personsourcedetailcall];
        
        if ([OMG callPhone:_mCarDetailInfo.salesPerson.salesphone]) {
            // 记录事件
            APIHelper *apiHelperEvent = [[APIHelper alloc] init];
            [apiHelperEvent callstatisticsEventWithCarID:_mCarDetailInfo.carid type:[NSNumber numberWithInt:10] dealerid:_mCarDetailInfo.userid];
            //TODO test action sheet
            [self openAfterCallActionSheet];
        }
        
    }
    // 在线咨询
    else if (btn.tag == kBtnIMTag) {
        self.imRootEntry = [[UCIMRootEntry alloc] init];
        [self.imRootEntry openChatRootByVerified:self.mCarDetailInfo];
        // 动画关闭
        UIControl *cBlackBg = _cBlackBg;
        UIButton *btnPhone = (UIButton *)[self viewWithTag:kBtnSelect];
        btnPhone.selected = NO;
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            _vChoosePhone.minY = cBlackBg.maxY + 40;
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        }completion:^(BOOL finished) {
            cBlackBg.hidden = YES;
            _svCarInfo.scrollEnabled = YES;
        }];
    }
    else if (btn.tag == kBtnMessageTag) {
        
        [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailmessage : c_3_1_personsourcedetailmessage];
        Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        
        if (messageClass != nil)
        {
            if ([messageClass canSendText])
            {
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                picker.body = [NSString stringWithFormat:@"您好，我在二手车之家看到您发的【%@】, 行驶【%@万公里】, 售价【%@万元】很感兴趣，我想了解一下车的情况。",_mCarDetailInfo.carnameText.length > 0 ? _mCarDetailInfo.carnameText : _mCarDetailInfo.productidText ,_mCarDetailInfo.drivemileageText,_mCarDetailInfo.bookpriceText];
                if (_mCarDetailInfo.salesPerson.salesphone.length == 0) {
                    [[AMToastView toastView] showMessage:@"用户信息异常,不能发送短信" icon:kImageRequestError duration:AMToastDurationNormal];
                    return;
                }
                
                NSString *msg = _mCarDetailInfo.salesPerson.salesphone;
                picker.recipients= [NSArray arrayWithObject:msg];
                self.viewController.modalPresentationStyle= UIModalPresentationPageSheet;
                [self.viewController presentModalViewController:picker animated:YES];
                
                // 记录事件
                APIHelper *apiHelperEvent = [[APIHelper alloc] init];
                
                [apiHelperEvent callstatisticsEventWithCarID:_mCarDetailInfo.carid type:[NSNumber numberWithInt:20] dealerid:_mCarDetailInfo.userid];
            }
            else
                [[AMToastView toastView] showMessage:@"您的设备不支持发送短信" icon:kImageRequestError duration:AMToastDurationNormal];
        }else
            [[AMToastView toastView] showMessage:@"系统版本过低" icon:kImageRequestError duration:AMToastDurationNormal];
        
        // 动画关闭
        UIControl *cBlackBg = _cBlackBg;
        UIButton *btnPhone = (UIButton *)[self viewWithTag:kBtnSelect];
        btnPhone.selected = NO;
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            _vChoosePhone.minY = cBlackBg.maxY + 40;
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        }completion:^(BOOL finished) {
            cBlackBg.hidden = YES;
            _svCarInfo.scrollEnabled = YES;
        }];
    }
}

/** 单击背景收回选择图片视图 */
- (void)onClickCloseChooseViewControl:(UIControl *)sender
{
    UIControl *cBlackBg = sender;
    UIButton *btnPhone = (UIButton *)[self viewWithTag:kBtnSelect];
    btnPhone.selected = NO;
    // 动画关闭
    [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
        _vChoosePhone.minY = cBlackBg.maxY + 40;
        cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
    }completion:^(BOOL finished) {
        cBlackBg.hidden = YES;
        _svCarInfo.scrollEnabled = YES;
    }];
}

/** 分享 */
- (void)onClickShareBtn:(UIButton *)btn
{
    NSArray *imgurls = [_mCarDetailInfo.imgurls componentsSeparatedByString:@","];
    [self shareCarImageUrl:(imgurls.count > 0 ? [imgurls objectAtIndex:0] : nil)];
}

/** 加入对比列表 */
- (void)onClickCompareBtn:(UIButton *)btn
{
    // 滑动引导存在时, 不响应点击事件
    if (_ivComparSlidingTips)
        return;
    
    UIImageView *ivAddCompare = (UIImageView *)[self viewWithTag:kAddCompareImageViewTag];
    
    if (_isExistInCompareItems) {
        // 如存在，取索引值
        NSInteger index = NSNotFound;
        for (int i = 0; i < _compareItems.count; i++) {
            UCCarDetailInfoModel * mCarDetail = [_compareItems objectAtIndex:i];
            if ([mCarDetail.carid integerValue] == [_mCarDetailInfo.carid integerValue]) {
                index = i;
                break;
            }
        }
        // 删除
        if (index == NSNotFound) {
            [[AMToastView toastView] showMessage:@"数据出错，删除失败了" icon:kImageRequestError duration:AMToastDurationNormal];
        } else {
            // 点击删除对比统计
            [UMStatistics event:c_3_3_pknoaddclick];
            [_compareItems removeObjectAtIndex:index];
            _isExistInCompareItems = NO;
            ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon"];
            
            // 更新对比数
            UIImageView *ivCompareCountBag = (UIImageView *)[self viewWithTag:kCompareCountBagTag];
            NSInteger willShowCompareCount = _compareItems.count;
            _labCompareCount.text = [NSString stringWithFormat:@"%d", willShowCompareCount];
            ivCompareCountBag.hidden = willShowCompareCount == 0 ? YES : NO;
            
            // 开始动画
            [self beginAnimation:ivCompareCountBag setValue:KChageCompareNumAnimation];
        }
        
    } else {
        // 最多10个
        if (_compareItems.count >= 10) {
            [[AMToastView toastView] showMessage:@"抱歉，最多只能添加10款对比车辆" icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        } else {
            // 点击增加对比统计
            [UMStatistics event:c_3_3_pkaddclick];
            // 增加
            _mCarDetailInfo.sourceid = _sourceid;
            if (_compareItems.count > 0)
                [_compareItems insertObject:_mCarDetailInfo atIndex:0];
            else
                [_compareItems addObject:_mCarDetailInfo];
            _isExistInCompareItems = YES;
            ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon_h"];
            
            // 更新对比数
            // 数字背景
            UIImageView *ivCompareCountBag = (UIImageView *)[self viewWithTag:kCompareCountBagTag];
            NSInteger willShowCompareCount = _compareItems.count;
            _labCompareCount.text = [NSString stringWithFormat:@"%d", willShowCompareCount];
            // 解决快速点击按钮时, 0个数还出现
            ivCompareCountBag.hidden = willShowCompareCount == 0 ? YES : NO;
            
            // 开始动画
            [self beginAnimation:ivCompareCountBag setValue:KChageCompareNumAnimation];
            
            // 去掉所有动画
            [_vCopyCarName.layer removeAllAnimations];
            [_vCopyCarName removeFromSuperview];
            
            /* 取消移动动画
            // 右移车名动画
            UILabel *labBasicTitle = (UILabel *)[self viewWithTag:kBasicTitleLabel];
            
            if (!_vCopyCarName) {
                if (IOS7_OR_LATER) {
                    _vCopyCarName = [_vCarName snapshotViewAfterScreenUpdates:NO];
                } else {
                    _vCopyCarName = [[UIView alloc] initWithFrame:_vCarName.bounds];
                    UIImage *iCopyCarName = [_vCarName screenshot];
                    UIImageView *ivCopyCarName = [[UIImageView alloc] initWithFrame:_vCopyCarName.bounds];
                    ivCopyCarName.image = iCopyCarName;
                    [_vCopyCarName addSubview:ivCopyCarName];
                }
                _vCopyCarName.userInteractionEnabled = NO;
            }
            _vCopyCarName.frame = CGRectMake(0, _vCarBasicInfo.minY + labBasicTitle.maxY, _vCarName.width, _vCarName.height);
            [_svCarInfo addSubview:_vCopyCarName];
            
            // 位置移动
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, _vCopyCarName.center.x, _vCopyCarName.center.y);
            CGPathAddLineToPoint(path, NULL, _vCopyCarName.center.x + 28, _vCopyCarName.center.y - 30);
            CGPathAddLineToPoint(path, NULL, _vCopyCarName.center.x + 56, _vCopyCarName.center.y - 40);
            CGPathAddLineToPoint(path, NULL, _vCopyCarName.center.x + 84, _vCopyCarName.center.y - 45);
            CGPathAddLineToPoint(path, NULL, _vCopyCarName.center.x + 108, _vCopyCarName.center.y - 33);
            CGPathAddLineToPoint(path, NULL, _vCopyCarName.center.x + 115, _vCopyCarName.center.y - 18);
            
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.duration = 0.6;
            animation.path = path;
            [_vCopyCarName.layer addAnimation:animation forKey:@"position"];
            CGPathRelease(path);
            
            // 缩放动画
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
            scaleAnimation.toValue = [NSNumber numberWithFloat:0.05];
            scaleAnimation.duration = 0.6f;
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            [animationGroup setValue:KMoveCarNameAnimation forKey:@"animType"];
            animationGroup.delegate = self;
            animationGroup.duration = 0.6f;
            animationGroup.removedOnCompletion = NO;
            animationGroup.fillMode = kCAFillModeForwards;
            
            [animationGroup setAnimations:[NSArray arrayWithObjects:animation, scaleAnimation, nil]];
            //将上述两个动画编组
            [_vCopyCarName.layer addAnimation:animationGroup forKey:KMoveCarNameAnimation];
             */
        }
    }
    
    // 更新对比数据和显示数量
    [AMCacheManage setCurrentCompareInfo:_compareItems];
    
    // 刷新列表
    _vCarCompare.compareItems = _compareItems;
    [_vCarCompare reloadData];
    
    // 旋转“+”
    [UIView animateWithDuration:0.3 animations:^{
        ivAddCompare.transform = CGAffineTransformMakeRotation([OMG degreesToRadians:(_isExistInCompareItems ? 45 : 0)]);
    }];
    
    // 显示对比滑动引导
    [self showComparSlidingTips];
}

/** 点击提示按钮 */
- (void)onClickPromptBtn:(UIButton *)btn
{
    if (btn.tag == UCCarDetailViewPromptHasDeposit)
        [[AMToastView toastView] showMessage:[NSString stringWithFormat:@"若与真实车况不符，赔%@", _mCarDetailInfo.bailmoney] icon:nil duration:AMToastDurationNormal];
    if (btn.tag == UCCarDetailViewPromptNewCar)
        [[AMToastView toastView] showMessage:@"本车车况近似新车" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarDetailViewPromptExtended)
        [[AMToastView toastView] showMessage:@"本车提供延长质保" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarDetailViewPromptHaswarranty)
        [[AMToastView toastView] showMessage:@"本车提供原厂质保" icon:nil duration:AMToastDurationNormal];
    else if (btn.tag == UCCarDetailViewPromptAuthentication)
        [[AMToastView toastView] showMessage:@"本车已通过品牌认证" icon:nil duration:AMToastDurationNormal];
}

 - (void)openAfterCallActionSheet{
     // 这里做点击拨打电话以后的弹框处理事件 sheet完成以后要加到 callPhone 方法里. 如果能拨打电话再弹框
     [self onClickCloseChooseViewControl:_cBlackBg];
     
     NSString *addFavStr = @"";
     // 是否收藏
     if (_isFavorite) {
         [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
         [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
         _isFavorite = YES;
         addFavStr = @"取消收藏";
     }
     else {
         [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
         [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
         _isFavorite = NO;
         addFavStr = @"车源收藏";
     }
     
     SHLActionSheet *as = [[SHLActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"车源举报",addFavStr, nil];
     [as setButtonResponse:SHLActionSheetButtonResponseHighlightsOnPress];
     [as setFont:[UIFont boldSystemFontOfSize:15]];
     [as setButtonAlpha:1.0];
     [as setButtonTextColor:kColorBlue];
     [as setButtonHighlightTextColor:kColorBlue];
     [as setButtonBackgroundColor:[UIColor whiteColor]];
     [as setButtonHighlightBackgroundColor:kColorNewLine];
     [as setTranparentViewAlpha:0.8];
     [as showInView:self];
 }

#pragma mark - SHLActionSheetDelegate

-(void)actionSheet:(SHLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            //举报
            // 添加友盟统计事件
            [UMStatistics event:pv_3_7_buycar_buinesssourcedetail_report];
            
            UCReportView *report = [[UCReportView alloc] initWithFrame:self.bounds];
            report.carName =  _mCarDetailInfo.carnameText;
            report.carId = _mCarDetailInfo.carid;
            report.seriesid = _mCarDetailInfo.seriesid;
            report.brandid = _mCarDetailInfo.brandid;
            report.specid = _mCarDetailInfo.productid;
            
            [[MainViewController sharedVCMain] openView:report animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
        case 1:
        {
            //收藏
            if (_isFavorite == NO) {
                [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailfavorites : c_3_1_personsourcedetailfavorites];
                UCFavoritesModel * mFavorite = [[UCFavoritesModel alloc] init];
                mFavorite.quoteID=[NSString stringWithFormat:@"%i", [_mCarDetailInfo.carid intValue]];
                mFavorite.image = [[_mCarDetailInfo.thumbimgurls componentsSeparatedByString:@","] firstObject];
                mFavorite.seriesId = _mCarDetailInfo.seriesid;
                mFavorite.name = _mCarDetailInfo.carname;
                mFavorite.completeSale = nil;
                mFavorite.price = [_mCarDetailInfo.bookprice stringValue];
                mFavorite.mileage = [_mCarDetailInfo.drivemileage stringValue];
                mFavorite.registrationDate = _mCarDetailInfo.firstregtime;
                mFavorite.publishDate = _mCarDetailInfo.publicdate;
                mFavorite.isDealer = _sourceid;
                mFavorite.levelId = _mCarDetailInfo.levelid;
                mFavorite.isnewcar = _mCarDetailInfo.isnewcar;
                mFavorite.invoice = _mCarDetailInfo.extendedrepair;
                
                BOOL isSucess= [AMCacheManage saveCarToFavourite:mFavorite];
                NSString *message = nil;
                UIImage *icon = nil;
                if (isSucess) {
                    [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
                    [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
                    _isFavorite = YES;
                    message = @"收藏成功";
                    icon = kImageRequestSuccess;
                } else {
                    message = @"收藏失败";
                    icon = kImageRequestError;
                }
                [[AMToastView toastView] showMessage:message icon:icon duration:AMToastDurationNormal];
            } else {
                [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailnofavorites : c_3_1_personsourcedetailnofavorites];
                BOOL isSuccess = [AMCacheManage deleteCarFromFavourite:[_mCarDetailInfo.carid stringValue]];
                NSString *message = nil;
                UIImage *icon = nil;
                if (isSuccess) {
                    [_btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
                    [_btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
                    _isFavorite = NO;
                    message = @"取消收藏成功";
                    icon = kImageRequestSuccess;
                } else {
                    message = @"取消收藏失败";
                    icon = kImageRequestError;
                }
                [[AMToastView toastView] showMessage:message icon:icon duration:AMToastDurationNormal];
            }
        }
            break;
        case 2:
        {
            //Cancel Button;
        }
            break;
        default:
            break;
    }
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    _btnLeftTab.selected = NO;
    _btnRithtTab.selected = NO;
    if (index == 0) {
        _userReputation.hidden = YES;
        _vNewCarConfig.hidden = YES;
        if (!_isForIM)
            _bvOptions.hidden = _mCarDetailInfo.state.integerValue == 2 ? YES : NO;
        
        [_svCarInfo setContentOffset:CGPointMake(0, 0) animated:YES];
        _svCarInfo.scrollEnabled = YES;
        _vCompareBtn.hidden = NO;
    } else if (index == 1) {
        // 点击新车配置统计
        [UMStatistics event:_isBusiness ? c_3_3_buinessnewcar : c_3_3_personnewcar];
        _userReputation.hidden = YES;
        _bvOptions.hidden = YES;
        if (!_vNewCarConfig) {
            _vNewCarConfig = [[UCNewCarConfigView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY + _obFilter.height, self.width, self.height - _obFilter.height - _tbTop.maxY) mCarDetailInfo:_mCarDetailInfo];
            [self addSubview:_vNewCarConfig];
            
            // 配置页统计
            [UMStatistics event:_isBusiness ? pv_3_3_buinesssnewcar : pv_3_3_personnewcar];
            [UMSAgent postEvent:_isBusiness ? dealercarconfig_pv : usercarconfig_pv page_name:NSStringFromClass(_vNewCarConfig.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarDetailInfo.carid.stringValue, @"objectid#1", _mCarDetailInfo.userid.stringValue, @"dealerid#5", _mCarDetailInfo.seriesid.stringValue, @"seriesid#2", _mCarDetailInfo.productid.stringValue, @"specid#3", nil]];
        } else {
            // 加载视图
            [_vNewCarConfig loadData];
            _vNewCarConfig.hidden = NO;
        }
        [_svCarInfo setContentOffset:CGPointMake(0, _tbTop.minY) animated:YES];
        _svCarInfo.scrollEnabled = NO;
        _vCompareBtn.hidden = YES;
    } else if (index == 2) {
        [UMStatistics event:c_3_7_buycar_buinesssourcedetail_experience];
        [UMStatistics event:pv_3_7_buycar_buinesssourcedetail_experiencelist];
        [UMSAgent postEvent:buycar_buinesssourcedetail_experiencelist_pv
                  page_name:NSStringFromClass(self.class)
                 eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             _mCarDetailInfo.userid.stringValue, @"dealerid#5",
                             _mCarDetailInfo.seriesid.stringValue, @"seriesid#2", nil]];

        if (!_userReputation) {
            _userReputation = [[UCUserReputation alloc] initWithFrame:CGRectMake(0, _tbTop.maxY + _obFilter.height, self.width, self.height -_tbTop.maxY - _obFilter.height)];
            [_userReputation loadWebWithString:[NSString stringWithFormat:@"http://apps.api.che168.com/m/koubei/iphone/spec/%@/",_mCarDetailInfo.productid]];
            [self addSubview:_userReputation];
        } else {
            [self bringSubviewToFront:_userReputation];
            _userReputation.hidden = NO;
        }
    }
}

#pragma mark - UCThumbnailsViewDelegate
- (void)UCThumbnailsView:(UCThumbnailsView *)vThumbnails onClickPhotoBtn:(UIButton *)btn
{
    NSArray *thumbimgurls = nil;
    NSArray *images = nil;
    // 车图片
    if (vThumbnails.tag == UCCarDetailViewThumbnailsCarPhoto) {
        images = [_mCarDetailInfo.imgurls componentsSeparatedByString:@","];
        thumbimgurls = [_mCarDetailInfo.thumbimgurls componentsSeparatedByString:@","];
    } else if (vThumbnails.tag == UCCarDetailViewThumbnailsTestReport) {
        thumbimgurls = [_mCarDetailInfo.dctionthumbimg componentsSeparatedByString:@","];
        images = [_mCarDetailInfo.dctionimg componentsSeparatedByString:@","];
    }
    
    if (thumbimgurls.count > 0 || images.count > 0) {
        UCImageBrowseView *vImageBrowse = [[UCImageBrowseView alloc] initWithFrame:self.bounds index:btn.tag thumbimgurls:thumbimgurls imageUrls:images];
        
        [[MainViewController sharedVCMain] openView:vImageBrowse animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        
        // 统计
        if (vThumbnails.tag == UCCarDetailViewThumbnailsCarPhoto) {
            [UMStatistics event:_isBusiness ? c_3_1_buinesssourcedetailphoto : c_3_1_personsourcedetailphoto];
            [UMStatistics event:_isBusiness ? pv_3_1_buinessviewlarge : pv_3_1_personviewlarge];
            if (_isBusiness) {
                UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                NSMutableDictionary *dic = nil;
                NSString *dealerid = _mCarDetailInfo.userid.stringValue;
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

#pragma mark - UCCarCompareViewDelegate
/** 关闭对比列表 */
- (void)closeCompareView:(NSMutableArray *)compareItems
{
    _compareItems = compareItems;
    
    // 是否存在对比列表数据中
    _isExistInCompareItems = NO;
    for (int i = 0; i < _compareItems.count; i++) {
        UCCarDetailInfoModel * mCarDetail = [_compareItems objectAtIndex:i];
        if ([mCarDetail.carid integerValue] == [_mCarDetailInfo.carid integerValue]) {
            _isExistInCompareItems = YES;
            break;
        }
    }
    
    // 显示是否加入对比
    UIImageView *ivCompareCountBag = (UIImageView *)[self viewWithTag:kCompareCountBagTag];
    UIImageView *ivAddCompare = (UIImageView *)[self viewWithTag:kAddCompareImageViewTag];
    if (_isExistInCompareItems) {
        ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon_h"];
        ivAddCompare.transform = CGAffineTransformMakeRotation([OMG degreesToRadians:45]);
    } else {
        ivAddCompare.image = [UIImage imageNamed:@"detail_addpk_icon"];
        ivAddCompare.transform = CGAffineTransformMakeRotation([OMG degreesToRadians:0]);
    }
    
    // 刷新详情页列表个数
    if (_compareItems.count == 0)
        ivCompareCountBag.hidden = YES;
    else
        ivCompareCountBag.hidden = NO;
    _labCompareCount.text = [NSString stringWithFormat:@"%d", _compareItems.count];
    
    // 关闭列表页
    [UIView animateWithDuration:0.2 animations:^{
        _vCompareBtn.minX = self.width - _vCompareBtn.width;
        _vCarCompare.frame = CGRectMake(self.width, _vCarCompare.minY, _vCarCompare.width, _vCarCompare.height);
    }];
}

#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        
        // 数字背景
        UIImageView *ivCompareCountBag = (UIImageView *)[self viewWithTag:kCompareCountBagTag];
        //去掉所有动画
        [ivCompareCountBag.layer removeAllAnimations];
        /* 取消移动动画
        if ([[anim valueForKey:@"animType"] isEqualToString:KMoveCarNameAnimation]) {
            // 更新对比数
            NSInteger willShowCompareCount = _compareItems.count;
            _labCompareCount.text = [NSString stringWithFormat:@"%d", willShowCompareCount];
            // 解决快速点击按钮时, 0个数还出现
            ivCompareCountBag.hidden = willShowCompareCount == 0 ? YES : NO;
            
            // 开始动画
            [self beginAnimation:ivCompareCountBag setValue:KChageCompareNumAnimation];
            
            // 去掉所有动画
            [_vCopyCarName.layer removeAllAnimations];
            [_vCopyCarName removeFromSuperview];
         
        } else {
            //去掉所有动画
            [ivCompareCountBag.layer removeAllAnimations];
        }
         */
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 立即下载
    if (buttonIndex == 1) {
        if (alertView.tag == kCarPriceAlertTag) {
            [[UIApplication sharedApplication] openURL:_urlCarPrice];
        } else {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/id415206413?mt=8"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}


#pragma  mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    CGPoint offsetofScrollView = scrollView1.contentOffset;
    UIPageControl *pcPhotot = (UIPageControl *)[self viewWithTag:32141876];
    [pcPhotot setCurrentPage:offsetofScrollView.x / scrollView1.frame.size.width];
    
}

#pragma mark - UCChangeScrollViewDelegate
- (void)UCChangeScrollViewDidScroll:(UIScrollView *)scrollView
{
    // 调整顶条
    if (scrollView.contentOffset.y > 0) {
        [self insertSubview:_obFilter belowSubview:_vCarCompare];

        _obFilter.minY = _tbTop.maxY;
    } else {
        [_svCarInfo addSubview:_obFilter];
        _obFilter.minY = 0;
        // 控制滚动条的位置
        _svCarInfo.scrollIndicatorInsets = UIEdgeInsetsMake(_obFilter.height - scrollView.contentOffset.y, 0, _mCarDetailInfo.state.integerValue == 2 ? 0 : KOptionsBarHeight, 0);
    }
    
    // 调整底条
    if (scrollView.contentOffset.y + scrollView.height < scrollView.contentSize.height) {
        _bvOptions.minY = scrollView.contentOffset.y + scrollView.height - _bvOptions.height;
    } else {
        _bvOptions.minY = scrollView.contentSize.height - _bvOptions.height;
        // 控制滚动条的位置
        _svCarInfo.scrollIndicatorInsets = UIEdgeInsetsMake(_obFilter.height, 0, _mCarDetailInfo.state.integerValue == 2 ? 0 : KOptionsBarHeight + (scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height), 0);
    }
}

/** 切换车辆 */
-(void)UCChangeScrollViewDidPull:(UIScrollView *)scrollView pullType:(UCChangeScrollViewPullType)pullType
{
    // 当前车源索引
    NSUInteger index = [_mCarLists indexOfObject:_mCarInfo];
    if (index == NSNotFound)
        return;
    
    // 屏蔽第一个和最后一个
    if ((index == 0 && pullType == UCChangeScrollViewPullTypeDown) || (index == _carListAllCount - 1 && pullType == UCChangeScrollViewPullTypeUp)) {
        return;
    }
    
    // 置灰分享和收藏按钮
    _btnShare.enabled = NO;
    _btnFavorite.enabled = NO;
    
    // 倒数第二个加载更多
    if (index == _mCarLists.count - 2) {
        [[UCMainView sharedMainView].vHome loadMoreCarListData];
    }
    // 隐藏切换栏和对比按钮
    _obFilter.hidden = YES;
    _vCompareBtn.hidden = YES;
    
    // 切换车辆
    [UIView animateWithDuration:KAnimationTurningTime animations:^{
        _svCarInfo.minY = (pullType == UCChangeScrollViewPullTypeUp ? -_svCarInfo.height - 60 : _svCarInfo.height + 60);
    } completion:^(BOOL finished) {
        // 清空 “视图 & 数据”
        [self removeAllSubviews];
        // 必须清空，为了不影响判断初始化后的代码
        _mCarDetailInfo = nil;
        _mReferencePrice = nil;
        _obFilter = nil;
        _cBlackBg = nil;
        _vNewCarConfig = nil;
        _userReputation = nil;
        [_apiHelper cancel];
        [_apiHelperPrice cancel];
        
        // 重新初始化视图
        NSUInteger index = [_mCarLists indexOfObject:_mCarInfo];
        if (index == NSNotFound)
            return;
                
        UCCarInfoModel *mCarInfo = (((index + 1) < _mCarLists.count || pullType == UCChangeScrollViewPullTypeDown)) ? [_mCarLists objectAtIndex:index + (pullType == UCChangeScrollViewPullTypeUp ? 1 : -1)] : nil;
        [self initViewWithCarInfoModel:mCarInfo];
        
        // 上下翻页与首页列表的联动
        if (_mCarInfo) {
            UITableView *tvCarList = [UCMainView sharedMainView].vHome.vCarList.tvCarList;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_mCarLists indexOfObject:_mCarInfo] inSection:0];
            
            if (![[AMCacheManage currentBuyCarListArray] containsObject:[_mCarInfo.carid stringValue]]) {
                // 加入已读痕迹
                [AMCacheManage addBuyCarListArray:_mCarInfo.carid.stringValue];
                if (indexPath.row < _mCarLists.count) {
                    [tvCarList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            // 刷新cell并滚动到此cell
            [tvCarList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result {
    
    switch(result)
    {
        caseMessageComposeResultCancelled:
            AMLog(@"Result: SMS sending canceled");
            break;
        caseMessageComposeResultSent:
            AMLog(@"Result: SMS sent");
            break;
        caseMessageComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"短信发送失败"  message:nil delegate:self cancelButtonTitle:@""otherButtonTitles: nil];
            [alert show];
        }
            break;
        default:
            AMLog(@"Result: SMS not sent");
            break;
    }
    [controller dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - APIHelper
/** 获取数据 */
- (void)getCarInfo:(NSNumber *)carid
{
    if (carid == nil) {
        [self setReloadBtnHidden:NO message:@"车源加载失败\n请稍后尝试" enable:NO];
        return;
    }
    [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
        [_apiHelper cancel];
        [[AMToastView toastView] hide];
    }];
    if (!self.apiHelper)
        self.apiHelper = [[APIHelper alloc] init];
    __weak UCCarDetailView *vCarDetail = self;
    [self.apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
                // 显示重新加载
                [vCarDetail setReloadBtnHidden:NO message:@"加载车源失败\n点击屏幕重试" enable:YES];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 增加pv
                    [vCarDetail setPVWithCarID:carid];
                    
                    // 总车数
                    NSDictionary *dicCarInfo = mBase.result;

                    if (!vCarDetail.mCarDetailInfo) {
                        vCarDetail.mCarDetailInfo = [[UCCarDetailInfoModel alloc] initWithJson:dicCarInfo];
                        
                        // 是否自定义车辆
                        vCarDetail.isCustomCar = [vCarDetail.mCarDetailInfo.productid integerValue] > 0 ? NO : YES;
                        
                        // 记录最后浏览车辆信息
                        if (vCarDetail.isRecordCarInfo) {
                            [AMCacheManage setCurrentCarDetailInfoModel:vCarDetail.mCarDetailInfo];
                        }
                    }
                    [vCarDetail initView:carid];
                    [vCarDetail reloadView];
                    if (vCarDetail.isForIM) {
                        // 分享按钮
                        vCarDetail.btnShare.enabled = NO;
                        vCarDetail.btnShare.hidden = YES;
                        vCarDetail.vReportView.hidden = YES;
                    }
                    else{
                        vCarDetail.btnShare.enabled = YES;
                        vCarDetail.btnShare.hidden = NO;
                    }

                    // 收藏按钮
                    vCarDetail.btnFavorite.enabled = YES;
                    
                    // 个人 || 商家 车辆详情页
                    [UMStatistics event:vCarDetail.isBusiness ? pv_3_1_buycarbuinesssourcedetail : pv_3_1_buycarpersonsourcedetail];
                }
                else {
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                    
                    // 显示重新加载
                    [vCarDetail setReloadBtnHidden:NO message:@"加载车源失败\n点击屏幕重试" enable:YES];
                }
                [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];

                // 显示重新加载
                [vCarDetail setReloadBtnHidden:NO message:@"加载车源失败\n点击屏幕重试" enable:YES];
            }
        } else {
            [[AMToastView toastView] hide];

            // 显示重新加载
            [vCarDetail setReloadBtnHidden:NO message:@"加载车源失败\n点击屏幕重试" enable:YES];
        }
    }];
    [_apiHelper getCarInfo:carid];
}

/** 添加收藏 */
- (void)addOrDeleteFavorite:(NSNumber *)carID toType:(NSInteger)type
{
    // 0删除, 1增加
    [[AMToastView toastView:YES] showLoading:@"正在操作中..." cancel:^{
        [self.apiFavorite cancel];
        [[AMToastView toastView] hide];
    }];
    if (!self.apiFavorite)
        self.apiFavorite = [[APIHelper alloc] init];
    
     __weak UCCarDetailView *vCarDetail = self;
    
    [self.apiFavorite setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    if (type == 1) {
                        [vCarDetail.btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn_h"] forState:UIControlStateNormal];
                        [vCarDetail.btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_h_d"] forState:UIControlStateDisabled];
                        vCarDetail.isFavorite = YES;
                    } else {
                        [vCarDetail.btnFavorite setImage:[UIImage imageNamed:@"detail_collect_btn"] forState:UIControlStateNormal];
                        [vCarDetail.btnFavorite setImage:[UIImage imageAutoNamed:@"detail_collect_btn_d"] forState:UIControlStateDisabled];
                        vCarDetail.isFavorite = NO;
                    }
                }
                if (mBase.message.length > 0)
                    [[AMToastView toastView] showMessage:mBase.message icon:mBase.returncode == 0 ? kImageRequestSuccess : kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    [self.apiFavorite addOrDeleteFavorite:carID toType:type];
}

/** 增加PV */
-(void)setPVWithCarID:(NSNumber *)carID
{
    if (!_apiSetPV)
        _apiSetPV = [[APIHelper alloc] init];
    [_apiSetPV setCarPVWithCarID:carID];
}

/** 获取PV */
-(void)getPVWithCarID:(NSNumber *)carID
{
    if (!_apiGetPV)
        _apiGetPV = [[APIHelper alloc] init];
    
    __weak UCCarDetailView *vCarDetail = self;
    
    [_apiGetPV setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    vCarDetail.carPVCount = [[mBase.result objectForKey:@"views"] integerValue];
                    [vCarDetail loadCarPVCount];
                }
            }
        }
    }];
    
    [_apiGetPV getCarPVWithCarID:carID];
}

/** 参考价 */
- (void)getReferencePrice:(UCPriceModel *)mPrice
{
    if (!self.apiHelperPrice)
        self.apiHelperPrice = [[APIHelper alloc] init];
    __weak UCCarDetailView *vCarDetail = self;
    
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

/** 个人登录后是否已收藏 */
- (void)isFavoriteCar:(NSNumber *)carID
{
    __weak UCCarDetailView *vCarDetail = self;
    
    [self.apiIsFavorite setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error)
            return;
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase.returncode == 0 && mBase.result) {
                [vCarDetail setIsFavoriteWithBool:[mBase.result integerValue]];
            }
        }
    }];
    
    [self.apiIsFavorite isFavoriteCar:carID];
}


#pragma mark - guide view
- (void)createGuideView{
    _vHint = [[EMHint alloc] init];
    _vHint.hintDelegate = self;
    [_vHint presentModalMessage:nil where:self];
}

#pragma mark - EMHintDelegate
-(BOOL)hintStateHasDefaultTapGestureRecognizer:(id)hintState{
    
    return YES;
}

-(void) hintStateDidClose:(id)hintState{
    [AMCacheManage setConfigStartIMGuideStatus:1];
}

-(BOOL) hintStateShouldAllowTouchPassedThrough:(id)hintState touch:(UITouch*)touch{
    return YES;
}

-(UIView*)hintStateViewForDialog:(id)hintState{
    UIImage *guideImage = [UIImage imageNamed:@"im_guide_arrow"];
    UIImageView *vGuide = [[UIImageView alloc] initWithImage:guideImage];
    
//    AMLog(@"_btnContactFrame:: %f %f %f %f", _btnContactFrame.origin.x, _btnContactFrame.origin.y, _btnContactFrame.size.width, _btnContactFrame.size.height);
//    AMLog(@"guideImage.size %f %f", guideImage.size.width, guideImage.size.height);
    
    EMHint *vhint = (EMHint*)hintState;
    CGFloat vGuideX = _btnContactFrame.origin.x - guideImage.width + 35;
    CGFloat vGuideY = vhint.modalView.size.height - guideImage.height - _btnContactFrame.size.height - 10;
    
    [vGuide setFrame:CGRectMake(vGuideX, vGuideY, guideImage.width, guideImage.height)];
    return vGuide;
}

-(NSArray*)hintStateRectsToHint:(id)hintState{
    
//    AMLog(@"_btnContactFrame:: %f %f %f %f", _btnContactFrame.origin.x, _btnContactFrame.origin.y, _btnContactFrame.size.width, _btnContactFrame.size.height);
    
    NSValue *value = [NSValue valueWithCGRect:CGRectMake(ceil(_btnContactFrame.origin.x+_btnContactFrame.size.width/2), [UIScreen mainScreen].bounds.size.height - 20, 55, 55)];
    return @[value];
}


- (void)dealloc
{
    AMLog(@"dealloc...");
    [[AMToastView toastView] hide];
    [_apiHelper cancel];
    [_apiHelperPrice cancel];
    [_apiIsFavorite cancel];
}

@end
