//
//  UCHistoryView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCIMHistoryView.h"
#import "UCTopBar.h"
#import "CKRefreshControl.h"
#import "UCIMHistoryCell.h"
#import "XMPPDBCacheManager.h"
#import "AMCacheManage.h"
#import "StorageMessage.h"
#import "XMPPDBCacheManager.h"
#import "UCChatRootView.h"
#import "APIHelper.h"
#import "IMCacheManage.h"
#import "IMHistoryContactModel.h"
#import "IMCacheManage.h"

#define kLoadViewHeight     40
const static CGFloat kDeleteButtonWidth = 85.f;
const static CGFloat kDeleteButtonHeight = kLoadViewHeight;

@interface UCIMHistoryView () {
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    UIButton * _deleteButton;
    BOOL _isFirstLoadData;
    BOOL _isFirstReciveMessage;
}

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITableView *tvHistory;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) UIView *vNoData; // 无数据提示
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic)CGFloat cellHeight;
@property (nonatomic, strong) APIHelper *apiContactList;
@property (nonatomic, strong) APIHelper *apiContactInfo;
@property (nonatomic, strong) APIHelper *serverHelper;

@end


@implementation UCIMHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [UMSAgent postEvent:[AMCacheManage currentUserType] == UserStyleBusiness ? buycar_chat_history_shop_pv : buycar_chat_history_user_pv page_name:NSStringFromClass(self.class)];
        
        _pageSize = 20;
        _isAllowsSelection = YES;
        _isEnablePullRefresh = NO;
        _isFirstLoadData = YES;
        _isFirstReciveMessage = YES;
        [self initView];
    }
    return self;
}

- (NSMutableArray *)mHistory
{
    if (!_mHistory) {
        _mHistory = [[NSMutableArray alloc] init];
    }
    return _mHistory;
}

-(void)viewWillShow:(BOOL)animated
{
    [super viewWillShow:animated];
    
    if ([IMCacheManage currentIMUserInfo].domain.length) {
        XMPPManager *xmpp = [XMPPManager sharedManager];
        if (!xmpp.xStream.isConnected && !xmpp.xStream.isConnecting) {
            [xmpp connectToServer];
//            BOOL connected = [xmpp connectToServer];
//            AMLog(@"*****XMPP Connected: %@ *****", (connected ? @"YES" : @"NO"));
        }
    }
    
    [self refreshCarListIsToTop:NO];
    
    // 有不完整信息获取后刷新
    NSArray *inComplete = [[XMPPDBCacheManager sharedManager] getInCompleteContacts];
    if (inComplete.count > 0) {
        [self getContactInfoWithContacts:inComplete];
    }
}

-(void)viewWillClose:(BOOL)animated
{
    [super viewWillClose:animated];
    [[XMPPManager sharedManager] logout];
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];
}

- (void)initView{
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 列表
    _tvHistory = [self creatHistoryTableView:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvHistory];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    
    [_pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvHistory.width, kLoadViewHeight)];
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
    
    // 无数据提示
    _vNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, 0)];
    _vNoData.hidden = YES;
    
    //
    UILabel *labNoData = [[UILabel alloc] init];
    labNoData.backgroundColor = kColorClear;
    labNoData.text = @"暂无咨询记录";
    labNoData.font = kFontSuper;
    labNoData.textColor = kColorNewGray2;
    [labNoData sizeToFit];
    labNoData.origin = CGPointMake((_vNoData.width - labNoData.width) / 2, 0);
    
    UILabel *labNoData2 = [[UILabel alloc] init];
    labNoData2.backgroundColor = kColorClear;
    labNoData2.text = @"请到“车辆详情”底部，点击“联系”咨询卖家";
    labNoData2.font = kFontLarge;
    labNoData2.textColor = kColorNewGray2;
    [labNoData2 sizeToFit];
    labNoData2.origin = CGPointMake((_vNoData.width - labNoData2.width) / 2, labNoData.maxY + 20);

    [_vNoData addSubview:labNoData];
    [_vNoData addSubview:labNoData2];

    _vNoData.height = labNoData2.maxY;
    _vNoData.minY = (_tvHistory.height - _vNoData.height) / 2 + _tbTop.height;
    
    [self addSubview:_tvHistory];
    [self addSubview:_vNoData];

    // 创建删除按钮
    [self initDeleteView];
    
    // 下拉刷新
    [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
        [[AMToastView toastView] hide];
    }];
    
    [self refreshCarList];

    IMUserInfoModel *mIMUserInfo = [IMCacheManage currentIMUserInfo];
    
    IMUserInfoModel *imUser = [IMCacheManage currentIMUserInfo];
    if (!imUser.domain.length) {
        [self getIMServiceInfo];
    } else {
        XMPPManager *xmpp = [XMPPManager sharedManager];
        [xmpp connectToServer];
//        BOOL connected = [xmpp connectToServer];
//        AMLog(@"*****XMPP Connected: %@ *****", (connected ? @"YES" : @"NO"));
        [[XMPPManager sharedManager] addToDelegateQueue:self];
        [self getIMLinkerListWtihName:mIMUserInfo.name page:nil index:nil];
    }
    
}

/** 创建聊天表格 */
- (UITableView *)creatHistoryTableView:(CGRect)frame
{
    _tvHistory = [[UITableView alloc] initWithFrame:frame];
    _tvHistory.delegate = self;
    _tvHistory.dataSource = self;
    _tvHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvHistory.backgroundColor = kColorNewBackground;
    _tvHistory.tableFooterView = _vFooter;
    
    return _tvHistory;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"咨询记录" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 初始化删除按钮 */
- (void)initDeleteView
{
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [_tvHistory addGestureRecognizer:_leftGestureRecognizer];
    
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_tvHistory addGestureRecognizer:_rightGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _deleteButton.frame = CGRectMake(self.width, 0, kDeleteButtonWidth, kDeleteButtonHeight);
    _deleteButton.backgroundColor = kColorRed;
    _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = kFontLarge;
    [_deleteButton setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [_tvHistory addSubview:_deleteButton];
}

#pragma mark - button actions
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveAuto];
}

#pragma mark - public Method
- (void)setFooterViewHeight:(CGFloat)height
{
    // 列表垫底视图
    if (!_vFooter)
    {
        _vFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, height)];
        [_vFooter setBackgroundColor:[UIColor clearColor]];
    }
    else
        _vFooter.height = height;
    // 设置加载更多的高度
    _vLoadMore.height = height + kLoadViewHeight;
}

// 加载更多
-(void)loadMore
{
    // 加载更多
    _tvHistory.tableFooterView = _vLoadMore;
    _pageIndex++;
    [self getMoreHistory];
}

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    _tvHistory.scrollIndicatorInsets = scrollIndicatorInsets;
    _pullRefresh.originalTopContentInset = scrollIndicatorInsets.top;
}

- (void)setIsEnablePullRefresh:(BOOL)isEnablePullRefresh {
    _isEnablePullRefresh = isEnablePullRefresh;
    _pullRefresh.enabled = isEnablePullRefresh;
}

#pragma mark - privatev Method
- (void)onPull
{
    if (_isEnablePullRefresh) {
        [self refreshCarList];
    }
}

/** 根据数据源刷 */
- (void)refreshCarListWithCarListModels:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount
{
    // 设置是否可选中
    _tvHistory.allowsSelection = _isAllowsSelection;
    _vNoData.hidden = mCarLists.count > 0 ? YES : NO;
    _pageIndex = 1;
    [self.mHistory removeAllObjects];
    [self.mHistory addObjectsFromArray:mCarLists];
    [_tvHistory reloadData];
    
    // 列表滚动到最顶端
    _tvHistory.contentOffset = CGPointMake(0, -_tvHistory.contentInset.top);
    
}

/** 刷新车辆列表 */
- (void)refreshCarList
{
    [self refreshCarListIsToTop:YES];
}

- (void)refreshCarListIsToTop:(BOOL)isToTop
{
    // 设置是否可选中
    _tvHistory.allowsSelection = _isAllowsSelection;
    _vNoData.hidden = YES;
    _pageIndex = 1;
    [self getMoreHistory];
    
    // 列表滚动到最顶端
    if (isToTop)
        _tvHistory.contentOffset = CGPointMake(0, -_tvHistory.contentInset.top);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"UCCarInfoCell";
    UCIMHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
        cell = [[UCIMHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];

    StorageContact *mContact = [self.mHistory objectAtIndex:indexPath.row];
    [cell makeView:mContact];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  kHistoryCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UMStatistics event:[AMCacheManage currentUserType] == UserStyleBusiness ? c_4_3_IM_Chat_History_Shop_List : c_4_3_IM_Chat_History_User_List];
    
    StorageContact *contact = [self.mHistory objectAtIndex:indexPath.row];
    UCChatRootView *vChat = [[UCChatRootView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds contact:contact withHistoryArray:[[XMPPDBCacheManager sharedManager] firstPageMessagesWithJid:contact.shortJid]];
    [[MainViewController sharedVCMain] openView:vChat animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一个cell 开始加载更多
    if (indexPath.row == self.mHistory.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (self.mHistory.count % _pageSize == 0) {
            if (tableView.tableFooterView != _vLoadMore) {
                tableView.tableFooterView = _vLoadMore;
                _pageIndex++;
                [self getMoreHistory];
            }
        } else {
            _tvHistory.tableFooterView = _vFooter;
        }
    }
}

/** 手势操作 */
- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    if(![_tvHistory.dataSource tableView:_tvHistory canEditRowAtIndexPath:indexPath]) {
        return;
    }
    
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [_tvHistory cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [_tvHistory cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)deleteItem:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否确认删除" message:Nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(_editingIndexPath) {
        UITableViewCell * cell = [_tvHistory cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除数据源
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [UMStatistics event:[AMCacheManage currentUserType] == UserStyleBusiness ? c_4_3_IM_Chat_History_Shop_Delete : c_4_3_IM_Chat_History_User_Delete];
        
        StorageContact *mContact = [self.mHistory objectAtIndex:indexPath.row];
        [self.mHistory removeObjectAtIndex:indexPath.row];
        
        [[XMPPDBCacheManager sharedManager] cleanupMessagesWithContact:mContact];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.mHistory.count == 0) {
            [self refreshCarList];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPat
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [_tvHistory indexPathForRowAtPoint:point];
    return indexPath;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell
{
    if(editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [_tvHistory cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    CGRect frame = cell.frame;
    
    CGFloat cellXOffset;
    CGFloat deleteButtonXOffsetOld;
    CGFloat deleteButtonXOffset;
    
    if(editing) {
        cellXOffset = -kDeleteButtonWidth;
        deleteButtonXOffset = self.width - kDeleteButtonWidth;
        deleteButtonXOffsetOld = self.width;
        _editingIndexPath = indexPath;
    } else {
        cellXOffset = 0;
        deleteButtonXOffset = self.width;
        deleteButtonXOffsetOld = self.width - kDeleteButtonWidth;
        _editingIndexPath = nil;
    }
    
    _cellHeight = [_tvHistory.delegate tableView:_tvHistory heightForRowAtIndexPath:indexPath];
    _deleteButton.frame = (CGRect) {deleteButtonXOffsetOld, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
    
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _deleteButton.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 弹出框删除和取消
    if (buttonIndex == 1) {
        
        NSIndexPath * indexPath = _editingIndexPath;
        UITableViewCell * cell = [_tvHistory cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        
        [_tvHistory.dataSource tableView:_tvHistory commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        
        _editingIndexPath = nil;
        [UIView animateWithDuration:0.2f animations:^{
            CGRect frame = _deleteButton.frame;
            _deleteButton.frame = (CGRect){frame.origin, frame.size.width, 0};
        } completion:^(BOOL finished) {
            CGRect frame = _deleteButton.frame;
            _deleteButton.frame = (CGRect){self.width, frame.origin.y, frame.size.width, kDeleteButtonHeight};
        }];
        
    } else if (buttonIndex == 0) {
        
        UITableViewCell * cell = [_tvHistory cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        CGRect frame = cell.frame;
        
        CGFloat cellXOffset = 0.0;
        [UIView animateWithDuration:0.2f animations:^{
            cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
            _deleteButton.frame = (CGRect) {self.width, frame.origin.y, _deleteButton.frame.size.width, _cellHeight};
        }];
        
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 关掉手势使其不是第一响应者
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 接受touch事件
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark -UIscrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_editingIndexPath) {
        UITableViewCell *cell = [_tvHistory cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        _editingIndexPath = nil;
    }
}

#pragma mark - XMPP Connection Delegate
- (void)didReceiveMessage:(StorageMessage *)message{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.showViewAnimated == AnimateOptionMoveUp && _isFirstReciveMessage) {
        [[AMToastView toastView:YES] showLoading:@"正在加载中..." cancel:^{
            [[AMToastView toastView] hide];
        }];
        _isFirstReciveMessage = NO;
    }
    if (message.type == IMMessageTypeCar) {
        [self getContactInfoWithContacts:[NSArray arrayWithObject:message.jid]];
    } else {
        [self performSelector:@selector(getMoreHistory) withObject:nil afterDelay:0.5];
    }
    
}

#pragma mark - APIHelper
- (void)getMoreHistory
{
    if (!_isEnablePullRefresh)
        _pullRefresh.enabled = YES;

    if (!self.isEnablePullRefresh)
        self.pullRefresh.enabled = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // 临时车辆列表
        NSMutableArray *tmpHistory = [[XMPPDBCacheManager sharedManager] allContacts];
        
        //影响到UI更新的操作需要放到主线程
        dispatch_sync(dispatch_get_main_queue(), ^{

            // 刷新成功清理缓存
            if (self.pageIndex == 1) {
                [self.mHistory removeAllObjects];
                [self.mHistory addObjectsFromArray:tmpHistory];
                // 刷新列表
                [self.tvHistory reloadData];

                // 滚动到顶
                self.tvHistory.contentOffset = CGPointMake(0, -self.tvHistory.contentInset.top);
            }
            // 加载更多
            else {
                NSUInteger originalCount = self.mHistory.count;
                NSMutableArray *indexPaths = [NSMutableArray array];
                for (int i = 0; i < tmpHistory.count; i++)
                    [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                [self.mHistory addObjectsFromArray:tmpHistory];
                [self.tvHistory insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (_isFirstLoadData) {
                if (tmpHistory.count == 0) {
                    [UMStatistics event:[AMCacheManage currentUserType] == UserStyleBusiness ? pv_4_3_IM_Chat_History_Shop_Nothing : pv_4_3_IM_Chat_History_User_Nothing];
                    
                } else {
                    [UMStatistics event:[AMCacheManage currentUserType] == UserStyleBusiness ? pv_4_3_IM_Chat_History_Shop : pv_4_3_IM_Chat_History_User];
                    
                }
                _isFirstLoadData = NO;
            }
            [[AMToastView toastView] performSelector:@selector(hide) withObject:nil afterDelay:0.4];
            
            //垫脚
            self.tvHistory.tableFooterView = self.vFooter;
            // 是否显示无数据提示
            self.vNoData.hidden = self.mHistory.count != 0;
            
        });
    });
    
}

- (void)getIMServiceInfo{
    
    if (!_serverHelper) {
        _serverHelper = [[APIHelper alloc] init];
    }
    
    __weak UCIMHistoryView *vSelf = self;
    [_serverHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        if (error) {
            [[AMToastView toastView] showMessage:@"链接失败，请稍后重试" icon:kImageRequestError duration:AMToastDurationNormal];
            return ;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase.returncode == 0) {
                IMUserInfoModel *mIMUser = [IMCacheManage currentIMUserInfo];
                mIMUser.server      = [mBase.result objectForKey:@"server"];
                mIMUser.port        = [mBase.result objectForKey:@"port"];
                mIMUser.domain      = [mBase.result objectForKey:@"domain"];
                mIMUser.imgupload   = [mBase.result objectForKey:@"imgupload"];
                mIMUser.imgprefix   = [mBase.result objectForKey:@"imgprefix"];
                mIMUser.voiceupload = [mBase.result objectForKey:@"voiceupload"];
                mIMUser.voiceprefix = [mBase.result objectForKey:@"voiceprefix"];
                
                [IMCacheManage setCurrentIMUserInfo:mIMUser];
                
                XMPPManager *xmpp = [XMPPManager sharedManager];
                [xmpp connectToServer];
//                BOOL connected = [xmpp connectToServer];
//                AMLog(@"*****XMPP Connected: %@ *****", (connected ? @"YES" : @"NO"));
                [xmpp addToDelegateQueue:vSelf];
                
                [vSelf getIMLinkerListWtihName:[IMCacheManage currentIMUserInfo].name page:[NSNumber numberWithInteger:1] index:[NSNumber numberWithInteger:10000]];
            }
        }
    }];
    [_serverHelper getIMServerInfo];
}

/** 获取联系人列表 */
- (void)getIMLinkerListWtihName:(NSString *)name page:(NSNumber *)page index:(NSNumber *)index
{
    if (!_apiContactList) {
        _apiContactList = [[APIHelper alloc] init];
    } else {
        [_apiContactList cancel];
    }
    
    __weak UCIMHistoryView *vSelf = self;
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在加载中…" cancel:^{
        [_apiContactList cancel];
        [[AMToastView toastView] hide];
    }];

    [_apiContactList setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 取消请求
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else{
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            }
            return;
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                // 处理成功
                if (mBase.returncode == 0) {
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"linkerlist"]) {
                            IMHistoryContactModel *contact = [[IMHistoryContactModel alloc] initWithJson:dicCarInfoTemp];
                            [[XMPPDBCacheManager sharedManager] updateContactWithIMHistoryModel:contact];
                        }
                        
                        //影响到UI更新的操作需要放到主线程
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [vSelf refreshCarList];
                        });
                    });
                }
                else if (mBase.message.length > 0){
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                } else {
                    [[AMToastView toastView] hide];
                }
            }
        }
    }];

    
    [_apiContactList getimlinkerlistWithMyName:name page:page index:index];
}

/** 补全信息 */
- (void)getContactInfoWithContacts:(NSArray *)contacts
{
    
    for (int i = 0; i < contacts.count; i++) {
        APIHelper *apiFillInfo = [[APIHelper alloc] init];
        __weak UCIMHistoryView *vSelf = self;
        [apiFillInfo setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
            
            if (apiHelper.data.length > 0) {
                BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
                if (mBase) {
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        // 处理成功
                        if (mBase.returncode == 0) {
                            IMHistoryContactModel *contact = [[IMHistoryContactModel alloc] initWithJson:mBase.result];
                            [[XMPPDBCacheManager sharedManager] updateContactWithIMHistoryModel:contact];
                        }
                        //影响到UI更新的操作需要放到线程
                        dispatch_sync(dispatch_get_main_queue(), ^{
                                [vSelf refreshCarList];
                        });
                    });
                    
                }
            }
        }];
        [apiFillInfo getIMLinkByNameFrom:[IMCacheManage currentIMUserInfo].name nameTo:[contacts objectAtIndex:i] memberID:nil dealerID:nil salesID:nil];
    }
}

-(void)dealloc
{
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];
    [[XMPPManager sharedManager] logout];
    [NSObject cancelPreviousPerformRequestsWithTarget:[AMToastView toastView]];
}

@end
