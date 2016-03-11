//
//  UCSaleLeadList.h
//  UsedCar
//
//  Created by wangfaquan on 14-4-18.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCSalesLeadsModel.h"

@protocol UCSaleLeadListDelegate;

@interface UCSalesLeadsListView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) NSMutableArray *markReads;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) NSInteger listState;       // 状态1已阅2未阅读3忽略4（已阅+未阅）
@property (nonatomic, weak) id<UCSaleLeadListDelegate>delegate;
@property (nonatomic, strong) UITableView *tvSaleLeadList;


/** 刷新数据 */
- (void)refreshData;
/** 设置列表滚动条位置 */
- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets;
/** 设置底部视图高度 */
- (void)setFooterViewHeight:(CGFloat)height;

@end

@protocol UCSaleLeadListDelegate <NSObject>

- (void)saleLeadList:(UCSalesLeadsListView *)vSaleLeadList saleLeadModel:(UCSalesLeadsModel *)mSaleLead;
- (void)UCSalesLeadsListDidSuccessed:(UCSalesLeadsListView *)vSaleLeadList;

@end
