//
//  UCNewFilterView.m
//  UsedCar
//
//  Created by 张鑫 on 14-7-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCNewFilterView.h"
#import "JPickRangeSlider.h"
#import "UCTopBar.h"
#import "UIImage+Util.h"
#import "UCFilterModel.h"
#import "APIHelper.h"
#import "UCCarListView.h"
#import "AMCacheManage.h"
#import "UCCarInfoModel.h"
#import "UCFilterHistoryView.h"
#import "UCAreaMode.h"
#import "UCFilterView.h"
#import "UCChoseLocationView.h"
#import "EMHint.h"
#import "UCCarAttenModel.h"
#import <objc/runtime.h>

#define kDelayLoadDataTime          0.3     // 屏蔽重复请求间隔

#define kSectionHeight              20
#define kSectionTitleMarginLeft     20
#define kContentTextMarginLeft      20
#define kCellHeight                 50

#define kPriceTag                   2000
#define kMileageTag                 2001
#define kCotyTag                    2002

#define kSingleSelection_Level          3001
#define kSingleSelection_Gearbox        3002
#define kSingleSelection_Color          3003
#define kSingleSelection_Displacement   3004
#define kSingleSelection_County         3005
#define kSingleSelection_Property       3006
#define kSingleSelection_Drive          3007
#define kSingleSelection_Structure      3008
#define kSingleSelection_Source         3009
#define kSingleSelection_Warranty       3010
#define kSingleSelection_Other          3011

#define kBlackBgViewTag                 4001        // SUV黑背景
#define kSVUButtonStartTag              5000        // SUV选项开始tag

@interface UCNewFilterView ()<EMHintDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UILabel *labLocation;     // 地点
@property (nonatomic, strong) UILabel *labBrand;        // 车辆品牌
@property (nonatomic, strong) UIButton *btnBrand;       // 品牌按钮
@property (nonatomic, strong) UILabel *labPricevalue;   // 价格
@property (nonatomic, strong) UILabel *labMileagevalue; // 里程
@property (nonatomic, strong) UILabel *labCotyvalue;    // 车龄
@property (nonatomic, strong) UIView *vLevel;           // 级别
@property (nonatomic, strong) UIView *vMoreFilter;      // 更多筛选
@property (nonatomic, strong) UIView *vBottom;          // 底部显示视图
@property (nonatomic, strong) UIButton *btnAtten;       // 关注按钮
@property (nonatomic, strong) UIButton *btnViewMore;    // 查看更多
@property (nonatomic, strong) UIButton *btnViewCount;   // 查看更多车源数
@property (nonatomic, strong) UIImageView *ivCarCountArrow;         // 车源数旁的箭头
@property (nonatomic, strong) UIScrollView *svMain;
@property (nonatomic, strong) UIView *vSUVView;         // SUV视图
@property (nonatomic, strong) UIActivityIndicatorView *vActivity;   // 菊花

@property (nonatomic) BOOL isShowSUVView;               // 是否显示SUV视图
@property (nonatomic) BOOL isAddAttention;              // 是否添加关注
@property (nonatomic) NSInteger attenID;                // 关注ID

@property (nonatomic, strong) NSString *orderby;        // 排序
@property (nonatomic, weak) UCFilterModel *mOriginalFilter;
@property (nonatomic, strong) UCFilterModel *mTempFilter;
@property (nonatomic, strong) UCAreaMode *mTempArea;    // 地点model
@property (nonatomic, weak) UCAreaMode *mOriginalArea;  // 地点原始model
@property (nonatomic, strong) NSArray *carColorValues;  // 颜色
@property (nonatomic, strong) NSArray *filterLevels;    // 筛选级别
@property (nonatomic, strong) NSArray *filterDisplacement;          // 筛选排量
@property (nonatomic, strong) NSArray *filterCounty;    // 国家
@property (nonatomic, strong) NSArray *filterProperty;  // 属性
@property (nonatomic, strong) NSArray *filterDrive;     // 驱动
@property (nonatomic, strong) NSArray *filterStructure; // 结构
@property (nonatomic, strong) NSArray *filterSource;    // 来源
@property (nonatomic, strong) APIHelper *apiSearchCar;  // 搜索接口
@property (nonatomic, strong) APIHelper *apiAttention;  // 关注接口
@property (nonatomic, strong) NSMutableArray *mCarLists;            // 列表数据源
@property (nonatomic) NSInteger rowCount;               // 车辆总数
@property (nonatomic) UCNewFilterViewStyle viewStyle;   // 页面种类 0为正常，1为从搜索结果进入的，品牌不能选择的
@property (nonatomic, strong) NSString *keyWords;       // 搜索结果关键字
@property (nonatomic, strong) NSMutableArray *colorImages;          // 颜色图片
@property (nonatomic, strong) NSNumber *attentionID;    // 关注id
@property (strong, nonatomic) UIButton *btnReset;
@property (nonatomic, strong) NSMutableArray *mAttentions;  // 已关注model集合

@property (strong, nonatomic) EMHint *vHint;

@end

@implementation UCNewFilterView

/** 首页进筛选 */
- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter rowCount:(NSInteger)rowCount orderby:(NSString *)orderby mArea:(UCAreaMode *)mArea;
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = UCNewFilterViewStyleFromHomeView;

        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:buycar_creening_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"dealerid#5", nil]];
        } else {
            [UMSAgent postEvent:buycar_creening_pv page_name:NSStringFromClass(self.class)];
        }
        _mTempArea = [mArea copy];
        _mAttentions = [[NSMutableArray alloc] init];
        [self initWithFilter:mFilter rowCount:rowCount orderby:orderby];
        //生成引导图
        NSInteger guideStatus = [AMCacheManage currentConfigFilterGuideStatus];
        NSInteger guideLastViewVersion = [AMCacheManage currentConfigFilterGuideLastViewVersion];
        NSInteger currentVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue];
        if(guideStatus == 0){
            [self createGuideView];
        }
        else if(guideLastViewVersion < currentVersion){
            [self createGuideView];
        }
        else{
            
        }
    }
    return self;
}

/** 带关键字的初始化，从搜索结果页进 */
- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter rowCount:(NSInteger)rowCount orderby:(NSString *)orderby keyWords:(NSString *)keyWords
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = UCNewFilterViewStyleFromSearchView;
        _keyWords = [NSString stringWithString:keyWords];
        [self initWithFilter:mFilter rowCount:rowCount orderby:orderby];
    }
    return self;
}

/** 添加关注或修改 */
- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter mArea:(UCAreaMode *)mArea attentionID:(NSNumber *)ID
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewStyle = ([mFilter isNull] && [mArea isNull]) ? UCNewFilterViewStyleFromAddAttentionView : UCNewFilterViewStyleFromEditAttentionView;
        if (_viewStyle == UCNewFilterViewStyleFromEditAttentionView)
            _attentionID = [ID copy];
        else if (_viewStyle == UCNewFilterViewStyleFromAddAttentionView) {

            if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                [UMSAgent postEvent:business_attentioncaradd_pv page_name:NSStringFromClass(self.class)
                         eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     mUserInfo.userid, @"dealerid#5",
                                     mUserInfo.userid, @"userid#4", nil]];
            } else {
                [UMSAgent postEvent:person_attentioncaradd_pv page_name:NSStringFromClass(self.class)];
            }
        }
        _mOriginalArea = mArea;
        _mTempArea = [mArea copy];
        [self initWithFilter:mFilter rowCount:NSNotFound orderby:nil];
    }
    return self;
}

- (void)initWithFilter:(UCFilterModel *)mFilter rowCount:(NSInteger)rowCount orderby:(NSString *)orderby
{
    // 排序
    if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView) {
        _orderby = orderby;
    }
    _mOriginalFilter = mFilter;
    _mTempFilter = [mFilter copy];
    _mCarLists = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    // 颜色色值
    _carColorValues = [NSArray arrayWithArray:values[@"FilterColors"]];
    // 筛选级别
    _filterLevels = [NSArray arrayWithArray:values[@"FilterLevels"]];
    // 筛选排量
    _filterDisplacement = [NSArray arrayWithArray:values[@"Displacement"]];
    // 国家
    _filterCounty = [NSArray arrayWithArray:values[@"County"]];
    // 属性
    _filterProperty = [NSArray arrayWithArray:values[@"Property"]];
    // 驱动
    _filterDrive = [NSArray arrayWithArray:values[@"FilterDrive"]];
    // 结构
    _filterStructure = [NSArray arrayWithArray:values[@"Structure"]];
    // 来源
    _filterSource = [NSArray arrayWithArray:values[@"Source"]];
    
    // 颜色图片
    _colorImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < _carColorValues.count - 1; i++) {
        NSArray *item = [[[_carColorValues objectAtIndex:i] objectForKey:@"Value"] componentsSeparatedByString:@","];
        [_colorImages addObject:[UIImage imageWithColor:[UIColor colorWithRed:[[item objectAtIndex:0] floatValue]/255.0f green:[[item objectAtIndex:1] floatValue]/255.0f blue:[[item objectAtIndex:2] floatValue]/255.0f alpha:1] size:CGSizeMake(13, 13)]];
    }
    [_colorImages addObject:[UIImage imageNamed:@"color_other"]];
    
    self.backgroundColor = kColorNewBackground;
    
    [self setObserverOpen:YES];
    
    [self initView];
    
    
    // 设置车源数
    if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView) {
        [self setLoadingAnimation:NO rowCount:rowCount];
    }
    
}

#pragma mark - initView
- (void)initView
{
    [UMStatistics event:pv_3_8_buycar_creening];
    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    _svMain = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    
    /** 基本 */
    // 地点
    CGFloat minY = 0;
    if (_viewStyle == UCNewFilterViewStyleFromAddAttentionView || _viewStyle == UCNewFilterViewStyleFromEditAttentionView) {
        UIView *vLocation = [self creatLocationView:CGRectMake(0, 0, _svMain.width, 70)];
        [_svMain addSubview:vLocation];
        minY = vLocation.maxY;
    }
    
    // 品牌
    UIView *vBrand = [self creatBrandView:CGRectMake(0, minY, _svMain.width, 70)];
    
    // 价格区间
    UIView *vPrice = [self creatPriceView:CGRectMake(0, vBrand.maxY, _svMain.width, 100)];
    
    // 里程区间
    UIView *vMileage = [self creatMileageView:CGRectMake(0, vPrice.maxY, _svMain.width, 100)];
    
    // 车龄区间
    UIView *vCoty = [self creatCotyView:CGRectMake(0, vMileage.maxY, _svMain.width, 100)];
    
    // 级别
    _vLevel = [self creatLevelView:CGRectMake(0, vCoty.maxY, _svMain.width, 0)];
    
    // 关注
    _vBottom = [self creatBottomView:CGRectMake(0, _vLevel.maxY, _svMain.width, 186 - 50 - kSectionHeight)];
    
    // 查看数量
    UIView *vViewMore = [self creatViewMoreView:CGRectMake(0, self.height - 65, self.width, 65)];
    
    [_svMain addSubview:vBrand];
    [_svMain addSubview:vPrice];
    [_svMain addSubview:vMileage];
    [_svMain addSubview:vCoty];
    [_svMain addSubview:_vLevel];
    [_svMain addSubview:_vBottom];
    
    [self addSubview: _tbTop];
    [self addSubview:_svMain];
    [self addSubview:vViewMore];
    
    _svMain.contentSize = CGSizeMake(self.width, _vBottom.maxY);
    
}

/** 创建更多视图 */
- (UIView *)creatMoreFilterView
{
    /** 更多 */
    _vMoreFilter = [[UIView alloc] initWithFrame:CGRectMake(0, _vLevel.maxY, _svMain.width, 0)];
    
    // 变速箱
    UIView *vGearbox = [self creatGearboxView:CGRectMake(0, 0, _svMain.width, 0)];
    
    // 颜色
    UIView *vColor = [self creatColorView:CGRectMake(0, vGearbox.maxY, _svMain.width, 0)];
    
    // 排量
    UIView *vDisplacement = [self creatDisplacementView:CGRectMake(0, vColor.maxY, _svMain.width, 0)];
    
    // 国别
    UIView *vCounty = [self creatCountyView:CGRectMake(0, vDisplacement.maxY, _svMain.width, 0)];
    
    // 属性
    UIView *vProperty = [self creatPropertyView:CGRectMake(0, vCounty.maxY, _svMain.width, 0)];
    
    // 驱动
    UIView *vDrive = [self creatDriveView:CGRectMake(0, vProperty.maxY, _svMain.width, 0)];
    
    // 结构
    UIView *vStructure = [self creatStructureView:CGRectMake(0, vDrive.maxY, _svMain.width, 0)];
    
    // 来源
    UIView *vSource = [self creatSourceView:CGRectMake(0, vStructure.maxY, _svMain.width, 0)];
    
    // 质保类型
    UIView *vWarranty = [self creatWarrantyView:CGRectMake(0, vSource.maxY, _svMain.width, 0)];
    
    // 其他
    UIView *vOther = [self creatOtherView:CGRectMake(0, vWarranty.maxY, _svMain.width, 88)];
    _vMoreFilter.height = vOther.maxY;
    
    [_vMoreFilter addSubview:vGearbox];
    [_vMoreFilter addSubview:vColor];
    [_vMoreFilter addSubview:vDisplacement];
    [_vMoreFilter addSubview:vCounty];
    [_vMoreFilter addSubview:vProperty];
    [_vMoreFilter addSubview:vDrive];
    [_vMoreFilter addSubview:vStructure];
    [_vMoreFilter addSubview:vSource];
    [_vMoreFilter addSubview:vWarranty];
    [_vMoreFilter addSubview:vOther];
    
    [_svMain insertSubview:_vMoreFilter belowSubview:_vBottom];
    
    return _vMoreFilter;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    [_tbTop.btnLeft setTitle:@"关闭" forState:UIControlStateNormal];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *strTitle = @"筛选";
    if (_viewStyle == UCNewFilterViewStyleFromAddAttentionView)
        strTitle = @"添加订阅车源";
    else if (_viewStyle == UCNewFilterViewStyleFromEditAttentionView)
        strTitle = @"编辑订阅车源";
    
    [_tbTop.btnTitle setTitle:strTitle forState:UIControlStateNormal];
    
    if (_viewStyle == UCNewFilterViewStyleFromHomeView) {
        [_tbTop.btnRight setTitle:@"筛选记录" forState:UIControlStateNormal];
        [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _tbTop;
}

/** 创建地点视图 */
-(UIView *)creatLocationView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"所在地";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionTitleMarginLeft, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 车辆品牌
    _labLocation = [[UILabel alloc] initWithFrame:CGRectMake(kContentTextMarginLeft, 0, vContent.width - 55, vContent.height)];
    _labLocation.textColor = kColorNewGray1;
    _labLocation.font = kFontLarge;
    _labLocation.text = @"全国";
    if (_mOriginalArea && (_mOriginalArea.areaid.length > 0 || _mOriginalArea.pid.length > 0 || _mOriginalArea.cid.length > 0)) {
        _labLocation.text = [NSString stringWithFormat:@"%@%@%@", _mOriginalArea.areaName.length > 0 ? [NSString stringWithFormat:@"%@ ", _mOriginalArea.areaName] : @"", _mOriginalArea.pName.length > 0 ? [NSString stringWithFormat:@"%@ ", _mOriginalArea.pName] : @"", _mOriginalArea.cName.length > 0 ? [NSString stringWithFormat:@"%@ ", _mOriginalArea.cName] : @""];
    }
    
    // 箭头
    UIImage *iArrow = [UIImage imageNamed:@"sellcar_information_butten"];
    UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
    ivArrow.origin = CGPointMake(vContent.width - iArrow.width - kSectionTitleMarginLeft, (vContent.height - iArrow.size.height) / 2);
    [vContent addSubview:ivArrow];
    
    // 按钮
    UIButton *btnLocation = [[UIButton alloc] initWithFrame:vContent.bounds];
    btnLocation.backgroundColor = kColorClear;
    [btnLocation addTarget:self action:@selector(onClickLocationBtn:) forControlEvents:UIControlEventTouchUpInside];

    [vContent addSubview:_labLocation];
    [vContent addSubview:btnLocation];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 品牌 */
- (UIView *)creatBrandView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;

    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = _viewStyle != UCNewFilterViewStyleFromSearchView ? @"品牌" : @"关键字";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionTitleMarginLeft, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 车辆品牌
    _labBrand = [[UILabel alloc] initWithFrame:CGRectMake(kContentTextMarginLeft, 0, vContent.width - 55, vContent.height)];
    _labBrand.textColor = kColorNewGray1;
    _labBrand.font = kFontLarge;
    if (_viewStyle == UCNewFilterViewStyleFromSearchView) {
        _labBrand.text = _keyWords;
    }
    else {
        NSString *strBrandText = @"全部品牌";
        
        if (![_mTempFilter isNull] && _mTempFilter.brandid.length > 0) {
            if (_mTempFilter.seriesid.length == 0) {
                strBrandText = _mTempFilter.brandidText;
            } else {
                // 更新品牌UI
                NSString *strSeries = _mTempFilter.seriesidText.length > 0 ? _mTempFilter.seriesidText : @"";
                NSString *strSpec = _mTempFilter.specidText.length > 0 ? _mTempFilter.specidText : @"";
                strBrandText = [NSString stringWithFormat:@"%@ %@", strSeries, strSpec];
            }
        }
        _labBrand.text = strBrandText;
    }
    
    // 箭头
    if (_viewStyle != UCNewFilterViewStyleFromSearchView) {
        UIImage *iArrow = [UIImage imageNamed:@"sellcar_information_butten"];
        UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
        ivArrow.origin = CGPointMake(vContent.width - iArrow.width - kSectionTitleMarginLeft, (vContent.height - iArrow.size.height) / 2);
        [vContent addSubview:ivArrow];
        
        // 按钮
        _btnBrand = [[UIButton alloc] initWithFrame:vContent.bounds];
        _btnBrand.backgroundColor = kColorClear;
        [_btnBrand addTarget:self action:@selector(onClickBrandBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [vContent addSubview:_labBrand];
    if (_viewStyle != UCNewFilterViewStyleFromSearchView)
        [vContent addSubview:_btnBrand];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 价格区间 */
- (UIView *)creatPriceView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"价格区间：";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    // 价格值
    _labPricevalue = [[UILabel alloc] initWithFrame:CGRectMake(labSectionTitle.maxX + 3, 0, 150, kSectionHeight)];
    _labPricevalue.text = @"不限";
    _labPricevalue.backgroundColor = kColorClear;
    _labPricevalue.textColor = kColorNewOrange;
    _labPricevalue.font = kFontSmall;
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionTitleMarginLeft, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 选择控件
    NSArray *texts = @[@"3万",@"5万",@"8万",@"10万",@"15万",@"20万",@"30万",@"50万",@"70万",@"100万"];
    NSArray *values = @[@(3),@(5),@(8),@(10),@(15),@(20),@(30),@(50),@(70),@(100)];
    
    JPickRangeSlider *slider = [[JPickRangeSlider alloc] initWithFrame:CGRectMake(0, 7, vContent.width, vContent.height - 7)
                                                         indexValues:values
                                                         andIndexTexts:texts];
    slider.tag = kPriceTag;
    slider.minValue = 3;
    slider.maxValue = 100;
    slider.autoMoveValue = 5;
    
    // 解决初次使用右端自动移动bug
    [slider resetToPriceAll];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置值
    if (_mTempFilter.priceregion.length > 0) {
        NSArray *prices = [_mTempFilter.priceregion componentsSeparatedByString:@"-"];
        if (prices.count > 1) {
            NSInteger min = [[prices objectAtIndex:0] integerValue];
            NSInteger max = [[prices objectAtIndex:1] integerValue];
            [slider moveThumbToMinPrice:min andMaxPrice:max];
            _labPricevalue.text = _mTempFilter.priceregion.length > 0 ? _mTempFilter.priceregionText : @"不限";
            // 刷新显示
            [self refreshSliderViewUI:slider];
        }
    }
    
    [vContent addSubview:slider];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    [vBody addSubview:_labPricevalue];
    
    return vBody;
}

/** 里程区间 */
- (UIView *)creatMileageView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"里程区间：";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    // 值
    _labMileagevalue = [[UILabel alloc] initWithFrame:CGRectMake(labSectionTitle.maxX + 3, 0, 150, kSectionHeight)];
    _labMileagevalue.text = @"不限";
    _labMileagevalue.backgroundColor = kColorClear;
    _labMileagevalue.textColor = kColorNewOrange;
    _labMileagevalue.font = kFontSmall;
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionTitleMarginLeft, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 选择控件
    NSArray *texts = @[@"1万",@"2万",@"3万",@"4万",@"5万",@"6万",@"7万",@"8万",@"9万",@"10万"];
    NSArray *values = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10)];
    
    JPickRangeSlider *slider = [[JPickRangeSlider alloc] initWithFrame:CGRectMake(0, 7, vContent.width, vContent.height - 7)
                                                           indexValues:values
                                                         andIndexTexts:texts];
    slider.tag = kMileageTag;
    slider.minValue = 1;
    slider.maxValue = 10;
    slider.autoMoveValue = 1;
    // 解决初次使用右端自动移动bug
    [slider resetToPriceAll];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置值
    if (_mTempFilter.mileageregion.length > 0) {
        NSArray *items = [_mTempFilter.mileageregion componentsSeparatedByString:@"-"];
        if (items.count > 1) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            [slider moveThumbToMinPrice:min andMaxPrice:max];
            _labMileagevalue.text = _mTempFilter.mileageregion.length > 0 ? _mTempFilter.mileageregionText : @"不限";
            // 刷新显示
            [self refreshSliderViewUI:slider];
        }
    }
    
    [vContent addSubview:slider];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    [vBody addSubview:_labMileagevalue];
    
    return vBody;
}

/** 车龄区间 */
- (UIView *)creatCotyView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"车龄区间：";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    // 值
    _labCotyvalue = [[UILabel alloc] initWithFrame:CGRectMake(labSectionTitle.maxX + 3, 0, 150, kSectionHeight)];
    _labCotyvalue.text = @"不限";
    _labCotyvalue.backgroundColor = kColorClear;
    _labCotyvalue.textColor = kColorNewOrange;
    _labCotyvalue.font = kFontSmall;
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionTitleMarginLeft, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 选择控件
    NSArray *texts = @[@"1年",@"2年",@"3年",@"4年",@"5年",@"6年",@"7年",@"8年",@"9年",@"10年"];
    NSArray *values = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10)];
    
    JPickRangeSlider *slider = [[JPickRangeSlider alloc] initWithFrame:CGRectMake(0, 7, vContent.width, vContent.height - 7)
                                                           indexValues:values
                                                         andIndexTexts:texts];
    slider.tag = kCotyTag;
    slider.minValue = 1;
    slider.maxValue = 10;
    slider.autoMoveValue = 1;
    // 解决初次使用右端自动移动bug
    [slider resetToPriceAll];
    
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderValueChangedEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置值
    if (_mTempFilter.registeageregion.length > 0) {
        NSArray *items = [_mTempFilter.registeageregion componentsSeparatedByString:@"-"];
        if (items.count > 1) {
            NSInteger min = [[items objectAtIndex:0] integerValue];
            NSInteger max = [[items objectAtIndex:1] integerValue];
            [slider moveThumbToMinPrice:min andMaxPrice:max];
            _labCotyvalue.text = _mTempFilter.registeageregion.length > 0 ? _mTempFilter.registeageregionText : @"不限";
            // 刷新显示
            [self refreshSliderViewUI:slider];
        }
    }
    
    [vContent addSubview:slider];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    [vBody addSubview:_labCotyvalue];
    return vBody;
}

/** 级别 */
- (UIView *)creatLevelView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"级别";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterLevels.count; i++) {
        [titles addObject:[[_filterLevels objectAtIndex:i] objectForKey:@"Name"]];
    }
    NSArray *images = [NSArray arrayWithObjects:@"mini_icon", @"small_icon", @"compact_icon", @"medium_icon", @"middle_icon", @"luxury_icon",@"suv_icon", @"mpv_icon", @"sportscar_icon", @"minibus_icon", @"pickuptruck_icon", nil];
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:0 marginY:0 buttonSize:CGSizeMake(self.width / 3, 73) singleLineCount:3 title:titles images:images UCSingleSelectionViewStyle:UCSingleSelectionViewStyleY offset:0];
    vSingleSelect.tag = kSingleSelection_Level;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(0, 5);
    
    /** 设置值 */
    BOOL isHaveSUVItem = NO;
    BOOL isHaveLevelItem = NO;
    NSInteger suvIndex = NSNotFound;
    NSInteger levelIndex = NSNotFound;
    if (_mTempFilter.levelid.integerValue > 0) {
        
        // 是否存在SUV内级别
        NSArray *SUVItems = [[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"];
        for (int i = 0; i < SUVItems.count; i++) {
            if ([[[SUVItems objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.levelid.integerValue) {
                suvIndex = i;
                isHaveSUVItem = YES;
                break;
            }
        }
        
        // 是否存在普通级别
        if (!isHaveSUVItem) {
            for (int i = 0; i < _filterLevels.count; i++) {
                if ([[[_filterLevels objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.levelid.integerValue) {
                    levelIndex = i;
                    isHaveLevelItem = YES;
                    break;
                }
            }
        }
    }
    
    // 设置高亮和选中颜色
    for (int i = 0; i < vSingleSelect.buttonItems.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h", [images objectAtIndex:i]]] forState:UIControlStateHighlighted];
        [btnItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h", [images objectAtIndex:i]]] forState:UIControlStateSelected];
        [btnItem setTitleColor:kColorBlue forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorBlue forState:UIControlStateSelected];
        
        /** 设置选中 */
        if (isHaveSUVItem) {
            if (i == 6) {
                btnItem.selected = YES;
                [btnItem setTitle:_mTempFilter.levelidText forState:UIControlStateNormal];
                btnItem.titleEdgeInsets = UIEdgeInsetsMake(35, -btnItem.imageView.width, 0, 0);
                btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25, -[btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width);
            }
        } else if (isHaveLevelItem && levelIndex == i) {
            btnItem.selected = YES;
            [btnItem setTitle:_mTempFilter.levelidText forState:UIControlStateNormal];
            btnItem.titleEdgeInsets = UIEdgeInsetsMake(35, -btnItem.imageView.width, 0, 0);
            btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25, -[btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width);
        }
        
    }
    
    vContent.height = vSingleSelect.maxY + 5;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 其他筛选 */
/** 变速箱 */
- (UIView *)creatGearboxView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"变速箱";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSArray *titles = [NSArray arrayWithObjects:@"手动挡", @"自动挡", nil];
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Gearbox;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.gearboxid && (_mTempFilter.gearboxid.integerValue == i + 1)) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 颜色 */
- (UIView *)creatColorView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"颜色";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _carColorValues.count - 1; i++) {
        NSArray *item = [[[_carColorValues objectAtIndex:i] objectForKey:@"Value"] componentsSeparatedByString:@","];
        [images addObject:[UIImage imageWithColor:[UIColor colorWithRed:[[item objectAtIndex:0] floatValue]/255.0f green:[[item objectAtIndex:1] floatValue]/255.0f blue:[[item objectAtIndex:2] floatValue]/255.0f alpha:1] size:CGSizeMake(13, 13)]];
    }
    
    [images addObject:[UIImage imageNamed:@"color_other"]];
        
    NSArray *titles = [NSArray arrayWithObjects:@"黑色", @"白色", @"银灰色", @"深灰色", @"红色", @"蓝色", @"绿色", @"黄色", @"香槟色", @"紫色", @"其他", nil];
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:7 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:images UCSingleSelectionViewStyle:UCSingleSelectionViewStyleX offset:0];
    vSingleSelect.tag = kSingleSelection_Color;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        if (i == 1) {
            btnItem.imageView.layer.borderColor = kColorNewGray2.CGColor;
            btnItem.imageView.layer.borderWidth = kLinePixel;
        }
        
        // 设置选中
        if (_mTempFilter.color && _mTempFilter.color.integerValue == i + 1) {
            [btnItem setImage:nil forState:UIControlStateNormal];
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;

}

/** 排量 */
- (UIView *)creatDisplacementView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"排量";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterDisplacement.count; i++) {
        [titles addObject:[[_filterDisplacement objectAtIndex:i] objectForKey:@"Name"]];
    }
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:7 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Displacement;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        btnItem.titleLabel.font = kFontMiddle;
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        btnItem.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        // 设置选中
        if (_mTempFilter.displacement.length > 0 && [[[_filterDisplacement objectAtIndex:i] objectForKey:@"Value"] isEqualToString:_mTempFilter.displacement]) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 国别 */
- (UIView *)creatCountyView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"国别";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterCounty.count; i++) {
        [titles addObject:[[_filterCounty objectAtIndex:i] objectForKey:@"Name"]];
    }
    
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:7 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_County;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.countryid.length > 0 && [[[_filterCounty objectAtIndex:i] objectForKey:@"Value"] isEqualToString:_mTempFilter.countryid]) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 属性 */
- (UIView *)creatPropertyView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"属性";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterProperty.count; i++) {
        [titles addObject:[[_filterProperty objectAtIndex:i] objectForKey:@"Name"]];
    }
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Property;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.countrytype && [[[_filterProperty objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.countrytype.integerValue) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 驱动 */
- (UIView *)creatDriveView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"驱动";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterDrive.count; i++) {
        [titles addObject:[[_filterDrive objectAtIndex:i] objectForKey:@"Name"]];
    }
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Drive;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.powertrain && [[[_filterDrive objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.powertrain.integerValue) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 结构 */
- (UIView *)creatStructureView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"结构";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterStructure.count; i++) {
        [titles addObject:[[_filterStructure objectAtIndex:i] objectForKey:@"Name"]];
    }
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Structure;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.structure && [[[_filterStructure objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.structure.integerValue) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 来源 */
- (UIView *)creatSourceView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"来源";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filterSource.count; i++) {
        [titles addObject:[[_filterSource objectAtIndex:i] objectForKey:@"Name"]];
    }
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Source;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        if (_mTempFilter.sourceid && [[[_filterSource objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.sourceid.integerValue) {
            btnItem.selected = YES;
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 质保类型 */
- (UIView *)creatWarrantyView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"质保类型";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, 0)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSArray *titles = [NSArray arrayWithObjects:@"原厂质保", @"延长质保", nil];
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:(self.width - 19.5*2 - 65*4)/3 marginY:0 buttonSize:CGSizeMake(65, 38) singleLineCount:4 title:titles images:nil UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Warranty;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 14);
    
    // 圆角
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateHighlighted];
        [btnItem setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner"] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateHighlighted];
        [btnItem setBackgroundImage:[UIImage imageNamed:@"butten_corner_h"] forState:UIControlStateSelected];
        
        // 设置选中
        // 原厂质保
        if (_mTempFilter.haswarranty) {
            if (_mTempFilter.haswarranty.integerValue == 1 && i == 0) {
                btnItem.selected = YES;
            }
        }
        // 延长质保
        else  if (_mTempFilter.extrepair){
            if (_mTempFilter.extrepair.integerValue == 1 && i == 1) {
                btnItem.selected = YES;
            }
        }
    }
    
    vContent.height = vSingleSelect.maxY + 14;
    vBody.height = vContent.height + kSectionHeight;
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 其他 */
- (UIView *)creatOtherView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = kColorClear;
    
    /** 标题 */
    UILabel *labSectionTitle = [[UILabel alloc] init];
    labSectionTitle.backgroundColor = kColorClear;
    labSectionTitle.textColor = kColorNewGray2;
    labSectionTitle.font = kFontSmall;
    labSectionTitle.text = @"其他";
    [labSectionTitle sizeToFit];
    labSectionTitle.origin = CGPointMake(kSectionTitleMarginLeft, (kSectionHeight - labSectionTitle.height) / 2);
    
    /** 内容 */
    UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight, vBody.width, frame.size.height - kSectionHeight)];
    vContent.backgroundColor = kColorWhite;
    
    // 按钮
    NSArray *titles = [NSArray arrayWithObjects:@"准新车", @"只看在售", @"只看有图", nil];
    NSArray *images = [NSArray arrayWithObjects:@"screennotes_choose_butten",@"screennotes_choose_butten",@"screennotes_choose_butten",nil];
    UCSingleSelectionVIew *vSingleSelect = [[UCSingleSelectionVIew alloc] initWithMarginX:0 marginY:0 buttonSize:CGSizeMake((self.width - 19.5*2) / 3, vContent.height) singleLineCount:3 title:titles images:images UCSingleSelectionViewStyle:UCSingleSelectionViewStyleNone offset:0];
    vSingleSelect.tag = kSingleSelection_Other;
    vSingleSelect.delegate = self;
    vSingleSelect.origin = CGPointMake(19.5, 0);
    
    // 选中样式
    for (int i = 0; i < titles.count; i++) {
        UIButton *btnItem = [vSingleSelect.buttonItems objectAtIndex:i];
        [btnItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h", [images objectAtIndex:i]]] forState:UIControlStateSelected];
        [btnItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h", [images objectAtIndex:i]]] forState:UIControlStateHighlighted];
        // 特殊控制，按钮左对齐、居中、右对齐
        if (i == 0) {
            btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnItem.titleEdgeInsets =  UIEdgeInsetsMake(0, 5, 0, 0);
        } else if (i == 1){
            btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            btnItem.imageEdgeInsets =  UIEdgeInsetsMake(0, 0, 0, 8);
        } else if (i == 2) {
            btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            btnItem.imageEdgeInsets =  UIEdgeInsetsMake(0, 0, 0, 5);
        }
        
        // 设置选中
        if (_mTempFilter.isnewcar.length > 0 && i == 0) {
            btnItem.selected = YES;
        }
        if (_mTempFilter.dealertype.integerValue == 9 && i == 1) {
            btnItem.selected = YES;
        }
        if (_mTempFilter.ispic.length > 0 && i == 2) {
            btnItem.selected = YES;
        }
    }
    
    [vContent addSubview:vSingleSelect];
    [vBody addSubview:vContent];
    [vBody addSubview:labSectionTitle];
    
    return vBody;
}

/** 底部视图 */
- (UIView *)creatBottomView:(CGRect)frame
{
    _vBottom = [[UIView alloc] initWithFrame:frame];
    _vBottom.backgroundColor = self.backgroundColor;
    
    // 顶部分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vBottom.width, kLinePixel) color:kColorNewLine];
    
    // 更多按钮
    UIImage *image = [UIImage imageNamed:@"develop_icon"];
    _btnViewMore = [[UIButton alloc] initWithFrame:CGRectMake(0, vLine.maxY, _vBottom.width, 50)];
    _btnViewMore.selected = NO;
    _btnViewMore.backgroundColor = kColorWhite;
    [_btnViewMore setTitle:@"更多筛选条件" forState:UIControlStateNormal];
    [_btnViewMore addTarget:self action:@selector(onClickViewMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnViewMore setImage:image forState:UIControlStateNormal];
    [_btnViewMore setTitleColor:kColorBlue forState:UIControlStateNormal];
    _btnViewMore.titleLabel.font = kFontLarge;
    _btnViewMore.titleEdgeInsets = UIEdgeInsetsMake(0, -_btnViewMore.imageView.width + 20, 0, _btnViewMore.titleLabel.width / 2 - 20);
    _btnViewMore.imageEdgeInsets = UIEdgeInsetsMake(0, _btnViewMore.titleLabel.width / 2 + 20 + _btnViewMore.imageView.width, 0, -_btnViewMore.titleLabel.width - 20);
    
    // 下分割线
    UIView *vBottomLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _btnViewMore.maxY, _btnViewMore.width, kLinePixel) color:kColorNewLine];
    
    [_vBottom addSubview:vLine];
    [_vBottom addSubview:vBottomLine];
    [_vBottom addSubview:_btnViewMore];
    
    return _vBottom;
}

/** 查看数量视图 */
- (UIView *)creatViewMoreView:(CGRect)frame
{
    UIView *vBody = [[UIView alloc] initWithFrame:frame];
    vBody.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    
    // 点击查看
    _btnViewCount = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, vBody.width - 60 - 20 - ((_viewStyle == UCNewFilterViewStyleFromHomeView) ? 60 : 0), 45)];
    [_btnViewCount addTarget:self action:@selector(onClickViewCarListBtn:) forControlEvents:UIControlEventTouchUpInside];
    NSString *strTitle = nil;
    if (_viewStyle == UCNewFilterViewStyleFromAddAttentionView)
        strTitle = @"确认添加";
    else if (_viewStyle == UCNewFilterViewStyleFromHomeView || _viewStyle == UCNewFilterViewStyleFromSearchView)
        strTitle = @"正在筛选中...";
    else if (_viewStyle == UCNewFilterViewStyleFromEditAttentionView)
        strTitle = @"确认编辑";
    [_btnViewCount setTitle:strTitle forState:UIControlStateNormal];
    [_btnViewCount setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen size:_btnViewCount.size] forState:UIControlStateNormal];
    [_btnViewCount setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen size:_btnViewCount.size] forState:UIControlStateDisabled];
    [_btnViewCount setBackgroundImage:[UIImage imageWithColor:kColorNewGreenH size:_btnViewCount.size] forState:UIControlStateHighlighted];
    _btnViewCount.titleLabel.font = kFontLarge;
    _btnViewCount.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // 圆角
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:_btnViewCount.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = _btnViewCount.bounds;
    maskLayer2.path = maskPath2.CGPath;
    _btnViewCount.layer.mask = maskLayer2;
    
    // 订阅按钮
    if (_viewStyle == UCNewFilterViewStyleFromHomeView) {
        _btnAtten = [[UIButton alloc] initWithFrame:CGRectMake(_btnViewCount.maxX + kLinePixel, 10, 60, 45)];
        _btnAtten.enabled = ![_mTempFilter isNull];
        _btnAtten.titleLabel.font = kFontLarge;
        [_btnAtten setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen size:_btnAtten.size] forState:UIControlStateNormal];
        [_btnAtten setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen3 size:_btnAtten.size] forState:UIControlStateHighlighted];
        [_btnAtten setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen3 size:_btnAtten.size] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_btnAtten setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen size:_btnAtten.size] forState:UIControlStateDisabled];
        [_btnAtten setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen1 size:_btnAtten.size] forState:UIControlStateDisabled | UIControlStateSelected];
        [_btnAtten setTitle:@"订阅" forState:UIControlStateNormal];
        [_btnAtten setTitle:@"已订阅" forState:UIControlStateSelected];
        [_btnAtten setTitle:@"已订阅" forState:UIControlStateSelected | UIControlStateHighlighted];
        [_btnAtten setTitleColor:kColorNewGreenH forState:UIControlStateDisabled];
        [_btnAtten addTarget:self action:@selector(onClickAttenBtn:) forControlEvents:UIControlEventTouchUpInside];
        [vBody addSubview:_btnAtten];
    }
    
    // 重置
    CGFloat minXResetbutton = _viewStyle == UCNewFilterViewStyleFromHomeView ? _btnAtten.maxX + kLinePixel : _btnViewCount.maxX + kLinePixel;
    
    _btnReset = [[UIButton alloc] initWithFrame:CGRectMake(minXResetbutton, 10, 60, 45)];
    [_btnReset addTarget:self action:@selector(onClickResetFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    _btnReset.titleLabel.font = kFontLarge;
    [_btnReset setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen size:_btnReset.size] forState:UIControlStateNormal];
    [_btnReset setBackgroundImage:[UIImage imageWithColor:kColorNeWGreen3 size:_btnReset.size] forState:UIControlStateHighlighted];
    [_btnReset setTitle:@"重置" forState:UIControlStateNormal];

    // 圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_btnReset.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _btnReset.bounds;
    maskLayer.path = maskPath.CGPath;
    _btnReset.layer.mask = maskLayer;
    
    if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView) {
        // 菊花
        _vActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _vActivity.userInteractionEnabled = NO;
        _vActivity.frame = CGRectMake((_btnViewCount.width + [_btnViewCount.titleLabel.text sizeWithFont:_btnViewCount.titleLabel.font].width) / 2 + 5, (_btnViewCount.height - 20) / 2, 20, 20);
        _vActivity.hidesWhenStopped = YES;
        [_vActivity stopAnimating];
        [_btnViewCount addSubview:_ivCarCountArrow];
        [_btnViewCount addSubview:_vActivity];
    }
    
    [vBody addSubview:_btnViewCount];
    [vBody addSubview:_btnReset];

    return vBody;
}

/** SUV视图 */
- (void)switchSUVView:(BOOL)isOpen
{
    _isShowSUVView = isOpen;
    
    // 创建选择方式视图
    UIControl *cBlackBg = nil;
    CGFloat vChoosePhotoHetght = 250;
    
    if (_isShowSUVView) {
        // 背景视图
        cBlackBg = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        cBlackBg.tag = kBlackBgViewTag;
        [cBlackBg addTarget:self action:@selector(onClickCloseChooseViewControl:) forControlEvents:UIControlEventTouchUpInside];
        cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        [cBlackBg addSubview:_vSUVView];
        [self addSubview:cBlackBg];
        
        // 创建选择图片视图
        if (!_vSUVView) {
            // 选图片视图
            _vSUVView = [[UIView alloc] initWithFrame:CGRectMake(0, cBlackBg.height - vChoosePhotoHetght, cBlackBg.width, vChoosePhotoHetght)];
            _vSUVView.layer.masksToBounds = YES;
            _vSUVView.backgroundColor = kColorClear;
            
            /** 标题 + 选项 视图 */
            UIView *vContent = [[UIView alloc] initWithFrame:CGRectMake(10, 0, _vSUVView.width - 20, 183)];
            vContent.layer.masksToBounds = YES;
            vContent.layer.cornerRadius = 5;
            vContent.backgroundColor = kColorWhite;
            
            // 标题
            UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vContent.width, 36)];
            labTitle.text = @"请选择以下级别选项";
            labTitle.textAlignment = NSTextAlignmentCenter;
            labTitle.font = kFontNormal;
            labTitle.textColor = kColorNewGray2;
            
            // 分割线
            UIView  *vLine = [[UIView alloc] initWithFrame:CGRectMake(0, labTitle.maxY, vContent.width, kLinePixel)];
            vLine.backgroundColor = kColorNewLine;
            
            // 选项
            NSArray *suvItems = [[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"];
            CGFloat minX = 0;
            CGFloat minY = vLine.maxY + 6;
            for (int i = 0; i < suvItems.count; i++) {
                // 按钮
                UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake(minX, minY, _vSUVView.width / 2, 45)];
                btnItem.tag = kSVUButtonStartTag + i;
                [btnItem addTarget:self action:@selector(onClickSUVItemBtn:) forControlEvents:UIControlEventTouchUpInside];
                [btnItem setImage:[UIImage imageNamed:@"screennotes_choose_butten"] forState:UIControlStateNormal];
                [btnItem setImage:[UIImage imageNamed:@"screennotes_choose_butten_h"] forState:UIControlStateHighlighted];
                [btnItem setImage:[UIImage imageNamed:@"screennotes_choose_butten_h"] forState:UIControlStateSelected];
                btnItem.imageEdgeInsets = UIEdgeInsetsMake(0, -btnItem.width * 9 / 16, 0, 0);

                // 标题
                UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(minX + btnItem.imageView.maxX + 3, minY, 120, 45)];
                labTitle.text = [[suvItems objectAtIndex:i] objectForKey:@"Name"];
                labTitle.textColor = kColorNewGray1;                
                
                if (i == 1 || i == 3 || i == 5) {
                    minX = 0;
                    minY += 45;
                } else {
                    minX += _vSUVView.width / 2 - 10;
                }
                
                // 设置选中
                if ([[[[[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"] objectAtIndex:i] objectForKey:@"Value"] integerValue] == _mTempFilter.levelid.integerValue) {
                    btnItem.selected = YES;
                }
                
                [vContent addSubview:btnItem];
                [vContent addSubview:labTitle];
            }
            
            // 取消
            UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(vContent.minX, vContent.maxY + (_vSUVView.height - vContent.maxY - 45) / 2, vContent.width, 45)];
            btnCancel.layer.masksToBounds = YES;
            btnCancel.layer.cornerRadius = 5;
            [btnCancel addTarget:self action:@selector(onClickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
            [btnCancel setTitleColor:kColorBlue forState:UIControlStateNormal];
            btnCancel.titleLabel.font = kFontLarge;
            btnCancel.backgroundColor = kColorWhite;
            
            [vContent addSubview:labTitle];
            [vContent addSubview:vLine];
            [_vSUVView addSubview:vContent];
            [_vSUVView addSubview:btnCancel];
            [cBlackBg addSubview:_vSUVView];
        }
        
        // 动画开启
        _vSUVView.minY = cBlackBg.height;
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            _vSUVView.minY = cBlackBg.height - vChoosePhotoHetght;
            
        }completion:^(BOOL finished) {
        }];
    } else {
        cBlackBg = (UIControl *)[self viewWithTag:kBlackBgViewTag];
        // 动画关闭
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            _vSUVView.minY = cBlackBg.height;
            cBlackBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        }completion:^(BOOL finished) {
            [cBlackBg removeFromSuperview];
            [_vSUVView removeFromSuperview];
            _vSUVView = nil;
        }];
    }
}


#pragma mark - onClickButton
- (void)onClickTopBar:(UIButton *)btn
{
    // 关闭
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
    }
    // 打开筛选记录
    else if (btn.tag == UCTopBarButtonRight) {
        [UMStatistics event:c_3_8_buycar_creening_recording_click];
        UCFilterHistoryView *vHistory = [[UCFilterHistoryView alloc] initWithFrame:self.bounds];
        vHistory.delegate = (id)_delegate;
        [[MainViewController sharedVCMain] openView:vHistory animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
}

/** 点击地点按钮 */
- (void)onClickLocationBtn:(UIButton *)btn
{
    // 调用地点控件
    UCChoseLocationView *vChoseLocation = [[UCChoseLocationView alloc] initWithFrame:self.bounds areaModel:_mTempArea];
    vChoseLocation.delegate = self;
    [[MainViewController sharedVCMain] openView:vChoseLocation animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 选择品牌按钮 */
- (void)onClickBrandBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_8_buycar_creening_brand];
    UCNewFilterBrandView *vBrand = [[UCNewFilterBrandView alloc] initWithFrame:self.bounds mFilter:_mTempFilter];
    vBrand.delegate = self;
    [[MainViewController sharedVCMain] openView:vBrand animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 点击SUV按钮 */
- (void)onClickSUVItemBtn:(UIButton *)btn
{
    NSString *strTitle = nil;
    UCSingleSelectionVIew *vSingleSelection = (UCSingleSelectionVIew *)[_vLevel viewWithTag:kSingleSelection_Level];
    UIButton *btnSUV = [vSingleSelection.buttonItems objectAtIndex:6];

    // 重复点击
    if (btn.selected) {
        btn.selected = NO;
        btnSUV.selected = NO;
        strTitle = @"SUV";
        [self cancelFilterModelWithSingleView:vSingleSelection btnSelected:btn];
        // 获取数据
        if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
            [self getCarListCount];
    }
    // 选择SUV
    else {
        
        // 恢复级别选项UI
        for (int i = 0; i < vSingleSelection.buttonItems.count; i++) {
            UIButton *btnItem = (UIButton *)[vSingleSelection.buttonItems objectAtIndex:i];
            btnItem.selected = NO;
        }
        
        // 恢复SUV选项UI
        for (int i = 0; i < 6; i++) {
            UIButton *btnItem = (UIButton *)[_vSUVView viewWithTag:kSVUButtonStartTag + i];
            btnItem.selected = NO;
        }
        
        [self cancelFilterModelWithSingleView:vSingleSelection btnSelected:btn];
        
        btn.selected = YES;
        btnSUV.selected = YES;
        strTitle = [[[[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"] objectAtIndex:btn.tag - kSVUButtonStartTag] objectForKey:@"Name"];
        
        _mTempFilter.levelid = [NSNumber numberWithInteger:[[[[[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"] objectAtIndex:btn.tag - kSVUButtonStartTag] objectForKey:@"Value"] integerValue]];
        _mTempFilter.levelidText = [[[[_filterLevels objectAtIndex:6] objectForKey:@"SUVItems"] objectAtIndex:btn.tag - kSVUButtonStartTag] objectForKey:@"Name"];
        // 获取数据
        if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
            [self getCarListCount];
    }
    
    // 更改SUV标题
    [btnSUV setTitle:strTitle forState:UIControlStateSelected];
    [btnSUV setTitle:strTitle forState:UIControlStateNormal];
    
    // 更改UI
    btnSUV.titleEdgeInsets = UIEdgeInsetsMake(35, -btnSUV.imageView.width, 0, 0);
    btnSUV.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25, -btnSUV.titleLabel.width);
    
    // 关闭面板
    if (![OMG isValidClick:kAnimateSpeedFast])
        return;
    [self switchSUVView:NO];
}

/** 展开收起动画 */
- (void)showMoreFilterViewWithButton:(UIButton *)btn isAnimation:(BOOL)isAnimation
{
    // 更多页面
    if (!_vMoreFilter)
        [self creatMoreFilterView];
    
    btn.selected = !btn.selected;
    
    // 更改按钮文字
    [_btnViewMore setTitle:btn.selected ? @"收起" : @"更多筛选条件" forState:UIControlStateNormal];
    _btnViewMore.titleEdgeInsets = UIEdgeInsetsMake(0, -_btnViewMore.imageView.width + (btn.selected ? 0 : 20), 0, _btnViewMore.titleLabel.width / 2 - (btn.selected ? 0 : 20));
    _btnViewMore.imageEdgeInsets = UIEdgeInsetsMake(0, _btnViewMore.titleLabel.width / 2 + (btn.selected ? 0 : 20) + _btnViewMore.imageView.width, 0, -_btnViewMore.titleLabel.width - (btn.selected ? 0 : 20));
    
    // 箭头方向
    _btnViewMore.imageView.transform = btn.selected ? CGAffineTransformRotate(_btnViewMore.imageView.transform, M_PI) : CGAffineTransformIdentity;
    
    // 动画
    [UIView animateWithDuration:(isAnimation ? kAnimateSpeedNormal : 0) animations:^{
        if (btn.selected)
            _vMoreFilter.hidden = NO;
        _vBottom.minY = btn.selected ? _vMoreFilter.maxY : _vLevel.maxY;
        _svMain.contentSize = CGSizeMake(_svMain.width, _vBottom.maxY);
    } completion:^(BOOL finished) {
        // 显示隐藏更多视图
        if (!btn.selected)
            _vMoreFilter.hidden = !btn.selected;
    }];

}

/** 查看更多 */
- (void)onClickViewMoreBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_8_buycar_creening_more];
    [self showMoreFilterViewWithButton:btn isAnimation:YES];
}

/** 点击取消SUV视图按钮 */
- (void)onClickCancelBtn:(UIButton *)btn
{
    if (![OMG isValidClick:kAnimateSpeedFast])
        return;
    [self switchSUVView:NO];
}

/** 重置 */
- (void)onClickResetFilterBtn:(UIButton *)btn
{
    // 屏蔽重复点击
    if (![OMG isValidClick:0.3])
        return;
    
    [UMStatistics event:c_3_8_buycar_creening_reset];
    
    // 是否打开了更多筛选
    BOOL isOpenMoreFilterView = _btnViewMore.selected;
    // 得到偏移量
    CGPoint offset = _svMain.contentOffset;
    
    // 移除观察者
    [self setObserverOpen:NO];
    _mTempFilter = [[UCFilterModel alloc] init];
    // 添加观察者
    [self setObserverOpen:YES];
    // 筛选页不清除地点
    if (_viewStyle != UCNewFilterViewStyleFromHomeView)
        [_mTempArea setNull];
    [self removeAllSubviews];
    _vMoreFilter = nil;
    _vSUVView = nil;
    _isAddAttention = NO;
    _isShowSUVView = NO;
    [self initView];
    // 展开更多筛选
    if (isOpenMoreFilterView) {
        _btnViewMore.selected = NO;
        [self showMoreFilterViewWithButton:_btnViewMore isAnimation:NO];
    }
    // 恢复到重置前位置
    _svMain.contentOffset = offset;
    [_svMain setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // 刷新数据
    if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
        [self getCarListCount];
}

/** 关注开关 */
- (void)onClickAttenBtn:(UIButton *)btn
{
    // 取消
    if (btn.selected) {
        [self deleteAttenWithID:[NSNumber numberWithInteger:_attenID]];
    }
    // 关注
    else {
        UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] init];
        [mAtten setAreaValue:_mTempArea];
        [mAtten setFilterValue:_mTempFilter];
        [self addAttentionAPIWithAttenModel:mAtten];
    }
}

/** 查看筛选结果 */
- (void)onClickViewCarListBtn:(UIButton *)btn
{
    if (![OMG isValidClick:kAnimateSpeedFast])
        return;
    
    [UMStatistics event:c_3_8_buycar_creening_viewcar];
    
    // 是否开启关注
    if (_isAddAttention || _viewStyle == UCNewFilterViewStyleFromAddAttentionView || _viewStyle == UCNewFilterViewStyleFromEditAttentionView) {
        if ([_mTempFilter isNull]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"至少选择一个车辆筛选条件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        } else {
            // 首页进筛选，地点model使用本地model
            if (_viewStyle == UCNewFilterViewStyleFromHomeView ) {
                _mTempArea = [AMCacheManage currentArea];
            }
            // 添加关注
            if ( _viewStyle == UCNewFilterViewStyleFromAddAttentionView) {
                if ([_delegate respondsToSelector:@selector(UCNewFilterView:addAttentionWithAreaModel:filterModel:)]) {
                    [_delegate UCNewFilterView:self addAttentionWithAreaModel:_mTempArea filterModel:_mTempFilter];
                }
            }
            // 修改关注
            if (_viewStyle == UCNewFilterViewStyleFromEditAttentionView) {
                if ([_delegate respondsToSelector:@selector(UCNewFilterView:attentionID:isChanged:editAttentionWithAreaModel:filterModel:)]) {
                    [_delegate UCNewFilterView:self attentionID:_attentionID isChanged:(![_mTempArea isEqualToArea:_mOriginalArea] || ![_mTempFilter isEqualToFilter:_mOriginalFilter]) editAttentionWithAreaModel:_mTempArea filterModel:_mTempFilter];
                }
            }
            
        }
    }
    
    
    // 筛选功能：返回结果
    if (_viewStyle == UCNewFilterViewStyleFromHomeView || _viewStyle == UCNewFilterViewStyleFromSearchView) {
        // 通知代理
        if ([_delegate respondsToSelector:@selector(UCNewFilterView:isChanged:filterModelChanged:didClickedViewCarListBtnWithCarLists:rowCount:)]) {
            if ([_mOriginalFilter isEqualToFilter:_mTempFilter])
                [_delegate UCNewFilterView:self isChanged:NO filterModelChanged:_mTempFilter didClickedViewCarListBtnWithCarLists:nil rowCount:NSNotFound];
            else
                [_delegate UCNewFilterView:self isChanged:YES filterModelChanged:_mTempFilter didClickedViewCarListBtnWithCarLists:_mCarLists rowCount:_rowCount];
        }
        
    }
    
}

#pragma mark - Public method

#pragma mark - Privite method
/** 单击背景收回选择图片视图 */
- (void)onClickCloseChooseViewControl:(UITapGestureRecognizer *)sender
{
    if (![OMG isValidClick:kAnimateSpeedFast])
        return;
    [self switchSUVView:NO];
}

/** 加载车源数 */
- (void)setLoadingAnimation:(BOOL)isAnimation rowCount:(NSInteger)rowCount
{
    if (isAnimation) {
        [_mCarLists removeAllObjects];
        _rowCount = 0;
        _btnViewCount.enabled = YES;
        [_btnViewCount setTitle:@"正在筛选中..." forState:UIControlStateNormal];
        _ivCarCountArrow.hidden = YES;
        [_vActivity startAnimating];
    }
    else {
        _ivCarCountArrow.hidden = NO;
        [_vActivity stopAnimating];
        [_btnViewCount setTitle:rowCount > 0 ? [NSString stringWithFormat:@"查看%d条车源", rowCount] : @"没有找到车源" forState:UIControlStateNormal];
        _btnViewCount.enabled = rowCount > 0 ? YES : NO;
        _rowCount = rowCount;
    }
}

/** 获得车源数据 */
- (void)getCarListCount
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(getCarListCountTemp) withObject:nil afterDelay:kDelayLoadDataTime];
}

/** 获得车源数据中间方法 */
- (void)getCarListCountTemp
{
    [self getCarListCountAPI];
}

/** 设置值 */
- (void)setFilterModelWithSingleView:(UCSingleSelectionVIew *)vSingle btnSelected:(UIButton *)btnSelected
{
    if (vSingle.tag == kSingleSelection_Level) {
        _mTempFilter.levelid = [NSNumber numberWithInteger:[[[_filterLevels objectAtIndex:btnSelected.tag] objectForKey:@"Value"] integerValue]];
        _mTempFilter.levelidText = [[_filterLevels objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_level label:_mTempFilter.levelidText];
    }
    else if (vSingle.tag == kSingleSelection_Gearbox) {
        _mTempFilter.gearboxid = [NSNumber numberWithInteger:btnSelected.tag + 1];
        _mTempFilter.gearboxidText = btnSelected.tag == 0 ? @"手动挡" : @"自动挡";
        [UMStatistics event:c_3_8_buycar_creening_gearbox label:_mTempFilter.gearboxidText];
    }
    else if (vSingle.tag == kSingleSelection_Color) {
        _mTempFilter.color = [NSNumber numberWithInteger:btnSelected.tag + 1];
        _mTempFilter.colorText = [[_carColorValues objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_colour label:_mTempFilter.colorText];
    }
    else if (vSingle.tag == kSingleSelection_Displacement) {
        _mTempFilter.displacement = [[_filterDisplacement objectAtIndex:btnSelected.tag] objectForKey:@"Value"];
        _mTempFilter.displacementText = [[_filterDisplacement objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_discharge label:_mTempFilter.displacementText];
    }
    else if (vSingle.tag == kSingleSelection_County) {
        _mTempFilter.countryid = [[_filterCounty objectAtIndex:btnSelected.tag] objectForKey:@"Value"];
        _mTempFilter.countryidText = [[_filterCounty objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_country label:_mTempFilter.countryidText];
    }
    else if (vSingle.tag == kSingleSelection_Property) {
        _mTempFilter.countrytype = [[_filterProperty objectAtIndex:btnSelected.tag] objectForKey:@"Value"];
        _mTempFilter.countrytypeText = [[_filterProperty objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_attribute label:_mTempFilter.countrytypeText];
    }
    else if (vSingle.tag == kSingleSelection_Drive) {
        _mTempFilter.powertrain = [NSNumber numberWithInteger:[[[_filterDrive objectAtIndex:btnSelected.tag] objectForKey:@"Value"] integerValue]];
        _mTempFilter.powertrainText = [[_filterDrive objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_driveform label:_mTempFilter.powertrainText];
    }
    else if (vSingle.tag == kSingleSelection_Structure) {
        _mTempFilter.structure = [NSNumber numberWithInteger:[[[_filterStructure objectAtIndex:btnSelected.tag] objectForKey:@"Value"] integerValue]];
        _mTempFilter.structureText = [[_filterStructure objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_bodystructure label:_mTempFilter.structureText];
    }
    else if (vSingle.tag == kSingleSelection_Source) {
        _mTempFilter.sourceid = [NSNumber numberWithInteger:[[[_filterSource objectAtIndex:btnSelected.tag] objectForKey:@"Value"] integerValue]];
        _mTempFilter.sourceidText = [[_filterSource objectAtIndex:btnSelected.tag] objectForKey:@"Name"];
        [UMStatistics event:c_3_8_buycar_creening_source label:_mTempFilter.sourceidText];
    }
    else if (vSingle.tag == kSingleSelection_Warranty) {
        if (btnSelected) {
            if (btnSelected.tag == 0) {
                _mTempFilter.haswarranty = [NSNumber numberWithInt:1];
                _mTempFilter.haswarrantyText = @"原厂质保";
                _mTempFilter.extrepair = nil;
                _mTempFilter.extrepairText = nil;
            } else if (btnSelected.tag == 1) {
                _mTempFilter.extrepair = [NSNumber numberWithInt:1];
                _mTempFilter.extrepairText = @"延长质保";
                _mTempFilter.haswarranty = nil;
                _mTempFilter.haswarrantyText = nil;
            }
            [UMStatistics event:c_3_8_buycar_creening_warrantytype label:_mTempFilter.extrepairText];
        }
    }
    else if (vSingle.tag == kSingleSelection_Other) {
        if (btnSelected.tag == 0) {
            _mTempFilter.isnewcar = @"1";
            _mTempFilter.isnewcarText = @"准新车";
            [UMStatistics event:c_3_8_buycar_creening_other label:_mTempFilter.isnewcarText];
        } else if (btnSelected.tag == 1) {
            _mTempFilter.dealertype = [NSNumber numberWithInt:9];
            _mTempFilter.dealertypeText = @"只看在售";
            [UMStatistics event:c_3_8_buycar_creening_other label:_mTempFilter.dealertypeText];
        } else if (btnSelected.tag == 2) {
            _mTempFilter.ispic = @"1";
            _mTempFilter.ispicText = @"只看有图";
            [UMStatistics event:c_3_8_buycar_creening_other label:_mTempFilter.ispicText];
        }
        
    }
}

/** 取消值 */
- (void)cancelFilterModelWithSingleView:(UCSingleSelectionVIew *)vSingle btnSelected:(UIButton *)btnSelected
{
    if (vSingle.tag == kSingleSelection_Level) {
        _mTempFilter.levelid = nil;
        _mTempFilter.levelidText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Gearbox) {
        _mTempFilter.gearboxid = nil;
        _mTempFilter.gearboxidText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Color) {
        _mTempFilter.color = nil;
        _mTempFilter.colorText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Displacement) {
        _mTempFilter.displacement = nil;
        _mTempFilter.displacementText = nil;
    }
    else if (vSingle.tag == kSingleSelection_County) {
        _mTempFilter.countryid = nil;
        _mTempFilter.countryidText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Property) {
        _mTempFilter.countrytype = nil;
        _mTempFilter.countrytypeText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Drive) {
        _mTempFilter.powertrain = nil;
        _mTempFilter.powertrainText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Structure) {
        _mTempFilter.structure = nil;
        _mTempFilter.structureText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Source) {
        _mTempFilter.sourceid = nil;
        _mTempFilter.sourceidText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Warranty) {
        _mTempFilter.haswarranty = nil;
        _mTempFilter.haswarrantyText = nil;
        _mTempFilter.extrepair = nil;
        _mTempFilter.extrepairText = nil;
    }
    else if (vSingle.tag == kSingleSelection_Other) {
        if (btnSelected.tag == 0) {
            _mTempFilter.isnewcar = nil;
            _mTempFilter.isnewcarText = nil;
        } else if (btnSelected.tag == 1) {
            _mTempFilter.dealertype = nil;
            _mTempFilter.dealertypeText = nil;
        } else if (btnSelected.tag == 2) {
            _mTempFilter.ispic = nil;
            _mTempFilter.ispicText = nil;
        }
    }
}

/** 刷新滑杆UI */
- (void)refreshSliderViewUI:(JPickRangeSlider *)sender
{
    NSString *strText = @"";
    NSString *unit = @"";
    NSString *describe = @"";
    NSInteger min = 0, max = 0;
    UILabel *labTemp = nil;
    
    // 价格
    if (sender.tag == kPriceTag) {
        min = 3;
        max = 100;
        unit = @"万";
        describe = @"下";
        labTemp = _labPricevalue;
    }
    // 里程
    else if (sender.tag == kMileageTag) {
        min = 1;
        max = 10;
        unit = @"万";
        describe = @"下";
        labTemp = _labMileagevalue;
    }
    // 车龄
    else if (sender.tag == kCotyTag) {
        min = 1;
        max = 10;
        unit = @"年";
        describe = @"内";
        labTemp = _labCotyvalue;
    }
    
    if (sender.leftValue < min && sender.rightValue > max) {
        strText = @"不限";
    } else {
        if (sender.leftValue < min)
            strText = [NSString stringWithFormat:@"%0.f%@以%@", sender.rightValue, unit, describe];
        else if (sender.rightValue > max)
            strText = [NSString stringWithFormat:@"%0.f%@以上", sender.leftValue, unit];
        else
            strText = [NSString stringWithFormat:@"%0.f-%0.f%@",sender.leftValue, sender.rightValue, unit];
    }
    
    labTemp.text = strText;
    
    // 设置model的text
    if (sender.tag == kPriceTag) {
        if (_mTempFilter.priceregion.length > 0)
            _mTempFilter.priceregionText = strText;
        else
            _mTempFilter.priceregionText = nil;
    }
    else if (sender.tag == kMileageTag) {
        if (_mTempFilter.mileageregion.length > 0)
            _mTempFilter.mileageregionText = strText;
        else
            _mTempFilter.mileageregionText = nil;
    }
    else if (sender.tag == kCotyTag) {
        if (_mTempFilter.registeageregion.length > 0)
            _mTempFilter.registeageregionText = strText;
        else
            _mTempFilter.registeageregionText = nil;
    }
}

/** 判断是否已存在关注条件 */
-(BOOL)isContainAttentionModel:(UCFilterModel *)mCarAtten
{
    BOOL isContain = NO;
    
    for (int i = 0; i < _mAttentions.count; i++) {
        UCCarAttenModel *mTemp = [[_mAttentions objectAtIndex:i] objectForKey:@"model"];
        UCFilterModel *mFilter = [[UCFilterModel alloc] init];
        [mFilter convertFromAttentionModel:mTemp];
        if ([mFilter isEqualToFilter:_mTempFilter]) {
            isContain = YES;
            _attenID = [[[_mAttentions objectAtIndex:i] objectForKey:@"id"] integerValue];
            break;
        }
    }
    
    return isContain;
}

/** 设置观察者模式 */
-(void)setObserverOpen:(BOOL)isOpen
{
    if (_viewStyle == UCNewFilterViewStyleFromHomeView) {
        // 注册观察者
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([UCFilterModel class], &outCount);
        for (i=0; i<outCount; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            if (isOpen) {
                [_mTempFilter addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld context:nil];
            } else {
                [_mTempFilter removeObserver:self forKeyPath:key];
            }
        }
        free(properties);
    }
}

#pragma mark - NSKeyValueObserving
/** 观察者 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不存在
    if ([_mTempFilter isNull]) {
        _btnAtten.enabled = NO;
    }
    // 存在
    else {
        _btnAtten.enabled = YES;
        _btnAtten.selected = [self isContainAttentionModel:_mTempFilter];
    }
}

#pragma mark - SliderValueChanged
- (void)sliderValueChanged:(JPickRangeSlider *)sender
{
    /** 存数数据 */
    NSInteger min = 0, max = 0;
    float saveMin = 0, saveMax = 0;
    
    // 价格
    if (sender.tag == kPriceTag) {
        min = 5;
        max = 100;
        
        // 存数数据
        if ((sender.leftValue < min && sender.rightValue > max)) {
            _mTempFilter.priceregion = nil;
        } else {
            saveMin = sender.leftValue >= 5 ? sender.leftValue : 0;
            saveMax = sender.rightValue <= 100 ? sender.rightValue : 0;
            _mTempFilter.priceregion = [NSString stringWithFormat:@"%0.f-%0.f", saveMin, saveMax];
        }
    }
    // 里程
    else if (sender.tag == kMileageTag) {
        min = 1;
        max = 10;
        
        // 存数数据
        if ((sender.leftValue < min && sender.rightValue > max)) {
            _mTempFilter.mileageregion = nil;
        } else {
            saveMin = sender.leftValue >= 1 ? sender.leftValue : 0;
            saveMax = sender.rightValue <= 10 ? sender.rightValue : 0;
            _mTempFilter.mileageregion = [NSString stringWithFormat:@"%0.f-%0.f", saveMin, saveMax];
        }
    }
    // 车龄
    else if (sender.tag == kCotyTag) {
        min = 1;
        max = 10;

        // 存数数据
        if ((sender.leftValue < min && sender.rightValue > max)) {
            _mTempFilter.registeageregion = nil;
        } else {
            saveMin = sender.leftValue >= 1 ? sender.leftValue : 0;
            saveMax = sender.rightValue <= 10 ? sender.rightValue : 0;
            _mTempFilter.registeageregion = [NSString stringWithFormat:@"%0.f-%0.f", saveMin, saveMax];
        }
    }
    // 刷新UI
    [self refreshSliderViewUI:sender];
    
}

/** 滑动完滑杆 */
- (void)sliderValueChangedEnd:(JPickRangeSlider *)sender
{
    // 点击事件记录
    [self sliderValueChanged:sender];
    
    float min = [[NSString stringWithFormat:@"%0.f",sender.leftValue] floatValue];
    float max = [[NSString stringWithFormat:@"%0.f", sender.rightValue] floatValue];
    [sender moveThumbToMinPrice:min andMaxPrice:max];
    
    // 获取数据
    if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
        [self getCarListCount];
    
    // 价格
    if (sender.tag == kPriceTag)
        [UMStatistics event:c_3_8_buycar_creening_price label:_mTempFilter.priceregion.length > 0 ? _mTempFilter.priceregion : @"0"];
    // 里程
    else if (sender.tag == kMileageTag)
        [UMStatistics event:c_3_8_buycar_creening_mileage label:_mTempFilter.mileageregion.length > 0 ? _mTempFilter.mileageregion : @"0"];
    // 车龄
    else if (sender.tag == kCotyTag)
        [UMStatistics event:c_3_8_buycar_creening_life label:_mTempFilter.registeageregion.length > 0 ? _mTempFilter.registeageregion : @"0"];
}

#pragma mark - UCSingleSelectionViewDelegate
-(void)UCSingleSelectionView:(UCSingleSelectionVIew *)vSingleSelection didSelectedButton:(UIButton *)btn
{
    /** 特殊控制：级别SUV */
    if (vSingleSelection.tag == kSingleSelection_Level && btn.tag == 6) {
        if (![OMG isValidClick:kAnimateSpeedFast])
            return;
        [self switchSUVView:YES];
        return;
    }
    
    /** UI & 数据 控制 */
    
    // 重复点击
    if (btn.selected) {
        btn.selected = NO;
        [self cancelFilterModelWithSingleView:vSingleSelection btnSelected:btn];
        // 获取数据
        if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
            [self getCarListCount];
    }
    // 选中按钮
    else {
        // 恢复默认
        if (vSingleSelection.tag != kSingleSelection_Other) {
            for (int i = 0; i < vSingleSelection.buttonItems.count; i++) {
                UIButton *btnItem = [vSingleSelection.buttonItems objectAtIndex:i];
                btnItem.selected = NO;
                if (vSingleSelection.tag == kSingleSelection_Level && i == 6)
                    [btnItem setTitle:@"SUV" forState:UIControlStateNormal];
            }
            [self cancelFilterModelWithSingleView:vSingleSelection btnSelected:btn];
        }
        
        btn.selected = YES;
        [self setFilterModelWithSingleView:vSingleSelection btnSelected:btn];
        // 获取数据
        if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
            [self getCarListCount];
    }
    
    /** 执行代码 */
    switch (vSingleSelection.tag) {
        case kSingleSelection_Level:
        {
            // 恢复SUVUI
            UIButton *btnSUV = [vSingleSelection.buttonItems objectAtIndex:6];
            btnSUV.titleEdgeInsets = UIEdgeInsetsMake(35, -btnSUV.imageView.width, 0, 0);
            btnSUV.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25, -btnSUV.titleLabel.width);

        }
            break;
        case kSingleSelection_Gearbox:
        {
            
        }
            break;
        // 颜色
        case kSingleSelection_Color:
        {
            // 改变图片
            for (int i = 0; i < vSingleSelection.buttonItems.count; i++) {
                UIButton *btnItem = [vSingleSelection.buttonItems objectAtIndex:i];
                [btnItem setImage:[_colorImages objectAtIndex:i] forState:UIControlStateNormal];
            }
            
            [self cancelFilterModelWithSingleView:vSingleSelection btnSelected:btn];
            
            // 设置无图
            if (btn.selected) {
                [btn setImage:nil forState:UIControlStateNormal];
                [self setFilterModelWithSingleView:vSingleSelection btnSelected:btn];
            }
            // 获取数据
            if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
                [self getCarListCount];
        }
            break;
        case kSingleSelection_Displacement:
        {
            
        }
            break;
        case kSingleSelection_County:
        {
            
        }
            break;
        case kSingleSelection_Property:
        {
            
        }
            break;
        case kSingleSelection_Drive:
        {
            
        }
            break;
        case kSingleSelection_Structure:
        {
            
        }
            break;
        case kSingleSelection_Source:
        {
            
        }
            break;
        case kSingleSelection_Warranty:
        {
            
        }
            break;
        case kSingleSelection_Other:
        {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UCNewFilterBrandViewDelegate
/** 得到品牌 */
-(void)UCNewFilterBrandView:(UCNewFilterBrandView *)vNewFilterBrand isChanged:(BOOL)isChanged filterModel:(UCFilterModel *)mFilter
{
    // 统计事件
    NSString *strBrand = mFilter.brandidText.length > 0 ? mFilter.brandidText : @"";
    NSString *strSeries = @"";
    NSString *strSpec = @"";
    if (strBrand.length > 0 && mFilter.seriesidText.length > 0) {
        strSeries = [NSString stringWithFormat:@"-%@", mFilter.seriesidText];
        if (strSeries.length > 0 && mFilter.specidText.length > 0)
            strSpec = [NSString stringWithFormat:@"-%@", mFilter.specidText];
    }
    NSString *strName = [NSString stringWithFormat:@"%@%@%@",strBrand, strSeries, strSpec];
    if (strName.length == 0)
        strName = @"不限品牌";
    
    [UMStatistics event:c_3_9_1_buycar_creening_brand_selected label:strName];
    
    // 赋值
    if (isChanged) {
        _mTempFilter.brandid = mFilter.brandid;
        _mTempFilter.brandidText = mFilter.brandidText;
        _mTempFilter.seriesid = mFilter.seriesid;
        _mTempFilter.seriesidText = mFilter.seriesidText;
        _mTempFilter.specid = mFilter.specid;
        _mTempFilter.specidText = mFilter.specidText;
        
        NSString *strBrandText = @"全部品牌";
        
        if (![mFilter isNull] && _mTempFilter.brandid.length > 0) {
            if (_mTempFilter.seriesid.length == 0) {
                strBrandText = _mTempFilter.brandidText;
            } else {
                // 更新品牌UI
                NSString *strSeries = _mTempFilter.seriesidText.length > 0 ? _mTempFilter.seriesidText : @"";
                NSString *strSpec = _mTempFilter.specidText.length > 0 ? _mTempFilter.specidText : @"";
                strBrandText = [NSString stringWithFormat:@"%@ %@", strSeries, strSpec];
            }
        }
        
        _labBrand.text = strBrandText;
        
        // 刷新数据
        if (_viewStyle != UCNewFilterViewStyleFromAddAttentionView && _viewStyle != UCNewFilterViewStyleFromEditAttentionView)
            [self getCarListCount];
    }
    
    // 关闭选车页面
    [[MainViewController sharedVCMain] closeView:vNewFilterBrand animateOption:AnimateOptionMoveUp];
}

#pragma mark - UCLocationViewDelegate
-(void)UCChoseLocationView:(UCChoseLocationView *)vChoseLocation isChanged:(BOOL)isChanged areaModel:(UCAreaMode *)mArea
{
    // 是否选取位置
    if (isChanged) {
        [_mTempArea setEqualToArea:mArea];
        
        // 显示地点
        NSMutableString *strLocation = [[NSMutableString alloc] init];
        if (_mTempArea.areaName.length > 0)
            [strLocation appendString:[NSString stringWithFormat:@" %@", _mTempArea.areaName]];
        if (_mTempArea.pName.length > 0)
            [strLocation appendString:[NSString stringWithFormat:@" %@", _mTempArea.pName]];
        if (_mTempArea.cName.length > 0)
            [strLocation appendString:[NSString stringWithFormat:@" %@", _mTempArea.cName]];
        
        if (strLocation.length > 0)
            [strLocation deleteCharactersInRange:NSMakeRange(0, 1)];
        else
            [strLocation appendString:@"全国"];
        
        _labLocation.text = strLocation;
    }
    
    // 关闭页面
    [[MainViewController sharedVCMain] closeView:vChoseLocation animateOption:AnimateOptionMoveUp];
}

#pragma mark - APIHelper
- (void)getCarListCountAPI
{
    if (!_apiSearchCar)
        _apiSearchCar = [[APIHelper alloc] init];
    else
        [_apiSearchCar cancel];
    
    __weak UCNewFilterView *vNewFilter = self;
    
    // 设置请求完成后回调方法
    [_apiSearchCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
                [vNewFilter setLoadingAnimation:NO rowCount:0];
            }
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 获取数据成功
                    // 临时车辆列表
                    [vNewFilter.mCarLists removeAllObjects];
                    for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"carlist"]) {
                        UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithJson:dicCarInfoTemp];
                        [vNewFilter.mCarLists addObject:mCarInfo];
                    }
                    // 总车数
                    NSInteger rowCount = [[mBase.result objectForKey:@"rowcount"] integerValue];
                    [vNewFilter setLoadingAnimation:NO rowCount:rowCount];
                } else {
                    [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
                    [vNewFilter setLoadingAnimation:NO rowCount:0];
                }
            } else {
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
                [vNewFilter setLoadingAnimation:NO rowCount:0];
            }
        }
        
    }];
    
    // 正在筛选中...
    [self setLoadingAnimation:YES rowCount:NSNotFound];
    
    // 搜索接口
    [_apiSearchCar searchCarWithKeyword:_keyWords pagesize:[NSNumber numberWithInt:kPageSize] pageindex:[NSNumber numberWithInteger:1] areaid:[AMCacheManage currentArea].areaid pid:[AMCacheManage currentArea].pid cid:[AMCacheManage currentArea].cid dealerid:nil filter:self.mTempFilter orderby:_orderby];
}

/** 添加订阅 */
-(void)addAttentionAPIWithAttenModel:(UCCarAttenModel *)mAtten
{
    if (!_apiAttention)
        _apiAttention = [[APIHelper alloc] init];
    else
        [_apiAttention cancel];
    
    __weak UCNewFilterView *vNewFilter = self;
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在订阅..." cancel:^{
        [_apiAttention cancel];
        [[AMToastView toastView] hide];
    }];

    // 设置请求完成后回调方法
    [_apiAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            }
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            [UMStatistics event:c_3_9_2_buycar_creening_subscribe];
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            // 订阅成功或重复订阅
            if (mBase.returncode == 0 || mBase.returncode == 2049526) {
                vNewFilter.btnAtten.selected = YES;
                vNewFilter.attenID = [[mBase.result objectForKey:@"id"] integerValue];
                [vNewFilter.mAttentions addObject:[NSDictionary dictionaryWithObjectsAndKeys:mAtten, @"model", [mBase.result objectForKey:@"id"], @"id", nil]];
            }
            [[AMToastView toastView] showMessage:mBase.message icon:((mBase.returncode == 0 || mBase.returncode == 2049526) ? kImageRequestSuccess : kImageRequestError) duration:AMToastDurationNormal];
        } else {
            [[AMToastView toastView] hide];
        }
        
    }];
    
    // 关注
    [_apiAttention addAttentionWithAttenModel:mAtten];
    
}

/** 取消订阅 */
- (void)deleteAttenWithID:(NSNumber *)attenID
{
    if (!_apiAttention)
        _apiAttention = [[APIHelper alloc] init];
    else
        [_apiAttention cancel];
    
    __weak UCNewFilterView *vNewFilter = self;
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在取消订阅..." cancel:^{
        [_apiAttention cancel];
        [[AMToastView toastView] hide];
    }];
    // 设置请求完成后回调方法
    [_apiAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            [UMStatistics event:c_3_9_2_buycar_creening_unsubscribe];
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    for (int i = 0; i < vNewFilter.mAttentions.count; i++) {
                        if (vNewFilter.attenID == [[[vNewFilter.mAttentions objectAtIndex:i] objectForKey:@"id"] integerValue]) {
                            [vNewFilter.mAttentions removeObjectAtIndex:i];
                            break;
                        }
                    }
                    [vNewFilter.btnAtten setEnabled:YES];
                    [vNewFilter.btnAtten setSelected:NO];
                }
            }
            [[AMToastView toastView] showMessage:mBase.message icon:(mBase.returncode == 0 ? kImageRequestSuccess : kImageRequestError) duration:AMToastDurationNormal];
        }
    }];
    [_apiAttention deleteConcernCars:attenID];
}

-(void)dealloc
{
    [_apiSearchCar cancel];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [self setObserverOpen:NO];
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
    [AMCacheManage setConfigFilterGuideStatus:1];
    [AMCacheManage setConfigFilterGuideLastViewVersion: [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue]];
}

-(UIView*)hintStateViewForDialog:(id)hintState{
    UIImage *guideImage = [UIImage imageNamed:@"filterView_guide"];
    UIImageView *vGuide = [[UIImageView alloc] initWithImage:guideImage];
    
    EMHint *vhint = (EMHint*)hintState;
    [vGuide setFrame:CGRectMake(self.width - 130, vhint.modalView.size.height - 135, guideImage.width, guideImage.height)];
    return vGuide;
}

-(NSArray*)hintStateRectsToHint:(id)hintState{
    NSValue *value = [NSValue valueWithCGRect:CGRectMake(self.width - 100, [UIScreen mainScreen].bounds.size.height - 30, 50, 50)];
    return @[value];
}

@end
