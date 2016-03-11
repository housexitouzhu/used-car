//
//  UCDepositDetailView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDepositDetailView.h"
#import "UCTopBar.h"
#import "CKRefreshControl.h"
#import "DepositDetailCell.h"
#import "UCCarDetailView.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "DepositStatementModel.h"
#import "BailMoneyItem.h"
#import "MoneyDetailItem.h"


static NSString *identifier = @"DepositCell";

@interface UCDepositDetailView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (retain, nonatomic) UITableView *tableView;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;     // 刷新

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation UCDepositDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataArray = [[NSMutableArray alloc] init];
        
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor = kColorWhite;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_tbTop];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:kColorNewBackground];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self addSubview:_tableView];
    
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tableView];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    _pullRefresh.backgroundColor = [UIColor clearColor];
    
    [_pullRefresh addTarget:self action:@selector(PullToRefresh) forControlEvents:UIControlEventValueChanged];
    
    [self PullToRefresh];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"保证金明细" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}


#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}


#pragma mark - tableview delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DepositDetailCell *cell = (DepositDetailCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
//        cell = [[DepositDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
        cell = [DepositDetailCell newCellWithCellWidth:tableView.width];
    }
    
    BailMoneyItem *bailItem = [self.dataArray objectAtIndex:indexPath.section];
    NSMutableArray *moneyArray = [[NSMutableArray alloc] initWithArray: bailItem.MoneyDetail];
    MoneyDetailItem *moneyItem = [moneyArray objectAtIndex:indexPath.row];
    [cell makeView:moneyItem];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    BailMoneyItem *bailItem = [self.dataArray objectAtIndex:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 35)];
    [view setBackgroundColor:kColorNewBackground];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, tableView.width, 35)];
    [sectionLabel setBackgroundColor:kColorNewBackground];
    [sectionLabel setTextColor:kColorNewGray1];
    [sectionLabel setFont:kFontMiddle];
    [sectionLabel setText:bailItem.InsertTime];
    
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, view.height-kLinePixel, tableView.width, kLinePixel) color:kColorNewLine];
    [view addSubview:sectionLabel];
    
    [view addSubview:hLine];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BailMoneyItem *bailItem = [self.dataArray objectAtIndex:section];
    return bailItem.MoneyDetail.count;
}

#pragma mark - 获取明细 api 请求
- (void)getDealerDepositStatement{
    if (!_apiHelper) {
        _apiHelper = [[APIHelper alloc] init];
    }
    __weak typeof(self) weakSelf = self;
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            AMLog(@"%@",error.domain);
            [weakSelf.pullRefresh endRefreshing];
            return;
        }
        
        if (apiHelper.data.length>0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                [UMStatistics event:pv_3_9_2_buiness_bond_detailed];
                if (weakSelf.dataArray.count>0)
                    [weakSelf.dataArray removeAllObjects];

                DepositStatementModel *dsm = [[DepositStatementModel alloc] initWithJson:mBase.result];
                [weakSelf.dataArray addObjectsFromArray:dsm.BailMoneyList];
                [weakSelf.tableView reloadData];
                [weakSelf.pullRefresh endRefreshing];
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
    
    [_apiHelper getDealerDepositDetailWithUserKey:[AMCacheManage currentUserInfo].userkey];
}

#pragma mark - 刷新列表

- (void)PullToRefresh
{
    [self.pullRefresh beginRefreshing];
    [self getDealerDepositStatement];
}

@end
