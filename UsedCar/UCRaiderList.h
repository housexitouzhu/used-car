//
//  UCRaiderList.h
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCRaiderView.h"

@interface UCRaiderList : UIView <UITableViewDataSource, UITableViewDelegate>

/** 是否本地攻略数据 */
@property (nonatomic) BOOL isLocal;
@property (nonatomic, weak) UCRaiderView *vRaider;

/** 刷新攻略数据 */
- (void)refreshData;

@end
