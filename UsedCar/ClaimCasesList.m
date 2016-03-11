//
//  ClaimCasesList.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-10.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "ClaimCasesList.h"
#import "ClaimCaseCell.h"
#import "APIHelper.h"
#import "CKRefreshControl.h"
#import "AMCacheManage.h"
#import "UCMainView.h"

#define kListPageSize       30
#define kLoadViewHeight     40

@interface ClaimCasesList ()
{
    NSInteger pageIndex;
}

@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) APIHelper *apiUpdateNew;
@property (nonatomic, strong) NSMutableArray *arrOnGoing;
@property (nonatomic, strong) NSMutableArray *arrFinished;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation ClaimCasesList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _arrOnGoing = [[NSMutableArray alloc] init];
        _arrFinished = [[NSMutableArray alloc] init];
        
        pageIndex = 1;
        _totalCount = 0;
        
        self.backgroundColor = kColorNewBackground;
        
        _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, kLoadViewHeight)];
        [_vFooter setBackgroundColor:[UIColor clearColor]];
        
        _hintLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_hintLabel setNumberOfLines:1];
        [_hintLabel setFont:kFontLarge];
        [_hintLabel setTextColor:kColorNewGray2];
        [_hintLabel setText:@"暂无投诉记录"];
        [_hintLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_hintLabel];
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:kColorClear];
        _tableView.tableFooterView = _vFooter;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
        
        
        _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tableView];
        _pullRefresh.titlePulling = @"下拉即可刷新";
        _pullRefresh.titleReady = @"松开立即刷新";
        _pullRefresh.titleRefreshing = @"正在加载中…";
        _pullRefresh.backgroundColor = [UIColor clearColor];
        [_pullRefresh addTarget:self action:@selector(PullToRefresh) forControlEvents:UIControlEventValueChanged];
        
        
        // 加载更多
        _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, kLoadViewHeight)];
        [_vLoadMore setBackgroundColor:[UIColor clearColor]];
        
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
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _tableView.frame = frame;
}


#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClaimRecordItem *itemModel = self.claimListType == ClaimListTypeOnGoing ? [self.arrOnGoing objectAtIndex:indexPath.row] : [self.arrFinished objectAtIndex:indexPath.row];
    
    if (itemModel.isnew.boolValue){
        [self updateReadNewForCarID:itemModel.carid.integerValue];
        ClaimCaseCell *cell = (ClaimCaseCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell setIsNewReaded:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(ClaimCasesList:didSelectItem:)])
        [self.delegate ClaimCasesList:self didSelectItem:itemModel];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CaseCell";
    ClaimCaseCell *cell = (ClaimCaseCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[ClaimCaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
    }
    
    ClaimRecordItem *itemModel = self.claimListType == ClaimListTypeOnGoing ?
                                [self.arrOnGoing objectAtIndex:indexPath.row] : [self.arrFinished objectAtIndex:indexPath.row];
    
    [cell makeViewWithModel:itemModel];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.claimListType == ClaimListTypeOnGoing){
        return self.arrOnGoing.count;
    }
    else{
        return self.arrFinished.count;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrTemp = self.claimListType == ClaimListTypeOnGoing ? self.arrOnGoing : self.arrFinished;
    
    // 最后一个cell 开始加载更多
    if (indexPath.row == arrTemp.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (arrTemp.count % kListPageSize == 0) {
            if (tableView.tableFooterView != _vLoadMore) {
                tableView.tableFooterView = _vLoadMore;
                if (arrTemp.count < _totalCount) {
                    pageIndex++;
                    [self getClaimListByType:_claimListType isRefreshing:NO];
                }
                else{
                    _vFooter.height = 0;
                    tableView.tableFooterView = _vFooter;
                }
            }
        } else {
            _vFooter.height = kLoadViewHeight;
            _tableView.tableFooterView = _vFooter;
        }
    }
}

#pragma mark - public

- (void)setClaimListType:(ClaimListType)claimListType{
    _claimListType = claimListType;
    pageIndex = 1;
    [_pullRefresh beginRefreshing];
    [self getClaimListByType:claimListType isRefreshing:YES];
}

#pragma mark - API & Pull Refresh

- (void)getClaimListByType:(ClaimListType)claimListType isRefreshing:(BOOL)isRefreshing{
    if (!_apiHelper) {
        _apiHelper = [[APIHelper alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            AMLog(@"%@",error.domain);
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            [weakSelf.pullRefresh endRefreshing];
            
            if (claimListType == ClaimListTypeOnGoing)
            {
                if (weakSelf.arrOnGoing.count==0) {
                    [weakSelf.hintLabel setHidden:NO];
                }
            }
            else{
                if (weakSelf.arrFinished.count==0) {
                    [weakSelf.hintLabel setHidden:NO];
                }
            }
            
            return;
        }
        
        if (apiHelper.data.length>0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                [UMStatistics event:claimListType == ClaimListTypeOnGoing ? pv_3_9_2_buiness_bond_complaint_unfinished : pv_3_9_2_buiness_bond_complaint_finished];
                [weakSelf.hintLabel setHidden:YES];
                ClaimRecordModel *recordModel = [[ClaimRecordModel alloc] initWithJson:mBase.result];
                weakSelf.totalCount = recordModel.Count.integerValue;
                
                if (isRefreshing) {
                    
                    if (claimListType == ClaimListTypeOnGoing) {
                        if (weakSelf.arrOnGoing.count>0)
                            [weakSelf.arrOnGoing removeAllObjects];
                    }
                    else{
                        if (weakSelf.arrFinished.count>0)
                            [weakSelf.arrFinished removeAllObjects];
                    }
                    
                    [weakSelf.pullRefresh endRefreshing];
                }
                else{
                    
                }
                
                if (weakSelf.totalCount > 0) {
                    [weakSelf.hintLabel setHidden:YES];
                }
                else{
                    [weakSelf.hintLabel setHidden:NO];
                    
                }
                
                weakSelf.tableView.tableFooterView = weakSelf.vFooter;
                
                if (claimListType == ClaimListTypeOnGoing) {
                    [weakSelf.arrOnGoing addObjectsFromArray:recordModel.ClaimList];
                }
                else{
                    [weakSelf.arrFinished addObjectsFromArray:recordModel.ClaimList];
                }
                
                [weakSelf.tableView reloadData];
                
            }
            else{
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
                else{
                    [[AMToastView toastView] hide];
                }
            }
        }
        
    }];
    
    [_apiHelper getDealerClaimListWithUserKey:[AMCacheManage currentUserInfo].userkey claimState:claimListType pageIndex:pageIndex pageSize:kListPageSize];
}



- (void)PullToRefresh
{
    pageIndex = 1;
    
    [self getClaimListByType:_claimListType isRefreshing:YES];
}

//更新单项的已读标识
- (void)updateReadNewForCarID:(NSInteger)carID{
    
    if (!_apiUpdateNew) {
        _apiUpdateNew = [[APIHelper alloc] init];
    }
    
    [_apiUpdateNew setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (apiHelper.data.length>0) {
            __unused BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                // 请求成功后更新 claim count 的总数
                UCMainView *mainView = [UCMainView sharedMainView];
                if (mainView.claimCount>0) {
                    mainView.claimCount --;
                }
            }
        }
        
    }];
    
    [_apiUpdateNew updateDealerClaimReadStateWithUserKey:[AMCacheManage currentUserInfo].userkey carID:[NSNumber numberWithInteger:carID]];
}


@end
