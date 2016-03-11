//
//  UCUserReputation.m
//  UsedCar
//
//  Created by 张鑫 on 14-6-9.
//  Copyright (c) 2014年 Alan. All rights reserved.
//

#import "UCUserReputation.h"
#import "UCReputationDetailView.h"
#import "APIHelper.h"

@interface UCUserReputation ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) UIActivityIndicatorView *aiActivity;
@property (nonatomic, strong) UIButton *btnReload;
@property (nonatomic, strong) NSString *strUrl;

@end

@implementation UCUserReputation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void) initView
{
    self.backgroundColor = kColorWhite;
    
    //自定义webView
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _webView.scrollView.backgroundColor = kColorWhite;
    _webView.delegate = self;
    
    // 菊花
    _aiActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _aiActivity.center = CGPointMake(self.width/2, self.height/2);
    _aiActivity.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    [_aiActivity startAnimating];
    [_webView addSubview:_aiActivity];
    [self addSubview:_webView];
}

#pragma mark - Public Method
/** 加载Url */
- (void)loadWebWithString:(NSString*)urlString
{
    _strUrl = urlString;
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [_webView reload];
}

/** 刷新页面 */
- (void)setReloadBtnHidden:(BOOL)isShow message:(NSString *)message enable:(BOOL)enable
{
    if (!_btnReload) {
        _btnReload = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 100)];
        _btnReload.backgroundColor = [UIColor clearColor];
        _btnReload.titleLabel.numberOfLines = 2;
        _btnReload.titleLabel.font = kFontLarge;
        _btnReload.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnReload setTitleColor:kColorGrey2 forState:UIControlStateNormal];
        [_btnReload addTarget:self action:@selector(onClickReloadViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!isShow) {
        [self addSubview:_btnReload];
    } else {
        [_btnReload removeFromSuperview];
        _btnReload = nil;
    }
    
    [_btnReload setTitle:message forState:UIControlStateNormal];
    _btnReload.enabled = enable;
}

/** 刷新页面 */
- (void)onClickReloadViewBtn:(UIButton *)btn
{
    // 隐藏刷新按钮
    [self setReloadBtnHidden:YES message:@"网络连接失败\n点击屏幕重新尝试" enable:YES];
    // 重新获取数据
    [_apiHelper cancel];
    [self loadWebWithString:_strUrl];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _aiActivity.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _aiActivity.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _aiActivity.hidden = YES;
    [self setReloadBtnHidden:NO message:@"网络连接失败\n点击屏幕重新尝试" enable:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url])
        {
            [UMStatistics event:pv_3_7_buycar_buinesssourcedetail_experienceend];

            UCReputationDetailView *reputation = [[UCReputationDetailView alloc] initWithFrame:self.bounds];
            [reputation loadWebWithString:url];
            [[MainViewController sharedVCMain] openView:reputation animateOption:AnimateOptionMoveLeft removeOption:RemoveOptionNone];
        }
        return NO;
    }
    return YES;
}

@end
