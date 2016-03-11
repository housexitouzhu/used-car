//
//  UCAttentionDetailList.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionDetailList.h"
#import "UCCarInfoCell.h"
#import "APIHelper.h"
#import "UCCarInfoModel.h"
#import "UCMainView.h"
#import "MainViewController.h"
#import "UCCarDetailView.h"
#import "CKRefreshControl.h"
#import "UIImageView+WebCache.h"
#import "AMCacheManage.h"
#import "UCCarAttenModel.h"

#define kLoadViewHeight     40

@interface UCAttentionDetailList ()

@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UIView *vLoadMore;

@property (nonatomic, strong) APIHelper *apiSearchCar;
@property (nonatomic) NSInteger pageIndex;

@property (nonatomic, strong) UIView *bvCarCount;
@property (nonatomic, strong) UILabel *labCarCount; // 加载到的车辆总数
@property (nonatomic, strong) UILabel *labNoData; // 无数据提示

@property (nonatomic, strong) UIImageView *ivBanner;
@property (nonatomic, strong) NSMutableArray *attArray;

@end

@implementation UCAttentionDetailList

- (id)initWithFrame:(CGRect)frame withUCCarAttenModel:(UCCarAttenModel*)mCarAtten AttentionDictionary:(NSMutableDictionary*)dict AttentionArray:(NSMutableArray*)attArray LastUpdate:(NSString*)lastUpdate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _mCarAtten = mCarAtten;
        _lastUpdate = lastUpdate;
        
        _dicReadNew = dict;
        _attArray = attArray;
        
        _mArea = [UCAreaMode new];
        if (_mCarAtten.areaid) {
            _mArea.areaid = [_mCarAtten.areaid stringValue];
            _mArea.areaName = _mCarAtten.areaname;
        }
        if (_mCarAtten.pid) {
            _mArea.pid = [_mCarAtten.pid stringValue];
            _mArea.pName = _mCarAtten.province;
        }
        if (_mCarAtten.cid) {
            _mArea.cid = [_mCarAtten.cid stringValue];
            _mArea.cName = _mCarAtten.city;
        }
        
        _mFilter = [UCFilterModel new];
        [_mFilter convertFromAttentionModel:_mCarAtten];
        _mFilter.dealertype = [NSNumber numberWithInteger:9];
        _mFilter.ispic = @"1";
        
        // 默认可以点击
        _isAllowsSelection = YES;
        // 默认显示浏览痕迹
        _isShowSelectedMark = YES;
        
        // 默认提示语
        _strNoData = @"暂无车辆信息";
        // 是否启用下拉刷新
        _isEnablePullRefresh = YES;
        
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView;
{
    self.backgroundColor = kColorNewBackground;
    self.clipsToBounds = YES;
    
    _mCarLists = [[NSMutableArray alloc] init];
    
    // 列表
    _tvCarList = [[UITableView alloc] initWithFrame:self.bounds];
    _tvCarList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvCarList.dataSource = self;
    _tvCarList.delegate = self;
    _tvCarList.tableFooterView = _vFooter;
    _tvCarList.backgroundColor = kColorNewBackground;
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvCarList];
    _pullRefresh.backgroundColor = kColorClear;
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    
    [_pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvCarList.width, kLoadViewHeight)];
    _vLoadMore.backgroundColor = kColorClear;
    
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vLoadMore.width, kLoadViewHeight)];
    labText.text = @"正在加载更多…";
    labText.textColor = kColorGrey2;
    labText.backgroundColor = kColorClear;
    labText.font = [UIFont systemFontOfSize:15];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    // 菊花
    UIActivityIndicatorView *aivLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aivLoading.hidesWhenStopped = NO;
    aivLoading.center = CGPointMake((self.width - [labText.text sizeWithFont:labText.font].width) / 2 - aivLoading.width, labText.centerY);
    aivLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    aivLoading.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [aivLoading startAnimating];
    
    [_vLoadMore addSubview:labText];
    [_vLoadMore addSubview:aivLoading];
    
    // 无数据提示
    _labNoData = [[UILabel alloc] initWithClearFrame:self.bounds];
    _labNoData.hidden = YES;
    _labNoData.text = _strNoData;
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.lineBreakMode = UILineBreakModeWordWrap;
    _labNoData.numberOfLines = 0;
    
    // 加载到的车辆总数显示
    _bvCarCount = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 36)];
    _bvCarCount.clipsToBounds = YES;
    _bvCarCount.userInteractionEnabled = NO;
    //    _bvCarCount.hidden = YES;
    _labCarCount = [[UILabel alloc] initWithClearFrame:CGRectMake(0, -_bvCarCount.height, _bvCarCount.width, _bvCarCount.height)];
    _labCarCount.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.85];
    _labCarCount.textColor = kColorWhite;
    _labCarCount.font = [UIFont systemFontOfSize:14];
    _labCarCount.textAlignment = NSTextAlignmentCenter;
    [_bvCarCount addSubview:_labCarCount];
    
    [self addSubview:_tvCarList];
    [self addSubview:_labNoData];
    [self addSubview:_bvCarCount];
}

#pragma mark - public Method
- (void)setFooterViewHeight:(CGFloat)height
{
    // 列表垫底视图
    if (!_vFooter)
        _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, height)];
    else
        _vFooter.height = height;
    // 设置加载更多的高度
    _vLoadMore.height = height + kLoadViewHeight;
}

// 加载更多
-(void)loadMore
{
    // 加载更多
    _tvCarList.tableFooterView = _vLoadMore;
    _pageIndex++;
    [self searchCar];
}

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    _tvCarList.scrollIndicatorInsets = scrollIndicatorInsets;
    _pullRefresh.originalTopContentInset = scrollIndicatorInsets.top;
    _bvCarCount.minY = scrollIndicatorInsets.top;
}

- (void)setIsEnablePullRefresh:(BOOL)isEnablePullRefresh {
    _isEnablePullRefresh = isEnablePullRefresh;
    _pullRefresh.enabled = isEnablePullRefresh;
}

#pragma mark - privatev Method
/** 显示提示 */
- (void)showTips:(NSString *)tips
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTips) object:nil];
    
    //    _bvCarCount.hidden = NO;
    _labCarCount.text = tips;
    [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
        _labCarCount.minY = 0;
    }];
    
    [self performSelector:@selector(hideTips) withObject:nil afterDelay:2];
}

- (void)onPull
{
    if (_isEnablePullRefresh) {
        [self refreshCarList:NO];
    }
}

/** 隐藏提示 */
- (void)hideTips
{
    [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
        _labCarCount.maxY = 0;
    } completion:^(BOOL finished) {
        //        _bvCarCount.hidden = YES;
    }];
}

/** 根据数据源刷 */
- (void)refreshCarListWithCarListModels:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount
{
    // 设置是否可选中
    _tvCarList.allowsSelection = _isAllowsSelection;
    _labNoData.hidden = mCarLists.count > 0 ? YES : NO;
    _pageIndex = 1;
    [_mCarLists removeAllObjects];
    [_mCarLists addObjectsFromArray:mCarLists];
    _carListAllCount = rowCount;
    [_tvCarList reloadData];
    
    // 列表滚动到最顶端
    _tvCarList.contentOffset = CGPointMake(0, -_tvCarList.contentInset.top);
    
    [self showTips:[NSString stringWithFormat:@"共找到%d辆车", rowCount]];
}

/** 刷新车辆列表 */
- (void)refreshCarList
{
    [self refreshCarList:YES];
    
}

- (void)refreshCarList:(BOOL)isToTop
{
    // 设置是否可选中
    _tvCarList.allowsSelection = _isAllowsSelection;
    _labNoData.hidden = YES;
    [_apiSearchCar cancel];
    _pageIndex = 1;
    [self searchCar];
    
    // 列表滚动到最顶端
    if (isToTop)
        _tvCarList.contentOffset = CGPointMake(0, -_tvCarList.contentInset.top);
}

//- (void)handleTapActivityZone
//{
//    if (_mActivity) {
//        NSString *url = ((AdlistItemModel *)_mActivity.adlist[0]).url;
//        // 跳转
//        UCActivityView *vActivity = [[UCActivityView alloc] initWithFrame:self.bounds];
//        [vActivity loadWebWithString:url];
//        [[MainViewController sharedVCMain] openView:vActivity animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
//    }
//}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mCarLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"UCCarInfoCell";
    UCCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCCarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    else
        [cell.ivCarPhoto sd_setImageWithURL:nil];
    
    UCCarInfoModel *mCars = [_mCarLists objectAtIndex:indexPath.row];
    [cell makeView:mCars isShowSelect:NO];
    BOOL isNew = mCars.isNew.boolValue;
    if (isNew && ![_attArray containsObject:mCars.carid]) {
        cell.statusLabel.hidden = NO;
    }
    else{
        cell.statusLabel.hidden = YES;
    }
    
    // 是否显示阅读痕迹
    if (_isShowSelectedMark) {
        if([[AMCacheManage currentBuyCarListArray] containsObject:[mCars.carid stringValue]]) {
            cell.labPrice.textColor = kColorGrey3;
            cell.labTitle.textColor = kColorGrey3;
        } else {
            cell.labTitle.textColor = kColorGray1;
            cell.labPrice.textColor = kColorOrange;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  UCCarInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCCarInfoCell *cell = (UCCarInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.labPrice.textColor = kColorGrey3;
    cell.labTitle.textColor = kColorGrey3;
    UCCarInfoModel *mCarInfo = [self.mCarLists objectAtIndex:indexPath.row];
    BOOL isNew = mCarInfo.isNew.boolValue;
    if (isNew && ![_attArray containsObject:mCarInfo.carid]) {
        [_attArray addObject:mCarInfo.carid];
    }
    
    if (_isShowSelectedMark && ![[AMCacheManage currentBuyCarListArray] containsObject:[mCarInfo.carid stringValue]])
        [AMCacheManage addBuyCarListArray:[mCarInfo.carid stringValue]];
    if ([self.delegate respondsToSelector:@selector(carListView:carInfoModel:)]) {
        [self.delegate carListView:self carInfoModel:mCarInfo];
    } else {
        MainViewController *vcMain = [MainViewController sharedVCMain];
        UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:vcMain.vMain.bounds mCarInfo:mCarInfo];
        [vcMain openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    
    [_tvCarList reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一个cell 开始加载更多
    if (indexPath.row == _mCarLists.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (_mCarLists.count % kPageSize == 0) {
            if (tableView.tableFooterView != _vLoadMore) {
                tableView.tableFooterView = _vLoadMore;
                _pageIndex++;
                [self searchCar];
            }
        } else {
            _tvCarList.tableFooterView = _vFooter;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [_scrollDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [_scrollDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [_scrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [_scrollDelegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_scrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [_scrollDelegate scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - APIHelper
- (void)searchCar
{
    if ([_delegate respondsToSelector:@selector(carListViewLoadData:)])
        [_delegate carListViewLoadData:self];
    
    if (!_apiSearchCar)
        _apiSearchCar = [[APIHelper alloc] init];
    else
        [_apiSearchCar cancel];
    
    if (!_isEnablePullRefresh)
        _pullRefresh.enabled = YES;
    [_pullRefresh beginRefreshing];
    
    __weak UCAttentionDetailList *vCarList = self;
    
    // 设置请求完成后回调方法
    [_apiSearchCar setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        [vCarList.pullRefresh endRefreshing];
        if (!vCarList.isEnablePullRefresh)
            vCarList.pullRefresh.enabled = NO;
        
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
            {
                [vCarList showTips:error.domain];
                if ([vCarList.delegate respondsToSelector:@selector(carListViewDidSearched:ConnectionError:)]) {
                    [vCarList.delegate carListViewDidSearched:vCarList ConnectionError:error];
                }
            }
            
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 临时车辆列表
                    NSMutableArray *tmpCarInfos = [NSMutableArray array];
                    for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"carlist"]) {
                        UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithJson:dicCarInfoTemp];
                        [tmpCarInfos addObject:mCarInfo];
                    }
                    // 刷新成功清理缓存
                    if (vCarList.pageIndex == 1) {
                        // 总车数
                        NSInteger rowCount = [[mBase.result objectForKey:@"rowcount"] integerValue];
                        vCarList.carListAllCount = rowCount;
                        
                        if (rowCount > 0){
                            [vCarList showTips:[NSString stringWithFormat:@"共找到%d辆车", rowCount]];
                        }
                        
                        [vCarList.mCarLists removeAllObjects];
                        [vCarList.mCarLists addObjectsFromArray:tmpCarInfos];
                        // 刷新列表
                        [vCarList.tvCarList reloadData];
                        // 滚动到顶
                        vCarList.tvCarList.contentOffset = CGPointMake(0, -vCarList.tvCarList.contentInset.top);
                    }
                    // 加载更多
                    else {
                        NSUInteger originalCount = vCarList.mCarLists.count;
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (int i = 0; i < tmpCarInfos.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                        [vCarList.mCarLists addObjectsFromArray:tmpCarInfos];
                        [vCarList.tvCarList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    }
                    // 获取数据成功
                    if ([vCarList.delegate respondsToSelector:@selector(carListViewLoadDataSuccess:)])
                        [vCarList.delegate carListViewLoadDataSuccess:vCarList];
                } else {
                    // 显示错误提示
                    [vCarList showTips:mBase.message];
                }
            }
        }
        // 垫脚
        vCarList.tvCarList.tableFooterView = vCarList.vFooter;
        // 是否显示无数据提示
        vCarList.labNoData.text = vCarList.strNoData;
        vCarList.labNoData.hidden = vCarList.mCarLists.count != 0;
        if (vCarList.mCarLists.count == 0)
            vCarList.carListAllCount = 0;
        if ([vCarList.delegate respondsToSelector:@selector(carListViewDidSearched:)]) {
            [vCarList.delegate carListViewDidSearched:vCarList];
        }
    }];
    
    // 搜索接口
    [_apiSearchCar searchCarWithKeyword:nil pagesize:[NSNumber numberWithInt:kPageSize] pageindex:[NSNumber numberWithInteger:vCarList.pageIndex] areaid:self.mArea.areaid pid:self.mArea.pid cid:self.mArea.cid dealerid:nil filter:self.mFilter orderby:self.orderby lastUpdate:_lastUpdate];
}

#pragma mark - setframe
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_tvCarList setFrame:self.bounds];
    [_labNoData setFrame:self.bounds];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiSearchCar cancel];
}

@end
