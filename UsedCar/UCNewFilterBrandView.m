//
//  UCNewFilterBrandView.m
//  UsedCar
//
//  Created by 张鑫 on 14-7-12.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCNewFilterBrandView.h"
#import "UCTopBar.h"
#import "UCExpandBrandView.h"
#import "UCFilterModel.h"

@interface UCNewFilterBrandView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, weak) UCFilterModel *mFilter;

@end

@implementation UCNewFilterBrandView

- (id)initWithFrame:(CGRect)frame mFilter:(UCFilterModel *)mFilter;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorNewBackground;
        _mFilter = mFilter;
        
        [self initView];
    }
    return self;
}

#pragma mark - initView
- (void)initView
{
    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 车型选择
    UCExpandBrandView *vExpandBrand = [self creatFilterBrandView:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY)];
    
    [self addSubview:_tbTop];
    [self addSubview:vExpandBrand];
    
    // 选中默认项
    if (_mFilter.brandid.integerValue > 0) {
        [vExpandBrand setSelectedBrandCellshouldSelectAllBrandCell:NO];
    }
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tbTop.btnTitle setTitle:@"品牌选择" forState:UIControlStateNormal];
    
    return _tbTop;
}

/** 车型选择 */
- (UCExpandBrandView *)creatFilterBrandView:(CGRect)frame
{
    UCExpandBrandView *vExpandBrand = [[UCExpandBrandView alloc] initWithFrame:frame filter:_mFilter ExpandFilterBrandViewStyle:ExpandFilterBrandViewStyleBrand];
    vExpandBrand.delegate = self;
    
    return vExpandBrand;
}

#pragma mark - onClickButton
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption: AnimateOptionMoveLeft];
    }
}

#pragma mark - UCExpandBrandViewDelegate
/** 获得车型model */
-(void)UCExpandBrandView:(UCExpandBrandView *)vFilterBarnd isChanged:(BOOL)isChanged filterModel:(UCFilterModel *)mFilter
{
    if ([_delegate respondsToSelector:@selector(UCNewFilterBrandView:isChanged:filterModel:)]) {
        [_delegate UCNewFilterBrandView:self isChanged:isChanged filterModel:mFilter];
    }
}

@end
