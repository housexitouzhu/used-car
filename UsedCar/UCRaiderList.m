//
//  UCRaiderList.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRaiderList.h"
#import "UCRaiderCell.h"
#import "CKRefreshControl.h"
#import "UCCarDetailView.h"
#import "AMCacheManage.h"
#import "UCCarDetailInfoModel.h"
#import "UCCarInfoModel.h"
#import "APIHelper.h"
#import "UCMainView.h"
#import "UCRaiderModel.h"
#import "UCRaiderDetailView.h"

#define kListPageSize       30
#define kMoreViewHeight     80
#define kLoadViewHeight     40
#define kFooterViewHeight   40
#define UCRaideCellHeight   101.5
#define UCLocalCellHeight   82

@interface UCRaiderList ()

@property (nonatomic, strong) NSMutableArray *mDataApi;
@property (nonatomic, strong) NSMutableArray *mDataLocal;

@property (nonatomic, strong) UITableView *tvRaiList;
@property (nonatomic, strong) UILabel *labNoData;

@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UIView *vLoadMore;

@property (nonatomic, strong) APIHelper *apiCommonSense;
@property (nonatomic) NSInteger pageIndex;

@end

@implementation UCRaiderList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mDataApi = [NSMutableArray array];
        _mDataLocal = [NSMutableArray array];
        [self initView];
    }
    return self;
}

- (void)initLocalData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LocalHTML" ofType:@"plist"];
    NSDictionary *values = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *localHtmls = values[@"LocalHTML"];
    for (NSDictionary *dic in localHtmls) {
        [_mDataLocal addObject:[[UCRaiderModel alloc] initWithJson:dic]];
    }
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 列表垫底视图
    _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kFooterViewHeight)];
    // 列表
    _tvRaiList = [[UITableView alloc] initWithFrame:self.bounds];
    _tvRaiList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvRaiList.dataSource = self;
    _tvRaiList.delegate = self;
    _tvRaiList.tableFooterView = _vFooter;
    _tvRaiList.scrollIndicatorInsets = UIEdgeInsetsMake(kTopOptionHeight, 0, kMainOptionBarHeight, 0);
    _tvRaiList.contentInset = UIEdgeInsetsMake(kTopOptionHeight, 0, 0, 0);
    _tvRaiList.backgroundColor = kColorNewBackground;
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvRaiList.width, kMoreViewHeight)];
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vLoadMore.width, kLoadViewHeight)];
    labText.text = @"正在加载更多…";
    labText.textColor = kColorGrey2;
    labText.font = [UIFont systemFontOfSize:15];
    labText.textAlignment = NSTextAlignmentCenter;
    
    // 菊花
    UIActivityIndicatorView *aivLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aivLoading.hidesWhenStopped = NO;
    aivLoading.center = CGPointMake((self.width - [labText.text sizeWithFont:labText.font].width) / 2 - aivLoading.width, labText.centerY);
    aivLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [aivLoading startAnimating];
    
    [_vLoadMore addSubview:labText];
    [_vLoadMore addSubview:aivLoading];

    // 无数据提示
    _labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height-44-50)];
    _labNoData.hidden = YES;
    _labNoData.text = @"暂无攻略信息";
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.backgroundColor = kColorClear;
    [self initLocalData];
    [self addSubview:_tvRaiList];
    [self addSubview:_labNoData];
}

#pragma mark - Publick Method
- (void)refreshData
{
    if (_isLocal) {
        
        _pullRefresh.hidden = YES;
        if ([_mDataLocal count] == 0)
            [self initLocalData];
        // 是否显示无数据提示
        _labNoData.hidden = _mDataLocal.count != 0;
        [_pullRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0];

    } else {
        if (!_pullRefresh) {
            _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvRaiList];
            _pullRefresh.titlePulling = @"下拉即可刷新";
            _pullRefresh.titleReady = @"松开立即刷新";
            _pullRefresh.titleRefreshing = @"正在加载中…";
            [_pullRefresh addTarget:self action:@selector(refreshDatas) forControlEvents:UIControlEventValueChanged];
            _pullRefresh.hidden = NO;

        }
        [self refreshDatas];
    }
    _labNoData.hidden = YES;
}

#pragma mark - private Method
/** 刷新数据 */
- (void)refreshDatas
{
    [_apiCommonSense cancel];
    _pageIndex = 1;
    [self getCommonSense];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isLocal)
         return _mDataLocal.count;
    else
         return _mDataApi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"CELL";
    UCRaiderCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCRaiderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    
    if (_isLocal)
        [cell makeView:[_mDataLocal objectAtIndex:indexPath.row] isLocal:_isLocal];
    else
        [cell makeView:[_mDataApi objectAtIndex:indexPath.row] isLocal:_isLocal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isLocal)
        return UCLocalCellHeight;
    else
        return UCRaideCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCRaiderDetailView *guessLike = [[UCRaiderDetailView alloc] initWithFrame:self.bounds];
    
    if (_isLocal) {
        
        UCRaiderModel *mRaider = [_mDataLocal objectAtIndex:indexPath.row];
        
        NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"LOCALHTML.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

        NSString *path = [[bundle pathForResource:mRaider.articletitle ofType:@"html"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:path];
        [guessLike openLoadLocalHtml:url];
        guessLike.TopTitle= @"买车必看";
    } else {
        UCRaiderModel *mRaider = _mDataApi[indexPath.row];
        guessLike.indexPathRow = indexPath.row;
        [guessLike openContent:mRaider.articleid];
        guessLike.TopTitle = @"购车常识";
    }
    
    [[MainViewController sharedVCMain] openView:guessLike animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLocal) {
        // 最后一个cell 开始加载更多
        if (indexPath.row == _mDataApi.count - 1) {
            // 满页情况下才有下一页 & 没有正在加载更多
            if (_mDataApi.count % kListPageSize == 0) {
                if (tableView.tableFooterView != _vLoadMore) {
                    tableView.tableFooterView = _vLoadMore;
                    _pageIndex++;
                    [self getCommonSense];
                }
            } else {
                _tvRaiList.tableFooterView = _vFooter;
            }
        }
    }
}

#pragma mark - APIHelper
- (void)getCommonSense
{
    [UMStatistics event:pv_3_1_buycarmustseeknowledge];
    [UMSAgent postEvent:mustseeknowledge_pv page_name:NSStringFromClass(_vRaider.class)];
    
    if (!_apiCommonSense)
        _apiCommonSense = [[APIHelper alloc] init];
    else
        [_apiCommonSense cancel];
    [_pullRefresh beginRefreshing];
    
    __weak UCRaiderList *vDataList = self;
      // 设置请求完成后回调方法
    [_apiCommonSense setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 非取消请求错误
            if (error.code != ConnectionStatusCancel) {
                [vDataList.pullRefresh endRefreshing];
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        [vDataList.pullRefresh endRefreshing];
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 临时列表
                    NSMutableArray *tmpCarInfos = [NSMutableArray array];
                    for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"articlelist"]) {
                        UCRaiderModel *mCarInfo = [[UCRaiderModel alloc] initWithJson:dicCarInfoTemp];
                        [tmpCarInfos addObject:mCarInfo];
                    }
                    // 刷新成功清理缓存
                    if (vDataList.pageIndex == 1) {
                        [vDataList.mDataApi removeAllObjects];
                        [vDataList.mDataApi addObjectsFromArray:tmpCarInfos];
                        //刷新列表
                        [vDataList.tvRaiList reloadData];
                    }
                    // 加载更多
                    else {
                        NSUInteger originalCount = vDataList.mDataApi.count;
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (int i = 0; i < tmpCarInfos.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                        [vDataList.mDataApi addObjectsFromArray:tmpCarInfos];
                        [vDataList.tvRaiList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            }
        }
        vDataList.tvRaiList.tableFooterView = vDataList.vFooter;
        vDataList.labNoData.hidden = vDataList.mDataApi.count != 0;
    }];
    
    [_apiCommonSense buyCarMustLook:[NSNumber numberWithInt:30] pagesize:[NSNumber numberWithInt:kListPageSize] pageindex:[NSNumber numberWithInteger:vDataList.pageIndex]];
}

@end
