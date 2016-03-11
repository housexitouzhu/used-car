//
//  UCHistoryView.h
//  UsedCar
//
//  Created by 张鑫 on 14/11/21.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCView.h"
#import "XMPPManager.h"

@interface UCIMHistoryView : UCView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, XMPPManagerDelegate>

@property (nonatomic        ) BOOL                  isEnablePullRefresh;// 是否启用下拉刷新
@property (nonatomic, strong) NSMutableArray *mHistory;
@property (nonatomic        ) BOOL                  isAllowsSelection;// 是否可点击 默认可以
@property (nonatomic) NSInteger pageSize;       // 一次加载多少
@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@end
