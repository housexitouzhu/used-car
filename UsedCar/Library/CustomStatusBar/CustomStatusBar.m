//
//  CustomStatusBar.m
//  CustomStatusBar
//
//  Created by Jason Lee on 12-3-12.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import "CustomStatusBar.h"
#import "AppDelegate.h"

#define kAnimationTime 0.35f

@interface CustomStatusBar()

@property (nonatomic) NSInteger showCount;

@end

@implementation CustomStatusBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showCount = 0;
        _animationTime = NSNotFound;
        
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        //		self.frame = [UIApplication sharedApplication].statusBarFrame;
        // 按钮
        _btnStatusMsg = [[UIButton alloc] initWithFrame:self.bounds];
        [_btnStatusMsg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnStatusMsg.titleLabel.font = [UIFont systemFontOfSize:11.0f];
        [_btnStatusMsg addTarget:self action:@selector(onClickStatueButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnStatusMsg];
        
    }
    return self;
}

/** 对齐方式 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _btnStatusMsg.titleLabel.textAlignment = textAlignment;
}

/** 点击状态栏 */
- (void)onClickStatueButton:(UIButton *)btn
{
    if (![OMG isValidClick:_animationTime] && _animationTime != NSNotFound)
        return;
    _block();
}

- (void)setShowMessageDatas:(NSArray *)arrMessageInfo
{
    if (![AppDelegate sharedAppDelegate].showSTHonSaleVersion)
        return;
    
    if (arrMessageInfo.count < 2)
        return;
    
    [self showStatusMessage:[arrMessageInfo objectAtIndex:0] onClickStatueBar:[arrMessageInfo objectAtIndex:1]];
}

/** 显示提示语 */
- (void)showStatusMessage:(NSString *)message onClickStatueBar:(StatueBarBlock)block
{
    
    if (![AppDelegate sharedAppDelegate].showSTHonSaleVersion)
        return;
    
    if (_showCount > 0) {
        [self performSelector:@selector(setShowMessageDatas:) withObject:[NSArray arrayWithObjects:message, [block copy], nil] afterDelay:_showCount * _animationTime * 2];
        return;
    }
    _block = block;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    // 设置标题
    [_btnStatusMsg setTitle:message forState:UIControlStateNormal];
    
    self.hidden = NO;
    
    _btnStatusMsg.minY = self.height;
    [UIView animateWithDuration:kAnimationTime animations:^{
        _btnStatusMsg.minY = 0;
    } completion:^(BOOL finished){
        if (_animationTime != NSNotFound) {
            [self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:_animationTime];
        }
    }];
    _showCount++;
}

/** 隐藏提示语 */
- (void)hideStatusMessage
{
    if (![AppDelegate sharedAppDelegate].showSTHonSaleVersion)
        return;

    // 显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        _btnStatusMsg.minY = self.height;
    } completion:^(BOOL finished){
        _showCount--;
        [_btnStatusMsg setTitle:@"" forState:UIControlStateNormal];
        self.hidden = YES;
    }];
}


- (void)dealloc
{
    _btnStatusMsg = nil;
}

@end
