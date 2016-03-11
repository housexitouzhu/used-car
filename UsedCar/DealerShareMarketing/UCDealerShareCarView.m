//
//  UCDealerShareCarView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-10-13.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCDealerShareCarView.h"
#import "UCTopBar.h"
#import "APIHelper.h"
#import "AMCacheManage.h"
#import "ShareCarInfoCell.h"
#import "UCCarInfoModel.h"
#import "CKRefreshControl.h"
#import "UCCarDetailView.h"
#import "UIImage+Util.h"
#import "UCSNSHelper.h"

#define kListPageSize   30
#define kLoadViewHeight 40
#define kFooterViewHeight   50

@interface UCDealerShareCarView ()<UITableViewDelegate, UITableViewDataSource, UCSNSHelperDelegate>
{
    NSInteger pageIndex;
    BOOL selecting;
    BOOL allSelected;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITableView *vTable;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *shareURL;
@property (nonatomic, strong) NSDictionary *wxsessionContent;
@property (nonatomic, strong) NSNumber *shareID;

@property (nonatomic, strong) APIHelper *carsHelper;
@property (nonatomic, strong) APIHelper *shareUrlHelper;
@property (nonatomic, strong) APIHelper *updateShareHelper;
@property (nonatomic, assign) SNSChannelType channelType;

@property (nonatomic, strong) NSMutableArray *arrTable;
@property (nonatomic, strong) NSMutableArray *arrSelected;
@property (nonatomic, strong) NSMutableArray *arrCarIDs;

@property (nonatomic, strong) UIView    *vFooter;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) UIView    *vLoadMore;
@property (nonatomic, strong) UILabel   *hintLabel;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;

@property (nonatomic, strong) UIView *vShareBar;
@property (nonatomic, strong) UIButton *btnBarShare;
//@property (nonatomic, strong) UIButton *btnSelectAll; //去掉全选

@property (nonatomic, strong) UCSNSHelper *snsHelper;

@end

@implementation UCDealerShareCarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.arrTable = [[NSMutableArray alloc] init];
        self.arrSelected = [[NSMutableArray alloc] init];
        self.arrCarIDs = [[NSMutableArray alloc] init];
        
        [self initView];
        
    }
    return self;
}

- (void)initView{
    
    [UMStatistics event:pv_4_1_buiness_share_carshare];
    self.backgroundColor =  kColorNewBackground;
    self.tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:self.tbTop];
    
    self.vTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.tbTop.maxY, self.width, self.height - self.tbTop.maxY)];
    [self.vTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.vTable setAllowsSelectionDuringEditing:YES];
    [self.vTable setAllowsMultipleSelectionDuringEditing:YES];
    [self.vTable setBackgroundColor: kColorWhite];
    [self.vTable setDelegate:self];
    [self.vTable setDataSource:self];
    [self addSubview:self.vTable];
    
    self.vShareBar = [[UIView alloc] initWithClearFrame:CGRectMake(0, self.height, self.width, 44)];
    self.vShareBar.backgroundColor = kColorWhite;
    UIView *hLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.vShareBar.width, kLinePixel) color:kColorNewLine];
    [self.vShareBar addSubview:hLine];
    [self addSubview:self.vShareBar];
    
    //    self.btnSelectAll = [UIButton buttonWithType:UIButtonTypeCustom];
    //    self.btnSelectAll.frame = CGRectMake(8, kLinePixel, 40, 44-kLinePixel);
    //    self.btnSelectAll.backgroundColor = kColorClear;
    //    self.btnSelectAll.titleLabel.font = kFontLarge1;
    //    [self.btnSelectAll setTitleColor:kColorBlue2 forState:UIControlStateNormal];
    //    [self.btnSelectAll setTitleColor:kColorNewGray2 forState:UIControlStateDisabled];
    //    [self.btnSelectAll setTitle:@"全选" forState:UIControlStateNormal];
    //    [self.btnSelectAll addTarget:self action:@selector(onClickedSelectAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnBarShare = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBarShare.frame = CGRectMake(8, 4, self.width - 16, 36);
    //CGRectMake(self.vShareBar.width-8-40, kLinePixel, 40, 44-kLinePixel);
    self.btnBarShare.backgroundColor = kColorClear;
    self.btnBarShare.titleLabel.font = kFontLarge1;
    [self.btnBarShare setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.btnBarShare setEnabled:NO];
    [self.btnBarShare setTitle:@"分享" forState:UIControlStateNormal];
    [self.btnBarShare setBackgroundImage:[UIImage imageWithColor:kColorBlue size:self.btnBarShare.size] forState:UIControlStateNormal];
    [self.btnBarShare setBackgroundImage:[UIImage imageWithColor:kColorBlueH size:self.btnBarShare.size] forState:UIControlStateHighlighted];
    [self.btnBarShare setBackgroundImage:[UIImage imageWithColor:kColorBlueD size:self.btnBarShare.size] forState:UIControlStateDisabled];
    [self.btnBarShare addTarget:self action:@selector(onClickedShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBarShare.layer setCornerRadius:3.0];
    [self.btnBarShare.layer setMasksToBounds:YES];
    
    //    [self.vShareBar addSubview:self.btnSelectAll];
    [self.vShareBar addSubview:self.btnBarShare];
    
    
    [self refreshTableList];
    
    
    // 无数据提示
    _hintLabel = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height)];
    //    _hintLabel.hidden = YES;
    _hintLabel.text = @"暂无车辆信息";
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.font = [UIFont systemFontOfSize:16];
    _hintLabel.textColor = kColorNewGray2;
    _hintLabel.backgroundColor = kColorClear;
    [self addSubview:_hintLabel];
    
    
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:self.vTable];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    _pullRefresh.backgroundColor = [UIColor clearColor];
    [_pullRefresh addTarget:self action:@selector(refreshTableList) forControlEvents:UIControlEventValueChanged];
    
    
    
    // 列表垫底视图
    _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, kFooterViewHeight)];
    [_vFooter setBackgroundColor:[UIColor clearColor]];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.vTable.width, kLoadViewHeight)];
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


/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"车源精准分享" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [vTopBar.btnRight setTitle:@"批量分享" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnRight setTitleColor:kColorWhite forState:UIControlStateHighlighted];
    [vTopBar.btnRight addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

- (void)onClickRightBtn:(UIButton *)btn{
    
    if (selecting) {
        [UMStatistics event:c_4_1_buiness_share_carshare_unbatch];
        selecting = NO;
        [self.tbTop.btnRight setTitle:@"批量分享" forState:UIControlStateNormal];
        [self.vTable setEditing:NO animated:YES];
        
        NSArray *visibleCells = [self.vTable visibleCells];
        for (ShareCarInfoCell *cell in visibleCells) {
            
            [cell setCellToEditingMode:NO Animated:YES];
            [cell setChecked:NO];
        }
        [self setToolbarHidden:YES];
        [self.arrSelected removeAllObjects];
        [self.arrCarIDs removeAllObjects];
        allSelected = NO;
        self.btnBarShare.enabled = NO;
        //        [self.btnSelectAll setTitle:@"全选" forState:UIControlStateNormal];
    }
    else{
        [UMStatistics event:c_4_1_buiness_share_carshare_batch];
        selecting = YES;
        [self.tbTop.btnRight setTitle:@"取消分享" forState:UIControlStateNormal];
        [self.vTable setEditing:YES animated:YES];
        NSArray *visibleCells = [self.vTable visibleCells];
        for (ShareCarInfoCell *cell in visibleCells) {
            [cell setCellToEditingMode:YES Animated:YES];
        }
        [self setToolbarHidden:NO];
        
    }
}

- (void)onClickedSelectAllBtn:(UIButton*)button{
    if (allSelected) {
        allSelected = NO;
        
        for (NSIndexPath *index in self.vTable.indexPathsForVisibleRows) {
            ShareCarInfoCell *cell = (ShareCarInfoCell*)[self.vTable cellForRowAtIndexPath:index];
            [cell setChecked:NO];
            [self.vTable deselectRowAtIndexPath:index animated:NO];
        }
        
        [self.arrSelected removeAllObjects];
        [self.arrCarIDs removeAllObjects];
        
        button.frame = CGRectMake(8, 0, 40, 44);
        [button setTitle:@"全选" forState:UIControlStateNormal];
        
        self.btnBarShare.enabled = NO;
    }
    else{
        [UMStatistics event:c_4_1_buiness_share_carshare_selectall];
        allSelected = YES;
        button.frame = CGRectMake(8, 0, 80, 44);
        [button setTitle:@"取消全选" forState:UIControlStateNormal];
        
        for (NSDictionary *dicCell in self.arrTable) {
            UCCarInfoEditModel *mEditModel = [[UCCarInfoEditModel alloc] initWithJson:dicCell];
            UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithCarInfoEditModelModel:mEditModel];
            [self.arrSelected addObject: mCarInfo];
            [self.arrCarIDs addObject:mCarInfo.carid];
        }
        
        for (NSIndexPath *index in self.vTable.indexPathsForVisibleRows) {
            ShareCarInfoCell *cell = (ShareCarInfoCell*)[self.vTable cellForRowAtIndexPath:index];
            [cell setChecked:YES];
            [self.vTable selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        self.btnBarShare.enabled = YES;
    }
}

- (void)onClickedShareBtn:(UIButton *)button{
    if (self.arrSelected.count>0) {
        [UMStatistics event:c_4_1_buiness_share_carshare_share];
        [self shareDealerCar];
    }
}

#pragma mark - 刷新列表
- (void)refreshTableList{
    pageIndex = 1;
    [self getDealerOnSaleCarsRefreshing:YES updateCount:NO];
}

- (void)refreshTableListUpdateCount{
    pageIndex = 1;
    [self getDealerOnSaleCarsRefreshing:YES updateCount:YES];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UCCarInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dicCell = [self.arrTable objectAtIndex:indexPath.row];
    UCCarInfoEditModel *mEditModel = [[UCCarInfoEditModel alloc] initWithJson:dicCell];
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithCarInfoEditModelModel:mEditModel];
    
    ShareCarInfoCell *cell = (ShareCarInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if (selecting) {
        
        [cell setChecked:YES];
        [self.arrSelected addObject:mCarInfo];
        [self.arrCarIDs addObject:mCarInfo.carid];
        if (self.arrSelected.count > 0) {
            [self.btnBarShare setEnabled:YES];
        }
        
    }
    else{
        
        UCCarDetailView *vDetail = [[UCCarDetailView alloc] initWithFrame:self.bounds mCarInfo:mCarInfo];
        [[MainViewController sharedVCMain] openView:vDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicCell = [self.arrTable objectAtIndex:indexPath.row];
    UCCarInfoEditModel *mEditModel = [[UCCarInfoEditModel alloc] initWithJson:dicCell];
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithCarInfoEditModelModel:mEditModel];
    
    ShareCarInfoCell *cell = (ShareCarInfoCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (selecting) {
        [cell setChecked:NO];
        
        // 移除 array 里的 model
        for (int i = 0; i < self.arrSelected.count; i++) {
            UCCarInfoModel *mtemp = [self.arrSelected objectAtIndex:i];
            if(mCarInfo.carid.integerValue == mtemp.carid.integerValue){
                [self.arrSelected removeObjectAtIndex:i];
            }
        }
        
        [self.arrCarIDs removeObject:mCarInfo.carid];
        if (self.arrCarIDs.count == 0) {
            [self.btnBarShare setEnabled:NO];
        }
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dicCell = [self.arrTable objectAtIndex:indexPath.row];
    UCCarInfoEditModel *mEditModel = [[UCCarInfoEditModel alloc] initWithJson:dicCell];
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithCarInfoEditModelModel:mEditModel];
    ShareCarInfoCell *sCell = (ShareCarInfoCell*)cell;
    
    if ([self.arrCarIDs containsObject:mCarInfo.carid]) {
        [sCell setChecked:YES];
    }
    else{
        [sCell setChecked:NO];
    }
    
    // 最后一个cell 开始加载更多
    if (indexPath.row == self.arrTable.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (self.arrTable.count % kListPageSize == 0) {
            if (self.vTable.tableFooterView != _vLoadMore) {
                self.vTable.tableFooterView = _vLoadMore;
                if (self.arrTable.count < _totalCount) {
                    pageIndex++;
                    [self getDealerOnSaleCarsRefreshing:NO updateCount:NO];
                }
                else{
                    _vFooter.height = 0;
                    self.vTable.tableFooterView = _vFooter;
                }
            }
        } else {
            _vFooter.height = kLoadViewHeight;
            self.vTable.tableFooterView = _vFooter;
        }
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrTable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MyCell";
    ShareCarInfoCell *cell = (ShareCarInfoCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[ShareCarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
    }
    
    
    NSDictionary *dicCell = [self.arrTable objectAtIndex:indexPath.row];
    UCCarInfoEditModel *mEditModel = [[UCCarInfoEditModel alloc] initWithJson:dicCell];
    UCCarInfoModel *mCarInfo = [[UCCarInfoModel alloc] initWithCarInfoEditModelModel:mEditModel];
    
    [cell makeView:mCarInfo isShowSelect:YES];
    
    if (selecting) {
        [cell setCellToEditingMode:YES Animated:NO];
    }
    else{
        [cell setCellToEditingMode:NO Animated:NO];
    }
        
    return cell;
}


#pragma mark - toolbar
- (void)setToolbarHidden:(BOOL)flag{
    [UIView animateWithDuration:kAnimateSpeedFast animations:^{
        if (flag) {
            self.vShareBar.frame = CGRectMake(0, self.height, self.width, 44);
            self.vTable.frame = CGRectMake(0, self.tbTop.maxY, self.width, self.height - self.tbTop.maxY);
        }
        else{
            self.vShareBar.frame = CGRectMake(0, self.height - 44, self.width, 44);
            self.vTable.frame = CGRectMake(0, self.tbTop.maxY, self.width, self.height - self.tbTop.maxY - 44);
        }
    }];
}

#pragma mark - 分享
- (void)shareDealerCar{
    
    self.title = [[AMCacheManage currentUserInfo].username stringByAppendingString:@"最新优质车源"];
    self.content = [self.title stringByAppendingString:@"，二手车之家推荐商家 #二手车之家# "];
    
    //先获取 share url
    [self getDealerCarShareURL];
}

- (void)openShareView{
    
    if (!self.snsHelper) {
        self.snsHelper = [[UCSNSHelper alloc] init];
    }
    self.snsHelper.delegate = self;
    
    self.snsHelper.title = self.title;
    self.snsHelper.content = [self.content stringByAppendingString: self.shareURL];
    self.snsHelper.contentNoURL = self.content;
    self.snsHelper.contentWeChat = @"欢迎随时到店了解最新优质车源信息 #二手车之家# ";
    self.snsHelper.useTitleForWechatTimeLine = YES;
    self.snsHelper.shareURL = self.shareURL;
    
    UCCarInfoModel *mCarInfo = [self.arrSelected firstObject];
    if (mCarInfo.imageLargeURLs.length>0) {
        NSArray *arrURL = [mCarInfo.imageLargeURLs componentsSeparatedByString:@","];
        AMLog(@"arrURL.firstObject %@", arrURL.firstObject);
        self.snsHelper.imageURL = [arrURL firstObject];
    }
    else{
        self.snsHelper.imageShareIcon = [UIImage imageNamed:@"failedtoload"];
    }
    
    [self.snsHelper openShareViewForAllPlatform:YES];
}


#pragma mark - UCSNSHelperDelegate
- (void)UCSNSHelper:(UCSNSHelper*)helper shareSuccessWithChannelType:(SNSChannelType)channelType{
    self.channelType = channelType;
    [self updateDealerShareCarInfo];
}



#pragma mark - 网络请求

- (void)getDealerOnSaleCarsRefreshing:(BOOL)refreshing updateCount:(BOOL)updateCount{
    
    if (!updateCount) {
        [[AMToastView toastView] showLoading:@"数据加载中..." cancel:nil];
    }
    
    if (!self.carsHelper) {
        self.carsHelper = [[APIHelper alloc] init];
    }
    
    __weak UCDealerShareCarView *weakSelf = self;
    [self.carsHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        [weakSelf.pullRefresh endRefreshing];
        
        if (error) {
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            weakSelf.hintLabel.hidden = weakSelf.arrTable.count != 0;
            return ;
        }
        
        if (apiHelper.data.length>0) {
            
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                [UMSAgent postEvent:buiness_share_carshare_pv page_name:NSStringFromClass(weakSelf.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];
                if (!updateCount) {
                    [[AMToastView toastView] hide];
                }
                
                weakSelf.totalCount = [[mBase.result objectForKey:@"rowcount"] integerValue];
                NSArray *arr = [mBase.result objectForKey:@"carlist"];
                [weakSelf.hintLabel setHidden:YES];
                
                if (refreshing && weakSelf.arrTable.count>0) {
                    [weakSelf.arrTable removeAllObjects];
                }
                
                if (weakSelf.totalCount > 0) {
                    [weakSelf.hintLabel setHidden:YES];
                }
                else{
                    [weakSelf.hintLabel setHidden:NO];
                }
                
                weakSelf.vTable.tableFooterView = weakSelf.vFooter;
                
                [weakSelf.arrTable addObjectsFromArray:arr];
                [weakSelf.vTable reloadData];
            }
            else{
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
                else{
                    if (!updateCount) {
                        [[AMToastView toastView] hide];
                    }
                }
            }
        }
        else{
            if (!updateCount) {
                [[AMToastView toastView] hide];
            }
        }
        
    }];
    
    [self.carsHelper getDealerStoreCarsPageIndex:pageIndex PageSize:kListPageSize];
    
}


/**
 *  @brief  获取店铺分享的 URL
 */
- (void)getDealerCarShareURL{
    
    [[AMToastView toastView] showLoading:@"数据提交中" cancel:nil];
    
    if (!self.shareUrlHelper) {
        self.shareUrlHelper = [[APIHelper alloc] init];
    }
    
    __weak UCDealerShareCarView *weakSelf = self;
    [self.shareUrlHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                [[AMToastView toastView] hide];
                weakSelf.shareURL = [mBase.result objectForKey:@"shareurl"];
                weakSelf.shareID = [mBase.result objectForKey:@"shareid"];
                [weakSelf openShareView];
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
        else{
            [[AMToastView toastView] hide];
        }
        
    }];
    
    //    NSMutableArray *arrCarIDs = [[NSMutableArray alloc] initWithCapacity:self.arrSelected.count];
    //    for (int i = 0; i<self.arrSelected.count; i++) {
    //        UCCarInfoModel *mCar = [self.arrSelected objectAtIndex:i];
    //        [arrCarIDs addObject:mCar.carid];
    //    }
    
    [self.shareUrlHelper addDealerShare:DealerShareTypeCar title:self.title content:self.content carids:self.arrCarIDs];
}

- (void)updateDealerShareCarInfo{
    
    if (!self.updateShareHelper) {
        self.updateShareHelper = [[APIHelper alloc] init];
    }
    
    __weak UCDealerShareCarView *weakSelf = self;
    [self.updateShareHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase.returncode == 0) {
                //分享成功后刷新列表
//                [weakSelf onClickRightBtn:nil];
                [weakSelf refreshTableListUpdateCount];
            }
        }
        
    }];
    
    [self.updateShareHelper updateDealerShareWithShareid:self.shareID channelType:self.channelType];
    
}


@end
