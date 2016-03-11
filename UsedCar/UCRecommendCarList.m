//
//  UCRecommendCarList.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRecommendCarList.h"
#import "UCTopBar.h"
#import "MainViewController.h"
#import "UCOptionBar.h"
#import "AMCacheManage.h"

@interface UCRecommendCarList ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCOptionBar *obTab;
@property (nonatomic, strong) UIView *vCarListSuper;
@property (nonatomic, strong) UCCarListView *vPriceCarList;
@property (nonatomic, strong) UCCarListView *vLevelCarList;
@property (nonatomic, strong) UCCarListView *vSeriesCarList;
@property (nonatomic, strong) UCFilterModel *mPriceFilter;
@property (nonatomic, strong) UCFilterModel *mLevelFilter;
@property (nonatomic, strong) UCFilterModel *mSeriesFilter;
@property (nonatomic, strong) NSArray *levelValues;
@property (nonatomic) BOOL isCloseRecord;

@end

@implementation UCRecommendCarList

- (id)initWithFrame:(CGRect)frame mCarDetailInfo:(UCCarDetailInfoModel *)mCarDetailInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        _mCarDetailInfo = mCarDetailInfo;
        
        _mPriceFilter = [[UCFilterModel alloc] init];
        _mLevelFilter = [[UCFilterModel alloc] init];
        _mSeriesFilter = [[UCFilterModel alloc] init];
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 标题
    [self.tbTop.btnTitle setTitle:@"类似车源" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    
    [self.tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    
    // 滑动条
    UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, kTopOptionHeight - 4, self.width / 3, 4)];
    vSlider.backgroundColor = kColorBlue;
    
    // 选项栏
    _obTab = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight) sliderView:vSlider];
    _obTab.isEnableBlur = NO;
    _obTab.isAutoAdjustSlider = YES;
    [_obTab addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _obTab.width, kLinePixel) color:kColorWhite]];
    _obTab.delegate = self;
    
    NSArray *titles = @[@"同价位", @"同级别", @"同车系"];
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        [items addObject:item];
    }
    [_obTab setItems:items];
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _obTab.height - kLinePixel, _obTab.width, kLinePixel) color:kColorNewLine];
    
    _vCarListSuper = [[UIView alloc] initWithFrame:CGRectMake(0, _obTab.maxY, self.width, self.height - _obTab.maxY)];
    _vCarListSuper.backgroundColor = [UIColor clearColor];
    
    [_obTab addSubview:vLine];
    [self addSubview:_vCarListSuper];
    [self addSubview:_tbTop];
    [self addSubview:_obTab];
    
    // 屏蔽记录价格
    _isCloseRecord = YES;
    // 选中第一个
	[_obTab selectItemAtIndex:0];
    
    
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    [_vCarListSuper removeAllSubviews];
    
    UCCarListView *vCarListTemp = nil;
    
    switch (index) {
        case 0:
            // 同价位
            if (_isCloseRecord)
                _isCloseRecord = NO;
            else
                // 相关车型同价位车源
                [UMStatistics event:c_3_1_buycarsameprice];
            
            if (!_vPriceCarList) {
                _vPriceCarList = [[UCCarListView alloc] initWithFrame:_vCarListSuper.bounds];
                _vPriceCarList.tag = UCRecommendCarListStylePrice;
                _vPriceCarList.delegate = self;
//                [_vPriceCarList setFooterViewHeight:_obTab.height];
                _vPriceCarList.mArea = [AMCacheManage currentArea];
                _mPriceFilter.priceregion = [_mCarDetailInfo.bookprice stringValue];
                _vPriceCarList.mFilter = _mPriceFilter;
                // 刷新
                [_vPriceCarList refreshCarList];
            }
            vCarListTemp = _vPriceCarList;
            break;
        case 1:
            // 同级别
            [UMStatistics event:c_3_1_buycarsamerank];
            if (!_vLevelCarList) {
                _vLevelCarList = [[UCCarListView alloc] initWithFrame:_vCarListSuper.bounds];
                _vLevelCarList.tag = UCRecommendCarListStyleLevel;
                _vLevelCarList.delegate = self;
//                [_vLevelCarList setFooterViewHeight:_obTab.height];
                _vLevelCarList.mArea = [AMCacheManage currentArea];
                _mLevelFilter.levelid = _mCarDetailInfo.levelid;
                _vLevelCarList.mFilter = _mLevelFilter;
                // 刷新
                [_vLevelCarList refreshCarList];
            }
            vCarListTemp = _vLevelCarList;
            break;
        case 2:
            // 同车系
            [UMStatistics event:c_3_1_buycarssamecar];
            if (!_vSeriesCarList) {
                _vSeriesCarList = [[UCCarListView alloc] initWithFrame:_vCarListSuper.bounds];
                _vSeriesCarList.tag = UCRecommendCarListStyleSeries;
                _vSeriesCarList.delegate = self;
//                [_vSeriesCarList setFooterViewHeight:_obTab.height];
                _vSeriesCarList.mArea = [AMCacheManage currentArea];
                _mSeriesFilter.seriesid = [_mCarDetailInfo.seriesid stringValue];
                _vSeriesCarList.mFilter = _mSeriesFilter;
                // 刷新
                [_vSeriesCarList refreshCarList];
            }
            vCarListTemp = _vSeriesCarList;
            break;
            
        default:
            break;
    }

    [_vCarListSuper addSubview:vCarListTemp];
}

#pragma mark - UCCarListViewDelegate
/** 统计事件 */
- (void)carListViewLoadData:(UCCarListView *)vCarList
{
    if (vCarList.tag == UCRecommendCarListStylePrice) {
        [UMStatistics event:pv_3_1_sameprice];
        [UMSAgent postEvent:sameprice_pv page_name:NSStringFromClass(self.class)];
    } else if (vCarList.tag == UCRecommendCarListStyleLevel) {
        [UMStatistics event:pv_3_1_samerank];
        [UMSAgent postEvent:samelevel_pv page_name:NSStringFromClass(self.class)];
    } else if (vCarList.tag == UCRecommendCarListStyleSeries) {
        [UMStatistics event:pv_3_1_samecar];
        [UMSAgent postEvent:sameseries_pv page_name:NSStringFromClass(self.class)];
    }
    
}

- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end
