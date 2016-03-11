//
//  UCCarAttentionList.m
//  UsedCar
//
//  Created by wangfaquan on 14-4-6.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCAttentionListView.h"
#import "APIHelper.h"
#import "UCAreaMode.h"
#import "UCCarAttenModel.h"
#import "CKRefreshControl.h"
#import "UCAttentionCell.h"
#import "UCNewFilterView.h"
#import "UCAttentionListView.h"
#import "UCAttentionDetailView.h"

#define UCCarAttentionInfoCellHeight 75
const static CGFloat kDeleteButtonWidth = 85;
const static CGFloat kDeleteButtonHeight = 40;

@interface UCAttentionListView()

@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) APIHelper *apiView;
@property (nonatomic, strong) APIHelper *apiAttentionList;
@property (nonatomic, strong) APIHelper *apiOperateAttention;    // 添加|修改订阅
@property (nonatomic, strong) NSMutableDictionary *dicReadNew;   // 已读痕迹

@property (nonatomic, strong) UILabel *labNoData;                // 无数据提示
@property (nonatomic, strong) UIImageView *ivRemind;             // 无数据图片
@property (nonatomic, strong) UIView *vTop;                      // 顶部条

@property (nonatomic, strong) UIView *vOperate;                  // 操作视图
@property (nonatomic, strong) UIButton *btnDelete;               // 删除按钮
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation UCAttentionListView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        _dicReadNew = [[NSMutableDictionary alloc] init];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    _vTop = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, 20) color:kColorNewLine];
    _vTop.hidden = YES;
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, _vTop.height-kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    [_vTop addSubview:vLine];
    UIImageView *ivNotice = [[UIImageView alloc] initLineWithFrame:CGRectMake(105, 4, 12, 12) color:kColorClear];
    [ivNotice setImage:[UIImage imageNamed:@"contrast_notice_icon"]];
    
    UILabel *labTitles = [[UILabel alloc] init];
    labTitles.backgroundColor = kColorClear;
    labTitles.text = @"最多可订阅10个车源";
    labTitles.textColor = kColorNewGray2;
    labTitles.font = kFontTiny;
    [labTitles sizeToFit];
    labTitles.origin = CGPointMake((_vTop.width - labTitles.width) / 2 + ivNotice.width / 2, (_vTop.height - labTitles.height) / 2);
    ivNotice.minX = labTitles.minX - ivNotice.width - 3;
    
    _ivRemind = [[UIImageView alloc] initWithClearFrame:CGRectMake((self.width - 206) / 2, 30, 206, 85)];
    [_ivRemind setImage:[UIImage imageNamed:@"remaind"]];
    _ivRemind.hidden = YES;
    
    
    // 对比列表
    _tvAttentionList = [[UITableView alloc] initWithFrame:CGRectMake(0, _vTop.maxY, self.width, self.height - _vTop.maxY )];
    _tvAttentionList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvAttentionList.dataSource = self;
    _tvAttentionList.delegate = self;
    _tvAttentionList.backgroundColor = kColorNewBackground;
    
    _pullRefresh = [[CKRefreshControl alloc] initInScrollView:_tvAttentionList];
    _pullRefresh.titlePulling = @"下拉即可刷新";
    _pullRefresh.titleReady = @"松开立即刷新";
    _pullRefresh.titleRefreshing = @"正在加载中…";
    _pullRefresh.backgroundColor = [UIColor clearColor];
    
    
    [_pullRefresh addTarget:self action:@selector(onPull) forControlEvents:UIControlEventValueChanged];
    
    [_vTop addSubview:ivNotice];
    [_vTop addSubview:labTitles];
    [self addSubview:_vTop];
    [self addSubview:_tvAttentionList];
    [self addSubview:_labNoData];
    [self addSubview:_ivRemind];
    [self initDeleteView];
}

#pragma mark - public Method
/** 刷新关注列表 */
- (void)refreshAttentionList
{
    //这里需要把 _dicReadNew 重置
    [_dicReadNew removeAllObjects];
    _ivRemind.hidden = _attentionItems.count != 0;
    _pullRefresh.enabled = _attentionItems.count != 0;
    _pullRefresh.hidden = _attentionItems.count == 0;
    _vTop.hidden = _attentionItems.count < 1;
    _btnRight.hidden = _attentionItems.count > 9;
    [_tvAttentionList reloadData];
}

- (void)onPull
{
    // 关注的车列表页
    [UMStatistics event:pv_3_5_attentioncarlist];
    // 是否显示无数据提示
    if ([_delegate respondsToSelector:@selector(getAttentionCars)]) {
        [_delegate getAttentionCars];
    }
}

#pragma mark - private Method
/** 手势操作 */
- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    // 找到要进行操作的地方
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    if(![_tvAttentionList.dataSource tableView:_tvAttentionList canEditRowAtIndexPath:indexPath])
        return;
    
    // 判断出手势的方向
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [_tvAttentionList cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [_tvAttentionList cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self closeCellOptionBtn];
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)handleLongPressGestures
{
    [self closeCellOptionBtn];
}

/** 初始化删除按钮 */
- (void)initDeleteView
{
    // 添加向右的手势
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [_tvAttentionList addGestureRecognizer:_leftGestureRecognizer];
    
    // 添加向左的手势
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_tvAttentionList addGestureRecognizer:_rightGestureRecognizer];
    
    // 添加点击手势
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    _longPressGestureRecognizer.minimumPressDuration = 1;
    _longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_longPressGestureRecognizer];
    
    // 操作视图
    _vOperate = [[UIView alloc] initWithFrame:CGRectMake(self.width, 0, kDeleteButtonWidth * 2, kDeleteButtonHeight)];
    _vOperate.layer.masksToBounds = YES;
    
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(_vOperate.width - kDeleteButtonWidth * 2, 0, kDeleteButtonWidth, UCCarAttentionInfoCellHeight)];
    btnEdit.backgroundColor = kColorNewBackground;
    btnEdit.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    btnEdit.titleLabel.font = kFontLarge;
    [btnEdit setTitleColor:kColorBlue forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(onClickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 定义删除按钮
    UIView *vLineDelete = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kLinePixel,UCCarAttentionInfoCellHeight) color:kColorNewLine];
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.frame = CGRectMake(_vOperate.width - kDeleteButtonWidth, 0, kDeleteButtonWidth, UCCarAttentionInfoCellHeight);
    _btnDelete.backgroundColor = kColorRed;
    _btnDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_btnDelete setTitle:@"删除" forState:UIControlStateNormal];
    _btnDelete.titleLabel.font = kFontLarge;
    [_btnDelete setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_btnDelete addTarget:self action:@selector(onClickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnDelete addSubview:vLineDelete];
    [_vOperate addSubview:btnEdit];
    [_vOperate addSubview:_btnDelete];
    
    [_tvAttentionList addSubview:_vOperate];
    
}

/** 关闭cell操作栏 */
- (void)closeCellOptionBtn
{
    if(_editingIndexPath) {
        UITableViewCell * cell = [_tvAttentionList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_tvAttentionList setFrame:self.bounds];
}

#pragma mark - onClickButton
/** UIAlertView的点击事件 */
- (void)onClickDeleteBtn:(UIButton *)btn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确认删除该车辆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

/** 点击编辑按钮 */
- (void)onClickEditBtn:(UIButton *)btn
{
    NSIndexPath *indexPath = _editingIndexPath;
    UCCarAttenModel *mCars = [_attentionItems objectAtIndex:indexPath.row];
    // 添加
    UCAreaMode *mArea = [[UCAreaMode alloc] init];
    if (mCars.areaid.integerValue > 0) {
        mArea.areaid = [mCars.areaid stringValue];
        mArea.areaName = mCars.areaname;
    }
    if (mCars.pid.integerValue > 0) {
        mArea.pid = [mCars.pid stringValue];
        mArea.pName = mCars.province;
    }
    if (mCars.cid.integerValue > 0) {
        mArea.cid = [mCars.cid stringValue];
        mArea.cName = mCars.city;
    }
    
    UCFilterModel *mFilter = [[UCFilterModel alloc] init];
    [mFilter convertFromAttentionModel:mCars];
    UCNewFilterView *vNewFilter = [[UCNewFilterView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds mFilter:mFilter mArea:mArea attentionID:mCars.attenID];
    vNewFilter.delegate = self;
    [[MainViewController sharedVCMain] openView:vNewFilter animateOption:AnimateOptionMoveUp removeOption:RemoveOptionNone];
    
    // 关闭cell
    [self closeCellOptionBtn];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_attentionItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UCAttentionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UCAttentionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
    }
    UCCarAttenModel *mCars = [_attentionItems objectAtIndex:indexPath.row];
    [cell makeView:mCars isShowSelect:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60;
    
    UCCarAttenModel *mAtten = [_attentionItems objectAtIndex:indexPath.row];
    if (mAtten.Name.length > 0 && (mAtten.priceregion.length > 0 || mAtten.mileageregion.length > 0 || mAtten.registeageregion.length > 0 || mAtten.levelid.integerValue > 0 || mAtten.gearboxid.integerValue > 0 || mAtten.color.integerValue > 0 || mAtten.displacement.integerValue > 0 || mAtten.countryid.integerValue > 0 || mAtten.countrytype.integerValue > 0 || mAtten.powertrain.integerValue > 0 || mAtten.structure.integerValue > 0 || mAtten.sourceid.integerValue > 0 || mAtten.haswarranty.integerValue == 1 || mAtten.isnewcar.integerValue == 1 || mAtten.dealertype.integerValue == 9 || mAtten.ispic.integerValue > 0))
        height = 75;
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除数据源
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![APIHelper isNetworkAvailable]) {
            [[AMToastView toastView] showMessage:@"没有网络,删除失败" icon:kImageRequestError   duration:AMToastDurationNormal];
            return;
        }
        UCCarAttenModel *mAttention = [_attentionItems objectAtIndex:indexPath.row];
        [self deleteConcern:mAttention.attenID atIndexPath:indexPath];
    }
}

- (void)removeCacheAtIndexPath:(NSIndexPath *)indexPath {
    UCCarAttenModel *mAttention = [_attentionItems objectAtIndex:indexPath.row];
    [_attentionItems removeObject:mAttention];
    [_tvAttentionList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (_attentionItems.count == 0 || _attentionItems.count == 9) {
        [self refreshAttentionList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UCCarAttenModel *mAttens = [_attentionItems objectAtIndex:indexPath.row];
    // 更新最后查看时间
    [self updatecarsLastdateWithAttentionids:mAttens.attenID];
    // 更新列表数为0
    mAttens.count = 0;
    [_tvAttentionList reloadData];
    
    [UMStatistics event:c_3_5_attentioncarlistclick];
    
    if (!_dicReadNew)
        _dicReadNew = [[NSMutableDictionary alloc] init];
    
    UCAttentionDetailView *vAttentionDetail = [[UCAttentionDetailView alloc] initWithFrame:[MainViewController sharedVCMain].view.bounds withAttentionModel:mAttens attentionDictionary:_dicReadNew];
    [[MainViewController sharedVCMain] openView:vAttentionDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPat
{
    // 屏蔽系统的自带删除按钮
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // 获取视图触摸位置
    UIView *vGesture = gestureRecognizer.view;
    if(![vGesture isKindOfClass:[UITableView class]])
        return nil;
    NSIndexPath *indexPath = [_tvAttentionList indexPathForRowAtPoint:[gestureRecognizer locationInView:vGesture]];
    return indexPath;
}

/** 对选中的Cell进行编辑 */
- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    // 判断是不是要删除选中的cell
    if (editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [_tvAttentionList cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    CGRect frame = cell.frame;
    CGFloat cellXOffset;
    CGFloat deleteButtonXOffsetOld;
    CGFloat deleteButtonXOffset;
    
    // 对删除按钮的偏移量进行处理
    if (editing) {
        cellXOffset = -kDeleteButtonWidth;
        deleteButtonXOffset = self.width - kDeleteButtonWidth * 2;
        deleteButtonXOffsetOld = self.width;
        _editingIndexPath = indexPath;
    } else {
        cellXOffset = 0;
        deleteButtonXOffset = self.width;
        deleteButtonXOffsetOld = self.width - kDeleteButtonWidth * 2;
        _editingIndexPath = nil;
    }
    _cellHeight = [_tvAttentionList.delegate tableView:_tvAttentionList heightForRowAtIndexPath:indexPath];
    _vOperate.frame = (CGRect){deleteButtonXOffsetOld, frame.origin.y, _vOperate.frame.size.width, _cellHeight};
    for (id btn in _vOperate.subviews) {
        if ([btn isKindOfClass:[UIButton class]])
            ((UIButton *)btn).height = _cellHeight;
    };
    
    // 处理cell的位移变化
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _vOperate.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _vOperate.frame.size.width, _cellHeight};
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 弹出框删除和取消
    if (buttonIndex == 1) {
        NSIndexPath * indexPath = _editingIndexPath;
        UITableViewCell * cell = [_tvAttentionList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        
        // 对数据源进行操作
        [_tvAttentionList.dataSource tableView:_tvAttentionList commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        
    } else if (buttonIndex == 0) {
        UITableViewCell * cell = [_tvAttentionList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 关掉手势使其不是第一响应者
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 接受touch事件
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark -UIscrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 对cell处理
    if (_editingIndexPath) {
        UITableViewCell *cell = [_tvAttentionList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        _editingIndexPath = nil;
    }
}

#pragma mark - UCNewFilterViewDelegate
/** 添加完毕 */
-(void)UCNewFilterView:(UCNewFilterView *)vNewFilter addAttentionWithAreaModel:(UCAreaMode *)mArea filterModel:(UCFilterModel *)mFilter
{
    UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] init];
    [mAtten setAreaValue:mArea];
    [mAtten setFilterValue:mFilter];
    
    // 添加关注
    [self addAttentionAPIWithAttenModel:mAtten newFilterView:vNewFilter];
}

/** 编辑完毕 */
-(void)UCNewFilterView:(UCNewFilterView *)vNewFilter attentionID:(NSNumber *)ID isChanged:(BOOL)isChanged editAttentionWithAreaModel:(UCAreaMode *)mArea filterModel:(UCFilterModel *)mFilter
{
    UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] init];
    [mAtten setAreaValue:mArea];
    [mAtten setFilterValue:mFilter];
    
    [self editAttentionWithID:ID attentionModel:mAtten filterView:vNewFilter];
}

#pragma mark - APIHelper
/** 删除关注列表请求 */
- (void)deleteConcern:(NSNumber *)attentionID atIndexPath:(NSIndexPath *)indexPath
{
    if (!_apiHelper)
        _apiHelper = [[APIHelper alloc] init];
    else
        [_apiHelper cancel];
    
    __weak UCAttentionListView *temp = self;
    // 状态提示框
    [[AMToastView toastView:YES] showLoading:@"正在操作..." cancel:^{
        [_apiHelper cancel];
        [[AMToastView toastView] hide];
    }];
    // 设置请求完成后回调方法
    [_apiHelper setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            // 非取消请求
            if (error.code != ConnectionStatusCancel)
                [[AMToastView toastView] showMessage:error.domain icon:kImageRequestError duration:AMToastDurationNormal];
            return;
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                if (mBase.returncode == 0) {
                    [temp removeCacheAtIndexPath:indexPath];
                    [[AMToastView toastView] hide];
                } else {
                    if(mBase.message)
                        [[AMToastView toastView] showMessage:mBase.message icon:kImageRequestError duration:AMToastDurationNormal];
                }
            } else
                [[AMToastView toastView] hide];
            
        }
    }];
    [_apiHelper deleteConcernCars:attentionID];
}

/** 根新最后关注时间 */
- (void)updatecarsLastdateWithAttentionids:(NSNumber *)attentionid;
{
    if (!_apiView)
        _apiView = [[APIHelper alloc] init];
    else
        [_apiView cancel];

    [_apiView updatecarsLastdateWithAttentionid:attentionid];
}

/** 添加关注 */
-(void)addAttentionAPIWithAttenModel:(UCCarAttenModel *)mAtten newFilterView:(UCNewFilterView *)vNewFilter
{
    if (!_apiOperateAttention)
        _apiOperateAttention = [[APIHelper alloc] init];
    else if (_apiOperateAttention.isConnecting) {
        return;
    } else
        [_apiOperateAttention cancel];
    
    __weak UCAttentionListView *vList = self;
    
    // 设置请求完成后回调方法
    [_apiOperateAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            }
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                [[AMToastView toastView] showMessage:mBase.message icon:(mBase.returncode == 0 ? kImageRequestSuccess : kImageRequestError) duration:AMToastDurationNormal];
                if (mBase.returncode == 0) {
                    UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] initWithJson:mBase.result];
                    [mAtten setTextValue];
                    [vList.attentionItems insertObject:mAtten atIndex:0];
                    [vList refreshAttentionList];
                    // 关闭
                    [[MainViewController sharedVCMain] closeView:vNewFilter animateOption:AnimateOptionMoveLeft];
                }
            }
        }
        
    }];
    
    // 关注
    [_apiOperateAttention addAttentionWithAttenModel:mAtten];
    
}

/** 修改关注 */
- (void)editAttentionWithID:(NSNumber *)ID attentionModel:(UCCarAttenModel *)mAttention filterView:(UCNewFilterView *)vNewFilter
{
    if (!_apiOperateAttention)
        _apiOperateAttention = [[APIHelper alloc] init];
    else
        [_apiOperateAttention cancel];
    
    __weak UCAttentionListView *vList = self;
    
    // 设置请求完成后回调方法
    [_apiOperateAttention setFinishBlock:^(APIHelper *apiHelper, NSError *error) {
        // 发生错误
        if (error) {
            if (error.code != ConnectionStatusCancel) {
                [[AMToastView toastView] showMessage:ConnectionTextNot icon:kImageRequestError duration:AMToastDurationNormal];
            }
        }
        // 正常返回
        else if (apiHelper.data.length > 0) {
            BaseModel *mBase = [[BaseModel alloc] initWithData:apiHelper.data];
            if (mBase) {
                [[AMToastView toastView] showMessage:mBase.message icon:(mBase.returncode == 0 ? kImageRequestSuccess : kImageRequestError) duration:AMToastDurationNormal];
                if (mBase.returncode == 0) {
                    UCCarAttenModel *mAtten = [[UCCarAttenModel alloc] initWithJson:mBase.result];
                    [mAtten setTextValue];
                    for (int i = 0; i < vList.attentionItems.count; i++) {
                        UCCarAttenModel *mAttenTemp = [vList.attentionItems objectAtIndex:i];
                        if (mAttenTemp.attenID.integerValue == [ID integerValue]) {
                            [vList.attentionItems replaceObjectAtIndex:i withObject:mAtten];
                            [vList refreshAttentionList];
                            break;
                        }
                    }
                    // 关闭
                    [[MainViewController sharedVCMain] closeView:vNewFilter animateOption:AnimateOptionMoveLeft];
                }
            }
        }
        
    }];
    
    // 关注
    [_apiOperateAttention editAttentionWithID:ID attenModel:mAttention];
}

@end
