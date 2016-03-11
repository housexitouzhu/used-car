//
//  UCSelectedView.m
//  UsedCar
//
//  Created by 张鑫 on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFilterView.h"
#import "UCHomeView.h"
#import "AMCacheManage.h"
#import "AppDelegate.h"
#import "UCMainView.h"
#import "UIImage+Util.h"

#define kPullButtonHeight 44

#define kFilterMoreView 13066254

@interface UCFilterView ()

@property (nonatomic, strong) UIButton *btnPull;
@property (nonatomic, strong) UIView *vMain;
@property (nonatomic, strong) UIView *vContent;
@property (nonatomic, getter = isPullDown) BOOL pullDown;
@property (nonatomic) UCFilterViewStyle viewStyle;
@property (nonatomic, strong) UCLocationView *vLocationView;

@end

@implementation UCFilterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

/** 初始化视图 */
- (void)initView
{
    self.clipsToBounds = YES;
    
    // 主视图
    _vMain = [[UIView alloc] initWithFrame:self.bounds];
    _vMain.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // 动态内容
    _vContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vMain.width, _vMain.height - kPullButtonHeight - kLinePixel)];
    _vContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vContent.maxY, _vMain.width, 1) color:kColorNewLine];
    vLine.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // 上拉按钮
    _btnPull = [[UIButton alloc] initWithFrame:CGRectMake(0, vLine.maxY, _vMain.width, kPullButtonHeight)];
    [_btnPull setTitle:@"关闭" forState:UIControlStateNormal];
    [_btnPull setTitleColor:kColorBlue forState:UIControlStateNormal];
    [_btnPull setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnPull.size] forState:UIControlStateHighlighted];
    _btnPull.titleLabel.font = kFontLarge_b;
    [_btnPull addTarget:self action:@selector(onClickPull:) forControlEvents:UIControlEventTouchUpInside];
    [_btnPull addTarget:self action:@selector(onDragPull:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    _btnPull.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_btnPull setBackgroundColor:kColorWhite];
    
    [_vMain addSubview:_vContent];
    [_vMain addSubview:vLine];
    [_vMain addSubview:_btnPull];
    
    [self addSubview:_vMain];
    
}

/** 定制对应的筛选视图 */
- (void)makeViewWithTag:(NSInteger)viewTag
{
    [_vContent removeAllSubviews];
    // 城市
    if (viewTag == -1) {
        _viewStyle = UCFilterViewStyleLocation;
        [UMStatistics event:pv_3_1_locationchoicecontrol];
        _vLocationView = [[UCLocationView alloc] initWithFrame:_vContent.bounds];
        _vLocationView.vFilter = self;
        [_vContent addSubview:_vLocationView];
        if (![UCMainView sharedMainView].vHome.isFirstLocation)
            // 设置已选项目
            [_vLocationView setSelectedCells:[AMCacheManage currentArea]];
        else
            [UCMainView sharedMainView].vHome.isFirstLocation = NO;
    }
    // 品牌
    else if (viewTag == 0) {
        _viewStyle = UCFilterViewStyleBrand;
//        [UMStatistics event:pv_3_1_brandchoicecontrol];
        
        // 从新车报价跳转二手车未启动时
        NSArray *conditions = [OMG getFilterModelAndAreaModelArrayWithUrl:[AppDelegate sharedAppDelegate].strCarPriceSearchUrl];
        if (conditions.count > 0)
            _mFilter = [conditions objectAtIndex:0];
        
        UCExpandBrandView *vFilterBrand = [[UCExpandBrandView alloc] initWithFrame:_vContent.bounds filter:_mFilter ExpandFilterBrandViewStyle:ExpandFilterBrandViewStyleBrand];
        vFilterBrand.delegate = self;
        [_vContent addSubview:vFilterBrand];
    
        [vFilterBrand setSelectedBrandCellshouldSelectAllBrandCell:YES];
        
    }
    // 价格筛选
    else if (viewTag == 1) {
        _viewStyle = UCFilterViewStylePrice;
//        [UMStatistics event:pv_3_1_priceselectcontrol];
        UCFilterPriceList *vFilterPrice = [[UCFilterPriceList alloc] initWithFrame:_vContent.bounds filter:self.mFilter];
        vFilterPrice.delegate = self;
        [_vContent addSubview:vFilterPrice];
    }
    // 里程筛选
    else if (viewTag == 2) {
        _viewStyle = UCFilterViewStyleMileage;
//        [UMStatistics event:pv_3_1_kiloselectcontrol];
        UCFilterOrderList *vFilterOrder = [[UCFilterOrderList alloc] initWithFrame:_vContent.bounds orderID:_strOrderID];
        vFilterOrder.delegate = self;
        [vFilterOrder setSelectedCellWithValue:[AMCacheManage currentOrder]];
        [_vContent addSubview:vFilterOrder];
    }
}

- (void)didMoveToSuperview
{
    _vMain.maxY = 0;
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        _vMain.minY = 0;
    }];
}

- (void)closeFilter:(BOOL)isValid
{
    [self onClickPull:isValid ? _btnPull : nil];
}

- (void)onClickPull:(UIButton *)btn
{
    // 关闭定位
    if (_viewStyle == UCFilterViewStyleLocation)
        [_vLocationView stopLocation];
    
    [self endEditing:YES];
        
    if (![_mFilter isNull] && [_mFilter conditionCount] > 1)
        [self saveFilterHistory];
    
    if (!self.isPullDown && [self.delegate respondsToSelector:@selector(filterView:filterMode:orderID:isValid:)])
        [self.delegate filterView:self filterMode:_mFilter orderID:_strOrderID isValid:btn ? YES : NO];
    
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        _vMain.minY = self.isPullDown ? 0 : -_vMain.height;
    } completion:^(BOOL finished) {
        if (!self.isPullDown)
            [self removeFromSuperview];
        else
            self.pullDown = NO;
    }];

}

- (void)onDragPull:(UIButton *)btn withEvent:(UIEvent *)event
{
    UITouch *touch =  (UITouch *)event.allTouches.anyObject;
    CGPoint location = [touch locationInView:btn];
    CGPoint previousLocation = [touch previousLocationInView:btn];
    CGFloat gap = previousLocation.y - location.y;

    if (gap != 0)
        self.pullDown = gap < 0 ? YES : NO;
    
    _vMain.minY -= gap;
    
    // 修正位置
    if (_vMain.minY > 0)
        _vMain.minY = 0;
    else if (_vMain.maxY < kPullButtonHeight)
        _vMain.maxY = kPullButtonHeight;
}

/** 存入历史记录 */
- (void)saveFilterHistory
{
    NSMutableArray *mfilters = [[NSMutableArray alloc] initWithArray:[AMCacheManage currentHistoryFilter]];
    
    // 排重
    for (UCFilterModel *mFilter in mfilters) {
        if ([self.mFilter isEqualToFilter:mFilter])
            return;
    }
    
    if ([mfilters count] == 0)
        [mfilters addObject:_mFilter];
    else if ([mfilters count] >0)
        [mfilters insertObject:_mFilter atIndex:0];
    if ([mfilters count] > 3) {
        [mfilters removeLastObject];
    }
    
    [AMCacheManage setCurrentHistoryFilter:mfilters];
}

#pragma mark - UCExpandBrandViewDelegate
-(void)UCExpandBrandView:(UCExpandBrandView *)vFilterBarnd isChanged:(BOOL)isChanged filterModel:(UCFilterModel *)mFilter
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
    
    [UMStatistics event:c_3_9_1_buycar_filter_brand_selected label:strName];

    if (isChanged) {
        _mFilter = [mFilter copy];
    }
    [self closeFilter:isChanged];
}

//#pragma mark-- UCMoreViewDelegate
///* 收回选择框 */
//-(void)getHistoryFilterModel
//{
////    [MainViewController sharedVCMain].mFilter = [_vMore getFilterModel];
//    if ([self.delegate respondsToSelector:@selector(getFilterModel)]) {
//        [self.delegate getFilterModel];
//    }
//}

///* 设置选中cell */
//-(void)setSelected
//{
//    MainViewController *vcMain = [MainViewController sharedVCMain];
//    NSArray *selectedCells = nil;//[vcMain.rowsOfSelectedView objectForKey:@"locationView"];
//    switch (_selectedViewTag) {
//        case 0:{
//            for (int i = 0; i < [selectedCells count]; i++) {
//                [_locationView setSelectedCells:selectedCells];
//            }
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

//#pragma mark - UCLocationViewDelegate
///* 已获得城市 */
//-(void)seletedCity:(NSDictionary *)dicCity
//{
//    // 返回定位城市
//    if ([self.delegate respondsToSelector:@selector(seletedCity:)]) {
//        [self.delegate seletedCity:dicCity];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLocationed"];
//    }
//}

#pragma mark - UCFilterOrderListDelegate
-(void)UCFilterOrderList:(UCFilterOrderList *)vFilterOrder didSelectedWithName:(NSString *)name value:(NSString *)value isChanged:(BOOL)isChanged
{
    [UMStatistics event:c_3_9_1_buycar_order_selected label:value.length > 0 ? value : @"0"];
    // 统计事件
    if (isChanged) {
        _strOrderID = [[NSString alloc] initWithString:value];
    }
    [self closeFilter:isChanged];
}

#pragma mark - UCFilterPriceListDelegate
-(void)UCFilterPriceList:(UCFilterPriceList *)vFilterPrice didSelectedWithName:(NSString *)name value:(NSString *)value isChanged:(BOOL)isChanged
{
    // 统计事件
    [UMStatistics event:c_3_9_1_buycar_filter_price_selected label:value.length > 0 ? value : @"0"];
    if (isChanged) {
        _mFilter.priceregion = value;
        _mFilter.priceregionText = name;
    }
    [self closeFilter:isChanged];
}

@end



