//
//  UCClaimHelpView.m
//  UsedCar
//
//  Created by Sun Honglin on 14-8-27.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCClaimHelpView.h"
#import "UCTopBar.h"
#import "UCWebView.h"
#import "APIHelper.h"

@interface UCClaimHelpView ()

@property (nonatomic, strong) UCTopBar *tbTop;
@property (retain, nonatomic) UCWebView *vWeb;

@end


@implementation UCClaimHelpView

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
    
    self.backgroundColor =  kColorNewBackground;
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    
    [self addSubview:_tbTop];
    
    _vWeb = [[UCWebView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY) withWebURL:[APIHelper getToolClaimHelpWebURL]];
    [_vWeb setBackgroundColor:kColorNewBackground];
    [_vWeb.webView setBackgroundColor:kColorNewBackground];
//    [_vWeb.webView.scrollView setBounces:NO];
    [self addSubview:_vWeb];
    
}

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    UCTopBar *vTopBar = [[UCTopBar alloc] initWithFrame:frame];
    // 标题
    [vTopBar.btnTitle setTitle:@"帮助" forState:UIControlStateNormal];
    [vTopBar setLetfTitle:@"返回"];
    [vTopBar.btnLeft setTitleColor:kColorWhite forState:UIControlStateSelected];
    [vTopBar.btnLeft addTarget:self action:@selector(onClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return vTopBar;
}


#pragma mark - onClickButton
/** 点击返回 */
- (void)onClickBackBtn:(UIButton *)btn
{
    // 网页go back逻辑
    if (_vWeb.webView.canGoBack){
        [_vWeb.webView goBack];
    }
    else{
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
    
}

@end
