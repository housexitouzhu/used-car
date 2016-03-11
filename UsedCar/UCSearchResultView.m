//
//  UCSearchResultView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSearchResultView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UCCarListView.h"
#import "AMBlurView.h"
#import "UIImage+Util.h"
#import "UCSearchResultHeaderView.h"
#import "UCAreaMode.h"
#import "NSString+Util.h"


@interface UCSearchResultView ()
<UCCarListViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *vStatusBar;
@property (nonatomic, strong) AMBlurView *bvToolBar;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCSearchResultHeaderView *vResultHeader;
@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic, strong) UCNewFilterView *vNewFilter;
@property (nonatomic, strong) UCOrderView *vOrder;

@property (nonatomic, strong) UCAreaMode *mArea;
@property (nonatomic, strong) UCFilterModel *mFilter;

@property (nonatomic, strong) NSArray *orderValues;
@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, assign) NSInteger resultCount;

@end

@implementation UCSearchResultView

- (id)initWithFrame:(CGRect)frame withKeyword:(NSString*)keyWord;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.keyWord = keyWord;
        self.mFilter = [[UCFilterModel alloc] init];
        [self initView];
    }
    return self;
}

- (void)initView{
    
    [UMStatistics event:pv_3_8_buycar_searchresults];
    
    self.clipsToBounds = YES;
    self.backgroundColor = kColorWhite;
    
    // 状态栏
    _vStatusBar = [self creatStatusBarView:CGRectMake(0, 0, self.width, 20)];
    [self addSubview:_vStatusBar];
    // 头视图(导航)
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    [self createToolBar];
    [self createResultHeader];
    [_bvToolBar setHidden:YES];
    [_vResultHeader setHidden:YES];
    
    _vCarList = [self creatCarListView:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
    [_vCarList refreshCarList];
    [self addSubview:_vCarList];
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
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnTitle setTitle:@"搜索结果" forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    
    [_tbTop.btnRight setTitle:@"筛选" forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorNewGray2 forState:UIControlStateDisabled];
    [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    return _tbTop;
}
/** 工具栏 */
-(void)createToolBar{
    // 工具栏
    _bvToolBar = [[AMBlurView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    _bvToolBar.clipsToBounds = YES;
    _bvToolBar.isEnableBlur = NO;
    
    // 筛选栏
    _vOrder = [[UCOrderView alloc] initWithFrame:CGRectMake(0, 0, _bvToolBar.width, kTopOptionHeight)];
    _vOrder.delegate = self;
    
    [_bvToolBar addSubview:_vOrder];
    [self addSubview:_bvToolBar];
}

-(void)createResultHeader{
    _vResultHeader = [[UCSearchResultHeaderView alloc] initWithFrame:CGRectMake(0, _bvToolBar.maxY, self.width, 20)];
    [self setResultHeaderTitle];
    [self addSubview:_vResultHeader];
}


/** 列表 */
- (UCCarListView *)creatCarListView:(CGRect)frame
{
    // 车辆列表
    _vCarList = [[UCCarListView alloc] initWithFrame:frame isForSearchResult:YES];
    _vCarList.mArea = self.mArea;
    _vCarList.keyword = self.keyWord;
    _vCarList.orderby = @"0";
    _vCarList.delegate = self;
    _vCarList.scrollDelegate = self;
    [_vCarList enableActivityZone:NO];
    
    return _vCarList;
}

/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (![OMG isValidClick:kAnimateSpeedNormal])
        return;
    
    switch (btn.tag) {
        case UCTopBarButtonLeft:
        {
            [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
        }
            break;
        case UCTopBarButtonRight:
        {
            _vNewFilter = [[UCNewFilterView alloc] initWithFrame:self.bounds mFilter:_mFilter rowCount:_vCarList.carListAllCount orderby:_vCarList.orderby keyWords:_keyWord];
            _vNewFilter.delegate = self;
            [[MainViewController sharedVCMain] openView:_vNewFilter animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 设置 result Header
- (void)setResultHeaderTitle{
    self.mArea = [AMCacheManage currentArea];
    NSString *areaStr = @"";
    if (self.mArea.cName){
        areaStr = self.mArea.cName;
    }
    else if (self.mArea.pName){
        areaStr = self.mArea.pName;
    }
    else if(self.mArea.areaName){
        areaStr = self.mArea.areaName;
    }
    else{
        areaStr = @"全国";
    }
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", [areaStr omitForSize:CGSizeMake(self.width * 7/32, self.vResultHeader.titleLabel.height) font:self.vResultHeader.titleLabel.font], [self.keyWord omitForSize:CGSizeMake(self.width * 7/32, self.vResultHeader.titleLabel.height) font:self.vResultHeader.titleLabel.font]];
    [self.vResultHeader setTitleStr:title];
    
    [self.vResultHeader setResultCount:self.resultCount];
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    // 地区
    if (index == -1) {
        // 重复点击
        if (optionBar.lastSelectedItemIndex == index || _tbTop.btnLeft.isSelected) {
            
        } else {
            // 设置三角高亮
            UCOptionBarItem *item = [optionBar itemAtIndex:index];
            [(UIImageView *)item.rightView setHighlighted:YES];
        }
        
    }
}

#pragma mark - UCOrderViewDelegate
-(void)orderView:(UCOrderView *)vOrder didSelectedIndex:(NSInteger)index
{
    NSString *order = [NSString stringWithFormat:@"%d", index];
    if (order != self.vCarList.orderby && ![order isEqualToString:self.vCarList.orderby]) {
        // 刷新主页车辆列表数据
        _vCarList.orderby = order;
        [_vCarList refreshCarList];
    }
}

#pragma mark - UCCarListViewDelegate
-(void)carListViewLoadDataSuccess:(UCCarListView *)vCarList
{
    
    // 刷新总数
    self.resultCount = vCarList.carListAllCount;
    [self setResultHeaderTitle];
}

-(void)carListViewDidSearched:(UCCarListView *)vCarList{
    [self hideToolBarAndHeaderWithRowCount:vCarList.carListAllCount];
}

#pragma mark - UCNewFilterViewDelegate
/** 筛选完毕 */
-(void)UCNewFilterView:(UCNewFilterView *)vNewFilter isChanged:(BOOL)isChanged filterModelChanged:(UCFilterModel *)mFilter didClickedViewCarListBtnWithCarLists:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount
{
    if (isChanged) {
        
        // 更新筛选model
        _vCarList.mFilter = _mFilter = mFilter;
        
        if (mCarLists.count > 0) {
            
            [self hideToolBarAndHeaderWithRowCount:mCarLists.count];
            
            // 刷新列表
            [_vCarList refreshCarListWithCarListModels:mCarLists rowCount:rowCount];
            
            // 更新顶栏数
            self.resultCount = _vCarList.carListAllCount;
            [self setResultHeaderTitle];
        }
        else{
            [_vCarList refreshCarList];
        }
        
    }
    
    // 关闭页面
    [[MainViewController sharedVCMain] closeView:vNewFilter animateOption:AnimateOptionMoveUp];
}

#pragma mark - UCFilterHistoryViewDelegate
/** 选择筛选记录，刷新列表 */
-(void)filterHistoryDidSelectModel:(UCFilterModel *)model
{
    // 关闭筛选页面
    [[MainViewController sharedVCMain] closeView:_vNewFilter animateOption:AnimateOptionMoveLeft];

    // 刷新列表
    _vCarList.mFilter = _mFilter = model;
    [_vCarList refreshCarList];
    
    // 更新顶栏数
    self.resultCount = _vCarList.carListAllCount;
    [self setResultHeaderTitle];

}

#pragma mark - 判断 count 设置 bar & header 的显隐
-(void)hideToolBarAndHeaderWithRowCount:(NSInteger)count{
    if (count > 0) {
        [_bvToolBar setHidden:NO];
        [_vResultHeader setHidden:NO];
        _vCarList.isEnablePullRefresh = YES;
        [_vCarList setFrame:CGRectMake(0, _vResultHeader.maxY, self.width, self.height - _vResultHeader.maxY)];
        [_vCarList.tvCarList setFrame:_vCarList.bounds];
    }
    else{
        [_bvToolBar setHidden:YES];
        [_vResultHeader setHidden:YES];
        _vCarList.isEnablePullRefresh = NO;
        [_vCarList setFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
        [_vCarList.tvCarList setFrame:_vCarList.bounds];
    }
}


@end
