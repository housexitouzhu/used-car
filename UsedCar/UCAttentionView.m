//
//  UCAttentionView.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionView.h"
#import "UCTopBar.h"
#import "UCAttentionListView.h"
#import "APIHelper.h"
#import "UCMainView.h"
#import "UCNewFilterView.h"
#import "UCCarAttenModel.h"
#import "AMCacheManage.h"

@interface UCAttentionView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) APIHelper *apiAttentionList;
@property (nonatomic, strong) NSMutableArray *attentionItems;
@property (nonatomic, strong) UCAttentionListView *vCarAttention;
@property (nonatomic) UCAttentionViewLeftButtonStyle leftButtonStyle;


@end

@implementation UCAttentionView

- (id)initWithFrame:(CGRect)frame UCAttentionViewLeftButtonStyle:(UCAttentionViewLeftButtonStyle)leftButtonStyle;
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([AMCacheManage currentUserType] == UserStyleBusiness) {
            UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
            [UMSAgent postEvent:business_attentioncarlist_pv page_name:NSStringFromClass(self.class)
                     eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 mUserInfo.userid, @"dealerid#5",
                                 mUserInfo.userid, @"userid#4", nil]];
        } else {
            [UMSAgent postEvent:person_attentioncarlist_pv page_name:NSStringFromClass(self.class)];
        }
        _leftButtonStyle = leftButtonStyle;
        _attentionItems = [NSMutableArray arrayWithCapacity:10];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    //导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_tbTop];
    
    // 获取对比列表
    if (!_vCarAttention) {
        _vCarAttention = [[UCAttentionListView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
        _vCarAttention.btnRight = _tbTop.btnRight;
        _vCarAttention.delegate = self;
         [self addSubview:_vCarAttention];
    }
    [_vCarAttention onPull];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"订阅车源" forState:(UIControlStateNormal)];
    if (_leftButtonStyle == UCAttentionViewLeftButtonStyleBack)
        [vTopBar setLetfTitle:@"返回"];
    else
        [vTopBar.btnLeft setTitle:@"关闭" forState:UIControlStateNormal];
    [vTopBar.btnRight setTitle:@"添加" forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents: UIControlEventTouchUpInside];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents: UIControlEventTouchUpInside];
    return vTopBar;
}

#pragma mark - private Method
/** 刷新事件 */
- (void)refreshAttentionLists
{
    [_vCarAttention refreshAttentionList];
}

#pragma mark - onClickBtn
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:_viewStyle == UCAttentionViewSytleMainView ? AnimateOptionMoveUp : AnimateOptionMoveLeft];
        
        // 这个情况只有在按钮是 close 的情况下才是 true
        if (self.shouldClearNotifyMarkAfterClose) {
            // 这里处理关掉[我的]红点儿,关掉进去的列表页的红点儿
            UCMainView *mainView = [UCMainView sharedMainView];
            [mainView setAttentionCountToZero]; //是否要真的消除红点, 交给 mainview 里的这个方法去做
        }
    }
    else if (btn.tag == UCTopBarButtonRight) {
        if (![OMG isValidClick:kAnimateSpeedNormal])
            return;
        
        // 关闭已打开选项
        [_vCarAttention closeCellOptionBtn];
        
        // 添加
        UCAreaMode *mArea = [[UCAreaMode alloc] init];
        UCFilterModel *mFilter = [[UCFilterModel alloc] init];
        UCNewFilterView *vNewFilter = [[UCNewFilterView alloc] initWithFrame:self.bounds mFilter:mFilter mArea:mArea attentionID:nil];
        vNewFilter.delegate = _vCarAttention;
        [[MainViewController sharedVCMain] openView:vNewFilter animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
    }
}

#pragma mark - APIHelper
/** 获得关注列表 */
- (void)getAttentionCars
{
    // 状态提示框
    if (!_apiAttentionList)
        _apiAttentionList = [[APIHelper alloc] init];
    else
        [_apiAttentionList cancel];
    [_vCarAttention.pullRefresh beginRefreshing];
    
    __weak UCAttentionView *vAttention = self;
    
    [_apiAttentionList setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        if (error) {
            if (error.code != ConnectionStatusRepeat)
                [vAttention.vCarAttention.pullRefresh endRefreshing];
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        
        [vAttention.vCarAttention.pullRefresh endRefreshing];
        
        if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [[AMToastView toastView] hide];
                    // 临时车辆列表
                    NSMutableArray *tmpCarAttentions = [NSMutableArray array];
                    for (NSDictionary *dicCarAttentionTemp in [mBase.result objectForKey:@"productlist"]) {
                        UCCarAttenModel *mCarAttention = [[UCCarAttenModel alloc] initWithJson:dicCarAttentionTemp];
                        [mCarAttention setTextValue];
                        [tmpCarAttentions addObject:mCarAttention];
                    }
                    [vAttention.attentionItems removeAllObjects];
                    [vAttention.attentionItems addObjectsFromArray:tmpCarAttentions];
                    vAttention.vCarAttention.attentionItems = vAttention.attentionItems;
                    [vAttention.vCarAttention refreshAttentionList];
                }
            } else {
                if (mBase.message) {
                    [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                } else
                    [[AMToastView toastView] hide];
            }
        }
    }];
    [_apiAttentionList getAttentionCars];
}

- (void)dealloc
{
    [_apiAttentionList cancel];
    [_apiHelper cancel];
    [[AMToastView toastView] hide];
}

@end
