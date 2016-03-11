//
//  UCGuessLikeView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-17.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCGuessLikeView.h"
#import "UCTopBar.h"
#import "UCFavoritesModel.h"
#import "UCFilterModel.h"
#import "AMCacheManage.h"
#import "UCCarDetailInfoModel.h"
#import "UCFavoritesView.h"
#import "UCOptionBar.h"
#import "UCFavoritesCloudModel.h"

#define vBusinessInfoHeight 145

@interface UCGuessLikeView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarListView *vCarList;

@end

@implementation UCGuessLikeView

- (id)initWithFrame:(CGRect)frame favoritesInCloud:(BOOL)inCloud favoritesList:(NSArray*)favList
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewFavoritesInCloud:inCloud favoritesList:favList];
    }
    return self;
}

- (void)initViewFavoritesInCloud:(BOOL)inCloud favoritesList:(NSArray*)favList
{
    self.backgroundColor = kColorNewBackground;
    //导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"猜你喜欢" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    // 级别id
    NSNumber *levelid = nil;
    // 从收藏读取最新收藏的一辆车的级别id
    if (inCloud && favList.count>0) {
        UCFavoritesCloudModel *mFav = [favList firstObject];
        levelid = mFav.levelid;
    }
    else if ([AMCacheManage currentFavourites].count > 0) {
        UCFavoritesModel *mLastFavorite = [[AMCacheManage currentFavourites] objectAtIndex:0];
        levelid = mLastFavorite.levelId;
    }
    // 没有从收藏读取到级别id 尝试从主页浏览记录中读取
    if (!levelid || levelid.integerValue == 0) {
        UCCarDetailInfoModel *mCarDetail = [AMCacheManage currentCarDetailInfoModel];
        levelid = mCarDetail.levelid;
    }
    // 检查是否有级别id
    if (!levelid || levelid.integerValue == 0) {
        [self showNoData];
    } else {
        // 车辆列表
        _vCarList = [[UCCarListView alloc] initWithFrame:CGRectMake(0, 64, self.width, self.height - 64 )];
        _vCarList.delegate = self;
        
        UCFilterModel *mFilter = [[UCFilterModel alloc] init];
        mFilter.levelid = levelid;
        _vCarList.mFilter = mFilter;
        UCAreaMode *mArea = [AMCacheManage currentArea];
        _vCarList.mArea = mArea;
        [_vCarList refreshCarList];
        
        [self addSubview:_vCarList];
    }
    
    [self addSubview:_tbTop];
}

/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        // 刷新收藏列表
        [_vFavorites refreshFavoritesList];
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

/** 暂无数据 */
- (void)showNoData
{
    // 无数据提示
    UILabel *labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.height)];
    labNoData.text = @"暂无车辆信息";
    labNoData.textAlignment = NSTextAlignmentCenter;
    labNoData.font = [UIFont systemFontOfSize:16];
    labNoData.textColor = kColorNewGray2;
    [self addSubview:labNoData];
}

#pragma mark - UCCarListViewDelegate
/** 统计事件 */
- (void)carListViewLoadData:(UCCarListView *)vCarList
{
    [UMStatistics event:pv_3_1_favoritesguessList];
    [UMSAgent postEvent:guessfavorate_pv page_name:NSStringFromClass(self.class)];
}

@end
