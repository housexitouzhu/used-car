//
//  UCSaleHelpView.m
//  UsedCar
//
//  Created by 张鑫 on 14/11/4.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCSaleHelpView.h"
#import "UCTopBar.h"
#import "UCWebView.h"
#import "APIHelper.h"
#import "NSString+Util.h"
#import "UCSaleHelpDetailView.h"

@interface UCSaleHelpView()

@property (nonatomic, strong) UCTopBar         *tbTop;
@property (nonatomic, strong) UCWebView *vWebView;

@end

@implementation UCSaleHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backgroundColor = kColorNewBackground;
    // 导航头
    _tbTop = [self creatTopBarView:CGRectMake(0, 0, self.width, 64)];
    // webview
    _vWebView = [[UCWebView alloc] initWithFrame:CGRectMake(0, _tbTop.maxY, self.width, self.height - _tbTop.maxY) withWebURL:[APIHelper getSaleHelp]];
    _vWebView.delegate = self;

    [self addSubview:_tbTop];
    [self addSubview:_vWebView];
}

#pragma mark - initView

/** 导航栏 */
- (UCTopBar *)creatTopBarView:(CGRect)frame
{
    _tbTop = [[UCTopBar alloc] initWithFrame:frame];
    
    [_tbTop.btnTitle setTitle:@"售车帮助" forState:UIControlStateNormal];
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
-(BOOL)UCWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if([urlComps count] > 1) {
        NSString *strURl = [urlComps objectAtIndex:1];
        if ([strURl isContainsString:@"m.app.che168.com/help/dealer/helpDetail_"]) {
            [UMStatistics event:c_4_1_Business_Manage_Help_List];
            [[MainViewController sharedVCMain] openView:[[UCSaleHelpDetailView alloc] initWithFrame:self.bounds withWebURL:urlString] animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];

            return NO;
        }
    };
    return YES;
}

-(void)UCWebViewDidFinishLoad:(UIWebView *)webView
{
    [UMStatistics event:pv_4_1_Business_Manage_Help_List];
    [UMSAgent postEvent:business_center_help_pv page_name:NSStringFromClass(self.class)];
}

@end
