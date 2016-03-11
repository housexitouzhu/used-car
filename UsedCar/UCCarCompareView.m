//
//  UCCarCompareView.m
//  UsedCar
//
//  Created by wangfaquan on 14-1-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCCarCompareView.h"
#import "UCCarCompareList.h"
#import "UCTopBar.h"
#import "AMCacheManage.h"

@interface UCCarCompareView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (nonatomic, strong) UCCarCompareList *vCarCompare;

@end

@implementation UCCarCompareView

static UCCarCompareView *carCompare = nil;
+ (UCCarCompareView *)shareCompare
{
    @synchronized(self) {
        if (carCompare == nil) {
            carCompare = [[UCCarCompareView alloc] init];
        }
    }
    return carCompare;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        carCompare = self;
    }
    return self;
}

#pragma mark - public Method
/** 创建列表 & 刷新数据 */
- (void)reloadData
{
    // 导航栏
    if (!_tbTop) {
        _tbTop = [[UCTopBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 64)];
        [_tbTop.btnRight setTitle:@"清空" forState:UIControlStateNormal];
        [_tbTop.btnRight addTarget:self action:@selector(onClickTopBar:) forControlEvents:
         UIControlEventTouchUpInside];
        [_tbTop.btnTitle setTitle:@"车辆对比" forState:UIControlStateNormal];
        [_tbTop setLetfTitle:@"返回"];
        [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBar:) forControlEvents:
         UIControlEventTouchUpInside];
        [self addSubview:_tbTop];
    }
    // 获取对比列表
    if (!_vCarCompare) {
        _vCarCompare = [[UCCarCompareList alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY) compareItems:_compareItems];
        _vCarCompare.tbTop = _tbTop;
        [self addSubview:_vCarCompare];
    }
    _vCarCompare.compareItems = _compareItems;
    [_vCarCompare reloadData];
}

#pragma mark - onClickBtn
/** 导航栏点击事件 */
- (void)onClickTopBar:(UIButton *)btn
{
    // 点击后返回
    if (btn.tag == UCTopBarButtonLeft) {
        if ([_delegate respondsToSelector:@selector(closeCompareView:)]) {
            // 统计对比列表时长
            [UMSAgent endTracPage:NSStringFromClass(self.class)];
            [UMStatistics endPageView:self];
            [_delegate closeCompareView:_compareItems];
        }
    }
    // 点击清除按钮
    else if (btn.tag == UCTopBarButtonRight) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否确认清除所有车辆" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 弹出框删除和取消
    if (buttonIndex == 1) {
        [_compareItems removeAllObjects];
        [AMCacheManage setCurrentCompareInfo:nil];
        [self reloadData];
    }
}
@end
