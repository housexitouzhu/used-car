//
//  UCCarStatusListView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCCarStatusListView.h"
#import "UCTopBar.h"
#import "APIHelper.h"
#import "UIImage+Util.h"
#import "UCSaleCarView.h"
#import "AMCacheManage.h"
#import "CKRefreshControl.h"
#import "UCUserCenterView.h"
#import "UCCarInfoEditModel.h"
#import "UCCarStatusInfoCell.h"
#import "UCUserCarDetailView.h"
#import "UCLoginClientView.h"
#import "UCLoginDealerView.h"

#define kListPageSize       30
#define kMoreViewHeight     90
#define kLoadViewHeight     40
#define kBtnMenuTag         23345000

@interface UCCarStatusListView ()<UCLoginDealerViewDelegate, UCLoginClientViewDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UIView *vContent;
@property (nonatomic, strong) NSMutableArray *mCarLists;
@property (nonatomic, strong) UIView *vFooter;
@property (nonatomic, strong) UITableView *tvCarList;
@property (nonatomic, strong) UILabel *labNoData;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) UIView *vLoadMore;
@property (nonatomic, strong) APIHelper *apiCarStatusList;
@property (nonatomic, strong) APIHelper *apiCarAction;
@property (nonatomic, strong) UIView *vBtnBackground;
@property (nonatomic, strong) UIView *vMenu;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic) NSUInteger previousCellRow;
@property (nonatomic) NSUInteger currentCellRow;
@property (nonatomic) BOOL isShowMenuView;
@property (nonatomic) UCCarStatusListViewStyle statusStyle;
@property (nonatomic) UserStyle userStyle;

@end

@implementation UCCarStatusListView

- (id)initWithFrame:(CGRect)frame carStatusListViewStyle:(UCCarStatusListViewStyle)viewStyle
{
    self = [super initWithFrame:frame];
    if (self) {
        _statusStyle = viewStyle;
        _mCarLists = [NSMutableArray array];
        _userStyle = [AMCacheManage currentUserType];
        [self initTitleView];
    }
    return self;
}

#pragma mark - initView
/** 初始化导航栏 */
- (void)initTitleView
{
    self.backgroundColor = kColorNewBackground;

    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 内容
    _vContent = [[UIView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    _vContent.layer.masksToBounds = YES;
    [self addSubview:_vContent];
    
    // 无数据提示
    _labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, _vContent.minY, self.width, _vContent.height)];
    _labNoData.hidden = YES;
    _labNoData.text = @"暂无车辆信息";
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.backgroundColor = kColorClear;
    [self addSubview:_labNoData];
    
    // 列表
    _tvCarList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, _vContent.height)];
    _tvCarList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvCarList.dataSource = self;
    _tvCarList.delegate = self;
    _tvCarList.backgroundColor = kColorNewBackground;
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvCarList];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    [_pullRefresh addTarget:self action:@selector(refreshCarList) forControlEvents:UIControlEventValueChanged];
    
    // 加载更多
    _vLoadMore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tvCarList.width, kMoreViewHeight)];
    
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
    
    // 菜单
    _vMenu = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - _tbTop.height - 150, self.width, 150)];
    _vMenu.backgroundColor = kColorWhite;
    
    NSArray *menuImages = @[@"list_saleing_btn", @"list_unpass_btn", @"list_sold_btn", @"list_doing_btn", @"list_checking_btn", @"list_invalid_btn"];
    NSArray *mentuImages_h =  @[@"list_saleing_btn_h", @"list_unpass_btn_h", @"list_saled_btn_h", @"list_doing_btn_h", @"list_checking_btn_h", @"list_invalid_btn_h"];
    
    NSArray *mentTitle = @[@"在售车", @"未通过", @"已售车", @"未填完", @"审核中", @"已过期"];
    
    // 添加菜单按钮
    CGFloat minY = 0;
    CGFloat minX = 0;
    CGFloat btnWidth = self.width / 3;
    for (int i = 0; i < mentTitle.count; i++) {
        UIButton *btnMenu = [[UIButton alloc] initWithFrame:CGRectMake(minX, minY, btnWidth, 74)];
        btnMenu.tag = i + kBtnMenuTag;
        [btnMenu setImage:[UIImage imageNamed:[menuImages objectAtIndex:i]] forState:UIControlStateNormal];
        [btnMenu setImage:[UIImage imageNamed:[mentuImages_h objectAtIndex:i]] forState:UIControlStateSelected];
        [btnMenu setImage:[UIImage imageNamed:[mentuImages_h objectAtIndex:i]] forState:UIControlStateHighlighted];
        [btnMenu addTarget:self action:@selector(onClickStatueBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnMenu setTitle:[mentTitle objectAtIndex:i] forState:UIControlStateNormal];
        btnMenu.titleLabel.font = [UIFont systemFontOfSize:12];
        [btnMenu setTitleColor:kColorGrey4 forState:UIControlStateNormal];
        [btnMenu setTitleColor:kColorBlue1 forState:UIControlStateSelected];
        [btnMenu setTitleColor:kColorBlue1 forState:UIControlStateHighlighted];
        btnMenu.titleEdgeInsets = UIEdgeInsetsMake(26, -btnMenu.imageView.width, 0, 0);
        btnMenu.imageEdgeInsets = UIEdgeInsetsMake(-18, btnMenu.titleLabel.width, 0, 0);
        // 分割线
        UIView *vLine1 = [[UIView alloc] initLineWithFrame:CGRectMake(minX + kLinePixel, minY + 20, kLinePixel, 40) color:kColorNewLine];
        [_vMenu addSubview:vLine1];
        minX += btnWidth;
        if (i == 2) {
            minY += 74;
            minX = 0;
        }
        
        [_vMenu addSubview:btnMenu];
    }
    
    // 分割线
    UIView *vLine2 = [[UIView alloc] initLineWithFrame:CGRectMake(20, 74, 280, kLinePixel) color:kColorNewLine];
    [_vMenu addSubview:vLine2];
    
    [_vContent addSubview:_tvCarList];
    
    // 获取数据
    [self makeView:_statusStyle];
    
    // 记录点击时间
    [self recordClickEvent];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnRight setTitle:@"其它" forState:UIControlStateNormal];
    
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnRight addTarget:self action:@selector(onClickOtherBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnRight setTitleColor:RGBColorAlpha(133, 153, 188, 1) forState:UIControlStateSelected];

    return vTopBar;
}

/** 重置标题 */
- (void)reloadTopBar
{
    NSString *title = nil;
    
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            title = @"在售车";
            break;
        case UCCarStatusListViewStyleSaled:
            title = @"已售车";
            break;
        case UCCarStatusListViewStyleChecking:
            title = @"审核中";
            break;
        case UCCarStatusListViewStyleNotpassed:
            title = @"未通过";
            break;
        case UCCarStatusListViewStyleNotfilled:
            title = @"未填完";
            break;
        case UCCarStatusListViewStyleInvalid:
            title = @"已过期";
            break;
    }
    
    [self.tbTop.btnTitle setTitle:title forState:UIControlStateNormal];
    
}

#pragma mark - private Method
/** 记录点击事件 */
- (void)recordClickEvent
{
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinessinthesourcelist : c_3_1_personthecarsource];
            break;
        case UCCarStatusListViewStyleSaled:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinessreceivesourcelist : c_3_1_personsoldcarsource];
            break;
        case UCCarStatusListViewStyleChecking:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinessreceivesource : c_3_1_personreviewsource];
            break;
        case UCCarStatusListViewStyleNotpassed:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinessnotthroughsource : c_3_1_personnotsource];
            break;
        case UCCarStatusListViewStyleNotfilled:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinesswithoutsource : c_3_1_personwithoutsource];
            break;
        case UCCarStatusListViewStyleInvalid:
            [UMStatistics event:_userStyle == UserStyleBusiness ? c_3_1_buinessmerchantsource : c_3_1_personexpiredsource];
            break;
    }
}

/** 记录统计时间 */
- (void)recordEvent
{
    UserInfoModel *mUserInfo = nil;
    NSMutableDictionary *dic = nil;
    
    if (_userStyle == UserStyleBusiness) {
        mUserInfo = [AMCacheManage currentUserInfo];
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:mUserInfo.userid, @"userid#4", nil];
    }
    
    // 统计
    NSString *title = nil;
    
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            title = @"在售车";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessinthesourcelist : pv_3_1_personthecarsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsellinglist_pv : usercarsellinglist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsellinglist_pv : usercarsellinglist_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleSaled:
            title = @"已售车";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessreceivesourcelist : pv_3_1_personsoldcarsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsoldlist_pv : usercarsoldlist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarsoldlist_pv : usercarsoldlist_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleChecking:
            title = @"审核中";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessreceivesource : pv_3_1_personreviewsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarreviewlist_pv : usercarreviewlist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarreviewlist_pv : usercarreviewlist_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleNotpassed:
            title = @"未通过";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessnotthroughsource : pv_3_1_personnotsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotthroughlist_pv : usercarnotthroughlist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotthroughlist_pv : usercarnotthroughlist_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleNotfilled:
            title = @"未填完";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesswithoutsource : pv_3_1_personwithoutsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotfinishlist_pv : usercarnotfinishlist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotfinishlist_pv : usercarnotfinishlist_pv page_name:NSStringFromClass(self.class)];
            break;
        case UCCarStatusListViewStyleInvalid:
            title = @"已过期";
            [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinessmerchantsource : pv_3_1_personmerchantsource];
            if (_userStyle == UserStyleBusiness)
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarexpiredlist_pv : usercarexpiredlist_pv page_name:NSStringFromClass(self.class) eventargvs:dic];
            else
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarexpiredlist_pv : usercarexpiredlist_pv page_name:NSStringFromClass(self.class)];
            break;
    }
}

/** 加载视图 */
-(void)makeView:(UCCarStatusListViewStyle)viewStyle
{
    // 取消上次请求
    [_apiCarAction cancel];
    // 设置列表状态
    _statusStyle = viewStyle;
    // 初始上一个cellRow值
    _previousCellRow = NSNotFound;
    _currentCellRow = NSNotFound;
    // 设置标题
    [self reloadTopBar];
    // 设置菜单按钮选中效果
    UIButton *selectedBtn = (UIButton *)[_vMenu viewWithTag:_statusStyle - 1 + kBtnMenuTag];
    selectedBtn.selected = YES;
    // 清空当前页
    [_mCarLists removeAllObjects];
    // 未填完，获取本地数据
    if (_statusStyle == UCCarStatusListViewStyleNotfilled) {
        _pullRefresh.enabled = NO;
        _pullRefresh.hidden = YES;
        NSMutableArray *carInfoEditDrafts = [AMCacheManage currentCarInfoEditDrafts];
        for (UCCarInfoEditModel *mCarInfoEditTemp in carInfoEditDrafts) {
            [mCarInfoEditTemp setTextValue];
            [_mCarLists addObject:mCarInfoEditTemp];
        }
        [_tvCarList reloadData];
        // 判断有无数据
        [self setNoDataPrompt];
        
        // 统计事件
        [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesswithoutsource : pv_3_1_personwithoutsource];
        [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotfinishlist_pv : usercarnotfinishlist_pv page_name:NSStringFromClass(self.class)];
    }
    // 获取网络数据
    else {
        _pullRefresh.enabled = YES;
        _pullRefresh.hidden = NO;
        [_tvCarList reloadData];
        // 重新刷表
        [self refreshCarList];
    }
}

/** 刷新车辆列表 */
- (void)refreshCarList
{
    [_apiCarStatusList cancel];
    _pageIndex = 1;
    [self getCarStatusListData];
}

/** 关闭cell */
-(void)closeCell:(NSUInteger)cellRow
{
    if (cellRow != NSNotFound && _statusStyle != UCCarStatusListViewStyleSaled) {
        UCCarStatusInfoCell *carInfoCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:0]];
        _previousCellRow = NSNotFound;
        _currentCellRow = NSNotFound;
        [carInfoCell openCell:NO btnBackgroundView:_vBtnBackground];
    }
}

/** 是否显示暂无数据 */
-(void)setNoDataPrompt
{
    ([_mCarLists count] == 0) ? (_labNoData.hidden = NO) : (_labNoData.hidden = YES);
}

/** 点击修改后重置列表个数 */
-(void)changeCarState:(UCCarStatusInfoCell *)carInfoCell mCarInfoL:(UCCarInfoEditModel *)mCarInfo
{
    //修改全局变量
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:UCCarStatusListViewStyleChecking];
            break;
        case UCCarStatusListViewStyleNotpassed:
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:UCCarStatusListViewStyleChecking];
            break;
        case UCCarStatusListViewStyleInvalid:
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:UCCarStatusListViewStyleChecking];
            break;
        default:
            break;
    }
    
}

/** 菜单视图开关 */
- (void)switchMenuView
{
    _isShowMenuView = !_isShowMenuView;
    
    static NSInteger vMenuTag = 87354632;
    UIView *vMenuBack = nil;
    
    if (_isShowMenuView) {
        _tbTop.btnRight.enabled = NO;
        // 背景视图
        UIControl *vMenuBack = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        vMenuBack.tag = vMenuTag;
        [vMenuBack addTarget:self action:@selector(tapCloseMenuView:) forControlEvents:UIControlEventTouchUpInside];
        
        vMenuBack.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        [vMenuBack addSubview:_vMenu];
        [_vContent addSubview:vMenuBack];
        
        // 动画开启
        _vMenu.minY = -_vMenu.height;
        [UIView animateWithDuration:kAnimateSpeedFast animations:^{
            vMenuBack.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            _vMenu.minY = 0;
            
        }completion:^(BOOL finished) {
            _tbTop.btnRight.enabled = YES;
        }];
        
    } else {
        vMenuBack = (UIControl *)[self viewWithTag:vMenuTag];
        _tbTop.btnRight.enabled = NO;
        // 动画关闭
        [UIView animateWithDuration:kAnimateSpeedFlash animations:^{
            _vMenu.minY = -_vMenu.height;
            _tbTop.btnRight.selected = NO;
            vMenuBack.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        }completion:^(BOOL finished) {
            _tbTop.btnRight.enabled = YES;
            [vMenuBack removeFromSuperview];
            [_vMenu removeFromSuperview];
        }];
        
    }
}

/** 单击背景收回菜单 */
- (void)tapCloseMenuView:(UITapGestureRecognizer *)sender
{
    [self switchMenuView];
}

/** 删除cell */
- (void)removeCarCell:(UCCarInfoEditModel *)mCarInfo
{
    for (int i = 0; i < [_mCarLists count]; i ++) {
        UCCarInfoEditModel *mCarInfoTemp = (UCCarInfoEditModel *)[_mCarLists objectAtIndex:i];
        if (mCarInfo.carid.integerValue == mCarInfoTemp.carid.integerValue) {
            [_mCarLists removeObjectAtIndex:i];
            [_tvCarList deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            // 无数据提示
            [self setNoDataPrompt];
            break;
        }
    }
}

#pragma mark - onClickButton
/** 返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [_apiCarAction cancel];
    [_apiCarStatusList cancel];
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 移动cell */
- (void)onClickMoveBtn:(UCCarStatusInfoCell *)carInfoCell
{
    NSIndexPath *cellRow = [_tvCarList indexPathForCell:carInfoCell];
    _currentCellRow = cellRow.row;
    
    // 关闭上个cell
    if (_previousCellRow != NSNotFound) {
        
        UCCarStatusInfoCell *previousCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_previousCellRow inSection:0]];
        [previousCell openCell:NO btnBackgroundView:_vBtnBackground];
        
        if (_previousCellRow == _currentCellRow) {
            _previousCellRow = NSNotFound;
            _currentCellRow = NSNotFound;
            return;
        }
    }
    
    if (_previousCellRow != _currentCellRow) {
        NSArray *btnTittles = nil;
        NSArray *btnActionTags = nil;
        switch (_statusStyle) {
            case UCCarStatusListViewStyleSaleing:
                if (_userStyle == UserStyleBusiness) {
                    btnTittles = @[@"标为已售",@"修改"];
                    btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionMarkSold], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
                } else {
                    btnTittles = @[@"标为已售",@"修改"];
                    btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionMarkSold], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
                }
                
                break;
            case UCCarStatusListViewStyleSaled:
                btnTittles = nil;
                btnActionTags = nil;
                break;
            case UCCarStatusListViewStyleChecking:
                btnTittles = @[@"删除",@"修改"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
                break;
            case UCCarStatusListViewStyleNotpassed:
                btnTittles = @[@"删除",@"修改",@"查看原因"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionReasons]];
                break;
            case UCCarStatusListViewStyleNotfilled:
                btnTittles = @[@"删除",@"继续填写"];
                btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionDelete], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionContinueFill]];
                break;
            case UCCarStatusListViewStyleInvalid:
                if (_userStyle == UserStyleBusiness) {
                    btnTittles = @[@"重新发布",@"修改"];
                    btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionRepublish], [NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
                } else {
                    btnTittles = @[@"修改"];
                    btnActionTags = @[[NSNumber numberWithInteger:UCCarStatusListViewButtonActionModify]];
                }
                
                break;
                
            default:
                break;
        }
        
        // 创建操作项按钮
        UIView *vBtnBackground = [[UIView alloc] initWithFrame:CGRectMake(27, 0, carInfoCell.width - 27, UCCarStatusInfoCellHeight - kLinePixel)];
        [carInfoCell.contentView insertSubview:vBtnBackground belowSubview:carInfoCell.vCarInfo];
        
        CGFloat btnWidth = vBtnBackground.width / [btnTittles count];
        
        for (int i = 0; i < [btnTittles count]; i++) {
            // 按钮
            UIButton *btnAction = [[UIButton alloc] initWithFrame:CGRectMake(i * btnWidth, 0, btnWidth, vBtnBackground.height)];
            btnAction.titleLabel.font = [UIFont systemFontOfSize:13];
            [btnAction setTitle:[btnTittles objectAtIndex:i] forState:UIControlStateNormal];
            [btnAction setTitleColor:kColorBlue1 forState:UIControlStateNormal];
            [btnAction setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(237, 237, 237, 1) size:btnAction.size] forState:UIControlStateHighlighted];
            [btnAction addTarget:self action:@selector(onClickActionBtn:) forControlEvents:UIControlEventTouchUpInside];
            btnAction.tag = [[btnActionTags objectAtIndex:i] integerValue];
            [vBtnBackground addSubview:btnAction];
            
            // 分割线
            UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(btnAction.maxX - 1, (UCCarStatusInfoCellHeight - 12) / 2, 1, 12) color:kColorNewLine];
            [vBtnBackground addSubview:vLine];
            
        }
        
        // 展开cell
        [carInfoCell openCell:YES btnBackgroundView:_vBtnBackground];
        if (_previousCellRow != NSNotFound && _previousCellRow == cellRow.row) {
            _previousCellRow = NSNotFound;
            return;
        }
        
        // 设置上一个打开的选项行
        _previousCellRow = [_tvCarList indexPathForCell:carInfoCell].row;
        _vBtnBackground = vBtnBackground;
    }
    
}

/** 点击菜单按钮 */
- (void)onClickOtherBtn:(UIButton *)btn
{
    _tbTop.btnRight.selected = YES;
    if (_currentCellRow != NSNotFound)
        [self closeCell:_currentCellRow];
    [self switchMenuView];
}

/** 进入其他状态列表 */
- (void)onClickStatueBtn:(UIButton *)btn
{
    // 选中
    for (int i = 0; i < 6; i++) {
        UIButton *btnMenus = (UIButton *)[_vMenu viewWithTag:i + kBtnMenuTag];
        btnMenus.selected = i == (btn.tag - kBtnMenuTag) ? YES : NO;
    }
    
    [self makeView:(UCCarStatusListViewStyle)(btn.tag - kBtnMenuTag + 1)];
    // 关闭菜单视图
    [self switchMenuView];
    
}

/** 点击操作按钮 */
- (void)onClickActionBtn:(UIButton *)btn
{
    UCCarStatusInfoCell *carInfoCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentCellRow inSection:0]];
    
    // 关闭cell（“标为已售、删除、查看原因” 特殊控制 不执行关闭）
    if (btn.tag == UCCarStatusListViewButtonActionRefresh || btn.tag == UCCarStatusListViewButtonActionRepublish || btn.tag == UCCarStatusListViewButtonActionContinueFill || btn.tag == UCCarStatusListViewButtonActionModify) {
        if (_currentCellRow != NSNotFound)
            [self closeCell:_currentCellRow];
    }
    
    if (btn.tag == UCCarStatusListViewButtonActionModify || btn.tag == UCCarStatusListViewButtonActionContinueFill) {
        
        // 初始化发车视图
        UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:carInfoCell.mCarInfoEdit];
        vSaleCar.delegate = self;
        [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        
        return;
    }
    
    switch (btn.tag) {
        case UCCarStatusListViewButtonActionDelete:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否确认删除"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确认",nil];
            alert.tag = UCCarStatusListViewButtonActionDelete;
            [alert show];
        }
            break;
            
        case UCCarStatusListViewButtonActionReasons:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:(carInfoCell.mCarInfoEdit.errortext.length > 0 ? carInfoCell.mCarInfoEdit.errortext : @"无被退回原因")
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
            break;
            
        case UCCarStatusListViewButtonActionMarkSold:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否标为已售" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            alert.tag = UCCarStatusListViewButtonActionMarkSold;
            [alert show];
        }
            break;
        case UCCarStatusListViewButtonActionRefresh:
            [self carOperate:CarOperateUpdate mCarInfo:carInfoCell.mCarInfoEdit salePrice:nil];
            break;
        case UCCarStatusListViewButtonActionRepublish:
            [self carOperate:CarOperateRelease mCarInfo:carInfoCell.mCarInfoEdit salePrice:nil];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UCUserCarDetailViewDelegate
/** 更新列表数 */
- (void)removeCarFromList:(UCCarInfoEditModel *)mCarInfo carOperate:(CarOperate)operate
{
    // 修改全局变量
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:   // 在售
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:UCCarStatusListViewStyleSaled];
            break;
        case UCCarStatusListViewStyleChecking:  // 审核
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:NSNotFound];
            break;
        case UCCarStatusListViewStyleNotpassed: // 未通过
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:NSNotFound];
            break;
        case UCCarStatusListViewStyleNotfilled: // 未完成
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:NSNotFound];
            break;
        case UCCarStatusListViewStyleInvalid:   // 已过期
            [AMCacheManage reduceCarListState:_statusStyle plusCarListState:UCCarStatusListViewStyleSaleing];
            break;
        default:
            break;
    }
    // 删除行
    [self removeCarCell:mCarInfo];
    
}

#pragma mark - UCChooseCarViewDelegate
/** 修改完毕 or 发布新车完毕*/
- (void)releaseCarFinish:(UCCarInfoEditModel *)mCarInfo
{
    // 未完成列表
    if (_statusStyle ==  UCCarStatusListViewStyleNotfilled) {
        [self makeView:UCCarStatusListViewStyleNotfilled];
        [AMCacheManage reduceCarListState:NSNotFound plusCarListState:UCCarStatusListViewStyleChecking];
    }
    
    // 非未完成列表
    else{
        
        BOOL isExists = NO;
        // 修改
        for (int i = 0; i < [_mCarLists count]; i ++) {
            UCCarInfoEditModel *mCarInfoTemp = [_mCarLists objectAtIndex:i];
            if ([mCarInfo.carid integerValue] == [mCarInfoTemp.carid integerValue]) {
                isExists = YES;
                UCCarStatusInfoCell *carInfoCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                // 审核中 & 商家在售
                if (_statusStyle == UCCarStatusListViewStyleChecking || (_statusStyle == UCCarStatusListViewStyleSaleing && _userStyle == UserStyleBusiness)) {
                    // 替换数据
                    [mCarInfo setTextValue];
                    [_mCarLists replaceObjectAtIndex:i withObject:mCarInfo];
                    // 刷新数据
                    [_tvCarList reloadData];
                } else {
                    [self removeCarCell:mCarInfo];
                    [self changeCarState:carInfoCell mCarInfoL:mCarInfo];
                }
            }
        }
        
        // 发布新车
        if (isExists == NO) {
            [AMCacheManage reduceCarListState:NSNotFound plusCarListState:UCCarStatusListViewStyleChecking];
            // 刷新数据
            [self refreshCarList];
        }
        
    }
    
}

/** 取消修改 */
- (void)releaseCarClose:(UCCarInfoEditModel *)mCarInfo
{
    // 未完成列表
    if (_statusStyle ==  UCCarStatusListViewStyleNotfilled) {
        [self makeView:_statusStyle];
    }
}

#pragma mark - UCReleaseSucceedViewDelegate
- (void)didSelectedReleaseAgain:(UCReleaseSucceedView *)vReleaseSuccessed
{
    UCSaleCarView *vSaleCar = [[UCSaleCarView alloc] initWithFrame:self.bounds carInfoEdit:nil];
    vSaleCar.delegate = self;
    [[MainViewController sharedVCMain] openView:vSaleCar animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionPrevious];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mCarLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    UCCarStatusInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (cell == nil) {
        cell = [[UCCarStatusInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
        cell.delegateView = self;
    }
    
    [cell makeView:[_mCarLists objectAtIndex:indexPath.row] carListState:_statusStyle cellRow:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return  UCCarStatusInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 关闭cell
    if (_currentCellRow != NSNotFound)
        [self closeCell:_currentCellRow];
    
    // 进详情
    UCCarInfoEditModel *mCarInfoEdit = [self.mCarLists objectAtIndex:indexPath.row];
    UCUserCarDetailView *vUserCarDetail = [[UCUserCarDetailView alloc] initWithFrame:self.bounds userStyle:_userStyle statusStyle:_statusStyle carInfoEdeiModel:mCarInfoEdit];
    vUserCarDetail.delegate = self;
    [[MainViewController sharedVCMain] openView:vUserCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一个cell 开始加载更多
    if (indexPath.row == _mCarLists.count - 1) {
        // 满页情况下才有下一页 & 没有正在加载更多
        if (_mCarLists.count % kListPageSize == 0) {
            if (tableView.tableFooterView != _vLoadMore) {
                tableView.tableFooterView = _vLoadMore;
                _pageIndex++;
                [self getCarStatusListData];
            }
        } else {
            _tvCarList.tableFooterView = _vFooter;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 关闭上一个打开的选项
    if (_previousCellRow != NSNotFound) {
        UCCarStatusInfoCell *previousCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_previousCellRow inSection:0]];
        [previousCell openCell:NO btnBackgroundView:_vBtnBackground];
        _previousCellRow = NSNotFound;
        _currentCellRow = NSNotFound;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UCCarStatusInfoCell *carInfoCell = (UCCarStatusInfoCell *)[_tvCarList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentCellRow inSection:0]];
    
    if (buttonIndex == 1) {
        
        // 标为已售
        if (alertView.tag == UCCarStatusListViewButtonActionMarkSold) {
            if (_currentCellRow != NSNotFound)
                [self closeCell:_currentCellRow];
            [self carOperate:CarOperateSaled mCarInfo:carInfoCell.mCarInfoEdit salePrice:nil];
        }
        // 删除
        else if (alertView.tag == UCCarStatusListViewButtonActionDelete) {
            
            // 未填完列表
            if (_statusStyle == UCCarStatusListViewStyleNotfilled)
            {
                // 删除缓存
                [_mCarLists removeObjectAtIndex:_currentCellRow];
                
                // 关闭cell
                if (_currentCellRow != NSNotFound)
                    [self closeCell:_currentCellRow];
                
                // 写入缓存
                if ([_mCarLists count] > 0)
                    [AMCacheManage setCurrentCarInfoEditDrafts:_mCarLists];
                else
                    [AMCacheManage setCurrentCarInfoEditDrafts:nil];
                
                // 刷新列表
                [_mCarLists removeAllObjects];
                NSMutableArray *carInfoEditDrafts = [AMCacheManage currentCarInfoEditDrafts];
                for (UCCarInfoEditModel *mCarInfoEditTemp in carInfoEditDrafts) {
                    [mCarInfoEditTemp setTextValue];
                    [_mCarLists addObject:mCarInfoEditTemp];
                }
                [_tvCarList reloadData];
                
                // 判断是否显示无数据提示
                [self setNoDataPrompt];
                
                // 统计事件
                [UMStatistics event:_userStyle == UserStyleBusiness ? pv_3_1_buinesswithoutsource : pv_3_1_personwithoutsource];
                [UMSAgent postEvent:_userStyle == UserStyleBusiness ? dealercarnotfinishlist_pv : usercarnotfinishlist_pv page_name:NSStringFromClass(self.class)];
                
            }
            // 非未填完列表
            else{
                // 关闭cell
                if (_currentCellRow != NSNotFound)
                    [self closeCell:_currentCellRow];
                [self carOperate:CarOperateDeleted mCarInfo:carInfoCell.mCarInfoEdit salePrice:nil];
            }
        }
    }
}

#pragma mark - APIHelper
/** 获取列表数据 */
- (void)getCarStatusListData
{
    // 统计事件
    [self recordEvent];
    
    if (!_apiCarStatusList)
        _apiCarStatusList = [[APIHelper alloc] init];
    
    [_pullRefresh beginRefreshing];
    
    __weak UCCarStatusListView *vCarStatusList = self;
    
    // 设置请求完成后回调方法
    [_apiCarStatusList setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        
        [vCarStatusList.pullRefresh endRefreshing];
        
        if (error) {
            if (error.code == ConnectionStatusCancel) {
                [[AMToastView toastView] hide];
            }
            // 其他错误
            else
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
        }
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            
            if (mBase) {
                NSString *message = nil;
                // 获取成功
                if (mBase.returncode == 0) {
                    NSMutableArray *carInfos = [NSMutableArray array];
                    for (NSDictionary *dicCarInfoTemp in [mBase.result objectForKey:@"carlist"]) {
                        // 车实体
                        UCCarInfoEditModel *mCarStatusInfo = [[UCCarInfoEditModel alloc] initWithJson:dicCarInfoTemp];
                        [mCarStatusInfo setTextValue];
                        [carInfos addObject:mCarStatusInfo];
                    }
                    
                    // 刷新成功清理缓存
                    if (vCarStatusList.pageIndex == 1) {
                        [vCarStatusList.mCarLists removeAllObjects];
                        [vCarStatusList.mCarLists addObjectsFromArray:carInfos];
                        // 刷新列表
                        [vCarStatusList.tvCarList reloadData];
                    }
                    // 加载更多
                    else {
                        NSUInteger originalCount = vCarStatusList.mCarLists.count;
                        NSMutableArray *indexPaths = [NSMutableArray array];
                        for (int i = 0; i < carInfos.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:originalCount + i inSection:0]];
                        [vCarStatusList.mCarLists addObjectsFromArray:carInfos];
                        [vCarStatusList.tvCarList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                    // 设置列表总数量
                    NSNumber *rowCount = [NSNumber numberWithInteger:[[mBase.result objectForKey:@"rowcount"] integerValue]];
                    // 刷新主页面数值
                    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                    switch (vCarStatusList.statusStyle) {
                        case UCCarStatusListViewStyleSaleing:   //在售
                            mUserInfo.carsaleing = rowCount;
                            break;
                        case UCCarStatusListViewStyleSaled:     //已售
                            mUserInfo.carsaled = rowCount;
                            break;
                        case UCCarStatusListViewStyleChecking:  //审核
                            mUserInfo.carchecking = rowCount;
                            break;
                        case UCCarStatusListViewStyleNotpassed: //未通过
                            mUserInfo.carnotpassed = rowCount;
                            break;
                        case UCCarStatusListViewStyleInvalid:   //已过期
                            mUserInfo.carinvalid = rowCount;
                            break;
                        default:
                            break;
                    }
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    
                }
                else if (mBase.returncode == 2049005){
                    message = @"身份验证失效，请重新登录";
                    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                        UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
                        vLoginDealer.delegate = vCarStatusList;
                        [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    else{
                        UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
                        vLoginClient.delegate = vCarStatusList;
                        [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    [AMCacheManage setCurrentUserInfo:nil];
                }
                else
                    message = @"网速不给力，请稍后尝试";
                
                // 显示提示语
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
            }
            
        }
        vCarStatusList.tvCarList.tableFooterView = vCarStatusList.vFooter;
        
        // 是否显示无数据提示
        vCarStatusList.labNoData.hidden = vCarStatusList.mCarLists.count != 0;
    }];
    
    NSInteger state = NSNotFound;
    switch (_statusStyle) {
        case UCCarStatusListViewStyleSaleing:
            state = 1;
            break;
        case UCCarStatusListViewStyleNotpassed:
            state = 4;
            break;
        case UCCarStatusListViewStyleSaled:
            state = 2;
            break;
        case UCCarStatusListViewStyleChecking:
            state = 3;
            break;
        case UCCarStatusListViewStyleInvalid:
            state = 5;
            break;
        default:

            break;
    }
    // 1在售车、2已售车、3审核中、4未通过、5已过期
    [_apiCarStatusList getCarinfoListWithListState:state pageIndex:_pageIndex pageSize:kListPageSize];
    
}

/** 车辆操作 */
- (void)carOperate:(CarOperate)operate mCarInfo:(UCCarInfoEditModel *)mCarInfo salePrice:(NSNumber *)salePrice
{
    if (!_apiCarAction)
        _apiCarAction = [[APIHelper alloc] init];
    [_apiCarAction cancel];
    
    __weak UCCarStatusListView *vCarStatusList = self;
    
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiCarAction cancel];
        [[AMToastView toastView] hide];
    }];
    _apiCarAction.tag = [NSString stringWithFormat:@"%d", operate];
    [_apiCarAction setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
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
                NSString *message = nil;
                // 处理成功
                if (mBase.returncode == 0) {
                    // 删除
                    if (operate == CarOperateDeleted){
                        [vCarStatusList removeCarFromList:mCarInfo carOperate:CarOperateDeleted];
                    }
                    // 标为已售
                    else if (operate == CarOperateSaled) {
                        [vCarStatusList removeCarFromList:mCarInfo carOperate:CarOperateSaled];
                    }
                    // 重新发布
                    else if (operate == CarOperateRelease) {
                        [vCarStatusList removeCarFromList:mCarInfo carOperate:CarOperateRelease];
                    }
                }
                else if (mBase.returncode == 2049005){
                    
                    message = @"身份验证失效，请重新登录";
                    if ([AMCacheManage currentUserType] == UserStyleBusiness) {
                        UCLoginDealerView *vLoginDealer = [[UCLoginDealerView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds];
                        vLoginDealer.delegate = vCarStatusList;
                        [[MainViewController sharedVCMain] openView:vLoginDealer animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    else{
                        UCLoginClientView *vLoginClient = [[UCLoginClientView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds loginType:UCLoginClientTypeNormal];
                        vLoginClient.delegate = vCarStatusList;
                        [[MainViewController sharedVCMain] openView:vLoginClient animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
                    }
                    [AMCacheManage setCurrentUserInfo:nil];
                }
                else if (mBase.returncode == 2049010)
                    message = @"操作失败，请稍后尝试";
                else if (mBase.returncode == 2049011)
                    message = @"该信息已删除，无法操作";
                else if (mBase.returncode == 2049013 || mBase.returncode == 2049012)
                    message = @"该车为已售车源，无法操作";
                else if (mBase.returncode == 2049014)
                    message = @"该车为审核中车源，无法操作";
                else if (mBase.returncode == 2049015)
                    message = @"该车为审核未通过车源，无法操作";
                else if (mBase.returncode == 2049020)
                    message = @"没有操作权限或信息已删除，无法操作";
                else
                    message = @"服务器连接失败，请稍后重试";
                
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            }
        }
    }];
    [_apiCarAction carOperate:operate mCarInfo:mCarInfo];
}

- (void)dealloc
{
    AMLog(@"dealloc...");
    [_apiCarAction cancel];
    [_apiCarStatusList cancel];
}

@end
