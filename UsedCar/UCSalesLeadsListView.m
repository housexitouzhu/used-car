//
//  UCSaleLeadList.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSalesLeadsListView.h"
#import "CKRefreshControl.h"
#import "UCSalesLeadsCell.h"
#import "UCSalesLeadsDetailView.h"
#import "UCSalesLeadsModel.h"
#import "APIHelper.h"

#define kFooterViewHeight   20
#define kMoreViewHeight     40
#define kLoadViewHeight     40
#define kListPageSize       30
#define kCellHeight         50

@interface UCSalesLeadsListView ()

@property (nonatomic, strong) APIHelper *apiAvailable;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) UILabel *labNoData;
@property (nonatomic) NSInteger pageIndex;

@end

@implementation UCSalesLeadsListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _items = [NSMutableArray array];
        [self initView];
    }
    return self;
}

#pragma mark - initVIew
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    // 列表垫底视图
    _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kFooterViewHeight)];

    // 列表
    _tvSaleLeadList = [[UITableView alloc] initWithFrame:self.bounds];
    _tvSaleLeadList.backgroundColor = [UIColor clearColor];
    _tvSaleLeadList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvSaleLeadList.dataSource = self;
    _tvSaleLeadList.delegate = self;
    _tvSaleLeadList.tableFooterView = _vFooter;
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvSaleLeadList];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    [_pullRefresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvSaleLeadList.width, kMoreViewHeight)];
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
    _labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height - 44 - 50)];
    _labNoData.hidden = YES;
    _labNoData.text = @"暂无信息";
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.backgroundColor = kColorNewBackground;

    [self addSubview:_tvSaleLeadList];
    [self addSubview:_labNoData];
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

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    _tvSaleLeadList.scrollIndicatorInsets = scrollIndicatorInsets;
    _pullRefresh.originalTopContentInset = scrollIndicatorInsets.top;
}

/** 刷新数据 */
- (void)refreshData
{
    _labNoData.hidden = YES;
    [_apiAvailable cancel];
    _pageIndex = 1;
    [self getAvailable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"cell";
    UCSalesLeadsCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCSalesLeadsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    
    UCSalesLeadsModel *mSaleLead = [_items objectAtIndex:indexPath.row];
    
    [cell makeView:mSaleLead markReads:_markReads];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCSalesLeadsCell *cell = (UCSalesLeadsCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.labName.textColor = kColorGrey3;
    cell.labCount.textColor = kColorGrey3;
    cell.labPhone.textColor = kColorGrey3;
    
    UCSalesLeadsModel *mSaleLead = [_items objectAtIndex:indexPath.row];
    
    if (![_markReads containsObject:mSaleLead.mobile])
        [_markReads addObject:mSaleLead.mobile];
    
    if ([_delegate respondsToSelector:@selector(saleLeadList:saleLeadModel:)]) {
        [_delegate saleLeadList:self saleLeadModel:mSaleLead];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
        // 最后一个cell 开始加载更多
        if (indexPath.row == _items.count - 1) {
            // 满页情况下才有下一页 & 没有正在加载更多
            if (_items.count % kListPageSize == 0) {
                if (tableView.tableFooterView != _vLoadMore) {
                    tableView.tableFooterView = _vLoadMore;
                    _pageIndex++;
                   
                    [self getAvailable];
                }
            } else {
                _tvSaleLeadList.tableFooterView = _vFooter;
            }
        }
}

#pragma mark - APIHelper
- (void)getAvailable
{
    if (!_apiAvailable)
        _apiAvailable = [[APIHelper alloc] init];
    else
        [_apiAvailable cancel];
    [_pullRefresh beginRefreshing];
    
    __weak UCSalesLeadsListView *vSaleLeadList = self;
    // 设置请求完成后回调方法
    [_apiAvailable setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        [vSaleLeadList.pullRefresh endRefreshing];
        if (error) {
            // 非取消请求错误
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        [vSaleLeadList.pullRefresh endRefreshing];

        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    // 获取成功
                    if ([vSaleLeadList.delegate respondsToSelector:@selector(UCSalesLeadsListDidSuccessed:)])
                        [vSaleLeadList.delegate UCSalesLeadsListDidSuccessed:vSaleLeadList];
                    
                    // 临时列表
                    NSMutableArray *tmpCarInfos = [NSMutableArray array];
                    for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"slist"]) {
                        UCSalesLeadsModel *mSaleLead = [[UCSalesLeadsModel alloc] initWithJson:dicCarInfoTemp];
                        [tmpCarInfos addObject:mSaleLead];
                    }
                    // 刷新成功清理缓存
                    if (vSaleLeadList.pageIndex == 1) {
                        [vSaleLeadList.items removeAllObjects];
                        [vSaleLeadList.items addObjectsFromArray:tmpCarInfos];
                        //刷新列表
                        [vSaleLeadList.tvSaleLeadList reloadData];
                    }
                    // 加载更多
                    else {
                        NSUInteger originalCount = vSaleLeadList.items.count;
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (int i = 0; i < tmpCarInfos.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                        [vSaleLeadList.items addObjectsFromArray:tmpCarInfos];
                        [vSaleLeadList.tvSaleLeadList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            }
        }
        vSaleLeadList.tvSaleLeadList.tableFooterView = vSaleLeadList.vFooter;
        vSaleLeadList.labNoData.hidden = vSaleLeadList.items.count != 0;
    }];
    
    [_apiAvailable getSalesLeadsListWithListstate:_listState pageIndex:_pageIndex pageSize:kListPageSize];
}

@end
