//
//  UCMainView.h
//  UsedCar
//
//  Created by Alan on 13-11-8.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"
#import "UCHomeView.h"
#import "XMPPManager.h"

typedef void(^GetAttentionCountBlock)(BOOL isSuccess);
typedef void(^GetSaleTotalCountBlock)(BOOL isSuccess);
typedef void(^GetClaimCountBlock)(BOOL isSuccess);

@interface UCMainView : UCView <UCOptionBarDelegate, UIGestureRecognizerDelegate, XMPPManagerDelegate>

@property (nonatomic) BOOL isShowOrderView;
@property (nonatomic, strong) UCHomeView *vHome;
@property (nonatomic, strong) UIView     *vContent;
@property (nonatomic, strong) UIImageView *ivPoint;
@property (nonatomic) NSInteger subscribeCount;
@property (nonatomic) NSInteger leadsCount;
@property (nonatomic) NSInteger claimCount;
@property (nonatomic) NSInteger imCount;
@property (nonatomic) NSInteger imPushCount;    // 通过push过来的数。用于区别用户中心页的红点是否显示
@property (nonatomic, copy) GetAttentionCountBlock blockAttention;
@property (nonatomic, copy) GetSaleTotalCountBlock blockSaleTotal;
@property (nonatomic, copy) GetClaimCountBlock blockClaim;

+ (UCMainView *)sharedMainView;

/** 设置是否隐藏标签栏 */
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
/** 刷新关注数 */
- (void)getAttentionCount:(BOOL)isShowStatusBar block:(GetAttentionCountBlock)block;
/** 刷新销售总数 */
- (void)getSaleTotalNumber:(BOOL)isClickSales block:(GetSaleTotalCountBlock)block;
/** 刷新保证金索赔 */
- (void)getClaimCount:(BOOL)isShowStatusBar block:(GetClaimCountBlock)block;
///** 获得IM未读消息数并显示红点和更新用户中心的未读个数 */
- (void)refreshRedPointAndUserCenterChatBarCountIfNeed;
/** 刷新我的页面 */
- (void)reloadUserCenterView;
/** 开启定时器 */
- (void)startTimer;
/** 从新车报价来,显示指定数据 */
- (BOOL)searchCarListFromCarPriceApp;

/** 得到新推送后, 更新红点儿等提示状态 **/
-(void)updateStatusBarForPushNotificationWithInfo:(NSDictionary *)userInfo;

/**
 *  在软件关闭/后台运行的情况下, 取得推送打开软件, 关闭关注页面后重置关注提醒的提示状态
 */
-(void)setAttentionCountToZero;

-(void)setclaimCountToZero;

@end
