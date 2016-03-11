//
//  UCClaimRecordView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-8.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCClaimRecordView.h"
#import "UCTopBar.h"
#import "UCOptionBar.h"
#import "UCCarDetailView.h"
#import "UCCarInfoModel.h"
#import "UCMainView.h"

@interface UCClaimRecordView()
<UCOptionBarDelegate, ClaimCasesListDelegate>

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (retain, nonatomic) ClaimCasesList *vList;

@end

@implementation UCClaimRecordView

- (id)initWithFrame:(CGRect)frame withStyle:(UCClaimRecordViewStyle)style ClaimType:(ClaimListType)claimType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _viewStyle = style;
        _claimType = claimType;
        
        [self initView];
    }
    return self;
}


- (void)initView{
    self.backgroundColor = kColorWhite;
    
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    [self addSubview:_tbTop];
    
    // 选项条
    _obFilter = [self creatFilterView:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    [self addSubview:_obFilter];
    
    _vList = [self createClaimCaseList:CGRectMake(0, _obFilter.maxY, self.width, self.height-_obFilter.maxY)];
    [_vList setDelegate:self];
    [self addSubview:_vList];
    
    if (_claimType == ClaimListTypeOnGoing) {
        [_obFilter selectItemAtIndex:0];
    }
    else{
        [_obFilter selectItemAtIndex:1];
    }
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"车源投诉记录" forState:UIControlStateNormal];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    if (_viewStyle == UCClaimRecordViewStyleNormal) {
        [vTopBar setLetfTitle:@"返回"];
    }
    else{
        [vTopBar setLetfTitle:@"关闭"];
    }
    
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}

/** 选项条 */
- (UCOptionBar *)creatFilterView:(CGRect)frame
{
    [_obFilter removeFromSuperview];
    _obFilter = nil;
    
    // 选项条
    NSArray *titles = @[@"未完结投诉", @"已完结投诉"];
    
    // 选项条
    UIView *vSlider = [[UIView alloc] initWithFrame:CGRectMake(0, kTopOptionHeight - 4, self.width / titles.count, 4)];
    vSlider.backgroundColor = kColorBlue;
    
    _obFilter = [[UCOptionBar alloc] initWithFrame:frame sliderView:vSlider];
    _obFilter.isAutoAdjustSlider = YES;
    _obFilter.isEnableBlur = NO;
    _obFilter.backgroundColor = kColorWhite;
    _obFilter.delegate = self;
    [_obFilter addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _obFilter.height - kLinePixel, _obFilter.width, kLinePixel) color:kColorNewLine]];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UCOptionBarItem *item = [[UCOptionBarItem alloc] init];
        item.titleFont = kFontLarge;
        item.titleColor = kColorNewGray1;
        item.titleColorSelected = kColorBlue;
        item.title = titles[i];
        [items addObject:item];
    }
    [_obFilter setItems:items];
    
    return _obFilter;
}

/** 列表 **/
- (ClaimCasesList *)createClaimCaseList:(CGRect)frame;{
    ClaimCasesList *list = [[ClaimCasesList alloc] initWithFrame:frame];
    
    return list;
}


#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    if (_viewStyle == UCClaimRecordViewStyleNormal) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
    else{
        if (self.shouldClearNotifyMarkAfterClose) {
            // 这里处理关掉[我的]红点儿,关掉进去的列表页的红点儿
            UCMainView *mainView = [UCMainView sharedMainView];
            [mainView setclaimCountToZero]; //是否要真的消除红点, 交给 mainview 里的这个方法去做
        }
        
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveUp];
    }
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    if (index == 0) {
        [_vList setClaimListType:ClaimListTypeOnGoing];
    } else if (index == 1) {
        [_vList setClaimListType:ClaimListTypeFinished];
    }
    [self bringSubviewToFront:_obFilter];
    [self bringSubviewToFront:_tbTop];
}

#pragma mark - ClaimCasesListDelegate
- (void)ClaimCasesList:(ClaimCasesList*)claimCasesList didSelectItem:(ClaimRecordItem*)claimItem{
    [UMStatistics event:claimCasesList.claimListType == ClaimListTypeOnGoing ? c_3_9_2_buiness_bond_complaint_unfinished_click : c_3_9_2_buiness_bond_complaint_finished_click];
    UCCarInfoModel *model = [[UCCarInfoModel alloc] init];
    model.carid = claimItem.carid;
    
    //!!!  1.个人，2.4s,3.商家，4。贩子，22.品牌车源，23.商家品牌车源
    model.sourceid = [NSNumber numberWithInt:3];
    
    UCCarDetailView *vCarDetail = [[UCCarDetailView alloc] initWithFrame:[MainViewController sharedVCMain].vMain.bounds mCarInfo:model];
    [[MainViewController sharedVCMain] openView:vCarDetail animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
    
}


@end
