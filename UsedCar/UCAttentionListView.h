//
//  UCCarAttentionList.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKRefreshControl.h"
#import "UCNewFilterView.h"

@protocol UCCarAttenlistDelegate <NSObject>

- (void)getAttentionCars;

@end

@interface UCAttentionListView : UIView <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UCNewFilterViewDelegate>

@property (nonatomic, weak) UIButton *btnRight;                  //右按钮
@property (nonatomic, weak) NSMutableArray *attentionItems;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;     // 刷新
@property (nonatomic, strong) UITableView *tvAttentionList;
@property (nonatomic, weak) id<UCCarAttenlistDelegate>delegate;

/** 刷新订阅列表 */
- (void)refreshAttentionList;

/** 刷新事件*/
- (void)onPull;
/** 关闭操作选项栏 */
- (void)closeCellOptionBtn;


@end
