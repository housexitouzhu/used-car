//
//  UCSaleHelpDetailView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSaleHelpDetailView.h"

#import "UCTopBar.h"
#import "UCWebView.h"
#import "APIHelper.h"
#import "NSString+Util.h"

@interface UCSaleHelpDetailView()

@property (nonatomic, strong) UCTopBar         *tbTop;
@property (nonatomic, strong) UCWebView *vWebView;

@end

@implementation UCSaleHelpDetailView

- (id)initWithFrame:(CGRect)frame withWebURL:(NSString *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView:url];
    }
    return self;
}

- (void)initView:(NSString *)url
{
    self.backgroundColor = kColorNewBackground;
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // webview
    _vWebView = [[UCWebView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY) withWebURL:url];
    _vWebView.delegate = self;
    
    [self addSubview:_tbTop];
    [self addSubview:_vWebView];
}

#pragma mark - initView

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    [_tbTop setLetfTitle:@"返回"];
    [_tbTop.btnLeft addTarget:self action:@selector(onClickTopBarBtn:) forControlEvents:UIControlEventTouchUpInside];
    return _tbTop;
}

#pragma mark - onClickButton
/** TopBar */
- (void)onClickTopBarBtn:(UIButton *)btn
{
    if (![OMG isValidClick])
        return;
    
    if (btn.tag == UCTopBarButtonLeft) {
        [[MainViewController sharedVCMain] closeView:self animateOption:AnimateOptionMoveLeft];
    }
}

#pragma mark - UCWebViewDelegate
-(void)UCWebViewDidFinishLoad:(UIWebView *)webView
{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [_tbTop.btnTitle setTitle:[theTitle dNull:@"售车帮助"] forState:UIControlStateNormal];
    
    [UMStatistics event:pv_4_1_Business_Manage_Help_Detail];
    [UMSAgent postEvent:business_center_help_detail_pv page_name:NSStringFromClass(self.class)];

}

@end

