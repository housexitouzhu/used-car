//
//  UCCarListView.h
//  UsedCar
//
//  Created by Alan on 13-11-6.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPageSize           24

typedef enum {
    UCCarListViewStyleSearch = 0,
    UCCarListViewStyleAttention,
    UCCarListViewStyleShareCarList,
} UCCarListViewStyle;

@class APIHelper;
@class UCFilterModel;
@class UCAreaMode;
@class UCCarInfoModel;
@class CKRefreshControl;

@protocol UCCarListViewDelegate;

@interface UCCarListView : UIView <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak  ) id<UCCarListViewDelegate> delegate;
@property (nonatomic, strong) NSString              *keyword;
@property (nonatomic, strong) NSNumber              *dealerid;
@property (nonatomic, strong) NSString              *orderby;
@property (nonatomic, strong) UCAreaMode            *mArea;
@property (nonatomic, strong) UCFilterModel         *mFilter;
@property (nonatomic        ) BOOL                  isEnablePullRefresh;// 是否启用下拉刷新
@property (nonatomic, strong) NSString              *strNoData;// 无数据提示文案
@property (nonatomic, weak  ) id<UIScrollViewDelegate > scrollDelegate;
@property (nonatomic        ) UCCarListViewStyle    viewStyle;// 页面种类
@property (nonatomic, strong) NSString              *mobile;// 关注车辆接口所需电话号码
@property (nonatomic        ) BOOL                  isAllowsSelection;// 是否可点击 默认可以
@property (nonatomic        ) BOOL                  isShowSelectedMark;// 是否显示浏览痕迹
@property (nonatomic        ) NSInteger             state;// 状态 （销售线索）
@property (nonatomic, strong) NSMutableArray        *mCarLists;// 列表数据源
@property (nonatomic        ) NSInteger             carListAllCount;// 车源总量
@property (nonatomic, strong) UITableView           *tvCarList;
@property (nonatomic        ) BOOL                  isEnableActivityZone;// 是否开启活动专区
@property (nonatomic) NSInteger shareID;        //分享ID
@property (nonatomic) NSInteger pageSize;       // 一次加载多少

/** 刷新车辆列表 */
- (void)refreshCarList;
/** 设置列表滚动条位置 */
- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets;
/** 设置底部视图高度 */
- (void)setFooterViewHeight:(CGFloat)height;
/** 加载更多 */
- (void)loadMore;
/** 开启活动专区 */
- (void)enableActivityZone:(BOOL)isEnable;
/** 根据数据源刷 */
- (void)refreshCarListWithCarListModels:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount;

- (id)initWithFrame:(CGRect)frame isForSearchResult:(BOOL)boolean;

@end


@protocol UCCarListViewDelegate <NSObject>
@optional

- (void)carListView:(UCCarListView *)vCarList carInfoModel:(UCCarInfoModel *)mCarInfo;
- (void)carListViewLoadData:(UCCarListView *)vCarList;
- (void)carListViewLoadDataSuccess:(UCCarListView *)vCarList;
- (void)carListViewDidSearched:(UCCarListView *)vCarList;        // 搜索完毕，包括正常和异常

@end