//
//  UCDealerShareHistory.m
//  UsedCar
//
//  Created by 张鑫 on 14-10-14.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerShareHistory.h"
#import "UCTopBar.h"
#import "ShareHistoryViewStoreCell.h"
#import "ShareHistoryViewCarCell.h"
#import "APIHelper.h"
#import "CKRefreshControl.h"
#import "AMToastView.h"
#import "UCShareHistoryModel.h"
#import "UCShareCarListView.h"
#import "AMCacheManage.h"

#define kLoadViewHeight     40
#define kHistoryPageSize    30

@interface UCDealerShareHistory()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITableView *tvHistory;
@property (nonatomic, strong) APIHelper *apiShareHistories;
@property (nonatomic, strong) UIView *vTimeLine;

@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UILabel *labNoData; // 无数据提示
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, strong) NSMutableArray *mShareHistories;


@end

@implementation UCDealerShareHistory


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMSAgent postEvent:buiness_share_history_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];
        // Initialization code
        _mShareHistories = [[NSMutableArray alloc] init];

        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // tableview
    _tvHistory = [self creatHistoryView:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    
    // 时间线
    _vTimeLine = [[UIView alloc] initLineWithFrame:CGRectMake(11, _tbTop.maxY, kLinePixel, self.height - _tbTop.maxY) color:kColorNewLine];
    
    [self addSubview:_vTimeLine];
    [self addSubview:_tbTop];
    [self addSubview:_tvHistory];
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvHistory];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    
    [_pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvHistory.width, kLoadViewHeight)];
    [_vLoadMore setBackgroundColor:[UIColor clearColor]];
    
    _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvHistory.width, 20)];
    [_vFooter setBackgroundColor:[UIColor clearColor]];
    
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vLoadMore.width, kLoadViewHeight)];
    labText.text = @"正在加载更多…";
    labText.textColor = kColorGrey2;
    labText.font = [UIFont systemFontOfSize:15];
    labText.backgroundColor = [UIColor clearColor];
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
    _labNoData.text = @"没有查到相关的结果";
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.lineBreakMode = UILineBreakModeWordWrap;
    _labNoData.numberOfLines = 0;
    _labNoData.backgroundColor = kColorClear;
    
    [self addSubview:_labNoData];
    
    [self refreshCarList];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    
    // 标题
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnTitle setTitle:@"分享历史记录" forState:UIControlStateNormal];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
}

- (UITableView *)creatHistoryView:(CGRect)frame
{
    _tvHistory = [[UITableView alloc] initWithFrame:frame];
    _tvHistory.backgroundColor = kColorClear;
    [_tvHistory setDelegate:self];
    [_tvHistory setDataSource:self];
    [_tvHistory setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    return _tvHistory;
}

#pragma mark - Public Method

#pragma mark - private Method
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

- (void)onPull
{
    [self refreshCarList];
}

- (void)refreshCarList
{
    // 设置是否可选中
    _labNoData.hidden = YES;
    [_apiShareHistories cancel];
    _pageIndex = 1;
    [self getHistoriesList];
    
}

// 加载更多
-(void)loadMore
{
    // 加载更多
    _tvHistory.tableFooterView = _vLoadMore;
    _pageIndex++;
    [self getHistoriesList];
}

#pragma mark - System Delegate

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _mShareHistories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UCShareHistoryModel *mShare = [_mShareHistories objectAtIndex:indexPath.row];
    UITableViewCell *myCell = nil;
    
    // 商铺
    if (mShare.type.integerValue == 10) {
        static NSString *identifier1 = @"ShareHistoryViewStoreCell";

        ShareHistoryViewStoreCell *cell = (ShareHistoryViewStoreCell*)[tableView dequeueReusableCellWithIdentifier:identifier1];
        
        if (!cell) {
            cell = [[ShareHistoryViewStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1 cellWidth:tableView.width];
        }
        
        [cell makeViewWithModel:mShare];
        
        myCell = cell;
    }
    // 车源
    else if (mShare.type.integerValue == 20){
        static NSString *identifier2 = @"ShareHistoryViewCarCell";

        ShareHistoryViewCarCell *cell = (ShareHistoryViewCarCell*)[tableView dequeueReusableCellWithIdentifier:identifier2];
        
        if (!cell) {
            cell = [[ShareHistoryViewCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2 cellWidth:tableView.width];
        }
        
        [cell makeViewWithModel:mShare];
        
        myCell = cell;
    }
    
    return myCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 105;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一个cell 开始加载更多
    if (indexPath.row == _mShareHistories.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (_mShareHistories.count % kHistoryPageSize == 0) {
            if (tableView.tableFooterView != _vLoadMore) {
                tableView.tableFooterView = _vLoadMore;
                _pageIndex++;
                [self getHistoriesList];
            }
        } else {
            _tvHistory.tableFooterView = _vFooter;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UCShareHistoryModel *mShare = [_mShareHistories objectAtIndex:indexPath.row];
    
    if (mShare.type.integerValue == 20) {
        UCShareCarListView *vShareList = [[UCShareCarListView alloc] initWithFrame:self.bounds shareCarModel:mShare];
        [[MainViewController sharedVCMain] openView:vShareList animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
}

#pragma mark - Custom Delegate

#pragma mark - APIHelper
- (void)getHistoriesList
{
    
    if (!_apiShareHistories)
        _apiShareHistories = [[APIHelper alloc] init];
    else
        [_apiShareHistories cancel];
    
    [_pullRefresh beginRefreshing];
    
    __weak UCDealerShareHistory *vShareHistories = self;
    
    // 设置请求完成后回调方法
    [_apiShareHistories setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        [vShareHistories.pullRefresh endRefreshing];
        
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [UMStatistics event:pv_4_1_buiness_share_history];
                    // 临时车辆列表
                    NSMutableArray *tmpShare = [NSMutableArray array];
                    for (NSDictionary *dicShareTemp in [mBase.result objectForKey:@"sharelist"]) {
                        UCShareHistoryModel *mShare = [[UCShareHistoryModel alloc] initWithJson:dicShareTemp];
                        [tmpShare addObject:mShare];
                    }
                    // 刷新成功清理缓存
                    if (vShareHistories.pageIndex == 1) {
                        [vShareHistories.mShareHistories removeAllObjects];
                        [vShareHistories.mShareHistories addObjectsFromArray:tmpShare];
                        // 刷新列表
                        [vShareHistories.tvHistory reloadData];
                        // 滚动到顶
                        vShareHistories.tvHistory.contentOffset = CGPointMake(0, -vShareHistories.tvHistory.contentInset.top);
                    }
                    // 加载更多
                    else {
                        NSUInteger originalCount = vShareHistories.mShareHistories.count;
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (int i = 0; i < tmpShare.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                        [vShareHistories.mShareHistories addObjectsFromArray:tmpShare];
                        [vShareHistories.tvHistory insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    }
                } else {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
            }
        }
        //垫脚
        vShareHistories.tvHistory.tableFooterView = vShareHistories.vFooter;
        // 是否显示无数据提示
        vShareHistories.labNoData.hidden = vShareHistories.mShareHistories.count != 0;
        vShareHistories.vTimeLine.hidden = !vShareHistories.labNoData.hidden;
    }];
    
    [_apiShareHistories getShareHistoriesWithPageIndex:vShareHistories.pageIndex size:kHistoryPageSize];
}


#pragma mark - delloc
-(void)dealloc
{
    AMLog(@"\ndealloc...:%@\n", NSStringFromClass([self class]));
}

@end
