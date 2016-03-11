//
//  UCHomeView.h
//  UsedCar
//
//  Created by Alan on 13-11-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCView.h"
#import "UCOptionBar.h"
#import "UCFilterView.h"
#import "UCAreaMode.h"
#import "UCFilterModel.h"
#import "UCCarListView.h"
#import "UCWelcome.h"
#import "UCSearchView.h"
#import "UCNewFilterView.h"
#import "UCFilterHistoryView.h"

typedef enum {
    UCHomeViewCarListStyleHomeList = 100,
    UCHomeViewCarListStyleSearchList,
} UCHomeViewCarListStyle;

@interface UCHomeView : UCView <UCOptionBarDelegate, UCFilterViewDelegate, UCCarListViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UCWelcomeDelegate, UCSerchViewDelegate, UIScrollViewDelegate, UCNewFilterViewDelegate, UCFilterHistoryViewDelegate>

@property (nonatomic, strong) UCAreaMode *mArea;
@property (nonatomic, strong) UCFilterModel *mFilter;
@property (nonatomic, strong) UCFilterView *vFilter;
@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic) BOOL isFirstLocation;     // 是否第一次选择城市

///** 设置城市名称 */
//- (void)setCityName:(NSString *)name;
///** 设置车源数量 */
//- (void)setCarCount:(NSInteger)count;
/** 更新筛选栏 */
- (void)updateFilterBar:(UCFilterModel *)mFilter;
/** 更新排序 */
- (void)updateOrderBy:(NSString *)order;
/** 根据数据刷新列表 */
- (void)reloadCarListByFilter:(UCFilterModel *)mFilter UCAreaModel:(UCAreaMode *)mArea;
// 无介绍页时直接调用
- (void)didCloseWelcomeView:(UCWelcome *)vWelcome;
/** 加载更多列表数据 */
- (void)loadMoreCarListData;
/** 打开蒙层 */
-(void)openMaskView;

@end
