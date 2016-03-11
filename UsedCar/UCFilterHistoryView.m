//
//  UCFilterHistoryView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCFilterHistoryView.h"
#import "FilterHistoryCell.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"
#import "UCFilterModel.h"
#import "NSString+Util.h"

static NSString *identifier = @"MyCell";

@interface UCFilterHistoryView () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, FilterHistoryCellDelegate>

@property (nonatomic, strong) UIView *vStatusBar;
@property (nonatomic, strong) UIView *vHead;
@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILabel *labNoData;

@end

@implementation UCFilterHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];
    }
    return self;
}


- (void)initView{
    
    self.clipsToBounds = YES;
    self.backgroundColor = kColorNewBackground;
    
    [UMStatistics event:pv_3_8_buycar_creening_recording];
    
    // 状态栏
    _vStatusBar = [self creatStatusBarView:CGRectMake(0, 0, self.width, 20)];
    
    // 头视图(导航)
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_vStatusBar];
    [self addSubview:_tbTop];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height-_tbTop.maxY)];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setSeparatorColor:kColorNewLine];
    [_tableView setBackgroundView:[[UIView alloc]initLineWithFrame:_tableView.bounds color:kColorNewBackground]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self addSubview:_tableView];
    
    [self loadFilterHistory];
}

/** 状态栏 */
- (UIView *)creatStatusBarView:(CGRect)frame
{
    _vStatusBar = [[UIView alloc] initWithFrame:frame];
    _vStatusBar.backgroundColor = kColorBlue;
    _vStatusBar.alpha = 0.9;
    _vStatusBar.hidden = YES;
    return _vStatusBar;
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    _tbTop.btnLeft.width = 130;
    _tbTop.btnLeft.adjustsImageWhenHighlighted = NO;
    _tbTop.btnLeft.titleLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnTitle setTitle:@"筛选记录" forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    
    [_tbTop.btnRight setTitle:@"清除" forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_tbTop.btnTitle setTitleColor:kColorNewGray2 forState:UIControlStateDisabled];
    [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    return _tbTop;
}

#pragma mark - method
- (void)setNoDataLable
{
    // 隐藏
    if (_dataArray.count > 0) {
        _labNoData.hidden = YES;
    }
    // 显示
    else {
        if (!_labNoData) {
            _labNoData = [[UILabel alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
            _labNoData.backgroundColor = kColorClear;
            _labNoData.text = @"暂无筛选记录";
            _labNoData.textAlignment = NSTextAlignmentCenter;
            _labNoData.font = kFontLarge;
            _labNoData.textColor = kColorNewGray2;
            [self addSubview:_labNoData];
        }
        _labNoData.hidden = NO;
    }
}

#pragma mark - onClickButton
/** 顶栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    switch (btn.tag) {
        case UCTopBarButtonLeft:
        {
            [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
        }
            break;
        case UCTopBarButtonRight:
        {
            [UMStatistics event:c_3_8_buycar_creening_recording_alldelete];
            if (self.dataArray.count > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"是否清除所有筛选记录?"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确认", nil];
                alert.tag = 0;
                [alert show];
            }
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Load & Remove History
- (void)loadFilterHistory{
    self.dataArray = [[NSMutableArray alloc] init];
    [self.dataArray addObjectsFromArray:[AMCacheManage currentHistoryFilter]];
    [self.tableView reloadData];
    [self setNoDataLable];
    _tbTop.btnRight.hidden = self.dataArray.count > 0 ? NO : YES;
    AMLog(@"FilterHistory %@", self.dataArray);
}

- (void)removeAllFilterHistory{
    [self.dataArray removeAllObjects];
    if ([AMCacheManage setCurrentHistoryFilter:self.dataArray]) {
        [[AMToastView toastView] showMessage:@"已清除全部筛选记录" icon:kImageRequestSuccess duration:AMToastDurationNormal];
        [self.tableView reloadData];
        [self setNoDataLable];
        _tbTop.btnRight.hidden = self.dataArray.count > 0 ? NO : YES;
    }
    else{
        [[AMToastView toastView] showMessage:@"清除全部筛选记录失败了" icon:kImageRequestError duration:AMToastDurationNormal];
        [self loadFilterHistory];
    }
}

- (void)removeSingleHistory:(NSInteger)index{
    AMLog(@"index %d", index );
    
    if (index < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:index];
        [AMCacheManage setCurrentHistoryFilter:self.dataArray];
        [self.tableView reloadData];
        [self setNoDataLable];
    }
    else{
        //如果 index 大于 dataArray 说明清除 all 的时候没有清空
        [self removeAllFilterHistory];
    }
    _tbTop.btnRight.hidden = self.dataArray.count > 0 ? NO : YES;
    
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self removeAllFilterHistory];
    }
}

#pragma mark - UITableview Delegate Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FilterHistoryCell *cell = (FilterHistoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FilterHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier cellHeight:tableView.width];
        cell.delegate = self;
    }
    
    if (self.dataArray.count == 0) {
        [cell.deleteButton setHidden:YES];
    }
    else{
        [cell.deleteButton setHidden:NO];
        [cell.deleteButton setTag:indexPath.row];
        [cell setIndexPath:indexPath];
        UCFilterModel *model = [self.dataArray objectAtIndex:indexPath.row];
        NSString *title = [self assembleTitleStringWithModel:model];

        [cell.recordLabel setText:title];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIView *bgView = [[UIView alloc] initWithFrame:cell.bounds];
    [bgView setBackgroundColor:kColorNewBackground];
    [cell setSelectedBackgroundView:bgView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [UMStatistics event:c_3_8_buycar_creening_recording_click];
    if ([self.delegate respondsToSelector:@selector(filterHistoryDidSelectModel:)]) {
        UCFilterModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [self.delegate filterHistoryDidSelectModel:model];
    }
}

#pragma mark - FilterHistoryCellDelegate

- (void)filterHistoryCellDeleteButtonClicked:(UIButton*)button atIndexPath:(NSIndexPath *)indexPath{
    [UMStatistics event:c_3_8_buycar_creening_recording_delete];
    [self removeSingleHistory:indexPath.row];
}

#pragma mark - Organize Cell Data
- (NSString *)assembleTitleStringWithModel:(UCFilterModel*)model{
    
    NSMutableString *title = [NSMutableString new];
    
    if (![model isNull] && model.brandid.length > 0) {
        NSString *strBrandText = @"";
        if (model.seriesid.length == 0) {
            strBrandText = model.brandidText;
        } else {
            // 更新品牌UI
            NSString *strSeries = model.seriesidText.length > 0 ? model.seriesidText : @"";
            NSString *strSpec = model.specidText.length > 0 ? model.specidText : @"";
            strBrandText = [NSString stringWithFormat:@"%@%@", strSeries, strSpec];
        }
        strBrandText = [strBrandText omitForSize:CGSizeMake(70, 15) font:kFontSmall];
        [title appendString:@"、"];
        [title appendString:strBrandText];
    }
    if (model.priceregionText) {
        [title appendString:@"、"];
        [title appendString:model.priceregionText];
    }
    if (model.mileageregionText) {
        [title appendString:@"、"];
        [title appendString:model.mileageregionText];
    }
    if (model.registeageregionText) {
        [title appendString:@"、"];
        [title appendString:model.registeageregionText];
    }
    if (model.levelidText) {
        [title appendString:@"、"];
        [title appendString:model.levelidText];
    }
    if (model.gearboxidText) {
        [title appendString:@"、"];
        [title appendString:model.gearboxidText];
    }
    if (model.colorText) {
        [title appendString:@"、"];
        [title appendString:model.colorText];
    }
    if (model.displacementText) {
        [title appendString:@"、"];
        [title appendString:model.displacementText];
    }
    if (model.countryidText) {
        [title appendString:@"、"];
        [title appendString:model.countryidText];
    }
    if (model.countrytypeText) {
        [title appendString:@"、"];
        [title appendString:model.countrytypeText];
    }
    if (model.powertrainText) {
        [title appendString:@"、"];
        [title appendString:model.powertrainText];
    }
    if (model.structureText) {
        [title appendString:@"、"];
        [title appendString:model.structureText];
    }
    if (model.sourceidText) {
        [title appendString:@"、"];
        [title appendString:model.sourceidText];
    }
    if (model.haswarrantyText) {
        [title appendString:@"、"];
        [title appendString:model.haswarrantyText];
    }
    if (model.extrepairText) {
        [title appendString:@"、"];
        [title appendString:model.extrepairText];
    }
    if (model.isnewcarText) {
        [title appendString:@"、"];
        [title appendString:model.isnewcarText];
    }
    if (model.dealertypeText) {
        [title appendString:@"、"];
        [title appendString:model.dealertypeText];
    }
    if (model.ispicText) {
        [title appendString:@"、"];
        [title appendString:model.ispicText];
    }
    // 去首顿号
    if (title.length > 0)
        [title deleteCharactersInRange:NSMakeRange(0, 1)];
    
    return [title copy];
}

@end
