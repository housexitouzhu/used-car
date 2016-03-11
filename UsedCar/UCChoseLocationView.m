//
//  UCChoseLocationView.m
//  UsedCar
//
//  Created by 张鑫 on 14-7-17.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCChoseLocationView.h"
#import "UCLocationView.h"
#import "UCTopBar.h"
#import "UCAreaMode.h"

@interface UCChoseLocationView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, weak) UCAreaMode *mArea;

@end

@implementation UCChoseLocationView

- (id)initWithFrame:(CGRect)frame areaModel:(UCAreaMode *)mArea
{
    self = [super initWithFrame:frame];
    if (self) {
        _mArea = mArea;
        [self initView];
    }
    return self;
}

- (void)initView
{
    // 导航栏
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    // 地点选择器
    UCLocationView *vLocation = [[UCLocationView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY) areaModel:_mArea];
    vLocation.delegate = self;
    
    [self addSubview:_tbTop];
    [self addSubview:vLocation];
    
    // 选中记录
    if (![_mArea isNull]) {
        [vLocation setSelectedCells:_mArea];
    }
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    // 导航头
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:UIControlEventTouchUpInside];
    [_tbTop.btnTitle setTitle:@"所在地" forState:UIControlStateNormal];
    
    return _tbTop;
}

#pragma mark - onClickButton

/** 点击导航栏按钮 */
- (void)onClickTopBar:(UIButton *)btn
{
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

#pragma mark - UCLocationViewDelegate
-(void)UCLocationView:(UCLocationView *)vLocation isChanged:(BOOL)isChanged areaModel:(UCAreaMode *)mArea
{
    [vLocation stopLocation];
    if ([_delegate respondsToSelector:@selector(UCChoseLocationView:isChanged:areaModel:)]) {
        [_delegate UCChoseLocationView:self isChanged:isChanged areaModel:mArea];
    }
}

@end
