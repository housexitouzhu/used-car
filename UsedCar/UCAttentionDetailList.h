//
//  UCAttentionDetailList.h
//  UsedCar
//
//  Created by Sun Honglin on 14-7-22.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APIHelper;
@class UCFilterModel;
@class UCAreaMode;
@class UCCarInfoModel;
@class CKRefreshControl;
@class UCAttentionDetailList;
@class UCCarAttenModel;

@protocol UCAttentionDetailListDelegate <NSObject>

@optional
- (void)carListView:(UCAttentionDetailList *)vCarList carInfoModel:(UCCarInfoModel *)mCarInfo;
- (void)carListViewLoadData:(UCAttentionDetailList *)vCarList;
- (void)carListViewLoadDataSuccess:(UCAttentionDetailList *)vCarList;
- (void)carListViewDidSearched:(UCAttentionDetailList *)vCarList;        // 搜索完毕，包括正常和异常
- (void)carListViewDidSearched:(UCAttentionDetailList *)vCarList ConnectionError:(NSError*)error;
@end

@interface UCAttentionDetailList : UIView
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak  ) id<UCAttentionDetailListDelegate> delegate;

@property (nonatomic, strong) NSNumber             *dealerid;
@property (nonatomic, strong) NSString             *orderby;
@property (nonatomic, strong) UCAreaMode           *mArea;
@property (nonatomic, strong) UCFilterModel        *mFilter;
@property (nonatomic        ) BOOL                 isEnablePullRefresh;// 是否启用下拉刷新
@property (nonatomic, strong) NSString             *strNoData;// 无数据提示文案
@property (nonatomic, weak  ) id<UIScrollViewDelegate> scrollDelegate;
@property (nonatomic, strong) NSString             *mobile;// 订阅车辆接口所需电话号码
@property (nonatomic        ) BOOL                 isAllowsSelection;// 是否可点击 默认可以
@property (nonatomic        ) BOOL                 isShowSelectedMark;// 是否显示浏览痕迹
@property (nonatomic        ) NSInteger            state;// 状态 （销售线索）
@property (nonatomic, strong) NSMutableArray       *mCarLists;// 列表数据源
@property (nonatomic        ) NSInteger            carListAllCount;// 车源总量
@property (nonatomic, strong) UITableView          *tvCarList;
@property (nonatomic, strong) NSMutableDictionary  *dicReadNew;
@property (retain, nonatomic) UCCarAttenModel      *mCarAtten;
@property (strong, nonatomic) NSString             *lastUpdate; //最后更新时间

/** 刷新车辆列表 */
- (void)refreshCarList;
/** 设置列表滚动条位置 */
- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets;
/** 设置底部视图高度 */
- (void)setFooterViewHeight:(CGFloat)height;
/** 加载更多 */
- (void)loadMore;
/** 根据数据源刷 */
- (void)refreshCarListWithCarListModels:(NSMutableArray *)mCarLists rowCount:(NSInteger)rowCount;

- (id)initWithFrame:(CGRect)frame withUCCarAttenModel:(UCCarAttenModel*)mCarAtten AttentionDictionary:(NSMutableDictionary*)dict AttentionArray:(NSMutableArray*)attArray LastUpdate:(NSString*)lastUpdate;


@end
