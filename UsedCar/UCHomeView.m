//
//  UCHomeView.m
//  UsedCar
//
//  Created by Alan on 13-11-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCHomeView.h"
#import "UCMainView.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "UCTopBar.h"
#import "UCCarDetailView.h"
#import "UserInfoModel.h"
#import "UCCarInfoModel.h"
#import "NSString+Util.h"
#import "UIImage+Util.h"
#import "UCCarBrandModel.h"
#import "UCCarSeriesModel.h"
#import "UCCarSpecModel.h"
#import "AppDelegate.h"
#import "UCSearchHistoryView.h"
#import "UCSearchResultView.h"
#import "UCCarAttenModel.h"
#import "EMHint.h"

#define kOptionBarArrowTag              200000
#define kSearchSubViewsStartTag         300000

@interface UCHomeView ()
<UCSearchHistoryViewDelegate, EMHintDelegate>

@property (nonatomic, strong) UIView *vStatusBar;
@property (nonatomic, strong) UIView *vHead;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) AMBlurView *bvToolBar;
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic, strong) UCSearchView *vSearch;
@property (nonatomic, strong) UIView *vSearchBoard;
@property (nonatomic, strong) UCSearchHistoryView *vSearchHistory;
@property (nonatomic, strong) UCNewFilterView *vNewFilter;
@property (nonatomic, strong) APIHelper *apiAttention;  // 关注

@property (nonatomic) CGFloat lastScrollOffsetY;
@property (nonatomic) CGFloat nodeScrollOffsetY;
@property (nonatomic) NSInteger scrollDirection;

@property (nonatomic, strong) NSArray *orderValues;

@property (retain, nonatomic) EMHint *vHint;

@end

@implementation UCHomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilterValues" ofType:@"plist"];
        NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
        self.orderValues = values[@"Order"];
        
        // 从新车报价跳转 & 二手车启动 时
        NSArray *conditions = [OMG getFilterModelAndAreaModelArrayWithUrl:[AppDelegate sharedAppDelegate].strCarPriceSearchUrl];
        if (conditions.count ==2 ) {
            _mFilter = [conditions objectAtIndex:0];
            _mArea = [conditions objectAtIndex:1];
        } else {
            self.mFilter = [[UCFilterModel alloc] init];
            self.mArea = [AMCacheManage currentArea];
        }
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.clipsToBounds = YES;
    self.backgroundColor = kColorWhite;
    
    // 状态栏
    _vStatusBar = [self creatStatusBarView:CGRectMake(0, 0, self.width, 20)];
    
    // 头视图(导航+工具栏)
    _vHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 64 + kTopOptionHeight)];
    
    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 工具栏
    _bvToolBar = [[AMBlurView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    _bvToolBar.isEnableBlur = NO;
    _bvToolBar.backgroundColor = kColorWhite;
    _bvToolBar.clipsToBounds = YES;
    
    // 排序栏
    _obFilter = [self creatFilterView:CGRectMake(10, 0, self.width - 10 * 2, kTopOptionHeight)];
        
    /** 搜索栏 */
    _vSearch = [self creatSearchView:CGRectMake((_tbTop.width - 110) / 2, (_tbTop.height - 30) / 2 + (_tbTop.height - 44) / 2, 110, 30)];
    _vSearch.backgroundColor = RGBColorAlpha(0, 96, 165, 1);
    _vSearch.layer.masksToBounds = YES;
    _vSearch.layer.cornerRadius = 15;
    _vSearch.tfSearch.textColor = kColorWhite;
    _vSearch.tfSearch.leftView = [[UIView alloc] initWithClearFrame:CGRectMake(0, 0, 30, _vSearch.height)];
    
    // 搜索
    UIImage *iSearch = [UIImage imageAutoNamed:@"search_icon"];
    UIImageView *ivSearch = [[UIImageView alloc] initWithImage:iSearch];
    ivSearch.userInteractionEnabled = NO;
    ivSearch.tag = kSearchSubViewsStartTag + 0;
    ivSearch.origin = CGPointMake((_vSearch.width - iSearch.width) / 2 - 20, (_vSearch.height - iSearch.height) / 2);
    
    // 搜索文字
    UILabel *labSearch = [[UILabel alloc] init];
    labSearch.backgroundColor = kColorClear;
    labSearch.userInteractionEnabled = NO;
    labSearch.textColor = kColorWhite;
    labSearch.font = kFontNormal;
    labSearch.text = @"搜索";
    [labSearch sizeToFit];
    labSearch.tag = kSearchSubViewsStartTag + 1;
    labSearch.origin = CGPointMake((_vSearch.width - labSearch.width) / 2 + 8, (_vSearch.height - labSearch.height) / 2);
    
    [_vSearch addSubview:ivSearch];
    [_vSearch addSubview:labSearch];
    [_bvToolBar addSubview:_obFilter];
    [_bvToolBar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _bvToolBar.height - kLinePixel, _bvToolBar.width, kLinePixel) color:kColorNewLine]];
    
    [_vHead addSubview:_bvToolBar];
    [_vHead addSubview:_tbTop];
    [_tbTop addSubview:_vSearch];
    
    // 列表
    _vCarList = [self creatCarListView:self.bounds];
    
    [self addSubview:_vCarList];
    [self addSubview:_vHead];
    [self addSubview:_vStatusBar];
    
    // 更新城市
    [self updateCity:self.mArea];
    // 设置排序
    self.vCarList.orderby = [AMCacheManage currentOrder];
    // 更新筛选条显示文字
    [self updateFilterBar:_mFilter];
    
    // 没有选择城市时, 打开城市选择
    if ([AMCacheManage currentIsUsed] && !self.mArea)
        [self optionBar:_obFilter didSelectAtIndex:-1];
    // 刷新车辆列表
    else {
        [self.vCarList refreshCarList];
        // 清除新车报价url
        [AppDelegate sharedAppDelegate].strCarPriceSearchUrl = nil;
    }
    
}

/** 状态栏 */
- (UIView *)creatStatusBarView:(CGRect)frame
{
    _vStatusBar = [[UIView alloc] initWithFrame:frame];
    _vStatusBar.backgroundColor = kColorBlue;
    _vStatusBar.alpha = 0.9;
    _vStatusBar.hidden = YES;
    return _vStatusBar;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    _tbTop.btnLeft.width = 130;
    _tbTop.btnLeft.adjustsImageWhenHighlighted = NO;
    _tbTop.btnLeft.titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    
    [_tbTop.btnLeft setTitle:@"全国" forState:UIControlStateNormal];
    [_tbTop.btnLeft setTitleColor:kColorOrange forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnRight setTitle:@"筛选" forState:UIControlStateNormal];
    [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    return _tbTop;
}

/** 筛选条 */
- (UCOptionBar *)creatFilterView:(CGRect)frame
{
    CGFloat width = self.width / 3;
    NSArray *titles = @[@"全部品牌", @"价格不限", @"默认排序"];
    
    // 排序条
    _obFilter = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, 0, titles.count * width, frame.size.height) sliderView:nil];
    _obFilter.backgroundColor = kColorWhite;
    _obFilter.isAutoAdjustSlider = YES;
    _obFilter.delegate = self;
    _obFilter.isEnableBlur = NO;
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        
        // 箭头
        UIImage *iArrow = [UIImage imageNamed:@"homeview_filter_normal"];
        UIImageView *ivArrow = [[UIImageView alloc] initWithImage:iArrow];
        ivArrow.origin = CGPointMake(0, 0);
        ivArrow.tag = kOptionBarArrowTag + i;
        
        UIView *vRight = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, ivArrow.width, _obFilter.height)];
        item.rightView = vRight;
        item.rightView.userInteractionEnabled = NO;
        [vRight addSubview:ivArrow];
        
        ivArrow.centerY = vRight.centerY;
        
        [items addObject:item];
        
        // 添加分割线
        [_obFilter addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(width * (1 + i) +kLinePixel, 0, kLinePixel, _obFilter.height) color:kColorNewLine]];
    }
    
	[_obFilter setItems:items];
    
    [self setAutoSizeFilterBar];
    
    return _obFilter;
}

/** 搜索栏 */
- (UCSearchView *)creatSearchView:(CGRect)frame
{
    // 搜索栏
    _vSearch = [[UCSearchView alloc] initWithFrame:frame isShowCancelButton:NO isLightView:YES];
    _vSearch.delegate = self;
    
    // 特殊处理 隐藏提示语
    _vSearch.tfSearch.placeholder = @"";
    
    return _vSearch;
}

/** 列表 */
- (UCCarListView *)creatCarListView:(CGRect)frame
{
    // 车辆列表
    _vCarList = [[UCCarListView alloc] initWithFrame:frame];
    _vCarList.tag = UCHomeViewCarListStyleHomeList;
    _vCarList.scrollIndicatorInsets = UIEdgeInsetsMake(_vHead.height, 0, kMainOptionBarHeight, 0);
    _vCarList.mArea = self.mArea;
    _vCarList.delegate = self;
    _vCarList.scrollDelegate = self;
    [_vCarList setFooterViewHeight:kMainOptionBarHeight];
    [_vCarList enableActivityZone:YES];
    
    // 设置排序
    if ([AMCacheManage currentOrder].length == 0) {
        [AMCacheManage setCurrentOrder:@"0"];
        _vCarList.orderby = [AMCacheManage currentOrder];
    }
    
    return _vCarList;
}

#pragma mark - Public method
/** 根据数据刷新列表 */
- (void)reloadCarListByFilter:(UCFilterModel *)mFilter UCAreaModel:(UCAreaMode *)mArea;
{
    // 城市数据 & 更新UI
    _mArea = mArea;
    [AMCacheManage setCurrentArea:_mArea];
    [self updateCity:_mArea];
    [AMCacheManage setCurrentOrder:[[self.orderValues objectAtIndex:0] objectForKey:@"Value"]];
    // 筛选条数据 & 更新UI
    _mFilter = mFilter;
    [self updateFilterBar:_mFilter];
    
    // 刷新列表数据
    _vCarList.orderby = [AMCacheManage currentOrder];
    _vCarList.mFilter = _mFilter;
    _vCarList.mArea = _mArea;
    [_vCarList refreshCarList];
}

/** 统计事件 */
- (void)carListViewLoadData:(UCCarListView *)vCarList
{
    if (vCarList.tag == UCHomeViewCarListStyleHomeList) {
        [UMStatistics event:pv_3_1_buycarcarsourcelist];
        [UMSAgent postEvent:carlist_pv page_name:NSStringFromClass(self.class)];
    }
}

/** 统计事件 */
-(void)carListViewLoadDataSuccess:(UCCarListView *)vCarList
{
    // 搜索结果页
    if (vCarList.tag == UCHomeViewCarListStyleSearchList) {
        [UMSAgent postEvent:searchresult_pv page_name:NSStringFromClass(self.class)];
    }
}

/** 加载更多列表数据 */
- (void)loadMoreCarListData
{
    [_vCarList loadMore];
}

/** 打开蒙层 */
-(void)openMaskView
{
    //生成引导图
    NSInteger guideStatus = [AMCacheManage currentConfigHomeGuideStatus];
    NSInteger guideLastViewVersion = [AMCacheManage currentConfigHomeGuideLastViewVersion];
    NSInteger currentVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue];
    if(guideStatus == 0){
        [self createGuideView];
    }
    else if(guideLastViewVersion < currentVersion){
        [self createGuideView];
    }
}

#pragma mark - Private Method
- (void)setAutoSizeFilterBar
{
    // 文字和箭头间距
    for (int i = 0; i < 3; i++) {
        UIButton *btnItem = (UIButton *)[self.obFilter itemViewAtIndex:i];
        btnItem.titleEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0);
        UCOptionBarItem *item = [_obFilter itemAtIndex:i];
        btnItem.titleLabel.textAlignment = NSTextAlignmentCenter;
        item.rightView.minX = (btnItem.width - [btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width) / 2 + [btnItem.titleLabel.text sizeWithFont:btnItem.titleLabel.font].width;
    }
}

/** 取消筛选条选中状态 */
- (void)cancelFilterBarSelectedState
{
    for (int i = 0; i < 3; i++) {
        UIImageView *ivOrder = (UIImageView *)[_obFilter viewWithTag:kOptionBarArrowTag + i];
        ivOrder.image = [UIImage imageNamed:@"homeview_filter_normal"];
    }
}

#pragma mark - onClickButton
/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (![OMG isValidClick:0.6])
        return;
    
    [self endEditing:YES];
    // 右按钮
    if (btn.tag == UCTopBarButtonRight) {
        
        if ([btn.titleLabel.text hasPrefix:@"筛选"]) {
            // 点击搜索时关闭城市城市
            [UMStatistics event:c_3_8_buycar_creening_click];
            
            if ([_vFilter isDescendantOfView:self])
                [_vFilter closeFilter:NO];
            
            _vNewFilter = [[UCNewFilterView alloc] initWithFrame:self.bounds mFilter:_mFilter rowCount:_vCarList.carListAllCount orderby:[AMCacheManage currentOrder] mArea:_mArea];
            _vNewFilter.delegate = self;
            [[MainViewController sharedVCMain] openView:_vNewFilter animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
        else if ([btn.titleLabel.text hasPrefix:@"取消"]) {
            
            [self didClickCancelButton:_vSearch];
        }
    }
    // 城市
    else if (btn.tag == UCTopBarButtonLeft) {
        [UMStatistics event:c_3_1_buycarlocation];
        [self optionBar:_obFilter didSelectAtIndex:-1];
    }
}

#pragma mark - UCSerchViewDelegate
- (void)searchView:(UCSearchView *)vSearch dicCarModel:(NSMutableDictionary *)dicCarModel
{
    NSString *strSearch;
    
    UCCarBrandModel *mCarBrand = [dicCarModel objectForKey:@"brand"];
    UCCarSeriesModel *mCarSeries = [dicCarModel objectForKey:@"series"];
    UCCarSpecModel *mCarSpec = [dicCarModel objectForKey:@"spec"];
    
    if (mCarSpec)
        strSearch = [NSString stringWithString:mCarSpec.name];
    else if (mCarSeries)
        strSearch = [NSString stringWithString:mCarSeries.name];
    else if (mCarBrand)
        strSearch = [NSString stringWithString:mCarBrand.name];
    
    NSString *text = strSearch.trim;
    
    if (text.length > 0) {
        [_vSearchHistory saveHistoryWithNewEntry:text]; // 保存一条搜索历史记录
        _vSearch.tfSearch.text = text;
        _vSearch.tvSelect.hidden = YES;
        [_vSearch.tvSelect removeFromSuperview];
    }
    
    // 搜索结果
    UCSearchResultView *vSearchResult = [[UCSearchResultView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds withKeyword:text];
    [[MainViewController sharedVCMain] openView:vSearchResult animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldBeginEditing:(UITextField *)textField
{
    [UMStatistics event:c_3_8_buycar_search_click];
    if ([_tbTop.btnRight.titleLabel.text isEqualToString:@"取消"]) {
        //处理说明 这里对右上角的按钮做判断, 如果是取消说明是在搜索状态, 防止:如果页面已经打开, 搜索框里有文字,二次获取焦点进行编辑的时候, 会导致重新加载 view, 屏幕会闪动
        // 刷新数据
        if (textField.text.length > 0) {
            _vSearch.tvSelect.hidden = NO;
            if (![_vSearch.tvSelect isDescendantOfView:_vSearchBoard])
                [_vSearchBoard addSubview:_vSearch.tvSelect];
            [vSearch reloadSearchResultData:textField];
        }
    }
    else{
        // 点击搜索时关闭城市城市
        if ([_vFilter isDescendantOfView:self])
            [_vFilter closeFilter:NO];
        
        // 移动
        UIImageView *ivSearch = (UIImageView *)[_vSearch viewWithTag:kSearchSubViewsStartTag + 0];
        UILabel *labSearch = (UILabel *)[_vSearch viewWithTag:kSearchSubViewsStartTag + 1];
        
        [UIView animateWithDuration:kAnimateSpeedNormal animations:^{
            _vSearch.frame = CGRectMake(10, _vSearch.minY, _tbTop.width - 64, _vSearch.height);
            _vSearch.tfSearch.width = _vSearch.width;
            ivSearch.minX = 12;//20.75;
            labSearch.minX = 36;
            // 屏蔽地区按钮
            _tbTop.btnLeft.alpha = 0;
        } completion:^(BOOL finished) {
            _tbTop.btnLeft.hidden = YES;
        }];
        
        // 设置右按钮为取消
        [_tbTop.btnRight setTitle:@"取消" forState:UIControlStateNormal];
        
        // 隐藏底栏
        [[UCMainView sharedMainView] setTabBarHidden:YES animated:NO];
        
        // 搜索面板
        if (!_vSearchBoard) {
            _vSearchBoard = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
            [_vSearchBoard setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:_vSearchBoard];
        }
        
        if (!_vSearchHistory) {
            _vSearchHistory = [[UCSearchHistoryView alloc] initWithFrame:_vSearchBoard.bounds];
            [_vSearchHistory setDelegate:self];
            [_vSearchBoard addSubview:_vSearchHistory];
        }
        
        _vSearchBoard.alpha = 0.0;
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            _vSearchBoard.alpha = 1.0;
        }];
        
        // 刷新数据
        if (textField.text.length > 0)
            [vSearch reloadSearchResultData:textField];
    }
    
    
    return YES;
}

- (BOOL)UCSearchView:(UCSearchView *)vSearch textFieldShouldReturn:(UITextField *)textField
{
    [_vSearch.tvSelect removeFromSuperview];
    
    if(textField.text.length>0){
        NSString *text = textField.text.trim;
        [_vSearchHistory saveHistoryWithNewEntry:text];
        
        UCSearchResultView *vSearchResult = [[UCSearchResultView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds withKeyword:text];
        [[MainViewController sharedVCMain] openView:vSearchResult animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        return YES;
    }
    else{
        
        return NO;
    }
}

- (void)UCSearchView:(UCSearchView *)vSearch textFieldHaveChanged:(UITextField *)textField
{
    [_vSearch viewWithTag:kSearchSubViewsStartTag + 1].hidden = textField.text.length > 0 ? YES : NO;
    
    // 布局列表
    _vSearch.tvSelect.frame = _vSearchBoard.bounds;
    if (textField.text.length > 0) {
        _vSearch.tvSelect.hidden = NO;
        if (![_vSearch.tvSelect isDescendantOfView:_vSearchBoard])
            [_vSearchBoard addSubview:_vSearch.tvSelect];
    }
    else{
        _vSearch.tvSelect.hidden = YES;
        [_vSearch.tvSelect removeFromSuperview];
    }
    
}

/** 关闭搜索 */
- (void)didClickCancelButton:(UCSearchView *)vSearch
{
    // 选车控件页取消搜索按钮
    [UMStatistics event:c_3_6_Selectcar_cancelsearch];
    
    UIImageView *ivSearch = (UIImageView *)[_vSearch viewWithTag:kSearchSubViewsStartTag + 0];
    UILabel *labSearch = (UILabel *)[_vSearch viewWithTag:kSearchSubViewsStartTag + 1];
    // 关闭搜索框
    [_vSearch closeSearchList];
    labSearch.hidden = NO;
    [_tbTop.btnRight setTitle:@"筛选" forState:UIControlStateNormal];
    // 显示底栏
    [[UCMainView sharedMainView] setTabBarHidden:NO animated:NO];
    
    // 清空列表
    [vSearch.naCarNames removeAllObjects];
    [vSearch.tvSelect reloadData];
    
    [UIView animateWithDuration:kAnimateSpeedNormal animations:^{
        // 显示地区按钮
        _tbTop.btnLeft.hidden = NO;
        _tbTop.btnLeft.alpha = 1;
        // 收搜索面板
        [_vSearchHistory setAlpha:0.0];
        [_vSearchBoard setBackgroundColor:[UIColor clearColor]];
        [_vSearchBoard setAlpha:0.0];
        _vSearch.frame = CGRectMake((_tbTop.width - 110) / 2, (_tbTop.height - 30) / 2 + (_tbTop.height - 44) / 2, 110, 30);
        UIImage *iSearch = [UIImage imageAutoNamed:@"search_icon"];
        ivSearch.minX = (_vSearch.width - iSearch.width) / 2 - 20;
        labSearch.minX = (_vSearch.width - labSearch.width) / 2 + 8;
    } completion:^(BOOL finished) {
        [_vSearch.tvSelect removeFromSuperview];
        [_vSearchHistory removeFromSuperview];
        [_vSearchBoard removeAllSubviews];
        [_vSearchBoard removeFromSuperview];
        _vSearchBoard = nil;
        _vSearchHistory = nil;
    }];
    
}

#pragma mark - UCSearchHistoryDelegate
-(void)searchHistoryDidSelectRowWithKeyword:(NSString *)keyword{
    UILabel *labSearch = (UILabel *)[_vSearch viewWithTag:kSearchSubViewsStartTag + 1];
    [labSearch setHidden:YES];
    _vSearch.tfSearch.text = keyword;
    [_vSearch.tfSearch resignFirstResponder];
    UCSearchResultView *vSearchResult = [[UCSearchResultView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds withKeyword:keyword];
    [[MainViewController sharedVCMain] openView:vSearchResult animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)shouldHideKeyboard{
    [_vSearch.tfSearch resignFirstResponder];
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    // 点击统计
    switch (index) {
        case 0: [UMStatistics event:c_3_9_1_buycar_filter_brand];   break;  // 品牌
        case 1: [UMStatistics event:c_3_9_1_buycar_filter_price];   break;  // 价格
        case 2: [UMStatistics event:c_3_9_1_buycar_order];          break;  // 里程
    }
    
    [self cancelFilterBarSelectedState];
    
    // 重复点击
    if (optionBar.lastSelectedItemIndex == index || _tbTop.btnLeft.isSelected) {
        _tbTop.btnLeft.selected = NO;
        [_vFilter closeFilter:NO];
    } else {
        // 隐藏底栏
        [[UCMainView sharedMainView] setTabBarHidden:YES animated:YES];
        
        if (!_vFilter) {
            _vFilter = [[UCFilterView alloc] initWithFrame:CGRectMake(0, _bvToolBar.maxY, self.width, self.height - _bvToolBar.maxY)];
            _vFilter.delegate = self;
        }
        
        // 地区
        if (index == -1) {
            // 城市
            _vFilter.minY = _tbTop.maxY;
            _vFilter.height = self.height - _tbTop.maxY;
            // 设置选中城市
            _tbTop.btnLeft.selected = YES;
        }
        // 品牌 价格 排序
        else {
            _vFilter.minY = _bvToolBar.maxY;
            _vFilter.height = self.height - _bvToolBar.maxY;
            // 设置选中
            ((UIImageView *)[_obFilter viewWithTag:kOptionBarArrowTag + index]).image = [UIImage imageNamed:@"homeview_filter_selected"];
        }
        
        // 筛选实体可能被摇一摇清除, 空的时候重新初始化一个.
        _vFilter.mFilter = self.mFilter ? [self.mFilter copy] : [[UCFilterModel alloc] init];
        _vFilter.strOrderID = [AMCacheManage currentOrder];
        [_vFilter makeViewWithTag:index];
        if (index == -1) {
            // 已经添加先移除
            if (_vFilter.superview)
                [_vFilter removeFromSuperview];
            [self insertSubview:_vFilter aboveSubview:_bvToolBar];
        } else {
            // 过滤重复添加
            if (![_vFilter isDescendantOfView:self])
                [self insertSubview:_vFilter belowSubview:_bvToolBar];
        }
    }
}

#pragma mark - UCCarListViewDelegate
- (void)carListView:(UCCarListView *)vCarList carInfoModel:(UCCarInfoModel *)mCarInfo
{
    // 买车列表单条记录点击
    [UMStatistics event:c_3_1_buycarlistclick];
    
    [self endEditing:YES];
    
    MainViewController *vcMain = [MainViewController sharedVCMain];
    UCCarDetailView *vCarDetail = nil;
    if (vCarList.tag == UCHomeViewCarListStyleHomeList) {
        vCarDetail = [[UCCarDetailView alloc] initTurningDetailViewWithFrame:vcMain.vMain.bounds mCarInfo:mCarInfo];
        // 设置上拉下拉文字
        [vCarDetail setCarInfoModels:_vCarList.mCarLists carAllCount:_vCarList.carListAllCount];
    } else {
        vCarDetail = [[UCCarDetailView alloc] initWithFrame:vcMain.vMain.bounds mCarInfo:mCarInfo];
    }
    
    vCarDetail.mCarLists = _vCarList.mCarLists;
    [vcMain openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - UCWelcomeDelegate
- (void)didCloseWelcomeView:(UCWelcome *)vWelcome
{
    _isFirstLocation = YES;
    // 打开定位
    [self optionBar:_obFilter didSelectAtIndex:-1];
    // 开启定时器
    [[UCMainView sharedMainView] startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustHeadView:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrollDirection = 0;
    _nodeScrollOffsetY = 0;
    _lastScrollOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self adjustHeadView:scrollView];
}

- (void)adjustHeadView:(UIScrollView *)scrollView
{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    
    // 到头不处理
    if (scrollView.contentInset.top > 0 && scrollOffsetY < -scrollView.contentInset.top) {
        return;
    }
    // 到底不处理
    if (scrollOffsetY > scrollView.contentSize.height - scrollView.height) {
        return;
    }
    
    if (![scrollView.superview isKindOfClass:[UCCarListView class]]) {
        return;
    }
    
    // 往上滚动
    if (scrollOffsetY < _lastScrollOffsetY) {
        if (_scrollDirection != 1) {
            _scrollDirection = 1;
            _nodeScrollOffsetY = scrollOffsetY;
        }
        
        if (scrollOffsetY <= 0 || fabs(scrollOffsetY - _nodeScrollOffsetY) > _vHead.height) {
            if (_vHead.minY != 0) {
                UCCarListView *clv = (UCCarListView *)scrollView.superview;
                // 显示头部导航条和工具栏
                [UIView animateWithDuration:kAnimateSpeedFast delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [clv setScrollIndicatorInsets:UIEdgeInsetsMake(_vHead.height, 0, kMainOptionBarHeight, 0)];
                    _vHead.minY = 0;
                } completion:^(BOOL finished) {
                    // 隐藏状态栏背景
                    _vStatusBar.hidden = YES;
                }];
                // 设置车辆列表底部高度
                [clv setFooterViewHeight:kMainOptionBarHeight];
                // 显示底部标签页
                [[UCMainView sharedMainView] setTabBarHidden:NO animated:YES];
            }
        }
    }
    // 往下滚动
    else if (scrollOffsetY > _lastScrollOffsetY) {
        if (_scrollDirection != 2) {
            _scrollDirection = 2;
            _nodeScrollOffsetY = scrollOffsetY;
        }
        
        if (fabs(scrollOffsetY - _nodeScrollOffsetY) > _vHead.height) {
            if (_vHead.maxY != 0) {
                UCCarListView *clv = (UCCarListView *)scrollView.superview;
                // 显示状态栏背景
                _vStatusBar.hidden = NO;
                // 隐藏头部导航条和工具栏
                [UIView animateWithDuration:kAnimateSpeedFast delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [clv setScrollIndicatorInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
                    _vHead.maxY = 0;
                } completion:nil];
                // 设置车辆列表底部高度
                [clv setFooterViewHeight:0];
                // 隐藏底部标签页
                [[UCMainView sharedMainView] setTabBarHidden:YES animated:YES];
            }
        }
    }
    
    _lastScrollOffsetY = scrollOffsetY;
}

#pragma mark - UCFilterViewDelegate
- (void)filterView:(UCFilterView *)filterView filterMode:(UCFilterModel *)mFilter orderID:(NSString *)orderID isValid:(BOOL)isValid;
{
    // 设置显示城市状态
    _tbTop.btnLeft.selected = NO;

    // 取消选中状态
    [self.obFilter cancelSelected];
    [self cancelFilterBarSelectedState];
    // 显示主标签
    [[UCMainView sharedMainView] setTabBarHidden:NO animated:YES];
    UCAreaMode *mArea = [AMCacheManage currentArea];
    
    BOOL isEqualArea = NO;
    BOOL isEqualAreaFiler = NO;
    BOOL isEqualOrder = NO;
    
    if (isValid == NO) {
        isEqualAreaFiler = YES;
        isEqualArea = YES;
        isEqualOrder = YES;
    } else {
        isEqualArea = _mArea == mArea || [_mArea isEqualToArea:mArea];
        isEqualAreaFiler = [_mFilter isEqualToFilter:mFilter];
        isEqualOrder = [[AMCacheManage currentOrder] integerValue] == orderID.integerValue;
    }
    
    if (!isEqualArea) {
        // 更新城市
        [self updateCity:[AMCacheManage currentArea]];
    }
    
    // 刷新首页车辆列表
    if (!isEqualArea || !isEqualAreaFiler || !isEqualOrder) {
        _vCarList.mArea = mArea;
        _vCarList.mFilter = mFilter;
        [AMCacheManage setCurrentOrder:orderID];
        _vCarList.orderby = [AMCacheManage currentOrder];
        [_vCarList refreshCarList];
    }
    
    // 更新筛选条
    if (isValid == YES && (!isEqualAreaFiler || !isEqualOrder)) {
        [self updateFilterBar:mFilter];
    }
}

/** 更新排序 */
- (void)updateOrderBy:(NSString *)order
{
    if (order != self.vCarList.orderby && ![order isEqualToString:self.vCarList.orderby]) {
        // 刷新主页车辆列表数据
        _vCarList.orderby = order;
        [_vCarList refreshCarList];
    }
}

/** 更新城市 */
- (void)updateCity:(UCAreaMode *)mArea
{
    self.mArea = mArea;
    NSString *cityName = @"全国";
    if (self.mArea.cName && self.mArea.cid) {
        cityName = self.mArea.cName;
    } else if (self.mArea.pName && self.mArea.pid)
        cityName = self.mArea.pName;
    else if (self.mArea.areaid)
        cityName = self.mArea.areaName;
    
    if (cityName.length > 5)
        cityName = [NSString stringWithFormat:@"%@…", [cityName substringToIndex:5]];
    
    [_tbTop.btnLeft setTitle:cityName forState:UIControlStateNormal];
}

/** 更新筛选栏 */
- (void)updateFilterBar:(UCFilterModel *)mFilter
{
    self.mFilter = mFilter;
    // 品牌
    UIButton *btnFilterBrand = (UIButton *)[self.obFilter itemViewAtIndex:0];
    NSString *brandName = @"全部品牌";
    if (self.mFilter.specid)
        brandName = self.mFilter.specidText;
    else if (self.mFilter.seriesid)
        brandName = self.mFilter.seriesidText;
    else if (self.mFilter.brandid)
        brandName = self.mFilter.brandidText;
    [btnFilterBrand setTitle:[brandName omitForSize:CGSizeMake(75, btnFilterBrand.height) font:btnFilterBrand.titleLabel.font] forState:UIControlStateNormal];
    // 价格
    UIButton *btnFilterPrice = (UIButton *)[self.obFilter itemViewAtIndex:1];
    [btnFilterPrice setTitle:self.mFilter.priceregion ? self.mFilter.priceregionText : @"价格不限" forState:UIControlStateNormal];
    // 排序
    UIButton *btnOrder = (UIButton *)[self.obFilter itemViewAtIndex:2];
    NSString *strOrderText = @"默认排序";
    for (int i = 0; i < _orderValues.count; i++) {
        NSDictionary *item = [_orderValues objectAtIndex:i];
        if ([[item objectForKey:@"Value"] integerValue] == [[AMCacheManage currentOrder] integerValue]) {
            strOrderText = [item objectForKey:@"Name"];
            break;
        }
    }
    [btnOrder setTitle: strOrderText forState:UIControlStateNormal];
    
    // 文字和箭头间距
    [self setAutoSizeFilterBar];
}

#pragma mark - UCNewFilterViewDelegate
/** 筛选完毕 isChanged：YES时筛选条件有改动，NO时筛选条件无改动 */
-(void)UCNewFilterView:(UCNewFilterView *)vNewFilter isChanged:(BOOL)isChanged filterModelChanged:(UCFilterModel *)mFilter didClickedViewCarListBtnWithCarLists:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount
{
    /** 存储筛选记录 */
    if ([mFilter conditionCount] > 1) {
        BOOL isEqual = NO;
        NSMutableArray *historys = [NSMutableArray arrayWithArray:[AMCacheManage currentHistoryFilter]];
        
        for (int i = 0; i < historys.count; i++) {
            UCFilterModel *item = [historys objectAtIndex:i];
            if ([item isEqualToFilter:mFilter]) {
                isEqual = YES;
                break;
            }
        }
        
        if (![mFilter isNull] && !isEqual) {
            if (historys.count > 0) {
                [historys insertObject:mFilter atIndex:0];
            } else {
                [historys addObject:mFilter];
            }
            [AMCacheManage setCurrentHistoryFilter:historys];
        }
    }
    
    // 刷新列表
    if (isChanged) {
        /** 更新filterView条 */
        [self updateFilterBar:mFilter];
        /** 更新筛选model */
        _vCarList.mFilter = _mFilter = mFilter;
        
        /** 刷新列表 */
        if (mCarLists.count > 0)
            [_vCarList refreshCarListWithCarListModels:mCarLists rowCount:rowCount];
        else
            [_vCarList refreshCarList];
    }
    
    // 关闭页面
    [[MainViewController sharedVCMain] closeView:vNewFilter animateOption:AnimateOptionMoveUp];

}

/** 关注 */
-(void)UCNewFilterView:(UCNewFilterView *)vNewFilter addAttentionWithAreaModel:(UCAreaMode *)mArea filterModel:(UCFilterModel *)mFilter
{
    UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] init];
    [mAtten setAreaValue:mArea];
    [mAtten setFilterValue:mFilter];
    [self addAttentionAPIWithAttenModel:mAtten];
}

#pragma mark - UCFilterHistoryViewDelegate
/** 选择筛选记录，刷新列表 */
-(void)filterHistoryDidSelectModel:(UCFilterModel *)model
{
    // 关闭筛选页面
    [[MainViewController sharedVCMain] closeView:_vNewFilter animateOption:AnimateOptionMoveLeft];
    
    // 刷新列表
    if (![_mFilter isEqualToFilter:model]) {
        _vCarList.mFilter = _mFilter = model;
        [self updateFilterBar:_mFilter];
        [_vCarList refreshCarList];
    }
}

#pragma mark - APIHelper
/** 添加关注 */
-(void)addAttentionAPIWithAttenModel:(UCCarAttenModel *)mAtten
{
    if (!_apiAttention)
        _apiAttention = [[APIHelper alloc] init];
    else
        [_apiAttention cancel];
    
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
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                [[AMToastView toastView] showMessage:mBase.message icon:(mBase.returncode == 0 ? kImageRequestSuccess : kImageRequestError) duration:AMToastDurationNormal];
            }
        }
                
    }];
    
    // 关注
    [_apiAttention addAttentionWithAttenModel:mAtten];
    
}

#pragma mark - guide view
- (void)createGuideView{
    
    _vHint = [[EMHint alloc] init];
    _vHint.hintDelegate = self;
    [_vHint presentModalMessage:nil where:[MainViewController sharedVCMain].vMain.subviews.firstObject];
}

#pragma mark - EMHintDelegate
-(BOOL)hintStateHasDefaultTapGestureRecognizer:(id)hintState{
    return YES;
}

-(BOOL)hintStateShouldAllowTouchPassedThrough:(id)hintState touch:(UITouch *)touch{
    return NO;
}

-(void) hintStateDidClose:(id)hintState{
    [AMCacheManage setConfigHomeGuideStatus:1];
    [AMCacheManage setConfigHomeGuideLastViewVersion:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue]];
}

-(UIView*)hintStateViewForDialog:(id)hintState{
    UIImage *guideImage = [UIImage imageNamed:@"homeView_filter_guide"];
    UIImageView *vGuide = [[UIImageView alloc] initWithImage:guideImage];
    [vGuide setFrame:CGRectMake(self.width - 125, 65, guideImage.width, guideImage.height)];
    return vGuide;
}

-(NSArray*)hintStateRectsToHint:(id)hintState{
    NSValue *value = [NSValue valueWithCGRect:CGRectMake(self.width - 30, 42, 40, 40)];
    return @[value];
}

#pragma mark - dealloc
- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end
