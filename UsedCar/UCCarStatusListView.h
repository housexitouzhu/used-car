//
//  UCCarStatusListView.h
//  UsedCar
//
//  Created by 张鑫 on 13-12-9.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCSaleCarView.h"
#import "UCReleaseSucceedView.h"

@class UCCarStatusInfoCell;

typedef enum {
    UCCarStatusListViewStyleSaleing = 1,
    UCCarStatusListViewStyleNotpassed = 2,
    UCCarStatusListViewStyleSaled = 3,
    UCCarStatusListViewStyleNotfilled = 4,
    UCCarStatusListViewStyleChecking = 5,
    UCCarStatusListViewStyleInvalid = 6,
} UCCarStatusListViewStyle;

typedef enum {
    UCCarStatusListViewButtonActionMarkSold = 0,
    UCCarStatusListViewButtonActionModify = 1,
    UCCarStatusListViewButtonActionRefresh = 2,
    UCCarStatusListViewButtonActionReasons = 3,
    UCCarStatusListViewButtonActionContinueFill = 4,
    UCCarStatusListViewButtonActionDelete = 5,
    UCCarStatusListViewButtonActionRepublish = 6,
} UCCarStatusListViewButtonAction;

@interface UCCarStatusListView : UCView <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UCReleaseCarViewDelegate, UCReleaseSucceedViewDelegate>

- (id)initWithFrame:(CGRect)frame carStatusListViewStyle:(UCCarStatusListViewStyle)viewStyle;
- (void)onClickMoveBtn:(UCCarStatusInfoCell *)carInfoCell;

@end
