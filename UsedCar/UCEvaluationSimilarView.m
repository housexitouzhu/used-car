//
//  UCEvaluationSimilarView.m
//  UsedCar
//
//  Created by 张鑫 on 14/10/23.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCEvaluationSimilarView.h"
#import "UCTopBar.h"
#import "UCCarInfoEditModel.h"
#import "UCAreaMode.h"
#import "UCFilterModel.h"
#import "UCCarDetailView.h"
#import "AMCacheManage.h"

@interface UCEvaluationSimilarView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarListView *vCarList;
@property (nonatomic, strong) UCOrderView *vOrder;
@property (nonatomic, strong) UIView *vCondition;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labCount;
@property (nonatomic, strong) UCCarInfoEditModel *mCarInfoEdit;
@property (nonatomic, strong) UCAreaMode *mArea;

@end

@implementation UCEvaluationSimilarView

- (id)initWithFrame:(CGRect)frame carInfoDEditModel:(UCCarInfoEditModel *)mCarInfoEdit
{
    self = [super initWithFrame:frame];
    if (self) {
        _mArea = [OMG areaModelWithCid:mCarInfoEdit.cityid.stringValue];
        _mCarInfoEdit = mCarInfoEdit;
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 排序
    _vOrder = [[UCOrderView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    _vOrder.delegate = self;
    
    // 条件
    _vCondition = [self creatConditionView:CGRectMake(0, _vOrder.maxY, self.width, _vOrder.height)];
    
    // 列表
    _vCarList = [self creatCarListView:CGRectMake(0, _vCondition.maxY, self.width, self.height - _vCondition.maxY)];
    [_vCarList refreshCarList];
    
    [self addSubview:_tbTop];
    [self addSubview:_vOrder];
    [self addSubview:_vCondition];
    [self addSubview:_vCarList];

}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [_tbTop.btnTitle setTitle:@"同款车源" forState:UIControlStateNormal];
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return _tbTop;
}

/** 条件 */
-(UIView *)creatConditionView:(CGRect)frame
{
    _vCondition = [[UIView alloc] initWithFrame:frame];
    _vCondition.backgroundColor = kColorClear;
    
    // 标题
    _labTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 171, frame.size.height)];
    _labTitle.backgroundColor = kColorClear;
    _labTitle.textColor = kColorNewGray2;
    _labTitle.font = kFontSmall;
    _labTitle.text = [NSString stringWithFormat:@"%@ %@", _mArea.cName, _mCarInfoEdit.seriesname];
    
    // 数字
    _labCount = [[UILabel alloc] initWithFrame:CGRectMake(_vCondition.width - 120 - 20, 0, 120, frame.size.height)];
    _labCount.backgroundColor = kColorClear;
    _labCount.textColor = kColorNewGray2;
    _labCount.font = kFontSmall;
    _labCount.textAlignment = NSTextAlignmentRight;
    
    [_vCondition addSubview:_labTitle];
    [_vCondition addSubview:_labCount];
    [_vCondition addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _vCondition.height - kLinePixel, _vCondition.width, kLinePixel) color:kColorNewLine]];
    
    return _vCondition;
}

/** 列表 */
- (UCCarListView *)creatCarListView:(CGRect)frame
{
    UCFilterModel *mFilter = [[UCFilterModel alloc] init];
    mFilter.brandid = _mCarInfoEdit.brandid.stringValue;
    mFilter.seriesid = _mCarInfoEdit.seriesid.stringValue;
    
    // 车辆列表
    _vCarList = [[UCCarListView alloc] initWithClearFrame:frame];
    _vCarList.mFilter = mFilter;
    _vCarList.mArea = _mArea;
    _vCarList.orderby = @"0";
    _vCarList.delegate = self;
    [_vCarList enableActivityZone:NO];
    
    return _vCarList;
}

#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
}

#pragma mark - Public Method

#pragma mark - private Method

#pragma mark - System Delegate

#pragma mark - Custom Delegate

#pragma mark - UCOrderViewDelegate
-(void)orderView:(UCOrderView *)vOrder didSelectedIndex:(NSInteger)index
{
    NSString *order = [NSString stringWithFormat:@"%d", index];
    if (order != self.vCarList.orderby && ![order isEqualToString:self.vCarList.orderby]) {
        // 刷新主页车辆列表数据
        _vCarList.orderby = order;
        [_vCarList refreshCarList];
        
    }
}

#pragma mark - UCCarListViewDelegate
-(void)carListViewLoadDataSuccess:(UCCarListView *)vCarList
{
    UserInfoModel *mUserInfo = [AMCacheManage currentUserInfo];
    NSNumber *userid = nil;
    NSNumber *dealerid = nil;
    switch ([AMCacheManage currentUserType]) {
        case UserStyleBusiness:
            dealerid = mUserInfo.userid;
            break;
        case UserStylePersonal:
            userid = mUserInfo.userid;;
            break;
            
        default:
            break;
    }
    [UMSAgent postEvent:tool_evaluation_sellcar_result_likelist_pv page_name:NSStringFromClass(self.class) eventargvs:[NSMutableDictionary dictionaryWithObjectsAndKeys:_mCarInfoEdit.seriesid.stringValue, @"seriesid#2", _mCarInfoEdit.productid.stringValue, @"specid#3", userid, @"userid#4", dealerid, @"dealerid#5", nil]];
    [UMStatistics event:pv_4_1_tool_evaluation_buycar_result_likelist];

    // 刷新总数
    NSString *countStr = [NSString stringWithFormat:@"共%d条结果", vCarList.carListAllCount];
    [_labCount setText:countStr];
}

-(void)carListView:(UCCarListView *)vCarList carInfoModel:(UCCarInfoModel *)mCarInfo
{
    [UMStatistics event:c_4_1_tool_evaluation_buycar_result_likelist_click];
    
    // 进入详情
    UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:self.bounds mCarInfo:mCarInfo];
    [[MainViewController sharedVCMain] openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

#pragma mark - APIHelper

#pragma mark - delloc
-(void)dealloc
{
    AMLog(@"\ndealloc...:%@\n", NSStringFromClass([self class]));
}

@end
