//
//  UCMainView.m
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCMainView.h"
#import "UIImage+Util.h"
#import "AMBlurView.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UCUserCenterView.h"
#import "UCRaiderView.h"
#import "UCSaleCarRootView.h"
#import "APIHelper.h"
#import "CustomStatusBar.h"
#import "UCAttentionView.h"
#import "AppDelegate.h"
#import "UCToolsView.h"
#import "UCClaimRecordView.h"
#import "UserLogInOutHelper.h"
#import "UCSalesLeadsView.h"
#import "UCIMHistoryView.h"
#import "XMPPDBCacheManager.h"
#import "XMPPManager.h"

@interface UCMainView ()

@property (nonatomic, strong) UIView            *vMain;
@property (nonatomic, strong) UCOptionBar       *obTab;
@property (strong, nonatomic) UCToolsView       *vTools;
@property (nonatomic, strong) UCUserCenterView  *vUserCenter;
@property (nonatomic, strong) UCRaiderView      *vRaider;
@property (nonatomic, strong) UCSaleCarRootView *vSaleCarRoot;
@property (nonatomic, strong) NSTimer           *tAttention;
@property (nonatomic, strong) APIHelper         *apiAttention;
@property (nonatomic, strong) APIHelper         *apiSales;
@property (nonatomic, strong) APIHelper         *apiClaim;

@property (nonatomic) BOOL isCloseRecord;

@property (nonatomic, strong) CustomStatusBar *csb;

@end

@implementation UCMainView

static UCMainView *mainView = nil;
+ (UCMainView *)sharedMainView
{
    return mainView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imCount = _leadsCount = _subscribeCount = _claimCount = _imPushCount = 0;
        mainView = self;
        [self initView];
    }
    return self;
}

-(void)setClaimCount:(NSInteger)claimCount
{
    _claimCount = claimCount;
    if (self.vUserCenter)
        [self.vUserCenter updateClaimUIWithCount:_claimCount];
}

-(void)viewWillClose:(BOOL)animated
{
    [super viewWillClose:animated];
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];

}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorBlue3;
    
    // 主视图
    _vMain = [[UIView alloc] initWithFrame:self.bounds];
    _vMain.clipsToBounds = YES;
    
    // 动态内容区
    _vContent = [[UIView alloc] initWithFrame:_vMain.bounds];
    
    // 选项栏
    _obTab = [[UCOptionBar alloc] initWithFrame:CGRectMake(0, self.height - kMainOptionBarHeight, self.width, kMainOptionBarHeight)];
    [_obTab addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _obTab.width, kLinePixel) color:kColorNewLine]];
    _obTab.delegate = self;
    
    NSArray *imgs = @[@"home_buy_btn", @"home_sell_btn", @"home_tool_btn", @"home_strategys_btn", @"home_my_btn"];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < imgs.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.image = [UIImage imageNamed:imgs[i]];
        item.imageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_h", imgs[i]]];
        [items addObject:item];
    }
    
	[_obTab setItems:items];
    // 屏蔽记录事件
    _isCloseRecord = YES;
    
    [_obTab selectItemAtIndex:0];
    
    // 关注提示小红点
    UIImage *iPoint = [UIImage imageAutoNamed:@"home_point"];
    _ivPoint = [[UIImageView alloc] initWithImage:iPoint];
    _ivPoint.origin = CGPointMake(_obTab.width - iPoint.width - 8, 4);
    _ivPoint.hidden = YES;
    
    [_obTab addSubview:_ivPoint];
    [_vMain addSubview:_vContent];
    [_vMain addSubview:_obTab];
    
    [self addSubview:_vMain];
    
    // 使用过软件时开启定时器，没使用过时关闭介绍页启动定时器
    if ([AMCacheManage currentIsUsed]) {
        [self startTimer];
    }
    
    [[XMPPManager sharedManager] connectToServer];
    [[XMPPManager sharedManager] addToDelegateQueue:self];
    
    // 是否显示红点
    [self refreshRedPointAndUserCenterChatBarCountIfNeed];

}

#pragma mark - Public Method
/** 开启定时器 */
- (void)startTimer
{
    // 开启定时器
    _tAttention = [NSTimer scheduledTimerWithTimeInterval:kAttentionRefreshTime target:self selector:@selector(refreshCount) userInfo:nil repeats:YES];
    [_tAttention fire];
}

/** 设置是否隐藏标签栏 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kAnimateSpeedFast];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    if (hidden)
        _obTab.minY = self.height;
    else
        _obTab.minY = self.height - _obTab.height;
    
    if (animated)
        [UIView commitAnimations];
}

/** 刷新我的页面 */
- (void)reloadUserCenterView
{
    if (_vUserCenter) {
        [_vUserCenter removeFromSuperview];
        _vUserCenter = nil;
    }
}

#pragma mark - Private Method
/** 获取关注数和销售线索数 */
- (void)refreshCount
{
    // 同步个人订阅和车源
    if ([AMCacheManage currentUserType] == UserStylePersonal) {
        if ([AMCacheManage SYNCclientSubscriptionNeeded] && [AMCacheManage SYNCclientSubscriptionSuccess] == NO) {
            [UserLogInOutHelper clientSyncSubscription];
        }
        if ([AMCacheManage SYNCclientCarNeeded] && [AMCacheManage SYNCclientCarSuccess] == NO) {
            [UserLogInOutHelper clientSyncCar];
        }
    }
    
    // 刷新关注总数
    [self getAttentionCount:YES block:nil];
    // 刷新销售总数
    if ([AMCacheManage currentUserType] == UserStyleBusiness)
        [self getSaleTotalNumber:NO block:nil];
    
    if ([AMCacheManage currentUserType] == UserStyleBusiness)
        [self getClaimCount:YES block:nil];
    
}

/** 从新车报价来,显示指定数据 */
- (BOOL)searchCarListFromCarPriceApp
{
    BOOL isCanLaunch = YES;
    
    // filterModel & areaModel
    NSArray *conditions = [OMG getFilterModelAndAreaModelArrayWithUrl:[AppDelegate sharedAppDelegate].strCarPriceSearchUrl];
    
    // 数据正确
    if (conditions.count == 2) {
        // 回到首页
        [_obTab selectItemAtIndex:0];
        if ([[MainViewController sharedVCMain].vMain subviews].count > 1)
            [[MainViewController sharedVCMain] closeView:[[[MainViewController sharedVCMain].vMain subviews] objectAtIndex:1] animateOption:AnimateOptionMoveNone];
        
        // 刷新列表 & 重置已选UI
        UCFilterModel *mFilter = [conditions objectAtIndex:0];
        if (mFilter.brandid.integerValue == 0 || mFilter.brandid.length == 0 || mFilter.seriesid.integerValue == 0 || mFilter.seriesid.length == 0 || mFilter.specid.integerValue == 0 || mFilter.specid.length == 0) {
            mFilter = nil;
        }
        UCAreaMode *mArea = [conditions objectAtIndex:1];
        if ((mArea.pid.integerValue == 0 || mArea.pid.length == 0) && mArea.cid.integerValue > 0) {
            mArea = nil;
        }
        [_vHome reloadCarListByFilter:mFilter UCAreaModel:[conditions objectAtIndex:1]];
    }
    // 数据错误
    else {
        isCanLaunch = NO;
    }
    // 清除本地url
    [AppDelegate sharedAppDelegate].strCarPriceSearchUrl = nil;
    
    return isCanLaunch;
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    if (optionBar.lastSelectedItemIndex != index) {
        if (index == 0) {
            // 屏蔽初始化时记录
            if (_isCloseRecord)
                _isCloseRecord = NO;
            else
                [UMStatistics event:c_3_1_homeclick];
            if (!_vHome) {
                _vHome = [[UCHomeView alloc] initWithFrame:_vContent.bounds];
                [MainViewController sharedVCMain].welcomeDelegate = _vHome;
            }
            [[MainViewController sharedVCMain] replaceView:[_vContent subviews].lastObject withView:_vHome superview:_vContent];
        } else if (index == 1) {
            [UMStatistics event:c_3_1_salecarclick];
            [UMStatistics event:pv_4_0_salecar];
            [UMSAgent postEvent:salecar_pv page_name:NSStringFromClass(self.class)];
            if (!_vSaleCarRoot)
                _vSaleCarRoot = [[UCSaleCarRootView alloc] initWithFrame:_vContent.bounds fromView:UCSaleCarRootViewFromRootView];
            [[MainViewController sharedVCMain] replaceView:[_vContent subviews].lastObject withView:_vSaleCarRoot superview:_vContent];
        } else if (index == 2) {
            [UMStatistics event:c_3_9_2_tool];
            [UMStatistics event:pv_3_9_2_tool];

            if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                [UMSAgent postEvent:tool_pv page_name:NSStringFromClass(self.class)
                         eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     mUserInfo.userid, @"dealerid#5",
                                     mUserInfo.userid, @"userid#4", nil]];
            } else {
                [UMSAgent postEvent:tool_pv page_name:NSStringFromClass(self.class)];
            }
            if (!_vTools) {
                _vTools = [[UCToolsView alloc] initWithFrame:_vContent.bounds];
            }
            [[MainViewController sharedVCMain] replaceView:[_vContent subviews].lastObject withView:_vTools superview:_vContent];
            
            
        } else if (index == 3) {
            [UMStatistics event:c_3_1_mustseeclick];
            if (!_vRaider) {
                _vRaider = [[UCRaiderView alloc] initWithFrame:_vContent.bounds];
            }
            else {
                _vRaider.isRecord = YES;
                [_vRaider recordMustSeeEvent];
            }
            [[MainViewController sharedVCMain] replaceView:[_vContent subviews].lastObject withView:_vRaider superview:_vContent];
        } else if (index == 4) {
            [UMStatistics event:c_3_1_personclick];
            if (!_vUserCenter) {
                _vUserCenter = [[UCUserCenterView alloc] initWithFrame:_vContent.bounds];
                _vUserCenter.claimCount = _claimCount;
            } else {
                
                UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                switch ([AMCacheManage currentUserType]) {
                    case UserStyleNone:
                        [UMSAgent postEvent:my_nouser_pv page_name:NSStringFromClass(self.class)];
                        break;
                    case UserStylePersonal:
                        [UMSAgent postEvent:my_person_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:mUserInfo.userid, @"userid#4", nil]];
                        break;
                    case UserStyleBusiness:
                        
                        break;
                    case UserStylePhone:
                        break;
                        
                    default:
                        break;
                }
            }
            
            //!!! 关注数/销售/保证金 的点击后进入页面的处理
            // 隐藏红点
            _ivPoint.hidden = YES;
            // 更新关注数
            _vUserCenter.subscribeCount = _subscribeCount;
            // 更新销售
            _vUserCenter.leadsCount = _leadsCount;
            //保证金
            // 保证金和关注、销售线索不同，保证金特殊控制，因为页面里还有个count值。
            [_vUserCenter updateClaimUIWithCount:_claimCount];
            // IM
            _vUserCenter.imCount = _imCount;
            
            [[MainViewController sharedVCMain] replaceView:[_vContent subviews].lastObject withView:_vUserCenter superview:_vContent];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 接受touch事件
    if (touch.view == self)
        return YES;
    return NO;
}

#pragma mark - APIHelper
/** 定时器 */
- (void)getAttentionCount:(BOOL)isShowStatusBar block:(GetAttentionCountBlock)block
{
    if (block) {
        self.blockAttention = block;
    }
    
    if (!_apiAttention)
        _apiAttention = [[APIHelper alloc] init];
    else
        [_apiAttention cancel];
    
    __weak UCMainView *vMain = self;
    
    // 设置请求完成后回调方法
    [_apiAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            // 调用block
            if (vMain.blockAttention) {
                vMain.blockAttention(NO);
                vMain.blockAttention = nil;
            }
            AMLog(@"%@",error.domain);
            return;
        }
        // 正常返回
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSInteger subscribeCount = [[mBase.result objectForKey:@"allcount"] integerValue];
                    
                    // 状态栏提示更新
                    if (isShowStatusBar && subscribeCount !=0 && vMain.subscribeCount != subscribeCount)
                    {
                        [vMain showUpdateInfoInStatusBar:subscribeCount];
                    }
                    vMain.subscribeCount = subscribeCount;
                    
                    // 小红点
                    vMain.ivPoint.hidden = (vMain.subscribeCount + vMain.leadsCount + vMain.imCount > 0 && [vMain.obTab selectedItemIndex] != 4) ? NO : YES;
                    if ([vMain.obTab selectedItemIndex] == 4) {
                        vMain.vUserCenter.subscribeCount = vMain.subscribeCount;
                    }
                    
                    // 调用block
                    if (vMain.blockAttention) {
                        vMain.blockAttention(YES);
                        vMain.blockAttention = nil;
                    }
                    
                } else {
                    // 调用block
                    if (vMain.blockAttention) {
                        vMain.blockAttention(NO);
                        vMain.blockAttention = nil;
                    }
                    AMLog(@"链接成功，请求失败");
                }
            } else {
                // 调用block
                if (vMain.blockAttention) {
                    vMain.blockAttention(NO);
                    vMain.blockAttention = nil;
                }
            }
        }
    }];
    
    [_apiAttention getAttentionCount];
}

/** 获取保证金数 */
- (void)getClaimCount:(BOOL)isShowStatusBar block:(GetClaimCountBlock)block
{
    if (block) {
        self.blockClaim = block;
    }
    
    if (!_apiClaim)
        _apiClaim = [[APIHelper alloc] init];
    else
        [_apiClaim cancel];
    
    __weak typeof(self) weakSelf = self;
    [_apiClaim setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            // 调用block
            if (weakSelf.blockClaim) {
                weakSelf.blockClaim(NO);
                weakSelf.blockClaim = nil;
            }
            return;
        }
        // 正常返回
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    
                    NSDictionary *result = mBase.result;
                    NSInteger count = [[result objectForKey:@"count"] integerValue];
                    
                    // 状态栏提示更新
                    if (isShowStatusBar && count != 0 && count != weakSelf.claimCount)
                    {
                        [weakSelf showUpdateClaimInStatusBar:count];
                    }
                    weakSelf.claimCount = count;
                    
                    // 小红点
                    weakSelf.ivPoint.hidden = (weakSelf.subscribeCount + weakSelf.leadsCount + weakSelf.imCount > 0 && [weakSelf.obTab selectedItemIndex] != 4) ? NO : YES;
                    if ([weakSelf.obTab selectedItemIndex] == 4) {
                        weakSelf.vUserCenter.claimCount = weakSelf.claimCount;
                    }
                    
                    // 调用block
                    if (weakSelf.blockClaim) {
                        weakSelf.blockClaim(YES);
                        weakSelf.blockClaim = nil;
                    }
                    
                } else {
                    AMLog(@"链接成功，请求失败");
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                    
                    // 调用block
                    if (weakSelf.blockClaim) {
                        weakSelf.blockClaim(NO);
                        weakSelf.blockClaim = nil;
                    }
                }
            } else {
                // 调用block
                if (weakSelf.blockClaim) {
                    weakSelf.blockClaim(NO);
                    weakSelf.blockClaim = nil;
                }
            }
        }
    }];
    
    [_apiClaim getDealerClaimCountWithUserKey:[AMCacheManage currentUserInfo].userkey];
    
}

/** 销售线索的数量 */
- (void)getSaleTotalNumber:(BOOL)isClickSales block:(GetSaleTotalCountBlock)block;
{
    if (block) {
        self.blockSaleTotal = block;
    }
    
    if (!_apiSales)
        _apiSales = [[APIHelper alloc] init];
    else
        [_apiSales cancel];
    
    __weak UCMainView *vMain = self;
    
    // 设置请求完成后回调方法
    [_apiSales setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 调用block
            if (vMain.blockSaleTotal) {
                vMain.blockSaleTotal(NO);
                vMain.blockSaleTotal = nil;
            }
            return;
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSString *salesDate = [mBase.result objectForKey:@"lastdate"];
                    // 后台刷新
                    if (isClickSales == NO) {
                        vMain.leadsCount = [[mBase.result objectForKey:@"offercount"] integerValue] ;
                        // 小红点
                        vMain.ivPoint.hidden = (vMain.subscribeCount + vMain.leadsCount + vMain.imCount > 0 && [vMain.obTab selectedItemIndex] != 4) ? NO : YES;
                        
                        // 只在我的页面时刷新销售线索数
                        if ([vMain.obTab selectedItemIndex] == 4) {
                            vMain.vUserCenter.leadsCount = vMain.leadsCount;
                        }
                    }
                    // 点击销售线索按钮
                    else {
                        // 判断如果是点击了销售按钮就把lastDate存入缓存
                        [[NSUserDefaults standardUserDefaults] setValue:salesDate forKey:@"salesDate"];
                    }
                    
                    // 调用block
                    if (vMain.blockSaleTotal) {
                        vMain.blockSaleTotal(YES);
                        vMain.blockSaleTotal = nil;
                    }

                } else {
                    // 调用block
                    if (vMain.blockSaleTotal) {
                        vMain.blockSaleTotal(NO);
                        vMain.blockSaleTotal = nil;
                    }
                }
            } else {
                // 调用block
                if (vMain.blockSaleTotal) {
                    vMain.blockSaleTotal(NO);
                    vMain.blockSaleTotal = nil;
                }
            }
        }
    }];
    
    [_apiSales getSaleTotalNumber:[[NSUserDefaults standardUserDefaults] valueForKey:@"salesDate"]];
}

/** 获得IM未读消息数 */
- (void)refreshRedPointAndUserCenterChatBarCountIfNeed
{
    NSInteger unNum = 0;
    
    NSArray *contacts = [[XMPPDBCacheManager sharedManager] allContacts];
    
    if (contacts) {
        for (int i = 0 ; i < contacts.count; i++) {
            StorageContact *contact = [contacts objectAtIndex:i];
            unNum += contact.unReadNum;
        }
        self.imCount = unNum;
    }
    else {
        self.imCount = 0;
    }
    
    // 只在我的页面时刷新聊天记录数
    if ([self.obTab selectedItemIndex] == 4) {
        self.vUserCenter.imCount = self.imCount + _imPushCount;
        self.ivPoint.hidden = YES;
    } else {
        // 小红点
        self.ivPoint.hidden = (self.subscribeCount + self.leadsCount + self.imCount > 0 && [self.obTab selectedItemIndex] != 4) ? NO : YES;
    }
    
    
}

/** 提示有新关注车辆 */
- (void)showUpdateInfoInStatusBar:(NSInteger)count
{
    if (count > 0) {
        // 过滤弹出关注列表页
        BOOL isContentAttentionView = NO;
        for (id vTemp in [MainViewController sharedVCMain].vMain.subviews) {
            if ([vTemp isKindOfClass:[UCAttentionView class]]) {
                isContentAttentionView = YES;
                break;
            }
        }
        
        if (!_csb) {
            _csb = [[CustomStatusBar alloc] initWithFrame:CGRectMake(self.width - 115, 0, 115, 20)];
            _csb.animationTime = 2;
        }
        _csb.btnStatusMsg.enabled = !isContentAttentionView;
        __weak UCMainView *vMain = self;
        [_csb showStatusMessage:[NSString stringWithFormat:@"您订阅的车源有更新了"] onClickStatueBar:^{
            // 刷新红点判断销售线索数量和索赔数量是否存在
            if (vMain.leadsCount == 0 && vMain.claimCount == 0)
                vMain.ivPoint.hidden = YES;
            
            // 隐藏我的关注数
            vMain.subscribeCount = 0;
            vMain.vUserCenter.subscribeCount = 0;
            
            // 关注列表
            UCAttentionView *vAttention = [[UCAttentionView alloc] initWithFrame:vMain.bounds UCAttentionViewLeftButtonStyle:UCAttentionViewLeftButtonStyleClose];
            vAttention.viewStyle = UCAttentionViewSytleMainView;
            [[MainViewController sharedVCMain] openView:vAttention animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }];
    }
}

/** 提示有保证金车辆 */
- (void)showUpdateClaimInStatusBar:(NSInteger)count
{
    if (count > 0) {
        // 过滤弹出关注列表页
        BOOL isClaimView = NO;
        for (id vTemp in [MainViewController sharedVCMain].vMain.subviews) {
            if ([vTemp isKindOfClass:[UCClaimRecordView class]]) {
                isClaimView = YES;
                break;
            }
        }
        
        if (!_csb) {
            _csb = [[CustomStatusBar alloc] initWithFrame:CGRectMake(self.width - 115, 0, 115, 20)];
            _csb.animationTime = 2;
        }
        _csb.btnStatusMsg.enabled = !isClaimView;
        
        __weak UCMainView *vMain = self;
        [_csb showStatusMessage:[NSString stringWithFormat:@"您收到新的投诉"] onClickStatueBar:^{
            // 刷新红点判断销售线索数量和关注数量是否存在
            if (vMain.leadsCount == 0 && vMain.subscribeCount == 0)
                vMain.ivPoint.hidden = YES;
            
            vMain.claimCount = 0;
            vMain.vUserCenter.claimCount = 0;
            
            // 保证金投诉列表
            UCClaimRecordView *claimRecordView = [[UCClaimRecordView alloc] initWithFrame:vMain.bounds withStyle:UCClaimRecordViewStylePopUp ClaimType:ClaimListTypeOnGoing];
            [[MainViewController sharedVCMain] openView:claimRecordView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }];
    }
}

#pragma mark - 收到 PUSH 后的状态更新操作
/** 得到新推送后, 更新红点儿等提示状态 **/
-(void)updateStatusBarForPushNotificationWithInfo:(NSDictionary *)userInfo{
    
    /**
     *  type: 1 车源关注 2 未完结投诉 3 已完结投诉
     */
    NSInteger type = [[userInfo objectForKey:@"t"] integerValue];
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *alert = [aps objectForKey:@"alert"];
    
    switch (type) {
        case 1:
            // type 1 刷新关注数
        {
            [self updateAttentionAfterPUSH];
        }
            break;
        case 2:
        {
            [self updateClaimCountAfterPUSH];
        }
            break;
        case 3:
        {
            [self updateClaimCountAfterPUSH];
        }
            break;
        case 4:
        {
            self.vUserCenter.imCount = self.imCount = _imPushCount = [[aps objectForKey:@"badge"] integerValue];
            self.ivPoint.hidden = (self.subscribeCount + self.leadsCount + self.imCount > 0 && [self.obTab selectedItemIndex] != 4) ? NO : YES;
            return;
        }
            break;
        case 5:
        {
            alert = [alert substringToIndex:8];
        }
        default:
            break;
    }
    self.ivPoint.hidden = NO;
    
    if (!_csb) {
        _csb = [[CustomStatusBar alloc] initWithFrame:CGRectMake(self.width - 115, 0, 115, 20)];
        _csb.animationTime = 2;
    }
    [_csb showStatusMessage:alert onClickStatueBar:^{
        switch (type) {
            case 1:
            {
                // 关注列表
                UCAttentionView *vAttention = [[UCAttentionView alloc] initWithFrame:self.bounds UCAttentionViewLeftButtonStyle:UCAttentionViewLeftButtonStyleClose];
                vAttention.viewStyle = UCAttentionViewSytleMainView;
                [[MainViewController sharedVCMain] openView:vAttention animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
                break;
            case 2:
            {
                // 保证金投诉列表
                UCClaimRecordView *claimRecordView = [[UCClaimRecordView alloc] initWithFrame:self.bounds withStyle:UCClaimRecordViewStylePopUp ClaimType:ClaimListTypeOnGoing];
                [[MainViewController sharedVCMain] openView:claimRecordView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
                break;
            case 3:
            {
                // 保证金已完结列表
                UCClaimRecordView *claimRecordView = [[UCClaimRecordView alloc] initWithFrame:self.bounds withStyle:UCClaimRecordViewStylePopUp ClaimType:ClaimListTypeFinished];
                [[MainViewController sharedVCMain] openView:claimRecordView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
                break;
            case 4:
            {
                // IM
                UCIMHistoryView *vIMHistory = [[UCIMHistoryView alloc] initWithFrame:self.frame];
                [[MainViewController sharedVCMain] openView:vIMHistory animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
                break;
            case 5:
            {
                UCSalesLeadsView *leadView = [[UCSalesLeadsView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds backButtonType:BackButtonTypeClose];
                [[MainViewController sharedVCMain] openView:leadView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
            }
            default:
                break;
        }
    }];
   
}

-(void)updateAttentionAfterPUSH{
    if (!_apiAttention)
        _apiAttention = [[APIHelper alloc] init];
    else
        [_apiAttention cancel];
    
    __weak UCMainView *vMain = self;
    
    // 设置请求完成后回调方法
    [_apiAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        
        // 正常返回
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    NSInteger attentionCount = [[mBase.result objectForKey:@"allcount"] integerValue];
                    vMain.subscribeCount = attentionCount;
                    vMain.vUserCenter.subscribeCount = vMain.subscribeCount;
                    
                } else {
                    AMLog(@"链接成功，请求失败");
                }
            }
        }
    }];
    
    [_apiAttention getAttentionCount];
}

// 注意: 本接口获取的是为查看的 未完结 & 已完结 的总数
-(void)updateClaimCountAfterPUSH{
    if (!_apiClaim)
        _apiClaim = [[APIHelper alloc] init];
    else
        [_apiClaim cancel];
    
    __weak typeof(self) weakSelf = self;
    [_apiClaim setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            AMLog(@"%@",error.domain);
            return;
        }
        // 正常返回
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    
                    NSDictionary *result = mBase.result;
                    NSInteger count = [[result objectForKey:@"count"] integerValue];
                    weakSelf.claimCount = count;
                    
                    weakSelf.vUserCenter.claimCount = weakSelf.claimCount;
                    [weakSelf.vUserCenter updateClaimUIWithCount:weakSelf.claimCount];
                    
                } else {
                    AMLog(@"链接成功，请求失败");
                    if (mBase.message) {
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                    }
                    else{
                        [[AMToastView toastView] hide];
                    }
                }
            }
        }
    }];
    
    [_apiClaim getDealerClaimCountWithUserKey:[AMCacheManage currentUserInfo].userkey];
    
}

-(void)setAttentionCountToZero{
    
    // 隐藏我的关注数
    if (self.claimCount==0 && self.leadsCount == 0) {
        self.ivPoint.hidden = YES;
    }
    
    self.subscribeCount = 0;
    self.vUserCenter.subscribeCount = 0;
}

-(void)setclaimCountToZero{
    
    //隐藏我的投诉数
    if (self.subscribeCount == 0 && self.leadsCount == 0) {
        self.ivPoint.hidden = YES;
    }
    
    self.claimCount = 0;
    self.vUserCenter.claimCount = 0;
}

#pragma mark - XMPP Connection Delegate
- (void)didReceiveMessage:(StorageMessage *)message{
    _imPushCount = 0;
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [[XMPPManager sharedManager] removeFromDelegateQueue:self];

}

@end
