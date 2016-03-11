//
//  UCSalesListView.m
//  UsedCar
//
//  Created by 张鑫 on 13-12-19.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCSalesListView.h"
#import "UCTopBar.h"
#import "UserInfoModel.h"
#import "AMCacheManage.h"
#import "UCAddSalesPerson.h"
#import "NSString+Util.h"
#import "CKRefreshControl.h"
#import "APIHelper.h"

@interface UCSalesListView ()

@property (nonatomic, strong) UITableView *tvSalesList;
@property (nonatomic, strong) CKRefreshControl *pullRefresh;
@property (nonatomic, strong) APIHelper *apiSalePerson;
@property (nonatomic, strong) UILabel *labNoData;

@end

@implementation UCSalesListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _apiSalePerson = [[APIHelper alloc] init];
        _sales = [NSMutableArray array];
        //页面
        [self initView];
    }
    return self;
}

#pragma mark - initView
-(void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    UCTopBar *tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];

    [self addSubview:tbTop];
    
    // 最多80
    UILabel *labMaxSales = [[UILabel alloc] initWithFrame:CGRectMake(0, tbTop.maxY, self.width, 35)];
    labMaxSales.backgroundColor = [UIColor clearColor];
    labMaxSales.textColor = kColorGrey3;
    labMaxSales.textAlignment = NSTextAlignmentCenter;
    labMaxSales.font = kFontMini;
    labMaxSales.text = @"最多可添加80位销售代表";
    [self addSubview:labMaxSales];
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, labMaxSales.height - kLinePixel, labMaxSales.width, kLinePixel) color:kColorNewLine];
    [labMaxSales addSubview:vLine];
    
    // 列表
    _tvSalesList = [[UITableView alloc] initWithFrame:CGRectMake(0, labMaxSales.maxY, self.width, self.height - labMaxSales.maxY)];
    _tvSalesList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvSalesList.delegate = self;
    _tvSalesList.dataSource = self;
    [self addSubview:_tvSalesList];
    
    // 无数据
    _labNoData = [[UILabel alloc] init];
    _labNoData.text = @"暂无销售代表";
    _labNoData.userInteractionEnabled = NO;
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.backgroundColor = kColorClear;
    [_labNoData sizeToFit];
    _labNoData.origin = CGPointMake((self.width - _labNoData.width) / 2, (self.height - labMaxSales.maxY - _labNoData.height) / 2 + labMaxSales.maxY);
    _labNoData.hidden = YES;
    [self addSubview:_labNoData];
    
    // 下拉刷新
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvSalesList];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    
    [_pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    
    // 刷新数据
    [self getSalesPerson];
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    
    // 标题
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnTitle setTitle:@"销售代表" forState:UIControlStateNormal];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vTopBar.btnRight setImage:[UIImage imageNamed:@"center_add_butten"] forState:UIControlStateNormal];
    [vTopBar.btnRight addTarget:self action:@selector(onClickAddBtn:) forControlEvents:UIControlEventTouchUpInside];
    vTopBar.btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16);
    return vTopBar;
}

#pragma mark - private Method
- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    _tvSalesList.scrollIndicatorInsets = scrollIndicatorInsets;
    _pullRefresh.originalTopContentInset = scrollIndicatorInsets.top;
}

- (void)setIsEnablePullRefresh:(BOOL)isEnablePullRefresh {
    _pullRefresh.enabled = isEnablePullRefresh;
}

- (void)onPull
{
    [self refreshCarList:NO];
}

/** 刷新车辆列表 */
- (void)refreshCarList
{
    [self refreshCarList:YES];
}

- (void)refreshCarList:(BOOL)isToTop
{
    // 设置是否可选中
    _labNoData.hidden = _sales.count > 0 ? YES : NO;
    [_apiSalePerson cancel];
    [self getSalesPerson];
    
    // 列表滚动到最顶端
    if (isToTop)
        _tvSalesList.contentOffset = CGPointMake(0, -_tvSalesList.contentInset.top);
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

/** 添加销售代表 */
- (void)onClickAddBtn:(UIButton *)btn
{
    [UMStatistics event:c_3_6_sales_salesadded];
    
    UCAddSalesPerson *vAddSalesPerson = [[UCAddSalesPerson alloc] initWithFrame:self.bounds];
    vAddSalesPerson.isFromSalesListView = YES;
    vAddSalesPerson.delegate = self;
    [[MainViewController sharedVCMain] openView:vAddSalesPerson animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

/* 关闭按钮 */
- (void)onClickClose
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - UCAddSalesPersonDelegate
/** 添加销售代表delegate */
-(void)UCAddSalesPerson:(UCAddSalesPerson *)vAddSalesPerson isSuccess:(BOOL)isSuccess
{
    // 添加成功
    if (isSuccess) {
        // 刷新销售代表
        _sales = [NSMutableArray arrayWithArray:((UserInfoModel *)[AMCacheManage currentUserInfo]).salespersonlist];
        _labNoData.hidden = _sales.count > 0 ? YES : NO;
        [_tvSalesList reloadData];
    }
    // 添加失败
    else {
        if (!vAddSalesPerson.isFromSalesListView) {
            [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
        } else {
            [[MainViewController sharedVCMain] closeView:vAddSalesPerson animateOption:AnimateOptionMoveLeft];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sales count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    
    UCSalesListCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UCSalesListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier cellWidth:tableView.width];
    }
    cell.mSalesPerson = [self.sales objectAtIndex:indexPath.row];
    [cell makeView];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 有无qq
    SalesPersonModel *mSaleP = [_sales objectAtIndex:indexPath.row];
    return (mSaleP.salesqq.length > 0) ? 90 : 50;
}

#pragma mark - APIHelper
/** 获得销售代表列表 */
- (void)getSalesPerson
{
    [_pullRefresh beginRefreshing];
    
    __weak UCSalesListView *vSalesPer = self;
    
    // 设置请求完成后回调方法
    [_apiSalePerson setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        [vSalesPer.pullRefresh endRefreshing];
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            vSalesPer.labNoData.hidden = vSalesPer.sales.count > 0 ? YES : NO;
            return;
        }
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                NSString *message = nil;
                if (mBase.returncode == 0) {
                    [vSalesPer.sales removeAllObjects];
                    for (NSDictionary *dicItem in mBase.result) {
                        SalesPersonModel *mItem = [[SalesPersonModel alloc] initWithJson:dicItem];
                        [vSalesPer.sales addObject:mItem];
                    }
                    vSalesPer.labNoData.hidden = vSalesPer.sales.count > 0 ? YES : NO;
                    [vSalesPer.tvSalesList reloadData];
                    // 滚动到顶
                    vSalesPer.tvSalesList.contentOffset = CGPointMake(0, -vSalesPer.tvSalesList.contentInset.top);
                    
                    // 替换本地数据
                    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
                    mUserInfo.salespersonlist = vSalesPer.sales;
                    [AMCacheManage setCurrentUserInfo:mUserInfo];
                    
                } else {
                    message = mBase.message;
                }
                if (message)
                    [[AMToastView toastView] showMessage:message icon:kImageRequestError duration:AMToastDurationNormal];
                else
                    [[AMToastView toastView] hide];
            } else {
                [[AMToastView toastView] hide];
            }
        } else {
            [[AMToastView toastView] hide];
        }
    }];
    
    [_apiSalePerson getDealerSalesPersonListWithListate:1 title:1];
}

-(void)dealloc
{
    [_apiSalePerson cancel];
    AMLog(@"dealloc");
}

@end

@interface UCSalesListCell ()

@property (nonatomic, strong) UIButton *btnHighlightedBg;
@property (nonatomic, strong) UILabel *labQQTitle;
@property (nonatomic, strong) UILabel *labQQ;
@property (nonatomic) CGFloat cellHetght;
@property (nonatomic, strong) UIView *vLine;

@end

#import "UCView.h"
#import "UIImage+Util.h"

@implementation UCSalesListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.width = self.contentView.width = cellWidth;
        
        self.layer.masksToBounds = NO;
        self.contentView.layer.masksToBounds = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _cellHetght = 50;
        
        //高亮背景
        _btnHighlightedBg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, _cellHetght - kLinePixel)];
        [_btnHighlightedBg setBackgroundImage:[UIImage imageWithColor:kColorGrey5 size:_btnHighlightedBg.size] forState:UIControlStateHighlighted];
        [_btnHighlightedBg setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:_btnHighlightedBg.size] forState:UIControlStateNormal];
        [_btnHighlightedBg addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
        
        // 头像
        UIImage *iHead = [UIImage imageNamed:@"sales_person_icon"];
        UIImageView *ivHead = [[UIImageView alloc] initWithImage:iHead];
        ivHead.frame = CGRectMake(13, 12, iHead.width, iHead.height);
        
        // 销售代表
        _labSalesName = [[UILabel alloc] initWithClearFrame:CGRectMake(50, 0, 80, 50)];
        _labSalesName.font = kFontLarge;
        _labSalesName.textColor = kColorGray1;
        
        // QQ
        _labQQTitle = [[UILabel alloc] init];
        _labQQTitle.backgroundColor = [UIColor clearColor];
        _labQQTitle.text = @"QQ";
        _labQQTitle.font = kFontLarge;
        _labQQTitle.textColor = _labSalesName.textColor;
        [_labQQTitle sizeToFit];
        _labQQTitle.origin = CGPointMake(50, 56);
        
        // 电话
        _labSalesPhone = [[UILabel alloc] initWithClearFrame:CGRectMake(_labSalesName.maxX, 0, self.contentView.width - _labSalesName.maxX, 50 - kLinePixel)];
        _labSalesPhone.font = [UIFont systemFontOfSize:15];
        _labSalesPhone.textAlignment = NSTextAlignmentLeft;
        _labSalesPhone.textColor = kColorGray1;
        
        // QQ
        _labQQ = [[UILabel alloc] init];
        _labQQ.backgroundColor = [UIColor clearColor];
        _labQQ.font = kFontLarge;
        _labQQ.textColor = kColorGray1;
        _labQQ.textAlignment = NSTextAlignmentLeft;
        
        //打电话图标
        UIImage *iTel = [UIImage imageNamed:@"sales_phone_icon"];
        UIImageView *ivTel = [[UIImageView alloc] initWithImage:iTel];
        ivTel.frame = CGRectMake(self.width - 40, (_cellHetght - iTel.height) / 2, ivTel.width, ivTel.height);
        
        // 分割线
        _vLine = [[UIView alloc] initLineWithFrame:CGRectMake(45, _cellHetght - kLinePixel , self.contentView.width - 45, kLinePixel) color:kColorNewLine];
        
        [self.contentView addSubview:_btnHighlightedBg];
        [self.contentView addSubview:ivHead];
        [self.contentView addSubview:_labSalesName];
        [self.contentView addSubview:_labQQTitle];
        [self.contentView addSubview:_labSalesPhone];
        [self.contentView addSubview:_labQQ];
        [self.contentView addSubview:ivTel];
        [self.contentView addSubview:_vLine];
    }
    
    return self;
}

/* 重建cell */
- (void)makeView
{
    _cellHetght = _mSalesPerson.salesqq.length > 0 ? 90 : 50;
    // 销售代表和电话号码
    _labSalesName.text = _mSalesPerson.salesname;
    _labSalesPhone.text = _mSalesPerson.salesphone;
    _labQQTitle.hidden = _mSalesPerson.salesqq.length > 0 ? NO : YES;
    _labQQ.hidden = _labQQTitle.hidden;
    _labQQ.text = [_mSalesPerson.salesqq dNull];
    [_labQQ sizeToFit];
    _labQQ.origin = CGPointMake(_labSalesPhone.minX, _labQQTitle.minY);
    _vLine.minY = _cellHetght - kLinePixel;
    _btnHighlightedBg.height = _cellHetght - kLinePixel;
}

/* 拨打电话 */
-(void)callPhone
{
    [OMG callPhone:self.mSalesPerson.salesphone];
}

@end
