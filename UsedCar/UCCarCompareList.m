//
//  UCCarCompareList.m
//  UsedCar
//
//  Created by wangfaquan on 14-1-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarCompareList.h"
#import "AMCacheManage.h"
#import "UCCompareDetailView.h"
#import "UIImage+Util.h"
#import "UCCarInfoCell.h"
#import "UCCarInfoModel.h"
#import "UCTopBar.h"

#define UCCarCompareInfoCellHeight 84

const static CGFloat kDeleteButtonWidth = 85;
const static CGFloat kDeleteButtonHeight = 40;

@interface UCCarCompareList ()

@property (nonatomic, strong) UISwipeGestureRecognizer *leftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILabel *labNoData;
@property (nonatomic, strong) UIView *vBottom;
@property (nonatomic, strong) UIButton *btnDelete;
@property (nonatomic, strong) NSMutableArray *twoCompareItems;
@property (nonatomic, strong) UITableView *tvCompareList;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, strong) NSMutableArray *selecteds;

@end

@implementation UCCarCompareList

- (id)initWithFrame:(CGRect)frame compareItems:(NSMutableArray *)compareItems
{
    self = [super initWithFrame:frame];
    if (self) {
        _compareItems = compareItems;
        
        // 创建一个数组存放各个状态
        _selecteds = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0 ; i < _compareItems.count; i++) {
            [_selecteds addObject:[NSNumber numberWithBool:NO]];
        }
        _twoCompareItems = [NSMutableArray arrayWithCapacity:2];
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    UIView *vTop = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, 20) color:kColorNewLine];
    
    // 分割线
    UIView *vLine = [[UIView alloc] initLineWithFrame:CGRectMake(0, vTop.height - kLinePixel, self.width, kLinePixel) color:kColorNewLine];
    
    UIImageView *ivNotice = [[UIImageView alloc] initLineWithFrame:CGRectMake(45, 4, 12, 12) color:kColorClear];
    [ivNotice setImage:[UIImage imageNamed:@"contrast_notice_icon"]];
    UILabel *labTitles = [[UILabel alloc] initLineWithFrame:CGRectMake(ivNotice.maxX + 4, 0, self.width - 80, 20) color:kColorClear];
    labTitles.text = @"最多可添加10辆车,每次可同时对比2辆车";
    labTitles.textColor = kColorGrey3;
    labTitles.font = [UIFont systemFontOfSize:11];
    [labTitles sizeToFit];
    labTitles.origin = CGPointMake((self.width - labTitles.width) / 2 + ivNotice.width / 2, (vTop.height - labTitles.height) / 2);
    ivNotice.minX = labTitles.minX - ivNotice.width - 2;
    
    // 创建比一比按钮
    UIButton *btnCompare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCompare setFrame:CGRectMake(20, 12.5, self.width - 40, 45)];
    [btnCompare setTitle:@"比一比" forState:UIControlStateNormal];
    [btnCompare setBackgroundImage:[UIImage imageWithColor:kColorLightGreen size:btnCompare.size] forState:UIControlStateNormal];
    [btnCompare setBackgroundImage:[UIImage imageWithColor:kColorGreen2 size:btnCompare.size] forState:UIControlStateHighlighted];
    [btnCompare setBackgroundImage:[UIImage imageWithColor:RGBColorAlpha(220, 220, 220, 1) size:btnCompare.size] forState:UIControlStateDisabled];
    btnCompare.layer.masksToBounds = YES;
    btnCompare.layer.cornerRadius = 5;
    [btnCompare addTarget:self action:@selector(onClickCompareBtns:) forControlEvents:(UIControlEventTouchUpInside)];
    
    // 创建最底部的不透明视图
    _vBottom = [[UIView alloc] initLineWithFrame:CGRectMake(0, self.height - 70 , self.width, 70) color:kColorWhite];
    
    // 对比列表
    _tvCompareList = [[UITableView alloc] initWithFrame:CGRectMake(0, vTop.maxY, self.width, self.height - vTop.maxY - _vBottom.height)];
    _tvCompareList.backgroundColor = kColorNewBackground;
    _tvCompareList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tvCompareList.dataSource = self;
    _tvCompareList.delegate = self;
    
    // 分割线
    UIView *vLineBottom = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, self.width, kLinePixel) color:kColorNewLine];
    [_vBottom addSubview:vLineBottom];
    _vBottom.userInteractionEnabled = YES;
    
    // 如果没有数据显示的类容
    _labNoData = [[UILabel alloc] initWithClearFrame:CGRectMake(0, 0, self.width, self.height - 64 - 40)];
    _labNoData.numberOfLines = 2;
    _labNoData.text = [NSString stringWithFormat:@"暂无对比车辆\n快去车辆详情页添加一辆吧"];
    _labNoData.textAlignment = NSTextAlignmentCenter;
    _labNoData.font = [UIFont systemFontOfSize:16];
    _labNoData.textColor = kColorNewGray2;
    _labNoData.backgroundColor=kColorClear;
    
    // 通过判断数组中数据来设置视图的显示或隐藏
    if (_compareItems.count == 0) {
        _labNoData.hidden = NO;
        _vBottom.hidden = YES;
    }
    
    [_vBottom addSubview:btnCompare];
    [self addSubview:_tvCompareList];
    [self addSubview:_vBottom];
    [vTop addSubview:ivNotice];
    [vTop addSubview:labTitles];
    [vTop addSubview:vLine];
    [self addSubview:vTop];
    [self initDeleteView];
    [self addSubview:_labNoData];
}

#pragma mark - public Method
/** 刷新数据 */
- (void)reloadData
{
    [_selecteds removeAllObjects];
    [_twoCompareItems removeAllObjects];
    
    if(_editingIndexPath) {
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
    
    for (int i = 0 ; i < _compareItems.count; i++) {
        [_selecteds addObject:[NSNumber numberWithBool:NO]];
    }
    if (_compareItems.count == 0) {
        _labNoData.hidden = NO;
        _vBottom.hidden = YES;
        _tbTop.btnRight.hidden = YES;
        _btnDelete.hidden = YES;
    } else if(_compareItems.count > 0) {
        _labNoData.hidden = YES;
        _vBottom.hidden = NO;
        _tbTop.btnRight.hidden = NO;
        _btnDelete.hidden = NO;
    }
    [_tvCompareList reloadData];
}

#pragma mark - private Method
/** 初始化删除按钮 */
- (void)initDeleteView
{
    // 添加向右的手势
    _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftGestureRecognizer.delegate = self;
    [_tvCompareList addGestureRecognizer:_leftGestureRecognizer];
    
    // 添加向左的手势
    _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    _rightGestureRecognizer.delegate = self;
    _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_tvCompareList addGestureRecognizer:_rightGestureRecognizer];
    
    // 添加点击手势
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tapGestureRecognizer.delegate = self;
    
    // 定义删除按钮
    UIView *vLineDelete = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kLinePixel,UCCarCompareInfoCellHeight) color:kColorNewLine];
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.frame = CGRectMake(self.width, 0, kDeleteButtonWidth, kDeleteButtonHeight);
    _btnDelete.backgroundColor = kColorRed;
    _btnDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_btnDelete setTitle:@"删除" forState:UIControlStateNormal];
    _btnDelete.titleLabel.font = kFontLarge;
    [_btnDelete setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_btnDelete addTarget:self action:@selector(onClickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_tvCompareList addSubview:_btnDelete];
    [_btnDelete addSubview:vLineDelete];
}


- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    // 找到要进行操作的地方
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    if(![_tvCompareList.dataSource tableView:_tvCompareList canEditRowAtIndexPath:indexPath])
        return;
    
    // 判断出手势的方向
    if(gestureRecognizer == _leftGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    // 点击手势的操作
    if(_editingIndexPath) {
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
    }
}

#pragma mark - onClickButton
/** UIAlertView的点击事件 */
- (void)onClickDeleteBtn:(UIButton *)btn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确认删除该车辆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

/** 比一比点击事件 */
- (void)onClickCompareBtns:(UIButton *)btn
{
    // 通过选着车辆的个数来判断
    if (_twoCompareItems.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请您先选择车辆" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    } else if (_twoCompareItems.count == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请再选择一辆车发起对比" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    } else if (_twoCompareItems.count == 2) {
        // 点击比一比统计
        [UMStatistics event:c_3_3_pk];
        UCCarCompareDetailView *mCarDetail = [[UCCarCompareDetailView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + _tbTop.height) twoCar:(NSArray *)_twoCompareItems];
        [[MainViewController sharedVCMain] openView:mCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    }
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_compareItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UCCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UCCarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellWidth:tableView.width];
    }
    
    // model之间的转换
    UCCarDetailInfoModel *mCarCompare = [_compareItems objectAtIndex:indexPath.row];
    UCCarInfoModel *mCarInfor = [[UCCarInfoModel alloc] init];
    // 图片urls
    NSArray *thumbimgurls = [[NSArray alloc] initWithArray:[mCarCompare.thumbimgurlsText componentsSeparatedByString:@","]];
    mCarInfor.image = thumbimgurls.count > 0 ? [thumbimgurls objectAtIndex:0] : nil;
    mCarInfor.carname = mCarCompare.carnameText;
    mCarInfor.sourceid = mCarCompare.sourceid;
    mCarInfor.price = mCarCompare.bookpriceText;
    mCarInfor.mileage = mCarCompare.drivemileageText;
    mCarInfor.isnewcar = mCarCompare.isnewcar;
    mCarInfor.invoice = mCarCompare.extendedrepair;
    mCarInfor.registrationdate = [mCarCompare.firstregtimeText substringToIndex:4];
    [cell makeView:mCarInfor isShowSelect:YES];
    
    // 图片转换
    UCCarDetailInfoModel * mCarDetailInfo = [_compareItems objectAtIndex:indexPath.row];
    if ([_twoCompareItems containsObject:mCarDetailInfo])
        [cell setImageWithSelectedState:[NSNumber numberWithBool:YES]];
    else
        [cell setImageWithSelectedState:[NSNumber numberWithBool:NO]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UCCarCompareInfoCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过选中IndexPath来取出要删除的数据
    UCCarDetailInfoModel * mCardetail = [_compareItems objectAtIndex:indexPath.row];
    
    // 判断数据是不是存在来做处理
    if ([_twoCompareItems containsObject:mCardetail]) {
        [_twoCompareItems removeObject:mCardetail];
    } else  {
        [_twoCompareItems addObject:mCardetail];
    }
    if (_twoCompareItems.count > 2) {
        [_twoCompareItems removeObject:mCardetail];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"最多仅支持两辆车同时对比" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除数据源
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UCCarDetailInfoModel *mCarCompare = [_compareItems objectAtIndex:indexPath.row];
        [_compareItems removeObject:mCarCompare];
        if ([_twoCompareItems containsObject:mCarCompare]) {
            [_twoCompareItems removeObject:mCarCompare];
        }
        [AMCacheManage setCurrentCompareInfo:_compareItems];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 判断出列表数据的数来处理要显示的视图
        if (_compareItems.count == 0) {
            _labNoData.hidden = NO;
            _vBottom.hidden = YES;
            _tbTop.btnRight.hidden = YES;
        }
    }
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
    NSIndexPath *indexPath = [_tvCompareList indexPathForRowAtPoint:[gestureRecognizer locationInView:vGesture]];
    return indexPath;
}

/** 对选中的Cell进行编辑 */
- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    // 判断是不是要删除选中的cell
    if (editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
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
        deleteButtonXOffset = self.width - kDeleteButtonWidth;
        deleteButtonXOffsetOld = self.width;
        _editingIndexPath = indexPath;
    } else {
        cellXOffset = 0;
        deleteButtonXOffset = self.width;
        deleteButtonXOffsetOld = self.width - kDeleteButtonWidth;
        _editingIndexPath = nil;
    }
    _cellHeight = [_tvCompareList.delegate tableView:_tvCompareList heightForRowAtIndexPath:indexPath];
    _btnDelete.frame = (CGRect){deleteButtonXOffsetOld, frame.origin.y, _btnDelete.frame.size.width, _cellHeight};
    
    // 处理cell的位移变化
    [UIView animateWithDuration:0.2f animations:^{
        cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
        _btnDelete.frame = (CGRect) {deleteButtonXOffset, frame.origin.y, _btnDelete.frame.size.width, _cellHeight};
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 弹出框删除和取消
    if (buttonIndex == 1) {
        NSIndexPath * indexPath = _editingIndexPath;
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        
        // 对数据源进行操作
        [_tvCompareList.dataSource tableView:_tvCompareList commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        _editingIndexPath = nil;
        
        // 删除按钮偏移量处理
        [UIView animateWithDuration:0.2f animations:^{
            CGRect frame = _btnDelete.frame;
            _btnDelete.frame = (CGRect){frame.origin, frame.size.width, 0};
        } completion:^(BOOL finished) {
            CGRect frame = _btnDelete.frame;
            _btnDelete.frame = (CGRect){self.width, frame.origin.y, frame.size.width, kDeleteButtonHeight};
        }];
    } else if (buttonIndex == 0) {
        UITableViewCell * cell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        CGRect frame = cell.frame;
        CGFloat cellXOffset = 0.0;
        
        // 删除按钮偏移量处理
        [UIView animateWithDuration:0.2f animations:^{
            cell.frame = CGRectMake(cellXOffset, frame.origin.y, frame.size.width, frame.size.height);
            _btnDelete.frame = (CGRect) {self.width, frame.origin.y, _btnDelete.frame.size.width, _cellHeight};
        }];
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
        UITableViewCell *cell = [_tvCompareList cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
        _editingIndexPath = nil;
    }
}

@end