//
//  UCShareCarListView.m
//  UsedCar
//
//  Created by 张鑫 on 14-10-15.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCShareCarListView.h"
#import "UCTopBar.h"
#import "UCShareHistoryModel.h"
#import "AMCacheManage.h"

@interface UCShareCarListView()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic, weak) UCShareHistoryModel *mShareCar;

@end

@implementation UCShareCarListView


- (id)initWithFrame:(CGRect)frame shareCarModel:(UCShareHistoryModel *)mShareCar
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _mShareCar = mShareCar;
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
    
    // 列表
    _vCarList = [[UCCarListView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.frame.size.width, self.frame.size.height - _tbTop.maxY)];
    _vCarList.shareID = _mShareCar.shareid.integerValue;
    _vCarList.viewStyle = UCCarListViewStyleShareCarList;
    _vCarList.delegate = self;
    _vCarList.pageSize = 30;
    
    [self addSubview:_tbTop];
    [self addSubview:_vCarList];
    
    [_vCarList refreshCarList];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    
    // 标题
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnTitle setTitle:@"分享车源列表" forState:UIControlStateNormal];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    return vTopBar;
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

#pragma mark - System Delegate

#pragma mark - Custom Delegate
-(void)carListViewLoadDataSuccess:(UCCarListView *)vCarList
{
    [UMStatistics event:pv_4_1_buiness_share_history_cars];
    [UMSAgent postEvent:buiness_share_history_cars_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:[AMCacheManage currentUserInfo].userid, @"dealerid#5", nil]];
}

#pragma mark - APIHelper

#pragma mark - delloc
-(void)dealloc
{
    AMLog(@"\ndealloc...:%@\n", NSStringFromClass([self class]));
}

@end
