//
//  UCFavoritesView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-5.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCFavoritesView.h"
#import "UCTopBar.h"
#import "UCFavoritesList.h"
#import "UCGuessLikeView.h"
#import "AMCacheManage.h"

@interface UCFavoritesView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCFavoritesList *vFavoritesList;

@end

@implementation UCFavoritesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorWhite;
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
    [_tbTop.btnTitle setTitle:@"收藏" forState:UIControlStateNormal];
    [_tbTop.btnRight setTitle:@"猜你喜欢" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    // 收藏车辆列表
    _vFavoritesList = [[UCFavoritesList alloc] initWithFrame:CGRectMake(0, 64, self.width, self.height-64)];
    
    [self addSubview:_tbTop];
    [self addSubview:_vFavoritesList];
    [self refreshFavoritesList];
}
- (void)refreshFavoritesList
{
    [UMStatistics event:[AMCacheManage currentUserType] == UserStyleBusiness ? pv_3_1_buinessfavoriteslists : pv_3_1_personfavoriteslists];
    [UMSAgent postEvent:userfavorate_pv page_name:NSStringFromClass(self.class)];
    [_vFavoritesList refreshFavoritesList];
}

#pragma mark - onClickBtn
/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonRight) {
        [UMStatistics event:c_3_1_favoritesguessList];
        UCGuessLikeView *guessLike = [[UCGuessLikeView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) favoritesInCloud:self.vFavoritesList.loadFavoritesInCloud favoritesList:self.vFavoritesList.mFavoritesList];
        guessLike.vFavorites = self;
        [[MainViewController sharedVCMain] openView:guessLike animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    } if (btn.tag == UCTopBarButtonLeft) {
        if ([_delegate respondsToSelector:@selector(refreshFavoritesCarList)]) {
            [_delegate refreshFavoritesCarList];
        }
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

@end