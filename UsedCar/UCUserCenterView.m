//
//  UCUserCenterView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCUserCenterView.h"
#import "UCTopBar.h"
#import "UIImage+Util.h"
#import "UCCarStatusListView.h"
#import "UCSetUpView.h"
#import "UCSalesListView.h"
#import "AMCacheManage.h"
#import "UCFavoritesView.h"
#import "UCAttentionView.h"
#import "UCMainView.h"
#import "UCSalesLeadsView.h"
#import "UCDealerDepositView.h"
#import "UCLoginClientView.h"
#import "UCLoginDealerView.h"
#import "CKRefreshTimeControl.h"
#import "UserCenterData.h"
#import "UCRetrieveCarValidateView.h"
#import "UCDealerShareMainView.h"
#import "UCSaleHelpView.h"
#import "UCContactUsView.h"
#import "UCIMRootEntry.h"
#import "IMCacheManage.h"

#define kItemStartTag                   30000
#define kItemCountStartTag              2000

@interface UCUserCenterView ()

@property (nonatomic, strong) UIView           *vUserCenter;
@property (nonatomic, strong) UIView           *vUserInfo;
@property (nonatomic, strong) UILabel          *labName;
@property (nonatomic, strong) UILabel          *labRefreshTime;
@property (nonatomic, strong) UCTopBar         *tbTop;
@property (nonatomic, strong) UIScrollView     *svMain;
@property (nonatomic, strong) UIView           *vScrollBg;
@property (nonatomic, strong) UserInfoView     *vUserInfo1;
@property (nonatomic, strong) InfoBarView      *vInfoBar;
@property (nonatomic, strong) CarStatusView    *vCarStatus3;
@property (nonatomic, strong) UIView *vDealerHelp;
//@property (nonatomic, strong) UIView           *vServicePhone;
@property (nonatomic, strong) UCContactUsView *vContactUs;
@property (nonatomic, strong) UCTopBar         *vTopBar;
@property (nonatomic, strong) CKRefreshTimeControl *pullRefresh;
@property (nonatomic, strong) UserCenterData *userCenterData;
@property (nonatomic) BOOL isNeedShowStatueBar;
@property (nonatomic) NSString *userkey;      // 本页存的userkey，和手机存储的userkey作对比，判断是否更改了用户
@property (nonatomic) NSInteger apiCount;       // 剩余请求接口数
@property (nonatomic) NSInteger clientFavoritesCount;
@property (nonatomic) BOOL isNeedShowLoad;      // 是否需要显示加载框，初始化视图强行等待1秒

@end

@implementation UCUserCenterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isNeedShowLoad = YES;
        _userStyle = [AMCacheManage currentUserType];
        [self initView];
    }
    return self;
}

-(void)setApiCount:(NSInteger)apiCount
{
    _apiCount = apiCount;
    if (_apiCount == 0) {
        if (self.pullRefresh.refreshing) {
            if (_isNeedShowLoad) {
                [_pullRefresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.4];
                _isNeedShowLoad = NO;
            } else {
                [_pullRefresh endRefreshing];
            }
        }
        [self updateUI];
    }
}

-(NSString *)userkey
{
    if (!_userkey) {
        _userkey = [[NSString alloc] init];
    }
    return _userkey;
}

-(UserCenterData *)userCenterData
{
    if (!_userCenterData) {
        _userCenterData = [[UserCenterData alloc] init];
    }
    return _userCenterData;
}

- (void)setUserStyle:(UserStyle)userStyle
{
    _userStyle = userStyle;
    
    /** 更新数据 */
    [self updateData];
}

-(void)setLeadsCount:(NSInteger)leadsCount
{
    _leadsCount = leadsCount;
    [self updateLeadsUIWithCount:_leadsCount];
}

-(void)setSubscribeCount:(NSInteger)subscribeCount
{
    _subscribeCount = subscribeCount;
    // 订阅的车
    [self updateSubscribeUIWithCount:_subscribeCount];
}

- (void)setImCount:(NSInteger)imCount
{
    
    _imCount = imCount;
    _vInfoBar.vChatPoint.hidden = (_imCount > 0 || [UCMainView sharedMainView].imCount > 0) ? NO : YES;
}

-(void)viewWillShow:(BOOL)animated
{
    NSString *localUserkey = [[NSString alloc] initWithFormat:@"%@", [AMCacheManage currentUserInfo].userkey];

    // 跟新销售代表数
    if (_userStyle != [AMCacheManage currentUserType] || (![localUserkey isEqualToString:self.userkey] && (localUserkey.length > 0 && self.userkey.length > 0))) {
        // 切换用户刷新数据设置为需要状态栏提示
        _isNeedShowStatueBar = YES;
        // 切换用户时销售线索、保证金、订阅数至空，防止相等数不提示的功能
        [UCMainView sharedMainView].leadsCount = 0;
        _leadsCount = 0;
        [UCMainView sharedMainView].claimCount = 0;
        _claimCount = 0;
        [UCMainView sharedMainView].subscribeCount = 0;
        _subscribeCount = 0;
        [UCMainView sharedMainView].imCount = 0;
        _imCount = 0;
        // 个人并且已同步，把收藏个数清空
        if ([AMCacheManage currentUserType] == UserStylePersonal) {
            _clientFavoritesCount = NSNotFound;
        }
        self.userStyle = [AMCacheManage currentUserType];
        _userkey = [AMCacheManage currentUserInfo].userkey;
        /** 迅速切换用户种类 */
        [self updateUI];
        [self scrollToTopView];
    } else if (!_isNeedShowLoad) {
        [self updateData];
    }
    
    switch (_userStyle) {
        case UserStyleNone:
            [UMStatistics event:pv_4_0_my_nouser];
            break;
        case UserStylePhone:
            [UMStatistics event:pv_4_0_my_person_phone];
            break;
        case UserStylePersonal:
            [UMStatistics event:pv_4_0_my_person];
            break;
        case UserStyleBusiness:
        
            break;
            
        default:
            break;
    }
}

- (void)viewDidShow:(BOOL)animated{
    // 软件重新进入, 页面就是当前页的时候去刷新
    NSInteger state = [AMCacheManage currentAppState];
    if (state == 1 && [AMCacheManage currentUserType] != UserStyleNone && _isNeedShowLoad == NO){
        [self updateUserInfo];
        [AMCacheManage setAppState:0];
    }
    
    //需求1：第一次登录商家中心弹注册IM页面
    if (_userStyle == UserStyleBusiness) {
        if (![IMCacheManage currentDealerCeneterIsUsed]) {
            UCIMRootEntry *imRootEntry = [[UCIMRootEntry alloc] init];
            [imRootEntry openVerifyDealerPermissionView];
            [IMCacheManage setCurrentDealerCenterIsUsed:YES];
        }
    }
}

-(void)viewWillHide:(BOOL)animated
{
    if (self.pullRefresh.refreshing) {
        [self.pullRefresh endRefreshing];
    }
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // 滑动视图
    _svMain = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height - kMainOptionBarHeight)];
    _svMain.showsVerticalScrollIndicator = NO;
    _svMain.backgroundColor = kColorBlue;
    // 滑动视图灰色背景
    _vScrollBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _vScrollBg.backgroundColor = kColorNewBackground;
    
    // 下拉刷新
    self.pullRefresh = [[CKRefreshTimeControl alloc] initInScrollView:_svMain];
    self.pullRefresh.titlePulling = @"下拉即可刷新";
    self.pullRefresh.titleReady = @"松开立即刷新";
    self.pullRefresh.titleRefreshing = @"正在加载中…";
    self.pullRefresh.tintColor = kColorWhite;
    
    [self.pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    // 顶部
    _vUserInfo1 = [[UserInfoView alloc] initWithUserStyle:_userStyle];
    _vUserInfo1.delegate = self;
    // 信息条
    _vInfoBar = [[InfoBarView alloc] initWithUserStyle:_userStyle];
    _vInfoBar.delegate = self;
    // 车源状态
    _vCarStatus3 = [[CarStatusView alloc] initWithUserStyle:_userStyle];
    _vCarStatus3.delegate = self;
    
    // 商家帮助
    if (_userStyle == UserStyleBusiness)
        _vDealerHelp = [self creatDealerHelpView:CGRectMake(0, _vCarStatus3.maxY + 20, self.width, 45)];
    
    // 联系电话
    _vContactUs = [[UCContactUsView alloc] initWithFrame:CGRectMake(0, 0, self.width, 90)
                                      withStatementArray:@[@"如有任何问题请在8:30-17:30联系",@"客服中心：010-59857661"]
                                          andPhoneNumber:@"01059857661"];
    
    [self addSubview:_tbTop];
    [self addSubview:_svMain];
    [_svMain addSubview:_vScrollBg];
    [_svMain addSubview:_vUserInfo1];
    [_svMain addSubview:_vInfoBar];
    [_svMain addSubview:_vCarStatus3];
    if (_userStyle == UserStyleBusiness)
        [_svMain addSubview:_vDealerHelp];
    [_svMain addSubview:_vContactUs];
    
    [self updateUI];
    [self onPull];

}

/** 商家帮助 */
- (UIView *)creatDealerHelpView:(CGRect)frame
{
    _vDealerHelp = [[UIView alloc] initWithFrame:frame];
    _vDealerHelp.backgroundColor = kColorWhite;
    
    NSArray *titles = @[@"售车帮助"];
    NSArray *images = @[@"my_list_salehelp"];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:_vDealerHelp.bounds];
        btnItem.backgroundColor = kColorWhite;
        btnItem.titleLabel.font = kFontLarge;
        [btnItem setTitleColor:kColorNewGray1 forState:UIControlStateNormal];
        [btnItem setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btnItem setImage:[UIImage imageNamed:[images objectAtIndex:i]] forState:UIControlStateNormal];
        [btnItem setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:btnItem.size] forState:UIControlStateHighlighted];
        btnItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btnItem setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
        [btnItem setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [btnItem addTarget:self action:@selector(onClickSaleHelpBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        // 箭头
        UIImage *imageArrow = [UIImage imageNamed:@"set_arrow_right"];
        UIImageView *ivArrow = [[UIImageView alloc] initWithImage:imageArrow];
        ivArrow.size = CGSizeMake(15, 15);
        ivArrow.origin = CGPointMake(self.width - 35 + 8, (btnItem.height - ivArrow.size.height) / 2);
        
        [btnItem addSubview:ivArrow];
        [_vDealerHelp addSubview:btnItem];
    }
    
    [_vDealerHelp addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, _vDealerHelp.width, kLinePixel) color:kColorNewLine]];
    [_vDealerHelp addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _vDealerHelp.height - kLinePixel, _vDealerHelp.width, kLinePixel) color:kColorNewLine]];
    
    return _vDealerHelp;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    _vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    NSString *strTitle = nil;
    switch (_userStyle) {
        case UserStyleNone:
            strTitle = @"我的";
            break;
        case UserStyleBusiness:
            strTitle = @"商家中心";
            break;
        case UserStylePersonal:
            strTitle = @"个人中心";
            break;
            
        default:
            break;
    }
    [_vTopBar.btnTitle setTitle:strTitle forState:UIControlStateNormal];
    [_vTopBar.btnRight setImage:[UIImage imageNamed:@"my_set"] forState:UIControlStateNormal];
    [_vTopBar.btnRight setImage:[UIImage imageNamed:@"my_set_pre"] forState:UIControlStateHighlighted];
    [_vTopBar.btnRight setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [_vTopBar.btnRight addTarget:self action:@selector(onClickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    return _vTopBar;
}

///** 创建客服电话视图 */
//- (id)creatServicePhoneViewWithSize:(CGSize)size
//{
//    UIView *vBody = [[UIView alloc] init];
//    vBody.size = size;
//    
//    UILabel *labText = [[UILabel alloc] init];
//    labText.backgroundColor = kColorClear;
//    labText.textColor = kColorNewGray2;
//    labText.font = kFontSmall;
//    labText.text = @"车源没有发布成功或找回密码请致电";
//    [labText sizeToFit];
//    labText.origin = CGPointMake(15, (vBody.height - labText.height) / 2 - 10);
//    
//    UILabel *labPhoe = [[UILabel alloc] init];
//    labPhoe.backgroundColor = kColorClear;
//    labPhoe.textColor = kColorNewGray1;
//    labPhoe.font = kFontSmall;
//    labPhoe.text = @"二手车之家服务电话：010-59857661";
//    [labPhoe sizeToFit];
//    labPhoe.origin = CGPointMake(15, (vBody.height - labPhoe.height) / 2 + 10);
//    
//    [vBody addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(vBody.width - 80, (vBody.height - 35) / 2, kLinePixel, 35) color:kColorNewLine]];
//    
//    UIImage *iPhone = [UIImage imageNamed:@"merchant home_tel_btn_icon"];
//    UIButton *btnPhone = [[UIButton alloc] initWithFrame:CGRectMake((vBody.width - 90 + (90 - iPhone.size.width) / 2), (vBody.height - iPhone.size.height) / 2, iPhone.width, iPhone.height)];
//    [btnPhone setImage:iPhone forState:UIControlStateNormal];
//    [btnPhone addTarget:self action:@selector(onClickPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [vBody addSubview:labText];
//    [vBody addSubview:labPhoe];
//    [vBody addSubview:btnPhone];
//    
//    return vBody;
//}

#pragma mark - onClickButton
/** 右按钮事件 */
- (void)onClickRightBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    // 设置
    UCSetUpView *vSetup = [[UCSetUpView alloc] initWithFrame:self.bounds];
    [[MainViewController sharedVCMain] openView:vSetup animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/** 售车帮助 */
- (void)onClickSaleHelpBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    UCSaleHelpView *vSaleHelp = [[UCSaleHelpView alloc] initWithFrame:self.bounds];
    [[MainViewController sharedVCMain] openView:vSaleHelp animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - public Method

#pragma mark - private Method
// 下拉刷新
- (void)onPull
{
    if ([AMCacheManage currentUserType] == UserStyleNone) {
        [UMSAgent postEvent:my_nouser_pv page_name:NSStringFromClass(self.class)];
    } else if ([AMCacheManage currentUserType] == UserStylePersonal) {
        [UMSAgent postEvent:my_person_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"userid#4", nil]];
    }
    
    // 为解决scrollview的contentsize大于scrollview.height时 beginRefresh失效，contentsize小于scrollview.height时不能下拉刷新
    _svMain.contentSize = CGSizeMake(_svMain.width, 0);
    _isNeedShowStatueBar = YES;
    [self.pullRefresh beginRefreshing];
    [self updateData];
}

/** 更新数据 */
- (void)updateData
{
    // 置空请求数量
    _apiCount = 0;
    
    // 获取用户信息
    [self updateUserInfo];
    
    // 商家有关数据
    if (_userStyle == UserStyleBusiness) {
        // 销售线索总数
        self.apiCount++;
        [[UCMainView sharedMainView] getSaleTotalNumber:NO block:^(BOOL isSuccess) {
            self.apiCount--;
        }];
        // 保证金总数
        if ([[AMCacheManage currentUserInfo].isbailcar integerValue] == 1) {
            self.apiCount++;
            [[UCMainView sharedMainView] getClaimCount:YES block:^(BOOL isSuccess) {
                self.apiCount--;
            }];
        }
    }
    
    // 个人收藏
    if (_userStyle == UserStylePersonal) {
        self.apiCount++;
        [self.userCenterData getClientFavorites:^(BOOL isSuccess, NSError *error, NSInteger count) {
            _clientFavoritesCount = count;
            self.apiCount--;
        }];
    }
    
    // 关注总数
    self.apiCount++;
    [[UCMainView sharedMainView] getAttentionCount:_isNeedShowStatueBar block:^(BOOL isSuccess) {
        self.apiCount--;
    }];
    
    // 未读消息
    self.apiCount ++;
    [[UCMainView sharedMainView] refreshRedPointAndUserCenterChatBarCountIfNeed];
    self.apiCount --;
    
    _isNeedShowStatueBar = NO;
}

/** 获取用户信息 */
- (void)updateUserInfo
{
    self.apiCount++;
    [self.userCenterData getUserInfo:_userStyle getUserInfo:^(BOOL isSuccess, NSError *error, BaseModel *mBase) {
        if (isSuccess) {
            self.apiCount--;
        } else {
            // 用户失效
            if (error.code == 2049005) {
                self.apiCount--;
                // 打开登录页
                if (_userStyle == UserStyleBusiness || _userStyle == UserStylePersonal) {
                    LoginButtonTag loginTag = _userStyle == UserStylePersonal ? LoginButtonTagClient : LoginButtonTagDealer;
                    [self openLoginViewWithLoginButtonTag:loginTag];
                }
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }

                // 更换用户信息
                [AMCacheManage setCurrentUserInfo:nil];
                self.userStyle = [AMCacheManage currentUserType];
            }
            else {
                if (error.domain.length > 0 && self.pullRefresh.refreshing) {
                    [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
                }
                self.apiCount--;
            }
        }
    }];
}

/** 更新UI */
- (void)updateUI
{
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    
    /** 更改标题 */
    switch (_userStyle) {
        case UserStyleNone:
        case UserStylePhone:
            [_vTopBar.btnTitle setTitle:@"我的" forState:UIControlStateNormal];
            break;
        case UserStyleBusiness:
            [_vTopBar.btnTitle setTitle:@"商家中心" forState:UIControlStateNormal];
            break;
        case UserStylePersonal:
            [_vTopBar.btnTitle setTitle:@"个人中心" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    /** 切换所有视图状态 */
    if (self.vUserInfo1) {
        [self.vUserInfo1.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.vUserInfo1 creatUserStyleViewWithUserStyle:_userStyle];
    }
    
    if (self.vInfoBar) {
        [self.vInfoBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.vInfoBar creatUserStyleViewWithUserStyle:_userStyle];
    }
    if (self.vCarStatus3) {
        [self.vCarStatus3.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.vCarStatus3 creatUserStyleViewWithUserStyle:_userStyle];
    }
    
    /** 更改用户信息栏 */
    switch (_userStyle) {
        case UserStyleBusiness:
            _vUserInfo1.labName.text = mUserInfo.username;
            break;
        case UserStylePersonal: {
            _vUserInfo1.labName.text = mUserInfo.username;
            [_vUserInfo1.labName sizeToFit];
            _vUserInfo1.labName.origin = CGPointMake(94, (_vUserInfo1.height - _vUserInfo1.labName.height) / 2 - 11);
            _vUserInfo1.labMobile.text = [NSString stringWithFormat:@"%@", mUserInfo.mobile];
            [_vUserInfo1.labMobile sizeToFit];
            _vUserInfo1.labMobile.origin = CGPointMake(94, (_vUserInfo1.height - _vUserInfo1.labMobile.height) / 2 + 11);
        }
            break;
            
        default:
            break;
    }
    
    /** 更改信息条 */
    // 销售代表
    [_vInfoBar getInfoBarCountLabelWithInfoBarButtonTag:InfoBarButtonTagSales].text = [NSString stringWithFormat:@"%d", mUserInfo.salespersonlist.count];
    // 销售线索
    [self updateLeadsUIWithCount:_leadsCount];
    // 保证金
    [self updateClaimUIWithCount:[UCMainView sharedMainView].claimCount];
    // 收藏的车
    NSInteger favoritesCount = _userStyle == UserStylePersonal ? _clientFavoritesCount : [[AMCacheManage currentFavourites] count];
    if (favoritesCount == NSNotFound)
        favoritesCount = 0;
    UILabel *labFavorites = [_vInfoBar getInfoBarCountLabelWithInfoBarButtonTag:InfoBarButtonTagFavourties];
    labFavorites.text = [NSString stringWithFormat:@"%d", favoritesCount];
    // 订阅的车
    [self updateSubscribeUIWithCount:_subscribeCount];
    // 咨询记录
    _vInfoBar.vChatPoint.hidden = (_imCount > 0 || [UCMainView sharedMainView].imCount > 0) ? NO : YES;
    
    if (_userStyle == UserStyleNone) {
        [_vCarStatus3.btnSetPhone setTitle:@"手机找车" forState:UIControlStateNormal];
    } else if (_userStyle == UserStylePhone) {
        [_vCarStatus3.btnSetPhone setTitle:@"更换手机" forState:UIControlStateNormal];
        [_vCarStatus3.btnMyCars setTitle:[NSString stringWithFormat:@"我卖的车(%@)", mUserInfo.username] forState:UIControlStateNormal];
    }
    
    /** 车源数 */
    _vCarStatus3.labRefreshTime.text = [NSString stringWithFormat:@"更新时间：%@", [OMG stringFromDateWithFormat:@"MM-dd HH:mm" date:[AMCacheManage currentLastRefreshUserInfoTime]]];
    
    // 各车辆数量
    NSArray *values = @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]];
    
    if (mUserInfo) {
        values = @[mUserInfo.carsaleing, mUserInfo.carnotpassed, mUserInfo.carsaled, [NSNumber numberWithInt:[AMCacheManage currentCarInfoEditDrafts].count], mUserInfo.carchecking, mUserInfo.carinvalid];
    }
    
    for (int i = 0; i < values.count; i++) {
        NSNumber *num = [values objectAtIndex:i];
        UILabel *labItemCount = [_vCarStatus3 getLabelWithCarStatusTag:CarStatusTagOnSale + i];
        labItemCount.text = [NSString stringWithFormat:@"%d", [num integerValue]];
    }
    
    // 商家售车帮助
    if (_userStyle == UserStyleBusiness && !_vDealerHelp) {
        _vDealerHelp = [self creatDealerHelpView:CGRectMake(0, _vCarStatus3.maxY + 20, self.width, 45)];
        [_svMain addSubview:_vDealerHelp];
    }
    else{
        if (_userStyle != UserStyleBusiness && _vDealerHelp) {
            [_vDealerHelp removeFromSuperview];
            _vDealerHelp = nil;
        }
    }
    
    // 联系电话
    NSString *title = @"如有任何问题请在8:30-17:30联系";
    NSString *text = @"客服中心：010-59857661";
    NSString *phoneNumber = @"01059857661";
    
    if (_userStyle == UserStyleBusiness && mUserInfo.adviser.name.length > 0 && mUserInfo.adviser.mobile.length > 0) {
        title = @"如有任何问题请联系区域经理";
        text = [NSString stringWithFormat:@"%@：%@", mUserInfo.adviser.name, mUserInfo.adviser.mobile];
        phoneNumber = mUserInfo.adviser.mobile;
    }
    [_vContactUs setViewWithStatementArray:@[title, text] andPhoneNumber:phoneNumber];
    
    // 修改frmae
    [self autoFitLayout];
}

- (void)scrollToTopView
{
    [_svMain setContentOffset:CGPointMake(0, 0)];
}

/** 修改frame */
- (void)autoFitLayout
{
    _vInfoBar.origin = CGPointMake(0, _vUserInfo1.maxY + ((_userStyle == UserStyleNone || _userStyle == UserStylePhone) ? 0 : 20));
    _vCarStatus3.minY = _vInfoBar.maxY + 20;
    if (_userStyle == UserStyleBusiness) {
        _vDealerHelp.minY = _vCarStatus3.maxY + 20;
        _vContactUs.minY = _vDealerHelp.maxY;
    } else {
        _vContactUs.minY = _vCarStatus3.maxY;
    }
    
    [self refreshMainScrollViewContentSize];

    if (_svMain.contentSize.height - 1 <= _svMain.height) {
        _vContactUs.minY = _svMain.height - _vContactUs.height;
    }
    _vScrollBg.height = _svMain.contentSize.height + self.height;
}

/** 设置scrollView滑动区域 */
- (void)refreshMainScrollViewContentSize
{
    if (_vContactUs.maxY < _svMain.height) {
        _svMain.contentSize = CGSizeMake(_svMain.width, _svMain.height + 1);
    } else {
        _svMain.contentSize = CGSizeMake(_svMain.width, _vContactUs.maxY);
    }
}

/** 更新销售线索UI */
- (void)updateLeadsUIWithCount:(NSInteger)count
{
    JSBadgeView *jsbItem = [_vInfoBar getInfoBarCountBubbleWithInfoBarButtonTag:InfoBarButtonTagLeads];
    
    if (jsbItem) {
        if (count == 0) {
            jsbItem.badgeText = nil;
        }
        else if (!(count > 99 && [jsbItem.badgeText isEqualToString:@"N"]) && count != [jsbItem.badgeText integerValue]) {
            jsbItem.badgeText = count > 99 ? @"N" : [NSString stringWithFormat:@"%d", count];
        }
    }
}

///** 更新咨询记录数 */
//- (void)updateChatHistorysUIWithCount:(NSInteger)count
//{
//    JSBadgeView *jsbItem = [_vInfoBar getInfoBarCountBubbleWithInfoBarButtonTag:InfoBarButtonTagChat];
//    
//    if (jsbItem) {
//        if (count == 0) {
//            jsbItem.badgeText = nil;
//        }
//        else if (!(count > 99 && [jsbItem.badgeText isEqualToString:@"N"]) && count != [jsbItem.badgeText integerValue]) {
////            jsbItem.badgeText = @"New";
//            jsbItem.badgeText = count > 99 ? @"N" : [NSString stringWithFormat:@"%d", count];
//        }
//    }
//}

/** 更新索赔UI */
- (void)updateClaimUIWithCount:(NSInteger)count
{
    JSBadgeView *jsbItem = [_vInfoBar getInfoBarCountBubbleWithInfoBarButtonTag:InfoBarButtonTagBail];
    
    if (jsbItem) {
        if (count == 0) {
            jsbItem.badgeText = nil;
        }
        else if (!(count > 99 && [jsbItem.badgeText isEqualToString:@"N"]) && count != [jsbItem.badgeText integerValue]) {
            jsbItem.badgeText = count > 99 ? @"N" : [NSString stringWithFormat:@"%d", count];
        }
    }
}

/** 更新订阅UI */
- (void)updateSubscribeUIWithCount:(NSInteger)count
{
    JSBadgeView *jsbAttention = [_vInfoBar getInfoBarCountBubbleWithInfoBarButtonTag:InfoBarButtonTagSubscribe];
    
    if (jsbAttention) {
        if (count == 0) {
            jsbAttention.badgeText = nil;
        }
        else if (!(count > 99 && [jsbAttention.badgeText isEqualToString:@"N"]) && count != [jsbAttention.badgeText integerValue]) {
            jsbAttention.badgeText = count > 99 ? @"N" : [NSString stringWithFormat:@"%d",count];
        }
    }
}

/** 更新车源数 */
- (void)updateCarSourceCount
{
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    
    // 各车辆数量
    NSArray *values = @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]];
    if (mUserInfo) {
        values = @[mUserInfo.carsaleing, mUserInfo.carsaled, mUserInfo.carchecking, mUserInfo.carnotpassed, [NSNumber numberWithInt:[AMCacheManage currentCarInfoEditDrafts].count], mUserInfo.carinvalid];
    }
    
    if (_userStyle != UserStyleNone) {
        // 更新时间
        NSString *updateTime = [OMG stringFromDateWithFormat:@"HH:mm" date:[AMCacheManage currentLastRefreshUserInfoTime]];
        _labRefreshTime.text = [NSString stringWithFormat:@"更新时间: %@", updateTime.length > 0 ? updateTime : @""];
    }
    
    // 车源数
    for (int i = 0; i < values.count; i++) {
        NSNumber *num = [values objectAtIndex:i];
        UILabel *labItemCount = (UILabel *)[self viewWithTag:kItemCountStartTag + i];
        labItemCount.text = [NSString stringWithFormat:@"%d", [num integerValue]];
    }
}

/** 打开登录页 */
- (void)openLoginViewWithLoginButtonTag:(LoginButtonTag)tag
{
    switch (tag) {
        case LoginButtonTagDealer:
            // 商家登录
        {
            [UMStatistics event:c_4_0_my_businessselogin];
            UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
            [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
            break;
        case LoginButtonTagClient:
            // 个人登录
        {
            [UMStatistics event:c_4_0_my_peronal];
            UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
            [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UserInfoViewDelegate
/** 登录 */
-(void)UserInfoView:(UserInfoView *)vUserInfo onClickLoginBtn:(UIButton *)btn
{
    [self openLoginViewWithLoginButtonTag:btn.tag];
}

#pragma mark - InfoBarView
-(void)infoBarView:(InfoBarView *)vInfoBar onClickInfoBarBtn:(UIButton *)btn
{
    switch (btn.tag) {
            // 销售代表
        case InfoBarButtonTagSales:
        {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            
            // 销售列表页
            UCSalesListView *vSalesList = [[UCSalesListView alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vSalesList animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
            
            // 进入添加代表页
            if (mUserInfo.salespersonlist.count == 0) {
                [UMStatistics event:c_3_6_buinesscenter_salesadded];
                UCAddSalesPerson *vAddSalesPerson = [[UCAddSalesPerson alloc] initWithFrame:self.bounds];
                vAddSalesPerson.delegate = vSalesList;
                [[MainViewController sharedVCMain] openView:vAddSalesPerson animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
            }
            
        }
            break;
            // 销售线索
        case InfoBarButtonTagLeads:
        {
            // 点击隐藏销售线索数
            [UMStatistics event:c_3_5_salesleads];
            
            // 更新最后点击时间
            [[UCMainView sharedMainView] getSaleTotalNumber:YES block:nil];
            
            self.leadsCount = 0;
            [UCMainView sharedMainView].leadsCount = 0;
            
            UCSalesLeadsView *vSaleLead = [[UCSalesLeadsView alloc] initWithFrame:[UCMainView sharedMainView].bounds];
            [[MainViewController sharedVCMain] openView:vSaleLead animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
            // 保证金
        case InfoBarButtonTagBail:
        {
            // 点击隐藏保证金线索数
            [UMStatistics event:c_3_9_2_buiness_bond];
            
            // 点击索赔数            
            UCDealerDepositView *deposit = [[UCDealerDepositView alloc] initWithFrame:[UCMainView sharedMainView].bounds claimCount:&_claimCount];
            [[MainViewController sharedVCMain] openView:deposit animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
            // 咨询记录
        case InfoBarButtonTagChat:
        {
            UCIMRootEntry *imRootEntry = [[UCIMRootEntry alloc] init];
            [imRootEntry openChatHistoryByVerified];
        }
            break;
            // 分享营销
        case InfoBarButtonTagShare:
        {
            [UMStatistics event:c_4_1_buiness_share_click];
            // 分享营销
            UCDealerShareMainView *vShare = [[UCDealerShareMainView alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vShare animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
            // 收藏的车
        case InfoBarButtonTagFavourties:
        {
            switch ([AMCacheManage currentUserType]) {
                case UserStylePhone:
                    [UMStatistics event:c_4_0_my_person_phone_favorites];
                    break;
                case UserStyleNone:
                    [UMStatistics event:c_4_0_my_nouser_favorites];
                    break;
                case UserStylePersonal:
                    [UMStatistics event:c_4_0_my_person_favorites];
                    break;
                case UserStyleBusiness:
                    [UMStatistics event:c_3_1_buinessfavoritesclick];
                    break;
                    
                default:
                    break;
            }
            
            UCFavoritesView *vFavorites = [[UCFavoritesView alloc] initWithFrame:self.bounds];
            [[MainViewController sharedVCMain] openView:vFavorites animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
            // 订阅的车
        case InfoBarButtonTagSubscribe:
        {
            switch ([AMCacheManage currentUserType]) {
                case UserStylePhone:
                    [UMStatistics event:c_4_0_my_person_phone_subscribe];
                    break;
                case UserStyleNone:
                    [UMStatistics event:c_4_0_my_nouser_subscribe];
                    break;
                case UserStylePersonal:
                    [UMStatistics event:c_4_0_my_person_subscribe];
                    break;
                case UserStyleBusiness:
                    [UMStatistics event:c_3_5_attentioncar];
                    break;
                    
                default:
                    break;
            }
            
            UCAttentionView *vAttention = [[UCAttentionView alloc] initWithFrame:self.bounds UCAttentionViewLeftButtonStyle:UCAttentionViewLeftButtonStyleBack];
            [[MainViewController sharedVCMain] openView:vAttention animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CarStatusViewDelegate
-(void)CarStatusView:(CarStatusView *)vCarStatus onClickMyCarButton:(UIButton *)btn
{
    UCRetrieveCarValidateView *vVerifyMobile = [[UCRetrieveCarValidateView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
    [[MainViewController sharedVCMain] openView:vVerifyMobile animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

-(void)CarStatusView:(CarStatusView *)vCarStatus onClickSetPhoneButton:(UIButton *)btn
{
    if ([AMCacheManage currentUserType] == UserStyleNone) {
        [UMStatistics event:c_4_0_my_nouser_phone];
    } else if ([AMCacheManage currentUserType] == UserStylePhone) {
        [UMStatistics event:c_4_0_my_person_phone_changephone];
    }
    UCRetrieveCarValidateView *retrieveCarView = [[UCRetrieveCarValidateView alloc] initWithFrame:self.bounds];
    [[MainViewController sharedVCMain] openView:retrieveCarView animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
}

/** 进入车源列表页 */
-(void)CarStatusView:(CarStatusView *)vCarStatus onClickCarStatusButton:(UIButton *)btn indexOfButton:(NSUInteger)index
{
    if ([AMCacheManage currentUserType] == UserStylePersonal) {
        switch (index) {
            case 0:
                [UMStatistics event:c_4_0_my_person_thecarsource];
                break;
            case 1:
                [UMStatistics event:c_4_0_my_person_notsource];
                break;
            case 2:
                [UMStatistics event:c_4_0_my_person_soldcarsource];
                break;
            case 3:
                [UMStatistics event:c_4_0_my_person_withoutsource];
                break;
            case 4:
                [UMStatistics event:c_4_0_my_person_reviewsource];
                break;
            case 5:
                [UMStatistics event:c_4_0_my_person_expiredsource];
                break;
                
            default:
                break;
        }
    }
    else if ([AMCacheManage currentUserType] == UserStylePhone) {
        switch (index) {
            case 0:
                [UMStatistics event:c_4_0_my_person_phone_thecarsource];
                break;
            case 1:
                [UMStatistics event:c_4_0_my_person_phone_notsource];
                break;
            case 2:
                [UMStatistics event:c_4_0_my_person_phone_soldcarsource];
                break;
            case 3:
                [UMStatistics event:c_4_0_my_person_phone_withoutsource];
                break;
            case 4:
                [UMStatistics event:c_4_0_my_person_phone_reviewsource];
                break;
            case 5:
                [UMStatistics event:c_4_0_my_person_phone_expiredsource];
                break;
                
            default:
                break;
        }
    }
    
    UCCarStatusListViewStyle style = index + 1;
    
    UCCarStatusListView *vCarStatusList = [[UCCarStatusListView alloc] initWithFrame:self.bounds carStatusListViewStyle:style];
    [[MainViewController sharedVCMain] openView:vCarStatusList animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - UCLoginClientViewDelegate
-(void)UCLoginClientView:(UCLoginClientView *)vLoginClient onClickLoginButton:(UIButton *)btnLogin
{
    [UMStatistics event:c_4_0_login_personlogin];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
}

@end
