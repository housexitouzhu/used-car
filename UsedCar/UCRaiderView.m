//
//  UCRaiderView.m
//  UsedCar
//
//  Created by wangfaquan on 13-12-18.
//  Copyright (c) 2013年 Alan. All rights reserved.
//

#import "UCRaiderView.h"
#import "UCTopBar.h"
#import "UCOptionBar.h"
#import "UCRaiderList.h"

@interface UCRaiderView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCOptionBar *obFilter;
@property (nonatomic, strong) UCRaiderList *rlMustLook;
@property (nonatomic, strong) UCRaiderList *rlCommonSense;

@end

@implementation UCRaiderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isRecord = YES;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    
    //导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 买车必看
    _rlMustLook = [self creatMustLookView:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    
    // 购车常识
    _rlCommonSense = [self creatCommonSenseView:_rlMustLook.frame];
    
    // 选项条
    _obFilter = [self creatFilterView:CGRectMake(0, _tbTop.maxY, self.width, kTopOptionHeight)];
    
    [self addSubview:_rlCommonSense];
    [self addSubview:_rlMustLook];
    [self addSubview:_obFilter];
    [self addSubview:_tbTop];
    
    // 刷新数据
    [_rlMustLook refreshData];
    [_rlCommonSense refreshData];
    // 选中买家必看
    [_obFilter selectItemAtIndex:0];
}

/** 买车必看 */
- (UCRaiderList *)creatMustLookView:(CGRect)frame
{
    _rlMustLook = [[UCRaiderList alloc] initWithFrame:frame];
    _rlMustLook.vRaider = self;
    _rlMustLook.isLocal = YES;
    
    return _rlMustLook;
}

/** 购车常识 */
- (UCRaiderList *)creatCommonSenseView:(CGRect)frame
{
    _rlCommonSense = [[UCRaiderList alloc] initWithFrame:frame];
    _rlCommonSense.vRaider = self;
    _rlCommonSense.isLocal = NO;
    
    return _rlCommonSense;
}

/** 选项条 */
- (UCOptionBar *)creatFilterView:(CGRect)frame
{
    [_obFilter removeFromSuperview];
    _obFilter = nil;
    
    // 选项条
    NSArray *titles = @[@"买车必看", @"购车常识"];
    
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

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"攻略" forState:UIControlStateNormal];
    return vTopBar;
}

/** 记录买车必看的统计事件 */
- (void)recordMustSeeEvent
{
    if (_obFilter.selectedItemIndex == 0) {
        [UMStatistics event:pv_3_1_buycarmustseelist];
        [UMSAgent postEvent:mustseelist_pv page_name:NSStringFromClass(self.class)];
        _isRecord = NO;
    }
}

#pragma mark - UCOptionBarDelegate
- (void)optionBar:(UCOptionBar *)optionBar didSelectAtIndex:(NSInteger)index
{
    if (index == 0) {
        // 显示买车必看
        [self bringSubviewToFront:_rlMustLook];
        if (_isRecord) {
            _isRecord = NO;
            [self recordMustSeeEvent];
        }
    } else if (index == 1) {
        // 显示购车常识
        [self bringSubviewToFront:_rlCommonSense];
    }
    [self bringSubviewToFront:_obFilter];
    [self bringSubviewToFront:_tbTop];
}

@end
