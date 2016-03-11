//
//  UCUserCenterView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCFavoritesView.h"
#import "JSBadgeView.h"
#import "UserInfoView.h"
#import "InfoBarView.h"
#import "CarStatusView.h"
#import "UCLoginClientView.h"

@interface UCUserCenterView : UCView <UserInfoViewDelegate, InfoBarViewDelegate, CarStatusViewDelegate, UCLoginClientViewDelegate>

@property (nonatomic) NSInteger leadsCount;
@property (nonatomic) NSInteger subscribeCount;
@property (nonatomic) NSInteger claimCount;
@property (nonatomic) NSInteger imCount;
@property (nonatomic) UserStyle userStyle;

/** 更新索赔 */
- (void)updateClaimUIWithCount:(NSInteger)count;

@end
